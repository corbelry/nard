import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/pressable.dart';
import 'live_notifications.dart';
import 'notification_models.dart';
import 'notification_providers.dart';
import 'notification_text.dart';

/// Shows live notifications (ADR-049) as a banner over every screen
/// (notifications.md §8, inferred: the design has no in-app toast). Tap
/// opens the row's link (as in 16.2), swipe up or × dismisses, and it hides
/// itself after [visibleFor]. Nothing is shown during a game or on
/// full-screen flows ([quietPaths]); the row is in the inbox either way.
class LiveBannerHost extends ConsumerStatefulWidget {
  const LiveBannerHost({
    super.key,
    required this.router,
    required this.child,
    this.visibleFor = const Duration(seconds: 5),
  });

  final GoRouter router;
  final Widget child;
  final Duration visibleFor;

  /// Screens a banner would interrupt.
  static const quietPaths = {
    '/game',
    '/online/vs',
    '/online/fair',
    '/splash',
    '/language',
    '/onboarding',
    '/lesson',
    '/push-prompt',
    '/levelup',
    '/notifications',
  };

  @override
  ConsumerState<LiveBannerHost> createState() => _LiveBannerHostState();
}

class _LiveBannerHostState extends ConsumerState<LiveBannerHost> {
  AppNotification? _shown;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AppNotification?>(liveNotificationsProvider, (_, next) {
      if (next != null) _show(next);
    });
  }

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  String get _path {
    try {
      return widget.router.routerDelegate.currentConfiguration.uri.path;
    } on Object {
      return '';
    }
  }

  void _show(AppNotification n) {
    if (LiveBannerHost.quietPaths.contains(_path)) {
      ref.read(liveNotificationsProvider.notifier).dismiss();
      return;
    }
    _hide?.cancel();
    _hide = Timer(widget.visibleFor, _dismiss);
    setState(() => _shown = n);
  }

  void _dismiss() {
    _hide?.cancel();
    if (!mounted) return;
    setState(() => _shown = null);
    ref.read(liveNotificationsProvider.notifier).dismiss();
  }

  void _open(AppNotification n) {
    _dismiss();
    ref.read(inboxProvider.notifier).markRead(n.id).ignore();
    final link = notificationLink(n);
    if (link == null) return;
    if (n.type == NotificationType.challenge) {
      if (!challengeOpen(n, DateTime.now())) return;
      joinChallenge(ref, n);
    }
    link.go ? widget.router.go(link.path) : widget.router.push(link.path);
  }

  @override
  Widget build(BuildContext context) {
    final n = _shown;
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: NardMotion.sheetIn,
              reverseDuration: NardMotion.sheetOut,
              switchInCurve: NardMotion.standard,
              transitionBuilder:
                  (child, animation) => SlideTransition(
                    position: Tween(
                      begin: const Offset(0, -1.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
              child:
                  n == null
                      ? const SizedBox.shrink()
                      : Dismissible(
                        key: ValueKey('live-${n.id}'),
                        direction: DismissDirection.up,
                        onDismissed: (_) => _dismiss(),
                        child: LiveBanner(
                          notification: n,
                          onTap: () => _open(n),
                          onClose: _dismiss,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The banner card: the 16.2 row (icon disc, bold who + text) on a raised
/// floating surface with a close button.
class LiveBanner extends StatelessWidget {
  const LiveBanner({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onClose,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final n = notification;
    final line = notificationLine(
      l,
      Localizations.localeOf(context).languageCode,
      n,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NardSpace.screenGutter,
        NardSpace.s2,
        NardSpace.screenGutter,
        0,
      ),
      child: Semantics(
        liveRegion: true,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: c.surfaceRaised,
              borderRadius: BorderRadius.circular(c.cardRadius),
              border: Border.all(color: c.accent.withValues(alpha: .3)),
              boxShadow: c.elevation2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Pressable(
                    onTap: onTap,
                    semanticLabel: '${line.who} ${line.text}',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        NardSpace.s3 + 2,
                        NardSpace.s3,
                        0,
                        NardSpace.s3,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.pillFill,
                              border: Border.all(
                                color: c.accent.withValues(alpha: .3),
                              ),
                            ),
                            child: Icon(
                              notificationIcon(n.type),
                              size: 18,
                              color: notificationIconColor(c, n.type),
                            ),
                          ),
                          const SizedBox(width: NardSpace.s3),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  if (line.who.isNotEmpty)
                                    TextSpan(
                                      text: '${line.who} ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  TextSpan(text: line.text),
                                ],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: NardType.body.copyWith(
                                fontSize: 14,
                                height: 19 / 14,
                                color: c.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Pressable(
                  onTap: onClose,
                  semanticLabel: l.close,
                  child: SizedBox(
                    width: NardSpace.hitMin,
                    height: NardSpace.hitMin,
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: c.text.withValues(alpha: .6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
