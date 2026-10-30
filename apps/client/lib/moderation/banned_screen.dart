import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/layout.dart';
import 'moderation.dart';

/// Full-screen banned state (ADR-042): when the ban ends, the reason, the
/// support address and a sign-out button. Shown above the whole app (no
/// navigator needed), so it also covers a refused sign-in.
class BannedScreen extends ConsumerStatefulWidget {
  const BannedScreen({super.key, required this.ban, this.onSignedOut});

  final AccountBan ban;

  /// Called after signing out (the app goes back to Home, offline).
  final VoidCallback? onSignedOut;

  @override
  ConsumerState<BannedScreen> createState() => _BannedScreenState();
}

class _BannedScreenState extends ConsumerState<BannedScreen> {
  Timer? _tick;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Re-check once a minute whether a temporary ban ran out.
    if (!widget.ban.permanent) {
      _tick = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(banProvider.notifier).signOut();
      widget.onSignedOut?.call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final until = widget.ban.until;
    final over = until != null && !until.isAfter(DateTime.now());
    final bottom = MediaQuery.paddingOf(context).bottom;
    final body =
        over
            ? l.bannedOverBody
            : [
              until == null
                  ? l.bannedBodyPermanent
                  : l.bannedBodyUntil(
                    formatModerationTime(until, l.localeName),
                  ),
              l.bannedContact(kSupportEmail),
            ].join('\n\n');
    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: NardSpace.s6),
                    child: MessageState(
                      title: over ? l.bannedOverTitle : l.bannedTitle,
                      body: body,
                      danger: !over,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  NardSpace.screenGutter,
                  0,
                  NardSpace.screenGutter,
                  max(NardSpace.s6, bottom + NardSpace.s2),
                ),
                child: Column(
                  children: [
                    if (!over) ...[
                      Text(
                        l.bannedOffline,
                        textAlign: TextAlign.center,
                        style: NardType.caption.copyWith(
                          fontWeight: FontWeight.w400,
                          color: c.textDim,
                        ),
                      ),
                      const SizedBox(height: NardSpace.s3),
                    ],
                    if (over)
                      NardButton(
                        label: l.bannedContinue,
                        onPressed: ref.read(banProvider.notifier).resume,
                      )
                    else
                      NardButton(
                        label: l.accountSignOut,
                        variant: NardButtonVariant.outline,
                        onPressed: _busy ? null : _signOut,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Covers [child] (the app's navigator, kept alive underneath) with the
/// [BannedScreen] while [banProvider] holds a ban. Sits in
/// `MaterialApp.builder`.
class BannedGate extends ConsumerWidget {
  const BannedGate({super.key, required this.child, this.onSignedOut});

  final Widget child;
  final VoidCallback? onSignedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ban = ref.watch(banProvider);
    return Stack(
      children: [
        // Unfocusable and silent while banned, so nothing underneath
        // reacts to keys or screen readers; the screen takes the taps.
        ExcludeFocus(
          excluding: ban != null,
          child: ExcludeSemantics(
            excluding: ban != null,
            child: TickerMode(enabled: ban == null, child: child),
          ),
        ),
        if (ban != null)
          Positioned.fill(
            child: BannedScreen(
              key: ValueKey(ban.until),
              ban: ban,
              onSignedOut: onSignedOut,
            ),
          ),
      ],
    );
  }
}
