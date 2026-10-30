import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/data/app_settings.dart';
import 'package:nard_client/game/game_controller.dart';
import 'package:nard_client/game/game_presenter.dart';
import 'package:nard_client/game/match_setup.dart';
import 'package:nard_client/game/session.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_core/nard_core.dart';

const longSetup = MatchSetup(
  variant: Variant.longNard,
  opponent: OpponentKind.passAndPlay,
);

GamePresenter presenter(Session s, {bool rolling = false}) => GamePresenter(
  GameView(session: s, rolling: rolling),
  const AppSettings(),
  lookupAppLocalizations(const Locale('en')),
);

void main() {
  group('GamePresenter', () {
    test('the opening throw stays on the board until the first roll', () {
      var s = Session.start(longSetup).openingRoll(5, 3);
      expect(s.phase, GamePhase.awaitingRoll);
      final p = presenter(s);
      expect(p.scene().dice, [5, 3]);
      expect(p.banner().title, 'Player 1 starts');
      expect(p.banner().sub, 'Dice 5 – 3');

      s = s.roll(DiceRoll(6, 2));
      expect(presenter(s).scene().dice, [6, 2]);
    });

    test('a tap on an empty point shows no error', () {
      var s = Session.start(longSetup).openingRoll(5, 3);
      s = s.roll(DiceRoll(6, 2)).select(12);
      expect(s.rejection, MoveRejection.noChecker);
      final p = presenter(s);
      expect(p.rejectionText(), isNull);
      expect(p.banner().title, isNot('Illegal move'));
    });

    test('a real refusal still explains itself', () {
      var s = Session.start(longSetup).openingRoll(5, 3);
      s = s.roll(DiceRoll(6, 2));
      s = s.move(24, 18).select(24);
      expect(s.rejection, MoveRejection.headRule);
      expect(presenter(s).rejectionText(), isNotNull);
    });
  });
}
