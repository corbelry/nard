import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart' show Variant;

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart' show ApiException;
import '../social/room_screen.dart' show RoomCodeField;
import '../social/social_gate.dart' show AsyncBody;
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/competition.dart';
import '../ui/extra_tokens.dart';
import '../ui/fields.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'tournament_models.dart';
import 'tournament_providers.dart';
import 'tournament_text.dart';

/// 4.1 "+" chooser: create a private tournament or join one by code.
Future<void> showPrivateChooser(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showNardSheet<void>(
    context,
    builder:
        (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.privateTourTitle),
            const SizedBox(height: 8),
            SheetActionRow(
              label: l.privateTourCreateChoice,
              icon: LucideIcons.plus,
              onTap: () {
                Navigator.of(ctx).pop();
                unawaited(context.push('/tournaments/private/new'));
              },
            ),
            SheetActionRow(
              label: l.privateTourJoinByCode,
              icon: LucideIcons.keyRound,
              onTap: () {
                Navigator.of(ctx).pop();
                unawaited(context.push('/tournaments/join'));
              },
            ),
          ],
        ),
  );
}

/// "Şənbə, 20:00" in the app locale.
String startLabel(AppLocalizations l, String locale, DateTime? at) =>
    at == null
        ? l.privateTourStartManual
        : l.privateTourStartValue(
          DateFormat.EEEE(locale).format(at),
          DateFormat.Hm(locale).format(at),
        );

/// 22.1 Private tournament settings: name, size, game, length, start time.
/// Private tournaments are free knockouts with an invite code (ADR-038),
/// so entry and format are fixed.
class CreatePrivateTournamentScreen extends ConsumerStatefulWidget {
  const CreatePrivateTournamentScreen({super.key});

  @override
  ConsumerState<CreatePrivateTournamentScreen> createState() =>
      _CreatePrivateState();
}

class _CreatePrivateState extends ConsumerState<CreatePrivateTournamentScreen> {
  final _name = TextEditingController();
  int _size = 8;
  Variant _variant = Variant.shortNard;
  int _length = 5;
  DateTime? _startsAt;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid {
    final n = _name.text.trim().length;
    return n >= 3 && n <= 40;
  }

  Future<void> _pickVariant() async {
    final l = AppLocalizations.of(context);
    final v = await _pick<Variant>(
      l.privateTourGame,
      [Variant.shortNard, Variant.longNard],
      (v) => variantName(l, v),
      _variant,
    );
    if (v != null) setState(() => _variant = v);
  }

  Future<void> _pickLength() async {
    final l = AppLocalizations.of(context);
    final v = await _pick<int>(
      l.privateTourLength,
      const [1, 3, 5, 7],
      l.formatPoints,
      _length,
    );
    if (v != null) setState(() => _length = v);
  }

