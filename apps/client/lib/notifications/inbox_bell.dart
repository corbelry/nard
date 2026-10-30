import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/pressable.dart';
import 'notification_models.dart';
import 'notification_providers.dart';
import 'push_prompt_screen.dart';
import 'push_registrar.dart';

/// Home header bell with the unread badge (notifications.md §1). While it
/// is on screen it polls the inbox every [interval] and on app resume,
/// registers the push token, opens tapped pushes and shows 16.3 once.
class InboxBell extends ConsumerStatefulWidget {
  const InboxBell({super.key, this.interval = const Duration(seconds: 60)});

  final Duration interval;

  @override
  ConsumerState<InboxBell> createState() => _InboxBellState();
}

class _InboxBellState extends ConsumerState<InboxBell> {
  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  final _subs = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) => _poll());
    _lifecycle = AppLifecycleListener(onResume: _poll);
    final registrar = ref.read(pushRegistrarProvider);
    _subs
      ..add(registrar.opened.listen(_openPush))
      ..add(registrar.tokenRefresh.listen((_) => _syncDevice()));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _syncDevice();
      if (!mounted) return;
      await maybeShowPushPrompt(context, ref, (p) => context.push(p));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      await ref.read(inboxProvider.notifier).poll();
    } on Object {
      // Offline: the next tick retries.
    }
  }

  Future<void> _syncDevice() async {
    try {
      await syncPushDevice(
        ref.read(apiClientProvider),
        ref.read(pushRegistrarProvider),
        Localizations.localeOf(context).languageCode,
      );
    } on Object {
      // Registered again on the next start.
    }
  }

  void _openPush(PushOpen push) {
    final decoded = push.data.isEmpty ? null : jsonDecode(push.data);
    final n = AppNotification(
      id: push.id,
      type: NotificationType.parse(push.type),
      data: decoded is Map<String, Object?> ? decoded : const {},
      createdAt: DateTime.now(),
    );
    ref.read(inboxProvider.notifier).markRead(n.id).ignore();
    final link = notificationLink(n);
    if (link == null || !mounted) return;
    if (n.type == NotificationType.challenge) {
      if (!challengeOpen(n, DateTime.now())) return;
      joinChallenge(ref, n);
    }
    link.go ? context.go(link.path) : context.push(link.path);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final unread = ref.watch(unreadCountProvider);
    return Pressable(
      onTap: () => context.push('/notifications'),
      semanticLabel: l.notifBellLabel(unread),
      child: SizedBox(
        width: NardSpace.hitMin,
        height: NardSpace.hitMin,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(LucideIcons.bell, size: 22, color: c.text)),
            if (unread > 0)
              Positioned(
                top: 6,
                right: 4,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.dangerText,
                    borderRadius: BorderRadius.circular(NardRadius.pill),
                    border: Border.all(color: c.bg, width: 2),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: NardType.micro.copyWith(
                      fontSize: 10,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: c.onDanger,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
