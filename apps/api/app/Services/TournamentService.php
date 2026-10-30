<?php

namespace App\Services;

use App\Jobs\PushTournamentUpdate;
use App\Models\GameMatch;
use App\Models\Item;
use App\Models\Tournament;
use App\Models\TournamentEntry;
use App\Models\TournamentPairing;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Tournaments (spec §8.3, docs/api/tournaments.md): registration with coin
 * entry fees through the ledger, sit-and-go tables, private tournaments,
 * rounds and pairings (PairingEngine), results from the game server,
 * walkovers, places and prizes. Matches are unrated (QUESTIONS #33).
 */
class TournamentService
{
    private const CODE_ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

    public function __construct(
        private WalletService $wallet,
        private GameServerClient $gameServer,
        private StoreService $store,
        private Notifier $notifier,
    ) {}

    // ---- registration ------------------------------------------------------

    /**
     * Registers [user]; a coin entry is debited, keyed by [key] (a retried
     * key returns the same entry). A full sit-and-go starts at once.
     */
    public function register(Tournament $tournament, User $user, ?string $key, ?string $code = null): TournamentEntry
    {
        $entry = DB::transaction(function () use ($tournament, $user, $key, $code): TournamentEntry {
            $t = $this->lock($tournament->id);
            $existing = TournamentEntry::query()->where(['tournament_id' => $t->id, 'user_id' => $user->id])->first();
            if ($existing !== null) {
                if ($key !== null && $existing->entry_key === $key) {
                    return $existing;
                }
                throw new TournamentException('already_registered');
            }
            if ($t->status !== 'registering') {
                throw new TournamentException('closed');
            }
            if ($t->is_private && $t->created_by !== $user->id && ($code === null || $code !== $t->invite_code)) {
                throw new TournamentException('invite_required');
            }
            $rating = $user->ratingFor($t->variant)->rating;
            if ($t->min_rating !== null && $rating < $t->min_rating) {
                throw new TournamentException('rating_too_low');
            }
            if ($t->entries()->count() >= $t->size) {
                throw new TournamentException('full');
            }
            if ($t->entry_coins > 0) {
                if ($key === null) {
                    throw new TournamentException('idempotency_key_required');
                }
                $walletKey = "tournament_entry:{$t->id}:{$user->id}:$key";
                // The key paid an entry that was refunded since: never reuse it.
                if (DB::table('wallet_transactions')->where('idempotency_key', $walletKey)->exists()) {
                    throw new TournamentException('idempotency_key_reused');
                }
                try {
                    $this->wallet->debit($user, 'coins', $t->entry_coins, 'tournament_entry', $walletKey, "tournament:{$t->id}");
                } catch (InsufficientFunds) {
                    throw new TournamentException('insufficient_coins');
                }
            }

            $entry = TournamentEntry::query()->create([
                'tournament_id' => $t->id,
                'user_id' => $user->id,
                'rating' => $rating,
                'entry_coins' => $t->entry_coins,
                'entry_key' => $key,
            ]);
            $this->changed($t);

            return $entry;
        });
        $tournament->refresh();
        if ($tournament->kind === 'sit_and_go' && $tournament->status === 'registering'
            && $tournament->entries()->count() >= $tournament->size) {
            $this->start($tournament);
        }

        return $entry;
    }

    /** Leaves before the start; the entry fee is refunded. */
    public function unregister(Tournament $tournament, User $user): void
    {
        DB::transaction(function () use ($tournament, $user): void {
            $t = $this->lock($tournament->id);
            if ($t->status !== 'registering') {
                throw new TournamentException('closed');
            }
            $entry = TournamentEntry::query()->where(['tournament_id' => $t->id, 'user_id' => $user->id])->first()
                ?? throw new TournamentException('not_registered');
            $this->refund($t, $entry);
            $entry->delete();
            $this->changed($t);
        });
    }

    /** Joins the open sit-and-go table of [size] (opening one if needed). */
    public function joinSitAndGo(User $user, int $size, ?string $key): Tournament
    {
        // Already seated at an open table of this size: nothing to do.
        $mine = Tournament::query()->where(['kind' => 'sit_and_go', 'status' => 'registering', 'size' => $size])
            ->whereHas('entries', fn ($q) => $q->where('user_id', $user->id))->first();
        if ($mine !== null) {
            return $mine;
        }
        $table = DB::transaction(fn (): Tournament => Tournament::query()
            ->where(['kind' => 'sit_and_go', 'status' => 'registering', 'size' => $size])
            ->orderBy('id')->lockForUpdate()->first() ?? $this->openSitAndGo($size));
        $this->register($table, $user, $key);

        return $table->refresh();
    }

    public function openSitAndGo(int $size): Tournament
    {
        $fee = (int) config('tournaments.sng.entry_coins');
        $fund = intdiv($size * $fee * (100 - (int) config('tournaments.sng.rake_percent')), 100);
        /** @var array<int, array{0: int, 1: int, 2: int|float}> $split */
        $split = config("tournaments.sng.split.$size");

        return Tournament::query()->create([
            'name' => config('tournaments.sng.name'),
            'format' => 'knockout',
            'kind' => 'sit_and_go',
            'variant' => config('tournaments.sng.variant'),
            'match_length' => config('tournaments.sng.match_length'),
            'size' => $size,
            'min_players' => $size,
            'entry_coins' => $fee,
            'prizes' => PairingEngine::splitFund($fund, $split),
            'prize_fund' => $fund,
            'status' => 'registering',
            'expires_at' => now()->addMinutes((int) config('tournaments.sng.fill_minutes')),
        ]);
    }

    // ---- private tournaments (22.x) ------------------------------------------

    /**
     * Creates a free, unrated knockout with an invite code; the organiser is
     * registered.
     *
     * @param  array{name: string, size: int, variant: string, matchLength: int, startsAt: ?Carbon}  $data
     */
    public function createPrivate(User $user, array $data): Tournament
    {
        $tournament = DB::transaction(function () use ($user, $data): Tournament {
            $open = Tournament::query()->where(['kind' => 'private', 'status' => 'registering', 'created_by' => $user->id])
                ->lockForUpdate()->count();
            if ($open >= (int) config('tournaments.private.max_open')) {
                throw new TournamentException('too_many_open');
            }

            return Tournament::query()->create([
                'name' => ['default' => $data['name']],
                'format' => 'knockout',
                'kind' => 'private',
                'variant' => $data['variant'],
                'match_length' => $data['matchLength'],
                'size' => $data['size'],
                'min_players' => (int) config('tournaments.private.min_players'),
                'entry_coins' => 0,
                'prizes' => [],
                'prize_fund' => 0,
                'status' => 'registering',
                'starts_at' => $data['startsAt'],
                'expires_at' => $data['startsAt'] === null ? now()->addHours((int) config('tournaments.private.expire_hours')) : null,
                'is_private' => true,
                'invite_code' => $this->newCode(),
                'created_by' => $user->id,
            ]);
        });
        $this->register($tournament, $user, null);

        return $tournament->refresh();
    }

    /** Accepts "K7Q29M", "k7q-29m" or "K7Q 29M". */
    public static function normalizeCode(string $code): string
    {
        return strtoupper((string) preg_replace('/[\s\-]/', '', $code));
    }

    public function byCode(string $code): Tournament
    {
        return Tournament::query()->where('invite_code', self::normalizeCode($code))->first()
            ?? throw new TournamentException('not_found', 404);
    }

    public function startByOrganizer(Tournament $tournament, User $user): void
    {
        $this->requireOrganizer($tournament, $user);
        if ($tournament->status !== 'registering') {
            throw new TournamentException('closed');
        }
        if ($tournament->entries()->count() < $tournament->min_players) {
            throw new TournamentException('not_enough_players');
        }
        $this->start($tournament);
    }

    public function cancelByOrganizer(Tournament $tournament, User $user): void
    {
        $this->requireOrganizer($tournament, $user);
        if ($tournament->status !== 'registering') {
            throw new TournamentException('closed');
        }
        $this->cancel($tournament, 'organizer');
    }

    /** The organiser removes an entrant before the start. */
    public function kick(Tournament $tournament, User $organizer, int $userId): void
    {
        $this->requireOrganizer($tournament, $organizer);
        if ($userId === $organizer->id) {
            throw new TournamentException('self');
        }
        DB::transaction(function () use ($tournament, $userId): void {
            $t = $this->lock($tournament->id);
            if ($t->status !== 'registering') {
                throw new TournamentException('closed');
            }
            $entry = TournamentEntry::query()->where(['tournament_id' => $t->id, 'user_id' => $userId])->first()
                ?? throw new TournamentException('not_registered');
            $this->refund($t, $entry);
            $entry->delete();
            $this->changed($t);
        });
    }

    private function requireOrganizer(Tournament $t, User $user): void
    {
        if ($t->kind !== 'private' || $t->created_by !== $user->id) {
            throw new TournamentException('forbidden', 403);
        }
    }

    private function newCode(): string
    {
        do {
            $code = '';
            for ($i = 0; $i < 6; $i++) {
                $code .= self::CODE_ALPHABET[random_int(0, strlen(self::CODE_ALPHABET) - 1)];
            }
        } while (Tournament::query()->where('invite_code', $code)->exists());

        return $code;
    }

    // ---- lifecycle -----------------------------------------------------------

    /**
     * Seeds the entrants by rating and creates round 1; with too few
     * entrants the tournament is cancelled and refunded. False if it did
     * not start.
     */
    public function start(Tournament $tournament): bool
    {
        $started = DB::transaction(function () use ($tournament): bool {
            $t = $this->lock($tournament->id);
            if ($t->status !== 'registering') {
                return false;
            }
            /** @var Collection<int, TournamentEntry> $entries */
            $entries = $t->entries()->with('user')->get();
            if ($entries->count() < max(2, $t->min_players)) {
                $this->cancelLocked($t, 'not_enough_players');

                return false;
            }
            foreach ($entries as $entry) {
                $entry->rating = $entry->user->ratingFor($t->variant)->rating;
            }
            $seeded = $entries->sort(fn (TournamentEntry $a, TournamentEntry $b) => [$b->rating, $a->id] <=> [$a->rating, $b->id])->values();
            foreach ($seeded as $i => $entry) {
                $entry->seed = $i + 1;
                $entry->save();
            }
            $n = $entries->count();
            $t->total_rounds = match ($t->format) {
                'knockout' => PairingEngine::knockoutRounds($n),
                'swiss' => min($t->swiss_rounds ?? PairingEngine::knockoutRounds($n), $n % 2 === 1 ? $n : $n - 1),
                default => $n % 2 === 1 ? $n : $n - 1,
            };
            $t->status = 'running';
            $t->started_at = now();
            $t->expires_at = null;
            $t->save();
            $this->notifier->notifyMany($entries->pluck('user_id')->map(fn ($id) => (int) $id), 'tournament_started',
                $this->about($t), "tournament_started:{$t->id}");
            $this->createRound($t, 1);
            $this->changed($t);

            return true;
        });
        if ($started) {
            $this->pushAfterCommit();
        }

        return $started;
    }

    public function cancel(Tournament $tournament, string $reason): void
    {
        DB::transaction(function () use ($tournament, $reason): void {
            $t = $this->lock($tournament->id);
            if ($t->status === 'registering') {
                $this->cancelLocked($t, $reason);
            }
        });
    }

    /**
     * Cancels and refunds every entry fee (the 'refund' credit path); every
     * entrant but the organiser who cancelled is notified with the refund.
     */
    private function cancelLocked(Tournament $t, string $reason): void
    {
        $t->status = 'cancelled';
        $t->cancel_reason = $reason;
        $t->expires_at = null;
        $t->save();
        $byRefund = [];
        foreach ($t->entries()->get() as $entry) {
            $this->refund($t, $entry);
            if ($reason === 'organizer' && $entry->user_id === $t->created_by) {
                continue;
            }
            $byRefund[$entry->refunded ? $entry->entry_coins : 0][] = $entry->user_id;
        }
        foreach ($byRefund as $refund => $userIds) {
            $this->notifier->notifyMany($userIds, 'tournament_cancelled',
                [...$this->about($t), 'reason' => $reason, 'refund' => $refund], "tournament_cancelled:{$t->id}");
        }
        $this->changed($t);
    }

    /**
     * Live refresh (ADR-049): after the commit the game server tells the
     * connected entrants to refetch [t]; screens still poll as a fallback.
     */
    private function changed(Tournament $t): void
    {
        if (GameServerClient::configured()) {
            PushTournamentUpdate::dispatch($t->id)->afterCommit();
        }
    }

    private function refund(Tournament $t, TournamentEntry $entry): void
    {
        if ($entry->entry_coins <= 0 || $entry->refunded) {
            return;
        }
        $this->wallet->credit($entry->user()->firstOrFail(), 'coins', $entry->entry_coins, 'refund',
            "tournament_refund:{$entry->id}", "tournament:{$t->id}");
        $entry->refunded = true;
        $entry->save();
    }

    /** Pairs round [n] (byes are decided at once) and advances if nothing is left to play. */
    private function createRound(Tournament $t, int $n): void
    {
        $pairs = match ($t->format) {
            'knockout' => $n === 1
                ? PairingEngine::knockoutFirstRound($this->seeded($t))
                : PairingEngine::knockoutNext($this->winners($t, $n - 1)),
            'swiss' => $this->swissPairs($t),
            default => PairingEngine::roundRobin($this->seeded($t))[$n - 1] ?? [],
        };
        DB::table('tournament_rounds')->insert([
            'tournament_id' => $t->id, 'number' => $n, 'status' => 'running',
            'started_at' => now(), 'created_at' => now(), 'updated_at' => now(),
        ]);
        $t->current_round = $n;
        $t->save();
        foreach ($pairs as $slot => [$white, $black]) {
            if ($white === null) {
                [$white, $black] = [$black, $white];
            }
            $pairing = TournamentPairing::query()->create([
                'tournament_id' => $t->id,
                'round' => $n,
                'slot' => $slot,
                'match_id' => "t{$t->id}-$n-$slot",
                'white_user_id' => $white,
                'black_user_id' => $black,
                'status' => 'pending',
            ]);
            if ($black !== null) {
                continue;
            }
            // A bye (or an empty knockout slot): decided without a match.
            $pairing->fill([
                'status' => 'finished',
                'bye' => true,
                'result' => $white === null ? 'none' : 'white',
                'winner_user_id' => $white,
                'finished_at' => now(),
            ])->save();
            if ($white !== null) {
                $entry = $this->entry($t, $white);
                $entry->had_bye = true;
                // Swiss: a bye scores a win (standard); round-robin: sits out.
                if ($t->format === 'swiss') {
                    $entry->points += 1;
                }
                $entry->save();
            }
        }
        if ($n > 1) {
            $this->notifyRound($t, $n);
        }
        $this->advance($t);
    }

    /** @return array<string, mixed> the tournament part of notification data */
    private function about(Tournament $t): array
    {
        return ['tournamentId' => (string) $t->id, 'tournament' => $t->name];
    }

    /** "Raund hazırdır" for both players of each real pairing of round [n]. */
    private function notifyRound(Tournament $t, int $n): void
    {
        $pairings = $t->pairings()->where('round', $n)->where('bye', false)
            ->whereNotNull('white_user_id')->whereNotNull('black_user_id')->get();
        $names = User::query()->whereIn('id', $pairings->flatMap(fn (TournamentPairing $p) => [$p->white_user_id, $p->black_user_id]))
            ->pluck('name', 'id');
        foreach ($pairings as $p) {
            foreach ([[$p->white_user_id, $p->black_user_id], [$p->black_user_id, $p->white_user_id]] as [$me, $them]) {
                $this->notifier->notify((int) $me, 'tournament_round', [
                    ...$this->about($t), 'round' => $n, 'matchId' => $p->match_id, 'opponent' => (string) ($names[$them] ?? ''),
                ], "tournament_round:{$t->id}:$n");
            }
        }
    }

    /** @return list<int> user ids by seed */
    private function seeded(Tournament $t): array
    {
        /** @var list<int> */
        return $t->entries()->orderBy('seed')->pluck('user_id')->map(fn ($id) => (int) $id)->values()->all();
    }

    /** @return list<int|null> winners of [round] in slot order */
    private function winners(Tournament $t, int $round): array
    {
        /** @var list<int|null> */
        return $t->pairings()->where('round', $round)->orderBy('slot')->pluck('winner_user_id')
            ->map(fn ($id) => $id === null ? null : (int) $id)->values()->all();
    }

    /** @return list<array{0: int, 1: int|null}> */
    private function swissPairs(Tournament $t): array
    {
        $entries = $t->entries()->get();
        $points = $entries->mapWithKeys(fn (TournamentEntry $e) => [$e->user_id => $e->points])->all();
        $ratings = $entries->mapWithKeys(fn (TournamentEntry $e) => [$e->user_id => $e->rating])->all();
        $hadBye = array_values($entries->filter(fn (TournamentEntry $e) => $e->had_bye)->map(fn (TournamentEntry $e) => $e->user_id)->all());

        return PairingEngine::swiss($points, $ratings, $this->opponents($t), $hadBye);
    }

    /** @return array<int, list<int>> user id => opponents met in decided pairings */
    private function opponents(Tournament $t): array
    {
        $opponents = [];
        $played = $t->pairings()->where('status', 'finished')
            ->whereNotNull('white_user_id')->whereNotNull('black_user_id')->get();
        foreach ($played as $p) {
            $opponents[(int) $p->white_user_id][] = (int) $p->black_user_id;
            $opponents[(int) $p->black_user_id][] = (int) $p->white_user_id;
        }

        return $opponents;
    }

    private function entry(Tournament $t, int $userId): TournamentEntry
    {
        return TournamentEntry::query()->where(['tournament_id' => $t->id, 'user_id' => $userId])->firstOrFail();
    }

    /** When the current round is complete: the next round, or the end. */
    private function advance(Tournament $t): void
    {
        $open = $t->pairings()->where('round', $t->current_round)->where('status', '!=', 'finished')->exists();
        if ($open) {
            return;
        }
        DB::table('tournament_rounds')->where(['tournament_id' => $t->id, 'number' => $t->current_round])
            ->update(['status' => 'finished', 'finished_at' => now(), 'updated_at' => now()]);
        if ($t->current_round >= (int) $t->total_rounds) {
            $this->finish($t);

            return;
        }
        $this->createRound($t, $t->current_round + 1);
    }

    /** Places, then prizes (coins via the ledger, items once each). */
    private function finish(Tournament $t): void
    {
        $entries = $t->entries()->get();
        if ($t->format === 'knockout') {
            $total = (int) $t->total_rounds;
            $champion = $t->pairings()->where('round', $total)->value('winner_user_id');
            $champion = $champion === null ? null : (int) $champion;
            foreach ($entries as $entry) {
                $entry->place = $entry->user_id === $champion
                    ? 1
                    : PairingEngine::knockoutPlace($total, $entry->eliminated_round ?? $total);
            }
        } else {
            $points = $entries->mapWithKeys(fn (TournamentEntry $e) => [$e->user_id => $e->points])->all();
            $ratings = $entries->mapWithKeys(fn (TournamentEntry $e) => [$e->user_id => $e->rating])->all();
            $buchholz = PairingEngine::buchholz($points, $this->opponents($t));
            $order = array_flip(PairingEngine::rank($points, $buchholz, $ratings));
            foreach ($entries as $entry) {
                $entry->buchholz = $buchholz[$entry->user_id];
                $entry->place = $order[$entry->user_id] + 1;
            }
        }
        foreach ($entries as $entry) {
            $entry->save();
        }
        $t->status = 'finished';
        $t->finished_at = now();
        $t->save();
        foreach ($entries as $entry) {
            if ($entry->place === 1) {
                $this->notifier->notify($entry->user_id, 'tournament_won', $this->about($t), "tournament_won:{$t->id}");
            } elseif ($t->format !== 'knockout' && $entry->place !== null) {
                $this->notifier->notify($entry->user_id, 'tournament_finished', [...$this->about($t), 'place' => $entry->place],
                    "tournament_finished:{$t->id}");
            }
        }
        foreach ($entries as $entry) {
            $prize = $entry->place === null ? null : PairingEngine::prizeFor($t->prizes, $entry->place);
            if ($prize === null) {
                continue;
            }
            $user = $entry->user()->firstOrFail();
            if ($prize['coins'] > 0) {
                $this->wallet->credit($user, 'coins', $prize['coins'], 'tournament',
                    "tournament_prize:{$t->id}:{$user->id}", "tournament:{$t->id}");
            }
            foreach ($prize['items'] as $itemId) {
                if (! Item::query()->whereKey($itemId)->exists()) {
                    Log::warning('tournament prize item missing', ['tournament' => $t->id, 'item' => $itemId]);

                    continue;
                }
                DB::table('user_items')->insertOrIgnore([
                    'user_id' => $user->id, 'item_id' => $itemId, 'source' => 'tournament',
                    'created_at' => now(), 'updated_at' => now(),
                ]);
            }
        }
    }

    // ---- results from the game server ---------------------------------------------

    /** A finished (or walked-over) tournament match from MatchResultService. */
    public function onMatch(GameMatch $match, string $tournamentId): void
    {
        $pairing = $this->pairing($match->id, $tournamentId);
        if ($pairing === null) {
            return;
        }
        $players = [$match->white_user_id, $match->black_user_id];
        if (! in_array($pairing->white_user_id, $players, true) || ! in_array($pairing->black_user_id, $players, true)) {
            Log::warning('tournament result players differ', ['matchId' => $match->id]);

            return;
        }
        $winner = $match->winner === 'white' ? $match->white_user_id : $match->black_user_id;
        $sameSides = $pairing->white_user_id === $match->white_user_id;
        DB::transaction(function () use ($pairing, $winner, $match, $sameSides): void {
            $t = $this->lock($pairing->tournament_id);
            $this->record($t, $pairing, $winner, $match->reason === 'walkover',
                $sameSides ? $match->white_score : $match->black_score,
                $sameSides ? $match->black_score : $match->white_score);
        });
        $this->pushAfterCommit();
    }

    /** Neither player came: nobody wins the pairing. */
    public function onNoShow(string $matchId, string $tournamentId): void
    {
        $pairing = $this->pairing($matchId, $tournamentId);
        if ($pairing === null) {
            return;
        }
        DB::transaction(function () use ($pairing): void {
            $this->record($this->lock($pairing->tournament_id), $pairing, null, true, 0, 0);
        });
        $this->pushAfterCommit();
    }

    private function pairing(string $matchId, string $tournamentId): ?TournamentPairing
    {
        $pairing = TournamentPairing::query()->where('match_id', $matchId)->first();
        if ($pairing === null || (string) $pairing->tournament_id !== $tournamentId) {
            Log::warning('unknown tournament match', ['matchId' => $matchId, 'tournamentId' => $tournamentId]);

            return null;
        }

        return $pairing;
    }

    /** Records a pairing once; losers of a knockout are out. */
    private function record(Tournament $t, TournamentPairing $pairing, ?int $winner, bool $walkover, ?int $whiteScore, ?int $blackScore): void
    {
        $p = TournamentPairing::query()->lockForUpdate()->findOrFail($pairing->id);
        if ($p->status === 'finished' || $t->status !== 'running') {
            return;
        }
        $p->fill([
            'status' => 'finished',
            'result' => $winner === null ? 'none' : ($winner === $p->white_user_id ? 'white' : 'black'),
            'winner_user_id' => $winner,
            'walkover' => $walkover,
            'white_score' => $whiteScore,
            'black_score' => $blackScore,
            'finished_at' => now(),
        ])->save();
        foreach ([$p->white_user_id, $p->black_user_id] as $userId) {
            if ($userId === null) {
                continue;
            }
            $entry = $this->entry($t, $userId);
            if ($userId === $winner) {
                $entry->wins += 1;
                $entry->points += 1;
            } else {
                $entry->losses += 1;
                if ($t->format === 'knockout') {
                    $entry->eliminated_round = $p->round;
                    $this->notifier->notify($userId, 'tournament_eliminated', [
                        ...$this->about($t), 'round' => $p->round,
                        'place' => PairingEngine::knockoutPlace((int) $t->total_rounds, $p->round),
                    ], "tournament_eliminated:{$t->id}");
                }
            }
            $entry->save();
        }
        $this->advance($t);
        $this->changed($t);
    }

    // ---- game server ----------------------------------------------------------------

    private function pushAfterCommit(): void
    {
        DB::afterCommit(fn () => $this->pushPending());
    }

    /** Pushes unplayed pairings (and stale pushed ones) to the game server. */
    public function pushPending(): int
    {
        $stale = now()->subMinutes((int) config('tournaments.repush_after_minutes'));
        $pairings = TournamentPairing::query()->with(['tournament', 'white', 'black'])
            ->whereHas('tournament', fn ($q) => $q->where('status', 'running'))
            ->whereNotNull('white_user_id')->whereNotNull('black_user_id')
            ->where(fn ($q) => $q->where('status', 'pending')
                ->orWhere(fn ($q) => $q->where('status', 'pushed')->where('pushed_at', '<=', $stale)))
            ->orderBy('id')->limit(500)->get();
        $pushed = 0;
        foreach ($pairings as $p) {
            if ($p->white === null || $p->black === null) {
                continue;
            }
            $ok = $this->gameServer->pushTournamentMatch([
                'matchId' => $p->match_id,
                'tournamentId' => (string) $p->tournament_id,
                'round' => $p->round,
                'variant' => $p->tournament->variant,
                'matchLength' => $p->tournament->match_length,
                'white' => $this->playerInfo($p->white),
                'black' => $this->playerInfo($p->black),
                'noShowSeconds' => (int) config('tournaments.no_show_seconds'),
            ]);
            if ($ok) {
                TournamentPairing::query()->whereKey($p->id)->where('status', '!=', 'finished')
                    ->update(['status' => 'pushed', 'pushed_at' => now()]);
                $pushed++;
            }
        }

        return $pushed;
    }

    /** @return array<string, mixed> PlayerInfo without a rating (unrated). */
    private function playerInfo(User $user): array
    {
        $info = ['userId' => (string) $user->id, 'name' => mb_substr($user->name, 0, 64), 'bot' => false];
        if ($user->country !== null) {
            $info['country'] = $user->country;
        }
        $cosmetics = $this->store->equipped($user);
        if ($cosmetics !== []) {
            $info['cosmetics'] = $cosmetics;
        }

        return $info;
    }

    // ---- scheduler ------------------------------------------------------------------

    /**
     * Every minute: starts due tournaments (or cancels them below the
     * minimum), cancels expired registrations (unfilled sit-and-go, stale
     * private ones) and pushes pairings.
     *
     * @return array{started: int, cancelled: int, pushed: int}
     */
    public function tick(Carbon $now): array
    {
        $started = 0;
        $cancelled = 0;
        $due = Tournament::query()->where('status', 'registering')->where('kind', '!=', 'sit_and_go')
            ->whereNotNull('starts_at')->where('starts_at', '<=', $now)->orderBy('id')->get();
        foreach ($due as $t) {
            if ($this->start($t)) {
                $started++;
            } else {
                $cancelled++;
            }
        }
        $expired = Tournament::query()->where('status', 'registering')
            ->whereNotNull('expires_at')->where('expires_at', '<=', $now)->orderBy('id')->get();
        foreach ($expired as $t) {
            $this->cancel($t, $t->kind === 'sit_and_go' ? 'not_filled' : 'expired');
            $cancelled++;
        }

        $this->remind($now);

        return ['started' => $started, 'cancelled' => $cancelled, 'pushed' => $this->pushPending()];
    }

    /** "Turnir başlayır": once per entrant, config('push.tournament_reminder_minutes') before the start. */
    public function remind(Carbon $now): int
    {
        $lead = (int) config('push.tournament_reminder_minutes');
        $soon = Tournament::query()->with('entries')->where('status', 'registering')->where('kind', '!=', 'sit_and_go')
            ->whereNotNull('starts_at')->where('starts_at', '>', $now)->where('starts_at', '<=', $now->copy()->addMinutes($lead))
            ->orderBy('id')->get();
        $sent = 0;
        foreach ($soon as $t) {
            $minutes = max(1, (int) ceil(abs($now->diffInSeconds($t->starts_at)) / 60));
            $sent += $this->notifier->notifyMany($t->entries->pluck('user_id')->map(fn ($id) => (int) $id), 'tournament_reminder',
                [...$this->about($t), 'minutes' => $minutes, 'startsAt' => $t->starts_at?->toIso8601String()],
                "tournament_reminder:{$t->id}");
        }

        return $sent;
    }

    /** Creates the next scheduled championships (idempotent by schedule key). */
    public function schedule(Carbon $now): int
    {
        $created = 0;
        /** @var array<string, array<string, mixed>> $schedule */
        $schedule = config('tournaments.schedule');
        foreach ($schedule as $id => $s) {
            foreach (self::occurrences($s, $now) as $at) {
                $key = "$id:".$at->format('Y-m-d');
                if (Tournament::query()->where('schedule_key', $key)->exists()) {
                    continue;
                }
                /** @var array<int, array{0: int, 1: int, 2: int, 3: array<int, string>}> $rows */
                $rows = $s['prizes'];
                $prizes = array_map(fn (array $r) => ['from' => $r[0], 'to' => $r[1], 'coins' => $r[2], 'items' => $r[3]], $rows);
                Tournament::query()->create([
                    'name' => $s['name'],
                    'format' => $s['format'],
                    'kind' => 'scheduled',
                    'variant' => $s['variant'],
                    'match_length' => $s['match_length'],
                    'size' => $s['size'],
                    'min_players' => $s['min_players'],
                    'entry_coins' => $s['entry_coins'],
                    'min_rating' => $s['min_rating'] ?? null,
                    'swiss_rounds' => $s['swiss_rounds'] ?? null,
                    'prizes' => $prizes,
                    'prize_fund' => PairingEngine::fund($prizes),
                    'status' => 'registering',
                    'starts_at' => $at,
                    'schedule_key' => $key,
                ]);
                $created++;
            }
        }

        return $created;
    }

    /**
     * Upcoming start times: today's and tomorrow's for daily entries, the
     * next one for weekly entries (ISO weekday `day`), all UTC.
     *
     * @param  array<string, mixed>  $s
     * @return list<Carbon>
     */
    public static function occurrences(array $s, Carbon $now): array
    {
        $first = $now->copy()->utc()->startOfDay()->setTimeFromTimeString((string) $s['at']);
        $times = [];
        for ($d = 0; $d <= 7; $d++) {
            $at = $first->copy()->addDays($d);
            if ($at->lte($now)) {
                continue;
            }
            if ($s['every'] === 'day') {
                $times[] = $at;
                if (count($times) === 2) {
                    break;
                }
            } elseif ($at->dayOfWeekIso === (int) $s['day']) {
                $times[] = $at;
                break;
            }
        }

        return $times;
    }

    // ---- views ----------------------------------------------------------------------

    private function lock(int $id): Tournament
    {
        return Tournament::query()->lockForUpdate()->findOrFail($id);
    }

    public function entryOf(Tournament $t, ?User $user): ?TournamentEntry
    {
        return $user === null ? null
            : TournamentEntry::query()->where(['tournament_id' => $t->id, 'user_id' => $user->id])->first();
    }

    /** Private tournaments are visible to their organiser and entrants. */
    public function canSee(Tournament $t, User $user): bool
    {
        return ! $t->is_private || $t->created_by === $user->id || $this->entryOf($t, $user) !== null;
    }

    /** @return array<string, mixed> */
    public function summary(Tournament $t, ?TournamentEntry $mine): array
    {
        return [
            'id' => (string) $t->id,
            'name' => $t->name,
            'type' => $t->format,
            'kind' => $t->kind,
            'status' => $t->status,
            'variant' => $t->variant,
            'matchLength' => $t->match_length,
            'clock' => config('tournaments.clock'),
            'size' => $t->size,
            'minPlayers' => $t->min_players,
            'entrants' => $t->entries_count ?? $t->entries()->count(),
            'entry' => [
                'kind' => $t->is_private ? 'invite' : ($t->entry_coins > 0 ? 'coins' : 'free'),
                'coins' => $t->entry_coins,
            ],
            'minRating' => $t->min_rating,
            'rated' => false,
            'private' => $t->is_private,
            'startsAt' => $t->starts_at?->toIso8601String(),
            'expiresAt' => $t->expires_at?->toIso8601String(),
            'startedAt' => $t->started_at?->toIso8601String(),
            'finishedAt' => $t->finished_at?->toIso8601String(),
            'cancelReason' => $t->cancel_reason,
            'currentRound' => $t->current_round,
            'totalRounds' => $t->total_rounds,
            'prizes' => $t->prizes,
            'prizeFund' => $t->prize_fund,
            'fairDice' => true,
            'myStatus' => self::myStatus($t, $mine),
            'myPlace' => $mine?->place,
        ];
    }

    private static function myStatus(Tournament $t, ?TournamentEntry $mine): string
    {
        if ($mine === null) {
            return 'none';
        }

        return match ($t->status) {
            'running' => $mine->eliminated_round !== null ? 'eliminated' : 'playing',
            'finished' => $mine->place === 1 ? 'champion' : 'finished',
            default => 'registered',
        };
    }

    /**
     * 4.2–4.4: summary + entrants, rounds (bracket), standings and my next
     * match.
     *
     * @return array<string, mixed>
     */
    public function detail(Tournament $t, User $viewer): array
    {
        $mine = $this->entryOf($t, $viewer);
        $entries = $t->entries()->with('user')->orderByRaw('seed is null')->orderBy('seed')->orderBy('id')->get();
        $pairings = $t->pairings()->orderBy('round')->orderBy('slot')->get();
        $users = $entries->mapWithKeys(fn (TournamentEntry $e) => [$e->user_id => self::lite($e->user)])->all();
        $rounds = [];
        foreach ($pairings->groupBy('round') as $number => $matches) {
            $rounds[] = [
                'number' => (int) $number,
                'stage' => $t->format === 'knockout' ? self::stage((int) $t->total_rounds, (int) $number) : (string) $number,
                'status' => $matches->every(fn (TournamentPairing $p) => $p->status === 'finished') ? 'finished' : 'running',
                'matches' => $matches->map(fn (TournamentPairing $p) => self::pairingView($p, $users))->values()->all(),
            ];
        }
        $next = $mine === null ? null : $pairings->first(fn (TournamentPairing $p) => $p->round === $t->current_round
            && $p->status !== 'finished' && $p->involves($viewer->id));
        $canSeeCode = $t->is_private && ($t->created_by === $viewer->id || $mine !== null);

        return [
            ...$this->summary($t, $mine),
            'organizerId' => $t->created_by === null ? null : (string) $t->created_by,
            'inviteCode' => $canSeeCode ? $t->invite_code : null,
            'entrantsList' => $entries->map(fn (TournamentEntry $e) => [
                'user' => $users[$e->user_id],
                'seed' => $e->seed,
                'rating' => $e->rating,
                'place' => $e->place,
            ])->values()->all(),
            'rounds' => $rounds,
            'standings' => $t->format === 'knockout' ? null : $this->standings($t, $entries, $users),
            'myNextMatch' => $next === null ? null : [
                'matchId' => $next->match_id,
                'round' => $next->round,
                'status' => self::pairingStatus($next),
                'opponent' => $users[$next->white_user_id === $viewer->id ? $next->black_user_id : $next->white_user_id] ?? null,
                'noShowSeconds' => (int) config('tournaments.no_show_seconds'),
            ],
        ];
    }

    /**
     * Swiss / round-robin table: points, then Buchholz (live).
     *
     * @param  Collection<int, TournamentEntry>  $entries
     * @param  array<int, array<string, mixed>>  $users
     * @return list<array<string, mixed>>
     */
    private function standings(Tournament $t, Collection $entries, array $users): array
    {
        $byUser = $entries->keyBy('user_id');
        $points = $entries->mapWithKeys(fn (TournamentEntry $e) => [$e->user_id => $e->points])->all();
        $ratings = $entries->mapWithKeys(fn (TournamentEntry $e) => [$e->user_id => $e->rating])->all();
        $buchholz = PairingEngine::buchholz($points, $this->opponents($t));
        $rows = [];
        foreach (PairingEngine::rank($points, $buchholz, $ratings) as $i => $userId) {
            /** @var TournamentEntry $e */
            $e = $byUser[$userId];
            $rows[] = [
                'rank' => $i + 1,
                'user' => $users[$userId],
                'wins' => $e->wins,
                'losses' => $e->losses,
                'points' => $e->points,
                'buchholz' => $buchholz[$userId],
            ];
        }

        return $rows;
    }

    /** "final", "1/2" (semi-finals), "1/4" … : matches in the round. */
    public static function stage(int $totalRounds, int $round): string
    {
        return $round >= $totalRounds ? 'final' : '1/'.(2 ** ($totalRounds - $round));
    }

    private static function pairingStatus(TournamentPairing $p): string
    {
        return match (true) {
            $p->status === 'pending' => 'pending',
            $p->status === 'pushed' => 'ready',
            $p->bye => 'bye',
            $p->walkover => 'walkover',
            default => 'finished',
        };
    }

    /**
     * @param  array<int, array<string, mixed>>  $users
     * @return array<string, mixed>
     */
    private static function pairingView(TournamentPairing $p, array $users): array
    {
        return [
            'slot' => $p->slot,
            'matchId' => $p->match_id,
            'white' => $p->white_user_id === null ? null : ($users[$p->white_user_id] ?? null),
            'black' => $p->black_user_id === null ? null : ($users[$p->black_user_id] ?? null),
            'status' => self::pairingStatus($p),
            'result' => $p->result,
            'winnerId' => $p->winner_user_id === null ? null : (string) $p->winner_user_id,
            'score' => $p->white_score === null ? null : [$p->white_score, $p->black_score],
        ];
    }

    /** @return array<string, mixed> */
    private static function lite(User $user): array
    {
        return ['id' => (string) $user->id, 'name' => $user->name, 'country' => $user->country, 'avatar' => $user->avatar];
    }
}
