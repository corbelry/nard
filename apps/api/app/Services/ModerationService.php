<?php

namespace App\Services;

use App\Models\AdminAction;
use App\Models\CheatFlag;
use App\Models\Clan;
use App\Models\Report;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use InvalidArgumentException;

/**
 * Admin writes (spec §8.13, ADR-042): bans, chat mutes, warnings, nickname
 * resets, ledger grants, the report queue and flag reviews. Every write
 * lands in the audit log (admin_actions).
 */
class ModerationService
{
    public function __construct(
        private WalletService $wallet,
        private Notifier $notifier,
        private ClanService $clans,
    ) {}

    /** [until] null = permanent. */
    public function ban(User $user, ?Carbon $until, string $reason, ?User $admin): void
    {
        $user->forceFill(['banned_at' => now(), 'banned_until' => $until, 'ban_reason' => $reason])->save();
        $this->audit($admin, 'ban', $user, $reason, ['until' => $until?->toIso8601String()]);
    }

    public function unban(User $user, ?string $note, ?User $admin): void
    {
        $user->forceFill(['banned_at' => null, 'banned_until' => null, 'ban_reason' => null])->save();
        $this->audit($admin, 'unban', $user, $note);
    }

    public function mute(User $user, Carbon $until, string $reason, ?User $admin): void
    {
        $user->forceFill(['muted_until' => $until])->save();
        $this->audit($admin, 'mute', $user, $reason, ['until' => $until->toIso8601String()]);
    }

    public function unmute(User $user, ?User $admin): void
    {
        $user->forceFill(['muted_until' => null])->save();
        $this->audit($admin, 'unmute', $user, null);
    }

    public function clearCooldown(User $user, ?User $admin): void
    {
        $user->forceFill(['queue_cooldown_until' => null])->save();
        $this->audit($admin, 'clear_cooldown', $user, null);
    }

    /** An inbox message to the player (no push). */
    public function warn(User $user, string $reason, ?User $admin): void
    {
        $this->notifier->notify($user, 'moderation_warning', ['reason' => $reason]);
        $this->audit($admin, 'warn', $user, $reason);
    }

    /** Replaces an offensive nickname with a fresh guest-style one. */
    public function resetName(User $user, ?User $admin): string
    {
        $old = $user->name;
        $name = __('nard.guest_name', ['n' => random_int(1000, 9999)], $user->locale);
        $user->forceFill(['name' => $name])->save();
        $this->audit($admin, 'reset_name', $user, null, ['old' => $old, 'new' => $name]);

        return $name;
    }

    /**
     * Credits coins or gems with the ledger reason 'admin' (support
     * compensation). Never tied to money (ADR-022): there is no price,
     * receipt or purchase on this path, and a note is mandatory.
     */
    public function grant(User $user, string $currency, int $amount, string $note, ?User $admin): int
    {
        $note = trim($note);
        if ($note === '') {
            throw new InvalidArgumentException('A note is required');
        }
        if ($amount < 1 || $amount > (int) config('fairplay.max_grant')) {
            throw new InvalidArgumentException('Amount out of range');
        }
        $key = 'admin-grant:'.Str::uuid()->toString();
        $balance = $this->wallet->credit($user, $currency, $amount, 'admin', $key, 'admin:'.($admin->id ?? 'system'));
        $this->audit($admin, 'grant', $user, $note, ['currency' => $currency, 'amount' => $amount, 'key' => $key]);

        return $balance;
    }

    /**
     * Closes a report: dismiss | warn | mute | ban. [hours] is the mute or
     * ban length (null ban = permanent).
     */
    public function handleReport(Report $report, string $action, ?string $note, ?int $hours, ?User $admin): void
    {
        DB::transaction(function () use ($report, $action, $note, $hours, $admin): void {
            $target = $report->reported()->firstOrFail();
            $reason = $note !== null && trim($note) !== '' ? trim($note) : $report->reason;
            match ($action) {
                'dismiss' => null,
                'warn' => $this->warn($target, $reason, $admin),
                'mute' => $this->mute($target, now()->addHours(max(1, $hours ?? 24)), $reason, $admin),
                'ban' => $this->ban($target, $hours === null ? null : now()->addHours(max(1, $hours)), $reason, $admin),
                default => throw new InvalidArgumentException("Unknown action $action"),
            };
            $report->forceFill([
                'status' => $action === 'dismiss' ? 'reviewed' : 'actioned',
                'action' => $action,
                'handled_by' => $admin?->id,
                'handled_at' => now(),
            ])->save();
            $this->audit($admin, 'report_'.$action, $report, $note);
        });
    }

    public function reviewFlag(CheatFlag $flag, string $status, ?string $note, ?User $admin): void
    {
        if (! in_array($status, ['reviewed', 'dismissed', 'actioned'], true)) {
            throw new InvalidArgumentException("Bad status $status");
        }
        $flag->forceFill([
            'status' => $status,
            'reviewed_by' => $admin?->id,
            'reviewed_at' => now(),
            'review_note' => $note,
        ])->save();
        $this->audit($admin, 'flag_'.$status, $flag, $note);
    }

    public function renameClan(Clan $clan, string $name, ?User $admin): void
    {
        $old = $clan->name;
        $this->clans->adminRename($clan, $name);
        $this->audit($admin, 'clan_rename', $clan, null, ['old' => $old, 'new' => $name]);
    }

    public function disbandClan(Clan $clan, string $reason, ?User $admin): void
    {
        $this->audit($admin, 'clan_disband', $clan, $reason, ['name' => $clan->name, 'tag' => $clan->tag]);
        $clan->delete();
    }

    /** @param array<string, mixed> $data */
    public function audit(?User $admin, string $action, Model|string|null $subject, ?string $note, array $data = []): void
    {
        if ($subject instanceof Model) {
            $key = $subject->getKey();
            $subject = Str::snake(class_basename($subject)).':'.(is_scalar($key) ? (string) $key : '?');
        }
        AdminAction::query()->create([
            'admin_id' => $admin?->id,
            'action' => $action,
            'subject' => $subject,
            'note' => $note === null ? null : Str::limit($note, 497),
            'data' => $data === [] ? null : $data,
        ]);
    }
}
