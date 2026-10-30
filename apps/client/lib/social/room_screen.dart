import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../game/online_overlays.dart' show PeriodicBuilder;
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/online_draft.dart';
import '../online/online_game_controller.dart';
import '../online/online_text.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart' show KeyValueRow;
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'social_models.dart';
import 'social_providers.dart';
import 'social_socket.dart';

/// Home "Şəxsi otaq": create a room or join one by code (§13.11 chooser).
Future<void> showRoomChooser(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final choice = await showNardSheet<bool>(
    context,
    builder:
        (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.roomTitle),
            const SizedBox(height: 16),
            _ChoiceCard(
              icon: LucideIcons.lock,
              title: l.roomCreate,
              sub: l.roomCreateSub,
              onTap: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 10),
            _ChoiceCard(
              icon: LucideIcons.keyRound,
              title: l.roomJoinByCode,
              sub: l.roomJoinByCodeSub,
              onTap: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
  );
  if (choice == null || !context.mounted) return;
  if (choice) {
    final draft = ref.read(onlineDraftProvider);
    ref
        .read(socialSocketProvider.notifier)
        .createRoom(draft.variant, max(1, draft.matchLength));
    unawaited(context.push('/room'));
  } else {
    unawaited(context.push('/room/join'));
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return SelectableCard(
      selected: false,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22, color: c.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: NardType.labelM.copyWith(color: c.text)),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Moves on to the VS screen once the room pairs us (`match.found`).
mixin _MatchedNavigation<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  void listenForMatch() {
    ref.listen<Lobby>(lobbyProvider, (_, next) {
      if (next.phase == LobbyPhase.found && next.match != null) {
        ref.read(socialSocketProvider.notifier).reset();
        context.pushReplacement('/online/vs');
      }
    });
  }
}

/// 6.3 Private room (host): code, copy/share, waiting card with the
/// expiry countdown, settings (tap to change before anyone joins). The
/// server starts the match as soon as the guest joins (no "Başla").
class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key});

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen>
    with _MatchedNavigation {
  Future<void> _leave() async {
    final l = AppLocalizations.of(context);
    final room = ref.read(socialSocketProvider);
    if (room.phase == RoomPhase.waiting &&
        room.expiresAt != null &&
        room.expiresAt!.isAfter(DateTime.now())) {
      final ok = await showNardSheet<bool>(
        context,
        builder:
            (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetTitle(l.roomCancelTitle),
                const SizedBox(height: 8),
                Text(
                  l.roomCancelBody,
                  style: NardType.body.copyWith(
                    fontSize: 14,
                    color: ctx.nard.text.withValues(alpha: .8),
                  ),
                ),
                const SizedBox(height: 18),
                NardButton(
                  label: l.roomCancelConfirm,
                  variant: NardButtonVariant.danger,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
                const SizedBox(height: 10),
                NardButton(
                  label: l.cancel,
                  variant: NardButtonVariant.outline,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ],
            ),
      );
      if (ok != true || !mounted) return;
    }
    ref.read(socialSocketProvider.notifier).cancelRoom();
    if (mounted) context.canPop() ? context.pop() : context.go('/home');
  }

  void _recreate({Variant? variant, int? matchLength}) {
    final room = ref.read(socialSocketProvider);
    final v = variant ?? room.variant;
    final len = matchLength ?? room.matchLength;
    final draft = ref.read(onlineDraftProvider);
    ref
        .read(onlineDraftProvider.notifier)
        .set(draft.copyWith(variant: v, matchLength: len));
    ref
        .read(socialSocketProvider.notifier)
        .createRoom(v, len, invite: room.invited);
  }

  Future<void> _pickVariant(RoomState room) async {
    final l = AppLocalizations.of(context);
    final v = await showNardSheet<Variant>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(l.roomSettingVariant),
              const SizedBox(height: 14),
              for (final v in Variant.values) ...[
                OptionTile(
                  label:
                      v == Variant.shortNard ? l.variantShort : l.variantLong,
                  selected: v == room.variant,
                  onTap: () => Navigator.of(ctx).pop(v),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
    );
    if (v != null && v != room.variant) _recreate(variant: v);
  }

  Future<void> _pickFormat(RoomState room) async {
    final l = AppLocalizations.of(context);
    final n = await showNardSheet<int>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(l.roomSettingFormat),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final n in const [1, 3, 5, 7]) ...[
                    if (n != 1) const SizedBox(width: 8),
                    Expanded(
                      child: OptionTile(
                        label: l.formatName(n),
                        selected: n == room.matchLength,
                        onTap: () => Navigator.of(ctx).pop(n),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
    );
    if (n != null && n != room.matchLength) _recreate(matchLength: n);
  }

  Future<void> _inviteFriend(RoomState room) async {
    final l = AppLocalizations.of(context);
    final code = room.code;
    if (code == null) return;
    final friend = await showNardSheet<PublicUser>(
      context,
      builder: (_) => const _FriendPicker(),
    );
    if (friend == null || !mounted) return;
    try {
      await ref
          .read(apiClientProvider)
          .challenge(friend.id, code, room.variant, room.matchLength);
      if (mounted) showNote(context, l.friendInviteSent(friend.name));
    } on Object catch (e) {
      if (mounted) showNote(context, friendErrorText(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    listenForMatch();
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final room = ref.watch(socialSocketProvider);
    final code = room.code;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: c.roomBg),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(title: l.roomTitle, bare: true, onBack: _leave),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
                    children: [
                      Center(
                        child: Text(
                          l.roomCodeLabel,
                          style: NardType.bodyS.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: .78,
                            color: c.text.withValues(alpha: .64),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child:
                            room.phase == RoomPhase.failed
                                ? Text(
                                  l.errorTitle,
                                  style: NardType.body.copyWith(
                                    color: c.dangerText,
                                  ),
                                )
                                : code == null
                                ? SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: c.accent,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : FittedBox(
                                  child: CodeCells(
                                    code: code,
                                    semanticLabel: '${l.roomCodeLabel} $code',
                                  ),
                                ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NardButton(
                            label: l.roomCopy,
                            icon: LucideIcons.copy,
                            size: NardButtonSize.s,
                            variant: NardButtonVariant.outline,
                            expand: false,
                            onPressed:
                                code == null
                                    ? null
                                    : () {
                                      unawaited(
                                        Clipboard.setData(
                                          ClipboardData(text: code),
                                        ),
                                      );
                                      showNote(context, l.copied);
                                    },
                          ),
                          const SizedBox(width: 10),
                          NardButton(
                            label: l.roomShare,
                            icon: LucideIcons.share2,
                            size: NardButtonSize.s,
                            variant: NardButtonVariant.outline,
                            expand: false,
                            // No share-sheet dependency: copies the invite.
                            onPressed:
                                code == null
                                    ? null
                                    : () {
                                      unawaited(
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: l.roomShareText(code),
                                          ),
                                        ),
                                      );
                                      showNote(context, l.copied);
                                    },
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      _waitingCard(context, l, room),
                      const SizedBox(height: 20),
                      _settings(context, l, room),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: NardButton(
                    label: l.roomInviteFriend,
                    icon: LucideIcons.userPlus,
                    variant: NardButtonVariant.secondary,
                    onPressed:
                        code == null || room.phase != RoomPhase.waiting
                            ? null
                            : () => _inviteFriend(room),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _waitingCard(BuildContext context, AppLocalizations l, RoomState r) {
    final c = context.nard;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.text.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.lineSoft),
      ),
      child: PeriodicBuilder(
        period: const Duration(seconds: 1),
        builder: (context) {
          final expires = r.expiresAt;
          final left = expires?.difference(DateTime.now());
          final expired = left != null && left.isNegative;
          final title =
              r.phase == RoomPhase.creating
                  ? l.roomCreating
                  : expired
                  ? l.roomExpired
                  : l.roomWaiting;
          String? sub;
          if (expires != null && !expired) {
            sub = l.roomExpiry(
              DateFormat.Hm(l.localeName).format(expires),
              formatDuration(left!),
            );
          }
          final invited = r.invited;
          return Row(
            children: [
              CustomPaint(
                size: const Size(48, 48),
                painter: _EmptySeatPainter(
                  ring: c.text.withValues(alpha: .3),
                  dash: c.text.withValues(alpha: .25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: NardType.labelM.copyWith(
                        color: expired ? c.dangerText : c.text,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        sub,
                        style: NardType.caption.copyWith(
                          fontWeight: FontWeight.w400,
                          color: c.text.withValues(alpha: .6),
                          fontFeatures: tabular,
                        ),
                      ),
                    ],
                    if (invited != null && !expired) ...[
                      const SizedBox(height: 3),
                      Text(
                        l.roomInvited(invited.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NardType.caption.copyWith(color: c.accentHi),
                      ),
                    ],
                  ],
                ),
              ),
              if (expired)
                SmallActionButton(
                  label: l.roomNewCode,
                  onTap: () => _recreate(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _settings(BuildContext context, AppLocalizations l, RoomState r) {
    final c = context.nard;
    final editable = r.phase == RoomPhase.waiting;
    Widget row(String label, String value, VoidCallback? onTap) {
      final kv = KeyValueRow(label: label, value: Text(value));
      return onTap == null || !editable
          ? kv
          : Pressable(onTap: onTap, semanticLabel: label, child: kv);
    }

    final clock = ClockConfig.standard;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.accent.withValues(alpha: .14))),
      ),
      child: Column(
        children: [
          row(
            l.roomSettingVariant,
            r.variant == Variant.shortNard ? l.variantShort : l.variantLong,
            () => _pickVariant(r),
          ),
          row(
            l.roomSettingFormat,
            l.formatName(r.matchLength),
            () => _pickFormat(r),
          ),
          row(
            l.roomSettingTime,
            l.timeValue(clock.reserveMs ~/ 60000, clock.delayMs ~/ 1000),
            null,
          ),
          row(l.roomSettingRating, l.roomUnrated, null),
        ],
      ),
    );
  }
}

/// Dashed empty seat (6.3).
class _EmptySeatPainter extends CustomPainter {
  const _EmptySeatPainter({required this.ring, required this.dash});

  final Color ring;
  final Color dash;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      size.width / 2 - .75,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final r = size.width / 2 - 6;
    final p =
        Paint()
          ..color = dash
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    const n = 16;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * pi / n;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        a,
        pi / n,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_EmptySeatPainter old) => false;
}

/// Friend list for the room's "Dostu çağır".
class _FriendPicker extends ConsumerWidget {
  const _FriendPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final friends = ref.watch(friendsProvider).value?.friends ?? const [];
    final sorted = sortByPresence(
      friends.map((f) => f.user),
      ref.watch(presenceProvider),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.roomPickFriend),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l.friendsEmptyTitle,
              textAlign: TextAlign.center,
              style: NardType.body.copyWith(color: c.textDim),
            ),
          ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final u in sorted)
                HairlineRow(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onTap: () => Navigator.of(context).pop(u),
                  semanticLabel: u.name,
                  child: Row(
                    children: [
                      PresenceAvatar(
                        name: u.name,
                        size: 36,
                        presence:
                            u.online ? PresenceDot.online : PresenceDot.offline,
                        ringBg: c.surfaceRaised,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          u.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.labelM.copyWith(color: c.text),
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: c.textDim,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Guest side of 6.3 (not designed, §13.11): enter the 6-character code,
/// then wait for `match.found`. Opened pre-filled from a friend challenge.
class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key, this.code});

  final String? code;

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen>
    with _MatchedNavigation {
  late final _code = TextEditingController(text: widget.code ?? '');

  static final _pattern = RegExp(r'^[A-Z2-9]{6}$');

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _join() {
    final code = _code.text.trim().toUpperCase();
    if (!_pattern.hasMatch(code)) return;
    ref.read(socialSocketProvider.notifier).joinRoom(code);
  }

  @override
  Widget build(BuildContext context) {
    listenForMatch();
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final room = ref.watch(socialSocketProvider);
    final joining = room.phase == RoomPhase.joining;
    final notFound = room.phase == RoomPhase.notFound;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.roomBg),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l.roomJoinTitle,
                bare: true,
                onBack: () {
                  ref.read(socialSocketProvider.notifier).cancelRoom();
                  context.canPop() ? context.pop() : context.go('/home');
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
                  children: [
                    Center(
                      child: Text(
                        l.roomCodeLabel,
                        style: NardType.bodyS.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: .78,
                          color: c.text.withValues(alpha: .64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoomCodeField(
                      controller: _code,
                      error: notFound,
                      enabled: !joining,
                      onCompleted: (_) => _join(),
                      onChanged: (_) {
                        if (notFound) {
                          ref.read(socialSocketProvider.notifier).reset();
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      notFound
                          ? l.roomNotFound
                          : joining
                          ? l.roomJoining
                          : l.roomJoinHint,
                      textAlign: TextAlign.center,
                      style: NardType.bodyS.copyWith(
                        color:
                            notFound
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
                  label: joining ? l.roomJoining : l.roomJoin,
                  onPressed:
                      joining ||
                              !_pattern.hasMatch(
                                _code.text.trim().toUpperCase(),
                              )
                          ? null
                          : _join,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Six cells over a hidden field: letters and digits `[A-Z2-9]`.
class RoomCodeField extends StatefulWidget {
  const RoomCodeField({
    super.key,
    required this.controller,
    this.error = false,
    this.enabled = true,
    this.onChanged,
    this.onCompleted,
  });

  final TextEditingController controller;
  final bool error;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<RoomCodeField> createState() => _RoomCodeFieldState();
}

class _RoomCodeFieldState extends State<RoomCodeField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _focus.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final text = widget.controller.text.toUpperCase();
    final active = min(text.length, 5);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focus.requestFocus(),
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AnimatedContainer(
                    duration: NardMotion.fast,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.surfaceRaised,
                      borderRadius: BorderRadius.circular(NardRadius.m),
                      border:
                          widget.error
                              ? Border.all(color: c.dangerText, width: 1.5)
                              : i == active && _focus.hasFocus
                              ? Border.all(color: c.accent, width: 1.5)
                              : Border.all(
                                color: c.accent.withValues(alpha: .35),
                              ),
                    ),
                    child: Text(
                      i < text.length ? text[i] : '',
                      style: NardType.mono.copyWith(
                        fontSize: 28,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: c.accentHi,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                autofocus: widget.controller.text.isEmpty,
                enabled: widget.enabled,
                maxLength: 6,
                showCursor: false,
                autocorrect: false,
                enableSuggestions: false,
                enableInteractiveSelection: false,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z2-9]')),
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (v) {
                  widget.onChanged?.call(v);
                  if (v.length == 6) widget.onCompleted?.call(v.toUpperCase());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
