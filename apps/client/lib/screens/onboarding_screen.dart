import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_core/nard_core.dart';

import '../app/providers.dart';
import '../board/board_preview.dart';
import '../board/board_scene.dart';
import '../l10n/gen/app_localizations.dart';
import '../screens/lesson_screen.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';

enum _Choice { short, long, learn }

/// 9.3 "Which nard do you play?" (offline flow: step 2 of 2).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Choice _choice = _Choice.short;

  Future<void> _continue() async {
    final variant =
        _choice == _Choice.long ? Variant.longNard : Variant.shortNard;
    await ref
        .read(settingsProvider.notifier)
        .change(
          (s) => s.copyWith(preferredVariant: variant, onboardingDone: true),
        );
    if (!mounted) return;
    context.go('/home');
    if (_choice == _Choice.learn) await context.push('/lesson');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    Widget card(_Choice choice, String title, String desc, Variant? preview) {
      final selected = _choice == choice;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SelectableCard(
          selected: selected,
          radius: 18,
          padding: EdgeInsets.zero,
          onTap: () => setState(() => _choice = choice),
          child: AnimatedSize(
            duration: NardMotion.sheetIn,
            curve: NardMotion.standard,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (selected && preview != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Center(
                      child: SizedBox(
                        width: 240,
                        child: BoardPreview(
                          scene: BoardScene(
                            rules: rulesFor(preview),
                            viewer: Side.white,
                            board: rulesFor(preview).initialState(),
                            cubeVisible: preview == Variant.shortNard,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: NardType.title.copyWith(color: c.text),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        desc,
                        style: NardType.bodyS.copyWith(color: c.textDim),
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

    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                  children: [
                    Overline(
                      l.onboardingStep(2, 2),
                      color: c.accent,
                      spacing: .96,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.variantQuestionTitle,
                      style: NardType.displayL.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 24),
                    card(
                      _Choice.short,
                      l.variantShort,
                      l.variantShortDesc,
                      Variant.shortNard,
                    ),
                    card(
                      _Choice.long,
                      l.variantLong,
                      l.variantLongDesc,
                      Variant.longNard,
                    ),
                    card(
                      _Choice.learn,
                      l.variantLearnTitle,
                      l.variantLearnDesc(LessonScreen.stepCount),
                      null,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: NardButton(
                  label: l.continueAction,
                  onPressed: _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
