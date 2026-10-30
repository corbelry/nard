import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart';
import '../social/social_providers.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'notification_models.dart';
import 'notification_providers.dart';
import 'notification_text.dart';

/// 16.2 Inbox: filter chips, rows grouped by day, inline actions for
/// friend requests and game invites; a tap opens the related screen.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  var _tab = InboxTab.all;
  final _busy = <int>{};

  @override
  void initState() {
    super.initState();
    // Catch up at once when opened from the bell.
    Future.microtask(() async {
      try {
        await ref.read(inboxProvider.notifier).poll();
      } on Object {
        // The list shows what it has; errors surface on a full reload.
      }
    });
  }

  Future<void> _guard(int id, Future<void> Function() action) async {
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      await action();
    } on Object catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context);
        showNote(
          context,
          e is ApiException && e.status == 404
              ? l.notifGone
              : friendErrorText(l, e),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Future<void> _open(AppNotification n) async {
    final inbox = ref.read(inboxProvider.notifier);
    if (!n.read) {
      inbox.markRead(n.id).ignore();
    }
    final link = notificationLink(n);
    if (link == null) return;
    if (n.type == NotificationType.challenge) {
      if (!challengeOpen(n, DateTime.now())) {
        showNote(context, AppLocalizations.of(context).notifGone);
        return;
      }
      joinChallenge(ref, n);
    }
    if (link.go) {
      context.go(link.path);
    } else {
      await context.push(link.path);
    }
  }

  /// Accept (true) or decline a request / invite, then drop the row.
  Future<void> _answer(AppNotification n, bool accept) =>
      _guard(n.id, () async {
        final inbox = ref.read(inboxProvider.notifier);
        switch (n.type) {
          case NotificationType.friendRequest:
            final friends = ref.read(friendsProvider.notifier);
            final id = n.number('requestId');
            try {
              await (accept ? friends.accept(id) : friends.dismiss(id));
            } on ApiException catch (e) {
              if (e.status != 404) rethrow;
              await inbox.remove(n.id);
              rethrow;
            }
            await inbox.remove(n.id);
          case NotificationType.challenge:
            if (accept) {
              await inbox.markRead(n.id);
              if (mounted) await _open(n);
            } else {
              await inbox.remove(n.id);
            }
          default:
            break;
        }
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final inbox = ref.watch(inboxProvider);
    final page = inbox.value;
    final unread = page?.unread ?? 0;
    final now = DateTime.now();
    final items = [
      for (final n in page?.items ?? const <AppNotification>[])
        if (_tab == InboxTab.all || n.tab == _tab) n,
    ];

    Widget body;
    if (page == null && inbox.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (page == null) {
      body = MessageState(
        title: l.errorTitle,
        body: l.authOffline,
        danger: true,
        action: l.retry,
        onAction: () => ref.invalidate(inboxProvider),
      );
    } else if (items.isEmpty) {
      body = MessageState(title: l.notifEmptyTitle, body: l.notifEmptyBody);
    } else {
      final groups = <String, List<AppNotification>>{};
      for (final n in items) {
        groups.putIfAbsent(dayLabel(l, n.createdAt, now), () => []).add(n);
      }
      body = RefreshIndicator(
        onRefresh: () => ref.read(inboxProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (final g in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Overline(g.key, color: c.text.withValues(alpha: .55)),
              ),
              for (final n in g.value)
                _InboxRow(
                  n: n,
                  now: now,
                  busy: _busy.contains(n.id),
                  onTap: () => _open(n),
                  onAnswer: (accept) => _answer(n, accept),
                ),
            ],
          ],
        ),
      );
    }

    String tabName(InboxTab t) => switch (t) {
      InboxTab.all => l.notifTabAll,
      InboxTab.game => l.notifTabGame,
      InboxTab.social => l.notifTabSocial,
      InboxTab.tournament => l.notifTabTournament,
    };

    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                bare: true,
                title: l.notifTitle,
                trailing:
                    unread == 0
                        ? null
                        : Pressable(
                          onTap: () async {
                            try {
                              await ref
                                  .read(inboxProvider.notifier)
                                  .markAllRead();
                            } on Object catch (e) {
                              if (context.mounted) {
                                showNote(context, friendErrorText(l, e));
                              }
                            }
                          },
                          semanticLabel: l.notifReadAll,
                          child: Center(
                            child: Text(
                              l.notifReadAll,
                              style: NardType.body.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: c.accentHi,
                              ),
                            ),
                          ),
                        ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    for (final t in InboxTab.values) ...[
                      if (t != InboxTab.all) const SizedBox(width: 8),
                      NardChoiceChip(
                        label: tabName(t),
                        selected: _tab == t,
                        onTap: () => setState(() => _tab = t),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// "BU GÜN" / "DÜNƏN" / "ƏVVƏL".
String dayLabel(AppLocalizations l, DateTime at, DateTime now) {
  final day = DateTime(at.year, at.month, at.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  return diff <= 0
      ? l.notifToday
      : diff == 1
      ? l.notifYesterday
      : l.notifEarlier;
}

/// "indi", "18 dəq", "1 saat", "Dünən 21:04", "12.10 14:30".
String timeLabel(AppLocalizations l, String locale, DateTime at, DateTime now) {
  final ago = now.difference(at);
  final hm = DateFormat('HH:mm', locale).format(at);
  return switch (dayLabel(l, at, now)) {
    final d when d == l.notifToday =>
      ago.inMinutes < 1
          ? l.notifNow
          : ago.inMinutes < 60
          ? l.notifMinutesAgo(ago.inMinutes)
          : l.notifHoursAgo(ago.inHours),
    final d when d == l.notifYesterday => l.notifYesterdayAt(hm),
    _ => '${DateFormat('dd.MM', locale).format(at)} $hm',
  };
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({
    required this.n,
    required this.now,
    required this.busy,
    required this.onTap,
    required this.onAnswer,
  });

  final AppNotification n;
  final DateTime now;
  final bool busy;
  final VoidCallback onTap;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final locale = Localizations.localeOf(context).languageCode;
    final line = notificationLine(l, locale, n);
    final actions = switch (n.type) {
      NotificationType.friendRequest => (l.friendAccept, l.notifDelete),
      NotificationType.challenge when challengeOpen(n, now) => (
        l.friendAccept,
        l.friendDismiss,
      ),
      _ => null,
    };
    return Pressable(
      onTap: onTap,
      semanticLabel: '${line.who} ${line.text}',
      child: Container(
        color: n.read ? null : c.unreadRow,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.pillFill,
                border: Border.all(color: c.accent.withValues(alpha: .3)),
              ),
              child: Icon(
                notificationIcon(n.type),
                size: 18,
                color: notificationIconColor(c, n.type),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        if (line.who.isNotEmpty)
                          TextSpan(
                            text: '${line.who} ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        TextSpan(text: line.text),
                      ],
                    ),
                    style: NardType.body.copyWith(
                      fontSize: 14,
                      height: 19 / 14,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel(l, locale, n.createdAt, now),
                    style: NardType.caption.copyWith(
                      fontWeight: FontWeight.w400,
                      color: c.text.withValues(alpha: .5),
                      fontFeatures: tabular,
                    ),
                  ),
                  if (actions != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PillButton(
                          label: actions.$1,
                          solid: true,
                          onTap: busy ? null : () => onAnswer(true),
                        ),
                        const SizedBox(width: 8),
                        _PillButton(
                          label: actions.$2,
                          onTap: busy ? null : () => onAnswer(false),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: n.read ? Colors.transparent : c.dangerText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 16.2 row action: pill h 32, padding h 14, 13 w600.
class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, this.onTap, this.solid = false});

  final String label;
  final VoidCallback? onTap;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      minSize: 32,
      child: Opacity(
        opacity: onTap == null ? .5 : 1,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: solid ? c.accent : null,
            borderRadius: BorderRadius.circular(NardRadius.pill),
            border:
                solid
                    ? null
                    : Border.all(color: c.accent.withValues(alpha: .3)),
          ),
          child: Text(
            label,
            style: NardType.bodyS.copyWith(
              fontWeight: FontWeight.w600,
              color: solid ? c.onAccent : c.text,
            ),
          ),
        ),
      ),
    );
  }
}
