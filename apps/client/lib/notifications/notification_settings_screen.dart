import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../social/social_providers.dart' show friendErrorText;
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'notification_models.dart';
import 'notification_providers.dart';
import 'push_registrar.dart';

/// 16.1 Notification settings (Ayarlar › Bildirişlər): push master switch,
/// quiet hours, one switch per category (notifications.md §2).
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final async = ref.watch(notificationSettingsProvider);
    final s = async.value;

    Future<void> change(
      NotificationSettings next,
      Map<String, Object?> fields,
    ) async {
      try {
        await ref
            .read(notificationSettingsProvider.notifier)
            .change(next, fields);
      } on Object catch (e) {
        if (context.mounted) showNote(context, friendErrorText(l, e));
      }
    }

    Widget body;
    if (s == null) {
      body =
          async.isLoading
              ? const Center(child: CircularProgressIndicator())
              : MessageState(
                title: l.errorTitle,
                body: l.authOffline,
                danger: true,
                action: l.retry,
                onAction: () => ref.invalidate(notificationSettingsProvider),
              );
    } else {
      Widget category(NotificationCategory cat, String label, [String? sub]) =>
          _Row(
            label: label,
            sub: sub,
            enabled: s.push,
            trailing: NardSwitch(
              value: s.isOn(cat),
              compact: true,
              semanticLabel: label,
              onChanged:
                  s.push
                      ? (v) => change(
                        s.copyWith(categories: {...s.categories, cat: v}),
                        {
                          'categories': {cat.api: v},
                        },
                      )
                      : null,
            ),
          );

      Future<void> togglePush(bool on) async {
        if (on) {
          // The OS has not been asked yet: explain first (16.3).
          final status = await ref.read(pushRegistrarProvider).status();
          if (status == PushStatus.notDetermined && context.mounted) {
            await context.push('/push-prompt');
          }
        }
        await change(s.copyWith(push: on), {'push': on});
      }

      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _Group(
            title: l.settingsGroupGeneral,
            rows: [
              _Row(
                label: l.notifPush,
                sub: s.pushAvailable ? null : l.notifPushUnavailable,
                trailing: NardSwitch(
                  value: s.push,
                  compact: true,
                  semanticLabel: l.notifPush,
                  onChanged: togglePush,
                ),
              ),
              _Row(
                label: l.notifQuietHours,
                enabled: s.push,
                onTap:
                    s.push
                        ? () async {
                          final next = await showQuietHoursSheet(context, s);
                          if (next == null) return;
                          await change(next, {
                            'quietHours': {
                              'enabled': next.quietEnabled,
                              'start': next.quietStart,
                              'end': next.quietEnd,
                            },
                          });
                        }
                        : null,
                trailing: _Value(
                  s.quietEnabled
                      ? l.notifQuietRange(s.quietStart, s.quietEnd)
                      : l.notifQuietOff,
                ),
              ),
            ],
          ),
          _Group(
            title: l.notifGroupGame,
            rows: [
              category(NotificationCategory.gameInvites, l.notifGameInvites),
            ],
          ),
          _Group(
            title: l.notifGroupTournament,
            rows: [
              category(
                NotificationCategory.tournamentStart,
                l.notifTournamentStart,
                l.notifTournamentStartSub(15),
              ),
              category(
                NotificationCategory.tournamentRound,
                l.notifRoundReady,
                l.notifRoundReadySub,
              ),
            ],
          ),
          _Group(
            title: l.notifGroupSocial,
            rows: [
              category(
                NotificationCategory.friendRequests,
                l.notifFriendRequests,
              ),
              category(NotificationCategory.clan, l.notifClanInvites),
              category(NotificationCategory.clanWar, l.notifClanWars),
            ],
          ),
          _Group(
            title: l.notifGroupRewards,
            rows: [
              category(NotificationCategory.rewards, l.notifSeasonResults),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(bare: true, title: l.notifTitle),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Overline(title, color: c.text.withValues(alpha: .55)),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: c.text.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(NardRadius.l),
              border: Border.all(color: c.accent.withValues(alpha: .14)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border:
                          i == rows.length - 1
                              ? null
                              : Border(
                                bottom: BorderSide(
                                  color: c.accent.withValues(alpha: .08),
                                ),
                              ),
                    ),
                    child: rows[i],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 16.1 row: min-height 46, label 15, optional 12 subtitle.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.trailing,
    this.sub,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final String? sub;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final content = Opacity(
      opacity: enabled ? 1 : .5,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: NardType.body.copyWith(fontSize: 15, color: c.text),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      sub!,
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: c.text.withValues(alpha: .55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
    return onTap == null
        ? content
        : Pressable(onTap: onTap, semanticLabel: label, child: content);
  }
}

class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: NardType.body.copyWith(
            fontSize: 14,
            color: c.text.withValues(alpha: .6),
            fontFeatures: tabular,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          LucideIcons.chevronRight,
          size: 14,
          color: c.text.withValues(alpha: .5),
        ),
      ],
    );
  }
}