  Future<T?> _pick<T>(
    String title,
    List<T> values,
    String Function(T) label,
    T current,
  ) => showNardSheet<T>(
    context,
    builder:
        (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(title),
            const SizedBox(height: 8),
            for (final v in values)
              SheetActionRow(
                label: label(v),
                icon: v == current ? LucideIcons.check : null,
                accent: v == current,
                onTap: () => Navigator.of(ctx).pop(v),
              ),
          ],
        ),
  );

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      initialDate: _startsAt ?? now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _startsAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null || !mounted) return;
    final at = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() => _startsAt = at.isAfter(now) ? at : null);
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final detail = await ref
          .read(apiClientProvider)
          .createPrivateTournament(
            name: _name.text.trim(),
            size: _size,
            variant: _variant,
            matchLength: _length,
            startsAt: _startsAt,
          );
      ref.invalidate(tournamentListProvider);
      if (mounted) {
        context.pushReplacement('/tournaments/${detail.tournament.id}/invite');
      }
    } on Object catch (e) {
      if (mounted) showNote(context, tournamentError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final locale = Localizations.localeOf(context).languageCode;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.privateTourTitle, bare: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      l.privateTourName,
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.text.withValues(alpha: .6),
                      ),
                    ),
                  ),
                  NardTextField(
                    controller: _name,
                    label: l.privateTourNameHint,
                    height: 52,
                    maxLength: 40,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
                    child: Overline(
                      l.privateTourSize,
                      color: c.text.withValues(alpha: .55),
                    ),
                  ),
                  EqualChips<int>(
                    values: const [4, 8, 16, 32],
                    labels: const ['4', '8', '16', '32'],
                    selected: _size,
                    onChanged: (v) => setState(() => _size = v),
                    height: 40,
                    radius: NardRadius.m,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  GroupCard(
                    children: [
                      InfoRow(
                        label: l.privateTourGame,
                        value: variantName(l, _variant),
                        onTap: _pickVariant,
                      ),
                      InfoRow(
                        label: l.privateTourLength,
                        value: l.formatPoints(_length),
                        onTap: _pickLength,
                      ),
                      InfoRow(
                        label: l.sngTimeControl,
                        value: l.timeValue(3, 12),
                      ),
                      InfoRow(
                        label: l.privateTourStart,
                        value: startLabel(l, locale, _startsAt),
                        onTap: _pickStart,
                      ),
                      InfoRow(
                        label: l.privateTourEntry,
                        value: l.privateTourFree,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, max(24, bottom + 8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.privateTourNote,
                    textAlign: TextAlign.center,
                    style: NardType.caption.copyWith(
                      fontWeight: FontWeight.w400,
                      color: c.text.withValues(alpha: .55),
                    ),
                  ),
                  const SizedBox(height: 10),
                  NardButton(
                    label: l.privateTourCreate,
                    onPressed: !_valid || _busy ? null : _create,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 22.2 Invite and registration: code, entrants, start / cancel for the
/// organiser, leave for players. Polls every 10 s and opens the bracket
/// once the tournament runs.
class PrivateTournamentScreen extends ConsumerStatefulWidget {
  const PrivateTournamentScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<PrivateTournamentScreen> createState() =>
      _PrivateTournamentState();
}

class _PrivateTournamentState extends ConsumerState<PrivateTournamentScreen> {
  Timer? _poll;
  bool _busy = false;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _poll = pollEvery(
      const Duration(seconds: 10),
      () => ref.invalidate(tournamentDetailProvider(widget.id)),
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref
        ..invalidate(tournamentDetailProvider(widget.id))
        ..invalidate(tournamentListProvider);
    } on Object catch (e) {
      if (mounted) showNote(context, tournamentError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _leaveTo(String location) {
    if (_left) return;
    _left = true;
    context.pushReplacement(location);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final detail = ref.watch(tournamentDetailProvider(widget.id));
    ref.listen<AsyncValue<TournamentDetail>>(
      tournamentDetailProvider(widget.id),
      (_, next) {
        final t = next.value?.tournament;
        if (t != null && t.status == TournamentStatus.running) {
          _leaveTo('/tournaments/${t.id}/bracket');
        }
      },
    );
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.bgGradient),
        child: SafeArea(
          bottom: false,
          child: AsyncBody<TournamentDetail>(
            value: detail,
            onRetry: () => ref.invalidate(tournamentDetailProvider(widget.id)),
            data: (d) => _body(context, d),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, TournamentDetail d) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final t = d.tournament;
    final locale = Localizations.localeOf(context).languageCode;
    final me = ref.watch(accountProvider).value?.id;
    final organizer = me != null && d.organizerId == me;
    final code = d.inviteCode ?? '';
    final bottom = MediaQuery.paddingOf(context).bottom;
    final name = t.nameFor(locale);
    final meta = l.privateTourMeta(
      startLabel(l, locale, t.startsAt),
      variantName(l, t.variant),
      t.matchLength,
    );
    final cancelled = t.status == TournamentStatus.cancelled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScreenHeader(title: name, bare: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Overline(
                      cancelled
                          ? l.tourStatusCancelled
                          : l.privateTourCodeLabel,
                      color: c.accent,
                      spacing: .96,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayCode(code),
                      style: NardType.mono.copyWith(
                        fontSize: 34,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 5.4,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      meta,
                      style: NardType.bodyS.copyWith(
                        color: c.text.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _CardButton(
                            label: l.roomCopy,
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: code),
                              );
                              if (context.mounted) showNote(context, l.copied);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CardButton(
                            label: l.privateTourCopyInvite,
                            solid: true,
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: l.privateTourShareText(
                                    name,
                                    displayCode(code),
                                  ),
                                ),
                              );
                              if (context.mounted) showNote(context, l.copied);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Overline(
                        l.privateTourRegistration,
                        color: c.text.withValues(alpha: .55),
                      ),
                    ),
                    Text(
                      l.tourParticipantsValue(t.entrants, t.size),
                      style: NardType.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                        fontFeatures: tabular,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GroupCard(
                children: [
                  for (final e in d.entrants)
                    GestureDetector(
                      onLongPress:
                          organizer && e.user.id != me
                              ? () => _remove(t, e.user)
                              : null,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            RowAvatar(name: e.user.name, me: e.user.id == me),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.user.id == me
                                    ? l.memberMe(e.user.name)
                                    : e.user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NardType.body.copyWith(color: c.text),
                              ),
                            ),
                            Text(
                              e.user.id == d.organizerId
                                  ? l.privateTourOrganizer
                                  : l.privateTourJoined,
                              style: NardType.caption.copyWith(
                                fontWeight: FontWeight.w400,
                                color:
                                    e.user.id == d.organizerId
                                        ? c.accent
                                        : c.text.withValues(alpha: .55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (!cancelled)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, max(24, bottom + 8)),
            child:
                _busy
                    ? SizedBox(
                      height: 56,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: c.accent,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                    : organizer
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NardButton(
                          label:
                              t.entrants >= 2
                                  ? l.privateTourStartNow
                                  : l.privateTourStartNowMin(2),
                          onPressed:
                              t.entrants >= 2
                                  ? () => _run(
                                    () => ref
                                        .read(apiClientProvider)
                                        .startTournament(t.id),
                                  )
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        NardButton(
                          label: l.privateTourCancel,
                          variant: NardButtonVariant.ghost,
                          size: NardButtonSize.s,
                          labelColor: c.dangerText,
                          onPressed: () => _cancel(t),
                        ),
                      ],
                    )
                    : NardButton(
                      label: l.tourUnregister,
                      variant: NardButtonVariant.outline,
                      onPressed:
                          () => _run(() async {
                            await ref
                                .read(apiClientProvider)
                                .unregisterTournament(t.id);
                            if (context.mounted) context.go('/tournaments');
                          }),
                    ),
          ),
      ],
    );
  }

  Future<void> _cancel(Tournament t) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmSheet(
      context,
      title: l.privateTourCancelTitle,
      body: l.privateTourCancelBody,
      action: l.privateTourCancel,
      cancel: l.cancel,
      danger: true,
    );
    if (!ok || !mounted) return;
    await _run(() async {
      await ref.read(apiClientProvider).cancelTournament(t.id);
      if (mounted) context.go('/tournaments');
    });
  }

  Future<void> _remove(Tournament t, UserLite user) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmSheet(
      context,
      title: l.privateTourRemove,
      body: user.name,
      action: l.privateTourRemove,
      cancel: l.cancel,
      danger: true,
    );
    if (!ok || !mounted) return;
    await _run(() => ref.read(apiClientProvider).removeEntrant(t.id, user.id));
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.onTap,
    this.solid = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: solid ? c.accent : null,
          borderRadius: BorderRadius.circular(NardRadius.m),
          border:
              solid ? null : Border.all(color: c.accent.withValues(alpha: .3)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: NardType.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: solid ? c.onAccent : c.text,
          ),
        ),
      ),
    );
  }
}

/// 7.3 join by code (proposal): six cells `[A-Z2-9]`, then 22.2.
class JoinTournamentScreen extends ConsumerStatefulWidget {
  const JoinTournamentScreen({super.key});

  @override
  ConsumerState<JoinTournamentScreen> createState() => _JoinTournamentState();
}

class _JoinTournamentState extends ConsumerState<JoinTournamentScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  static final _pattern = RegExp(r'^[A-Z2-9]{6}$');

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool get _ready => _pattern.hasMatch(_code.text.trim().toUpperCase());

  Future<void> _join() async {
    if (!_ready || _busy) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final d = await ref
          .read(apiClientProvider)
          .joinTournamentByCode(_code.text.trim().toUpperCase());
      ref.invalidate(tournamentListProvider);
      if (mounted) {
        context.pushReplacement('/tournaments/${d.tournament.id}/invite');
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = tournamentError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.roomBg),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.privateTourJoinByCode, bare: true),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
                  children: [
                    Center(child: Overline(l.privateTourCodeLabel)),
                    const SizedBox(height: 20),
                    RoomCodeField(
                      controller: _code,
                      error: _error != null,
                      enabled: !_busy,
                      onCompleted: (_) => _join(),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _error ?? l.privateTourCodeHint,
                      textAlign: TextAlign.center,
                      style: NardType.bodyS.copyWith(
                        color:
                            _error != null
                                ? c.dangerText
                                : c.text.withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: NardButton(
                  label: l.sngJoin,
                  onPressed: _ready && !_busy ? _join : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
