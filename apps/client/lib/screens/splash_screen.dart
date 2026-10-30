import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/controls.dart';

/// 9.1 Splash: brand while settings load, then onboarding or home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  Future<void> _boot() async {
    final started = DateTime.now();
    final settings = await ref.read(settingsProvider.future);
    final wait =
        const Duration(milliseconds: 700) - DateTime.now().difference(started);
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    if (!mounted) return;
    if (settings.onboardingDone) {
      context.go('/home');
    } else if (settings.locale == null) {
      context.go('/language');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.1),
            radius: 1.0,
            colors: [Color(0xFF4A321F), Color(0xFF2B1D14), Color(0xFF120C08)],
            stops: [0, .55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback:
                    (r) => const RadialGradient(
                      center: Alignment(0, -.1),
                      radius: .6,
                      colors: [Colors.white, Colors.transparent],
                    ).createShader(r),
                child: CustomPaint(
                  painter: LatticePainter(
                    color: c.accent.withValues(alpha: .06),
                    spacing: 22,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: pi / 4,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border.all(color: c.accent, width: 6),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 16,
                        height: 16,
                        color: c.accentHi,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Nard',
                          style: NardType.displayXl.copyWith(
                            height: 1,
                            color: c.text,
                          ),
                        ),
                        TextSpan(
                          text: 'Arena',
                          style: NardType.displayXl.copyWith(
                            height: 1,
                            color: c.accent,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Center(
                child: SizedBox(width: 120, child: _IndeterminateBar()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndeterminateBar extends StatelessWidget {
  const _IndeterminateBar();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: .1, end: 1),
    duration: const Duration(milliseconds: 700),
    curve: NardMotion.outCubic,
    builder: (_, v, _) => NardProgressBar(value: v, height: 3),
  );
}