/// Quiet hours (16.1 "Sakit saatlar"): on/off and whole-hour bounds.
Future<NotificationSettings?> showQuietHoursSheet(
  BuildContext context,
  NotificationSettings s,
) => showNardSheet<NotificationSettings>(
  context,
  builder: (_) => _QuietHoursSheet(initial: s),
);

class _QuietHoursSheet extends StatefulWidget {
  const _QuietHoursSheet({required this.initial});

  final NotificationSettings initial;

  @override
  State<_QuietHoursSheet> createState() => _QuietHoursSheetState();
}

class _QuietHoursSheetState extends State<_QuietHoursSheet> {
  late var _on = widget.initial.quietEnabled;
  late var _start = _hour(widget.initial.quietStart);
  late var _end = _hour(widget.initial.quietEnd);

  static int _hour(String hm) => (int.tryParse(hm.split(':').first) ?? 0) % 24;

  static String _hm(int h) => '${h.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    Widget stepper(String label, int value, ValueChanged<int> set) => Opacity(
      opacity: _on ? 1 : .5,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: NardType.body.copyWith(fontSize: 15, color: c.text),
            ),
          ),
          NardIconButton(
            icon: LucideIcons.chevronLeft,
            semanticLabel: l.notifEarlierHour,
            onPressed: _on ? () => set((value + 23) % 24) : null,
          ),
          SizedBox(
            width: 64,
            child: Text(
              _hm(value),
              textAlign: TextAlign.center,
              style: NardType.labelM.copyWith(
                color: c.accentHi,
                fontFeatures: tabular,
              ),
            ),
          ),
          NardIconButton(
            icon: LucideIcons.chevronRight,
            semanticLabel: l.notifLaterHour,
            onPressed: _on ? () => set((value + 1) % 24) : null,
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.notifQuietHours),
        const SizedBox(height: 6),
        Text(
          l.notifQuietBody,
          style: NardType.bodyS.copyWith(color: c.text.withValues(alpha: .7)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                l.notifQuietHours,
                style: NardType.body.copyWith(fontSize: 15, color: c.text),
              ),
            ),
            NardSwitch(
              value: _on,
              compact: true,
              semanticLabel: l.notifQuietHours,
              onChanged: (v) => setState(() => _on = v),
            ),
          ],
        ),
        stepper(l.notifQuietFrom, _start, (v) => setState(() => _start = v)),
        stepper(l.notifQuietTo, _end, (v) => setState(() => _end = v)),
        const SizedBox(height: 12),
        NardButton(
          label: l.notifQuietSave,
          onPressed:
              () => Navigator.of(context).pop(
                widget.initial.copyWith(
                  quietEnabled: _on,
                  quietStart: _hm(_start),
                  quietEnd: _hm(_end),
                ),
              ),
        ),
      ],
    );
  }
}
