// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NardArena';

  @override
  String get continueAction => 'Continue';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Try again';

  @override
  String get valueOn => 'On';

  @override
  String get valueOff => 'Off';

  @override
  String get variantShort => 'Short Nard';

  @override
  String get variantLong => 'Long Nard';

  @override
  String get variantShortUpper => 'SHORT NARD';

  @override
  String get variantLongUpper => 'LONG NARD';

  @override
  String matchToPointsUpper(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n POINTS',
      one: '1 POINT',
    );
    return 'TO $_temp0';
  }

  @override
  String get oneGameUpper => '1 GAME';

  @override
  String get tabHome => 'Home';

  @override
  String get tabProfile => 'Profile';

  @override
  String get playerWhite => 'White';

  @override
  String get playerBlack => 'Black';

  @override
  String get computerName => 'Computer';

  @override
  String get you => 'You';

  @override
  String get languageTitle => 'Choose language';

  @override
  String get languageSubtitle => 'Choose language · Выберите язык · Dil seçin';

  @override
  String get languageNameAz => 'Azərbaycanca';

  @override
  String get languageNameTr => 'Türkçe';

  @override
  String get languageNameRu => 'Русский';

  @override
  String get languageNameEn => 'English';

  @override
  String get languageSubAz => 'Azerbaijani';

  @override
  String get languageSubTr => 'Turkish';

  @override
  String get languageSubRu => 'Russian';

  @override
  String get languageSubEn => 'English';

  @override
  String onboardingStep(int current, int total) {
    return 'STEP $current / $total';
  }

  @override
  String get variantQuestionTitle => 'Which nard do you play?';

  @override
  String get variantShortDesc => 'Classic backgammon: hitting, the bar, the doubling cube.';

  @override
  String get variantLongDesc => 'All checkers start on the head. No hitting, only blocking.';

  @override
  String get variantLearnTitle => 'I want to learn';

  @override
  String variantLearnDesc(int steps) {
    return '$steps-step interactive lesson, 5 minutes.';
  }

  @override
  String get lessonSkip => 'Skip';

  @override
  String lessonProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get lessonStep1Title => 'This is your board';

  @override
  String get lessonStep1Body => 'The white checkers are yours. They move from point 24 towards point 1, then are borne off the board. Tap any checker to continue.';

  @override
  String get lessonStep2Title => 'Move a checker 6 points';

  @override
  String get lessonStep2Body => 'The die shows 6. Tap the checker on point 13, then tap or drag it to the highlighted point 7.';

  @override
  String get lessonStep3Title => 'Play both dice';

  @override
  String get lessonStep3Body => 'The dice show 3 and 1. Move checkers from points 8 and 6 to point 5 and make the point.';

  @override
  String get lessonStep4Title => 'Blocked point';

  @override
  String get lessonStep4Body => 'You can\'t move to a point that holds two or more of your opponent\'s checkers. The die shows 5: move the checker from point 13 to point 8.';

  @override
  String get lessonStep5Title => 'Hitting';

  @override
  String get lessonStep5Body => 'Land on a lone opponent checker and you send it to the bar. Move the checker from point 6 to point 4 and hit.';

  @override
  String get lessonStep6Title => 'Entering from the bar';

  @override
  String get lessonStep6Body => 'If you have a checker on the bar, you must enter it into your opponent\'s home first. Tap the checker on the bar and move it to point 22.';

  @override
  String get lessonStep7Title => 'Bear off your checkers';

  @override
  String get lessonStep7Body => 'All your checkers are home (1–6). The die shows 6: bear off the checker on point 6.';

  @override
  String get lessonDoneTitle => 'Well done, you\'re ready';

  @override
  String get lessonDoneBody => 'You know the rules. Now practice against the computer.';

  @override
  String get lessonFinish => 'Start playing';

  @override
  String get homePlay => 'Play';

  @override
  String get homeChangeMode => 'Change mode';

  @override
  String homeOtherVariant(String variant) {
    return '$variant →';
  }

  @override
  String homeHeroMeta(String variant, String format) {
    return '$variant · $format';
  }

  @override
  String homeHeroMode(String level) {
    return 'Vs computer · $level';
  }

  @override
  String get modeComputer => 'Computer';

  @override
  String get modeSameDevice => 'Same device';

  @override
  String get modeLesson => 'Lesson';

  @override
  String get modeReplays => 'My games';

  @override
  String get setupTitle => 'New game';

  @override
  String get setupVariantLabel => 'VARIANT';

  @override
  String get setupFormatLabel => 'FORMAT';

  @override
  String get formatOneGame => '1 game';

  @override
  String formatPoints(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String get setupCube => 'Doubling cube';

  @override
  String get aiTitle => 'Vs computer';

  @override
  String get aiLevelBeginner => 'Beginner';

  @override
  String get aiLevelAmateur => 'Amateur';

  @override
  String get aiLevelMedium => 'Intermediate';

  @override
  String get aiLevelStrong => 'Strong';

  @override
  String get aiLevelMaster => 'Master';

  @override
  String get aiLevelGrandmaster => 'Grandmaster';

  @override
  String get aiLevelBeginnerDesc => 'For those learning the rules';

  @override
  String get aiLevelAmateurDesc => 'Makes simple mistakes';

  @override
  String get aiLevelMediumDesc => 'Knows the basic strategy';

  @override
  String get aiLevelStrongDesc => 'Rare mistakes, handles the cube well';

  @override
  String get aiLevelMasterDesc => 'Club player level';

  @override
  String get aiLevelGrandmasterDesc => 'Strongest mode, makes no mistakes';

  @override
  String aiStart(String level) {
    return 'Start · $level';
  }

  @override
  String get hotseatTitle => 'Same device';

  @override
  String get hotseatWhite => 'White checkers';

  @override
  String get hotseatBlack => 'Black checkers';

  @override
  String get hotseatGameSection => 'GAME';

  @override
  String get hotseatHideBetweenTurns => 'Hide screen between turns';

  @override
  String get hotseatHideBetweenTurnsSub => '“Pass the phone to your opponent” screen';

  @override
  String get hotseatFlipBoard => 'Flip the board';

  @override
  String get hotseatFlipBoardSub => 'Towards the next player every turn';

  @override
  String get hotseatAllowUndo => 'Allow undo';

  @override
  String get hotseatAllowUndoSub => 'Until the opponent is ready';

  @override
  String get hotseatStart => 'Start game';

  @override
  String get hotseatEditName => 'Edit name';

  @override
  String get hotseatNameHint => 'Player name';

  @override
  String get hotseatDefaultWhite => 'Player 1';

  @override
  String get hotseatDefaultBlack => 'Player 2';

  @override
  String get handoffOverline => 'TURN CHANGED';

  @override
  String handoffTitle(String name) {
    return 'Over to $name';
  }

  @override
  String handoffBody(String side, String prevName, String moves) {
    return '$side. $prevName played $moves.';
  }

  @override
  String handoffBodyNoMove(String side, String prevName) {
    return '$side. $prevName couldn\'t move.';
  }

  @override
  String handoffFirst(String side) {
    return '$side. You start the game.';
  }

  @override
  String handoffReady(String name) {
    return '$name, I\'m ready';
  }

  @override
  String handoffUndo(String prevName) {
    return '$prevName: undo move';
  }

  @override
  String gameModeTo(String variant, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '$variant · to $_temp0';
  }

  @override
  String gameModeSingle(String variant) {
    return '$variant · 1 game';
  }

  @override
  String gameScore(int me, int opp) {
    return '$me – $opp';
  }

  @override
  String get bannerYourTurn => 'Your turn';

  @override
  String bannerTurnOf(String name) {
    return '$name to play';
  }

  @override
  String get bannerRollHint => 'Roll or offer a double';

  @override
  String bannerLegalMoveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count legal moves',
      one: '1 legal move',
    );
    return '$_temp0';
  }

  @override
  String get bannerRolling => 'Rolling the dice';

  @override
  String get bannerOpening => 'Who starts?';

  @override
  String get bannerOpeningTie => 'Tie · rolling again';

  @override
  String bannerOpeningWinner(String name) {
    return '$name starts';
  }

  @override
  String get bannerOpponentThinking => 'Opponent is thinking';

  @override
  String bannerDice(int a, int b) {
    return 'Dice $a – $b';
  }

  @override
  String get bannerCubeOffer => 'Double offered';

  @override
  String get bannerCubeWaiting => 'Waiting for an answer';

  @override
  String get bannerNoMoves => 'No moves';

  @override
  String get bannerGameOver => 'Game over';

  @override
  String get bannerHeadRuleHint => 'Only one checker from the head';

  @override
  String get bannerIllegalMove => 'Illegal move';

  @override
  String get bannerOpponentNeedsOne => 'Opponent needs 1 point';

  @override
  String get bannerYouNeedOne => 'You need 1 point';

  @override
  String get crawfordChip => 'Crawford game · no cube';

  @override
  String get actionRoll => 'Roll';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String actionMovesProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get actionPass => 'Pass';

  @override
  String get actionNextGame => 'Next game';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionDouble => 'Double';

  @override
  String get actionMenu => 'Menu';

  @override
  String playerPip(int pip) {
    return 'Pip $pip';
  }

  @override
  String playerBotLevel(String level) {
    return 'Computer · $level';
  }

  @override
  String get noMovesTitle => 'No legal moves';

  @override
  String noMovesBody(int a, int b, String reason) {
    return '$a – $b · $reason. The turn passes to your opponent in 2 seconds.';
  }

  @override
  String get noMovesReasonBar => 'entry from the bar is blocked';

  @override
  String get noMovesReasonBlocked => 'every path is blocked';

  @override
  String cubeOfferTitle(String name) {
    return '$name offers a double';
  }

  @override
  String cubeOfferBody(int from, int to) {
    return 'The game is worth $from → $to points. If you accept, the cube passes to you.';
  }

  @override
  String get cubeDecline => 'Decline';

  @override
  String cubeDeclineSub(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '−$_temp0, game ends';
  }

  @override
  String get cubeAccept => 'Accept';

  @override
  String cubeAcceptSub(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return 'Worth $_temp0';
  }

  @override
  String cubeBotTook(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return 'The computer took the double · worth $_temp0';
  }

  @override
  String get gameWonTitle => 'VICTORY';

  @override
  String get gameLostTitle => 'DEFEAT';

  @override
  String gameWinnerTitle(String name) {
    return '$name WINS';
  }

  @override
  String resultSingle(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '+$_temp0';
  }

  @override
  String resultMars(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return 'Mars · +$_temp0';
  }

  @override
  String resultKoks(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return 'Koks · +$_temp0';
  }

  @override
  String resultDropped(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return 'Double declined · +$_temp0';
  }

  @override
  String resultResigned(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return 'Resigned · +$_temp0';
  }

  @override
  String gameMatchProgress(int target, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left points',
      one: '1 point',
    );
    return 'To $target points · $_temp0 left in the match';
  }

  @override
  String get actionViewReplay => 'Replay';

  @override
  String get matchWonTitle => 'Match won';

  @override
  String get matchLostTitle => 'Match lost';

  @override
  String matchWinnerTitle(String name) {
    return '$name wins the match';
  }

  @override
  String matchMeta(String me, String opp, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '$me · $opp · to $_temp0';
  }

  @override
  String matchMetaSingle(String me, String opp) {
    return '$me · $opp · 1 game';
  }

  @override
  String get matchRematch => 'Rematch';

  @override
  String get matchHome => 'Home';

  @override
  String get resignTitle => 'Resign';

  @override
  String resignBody(int cube) {
    return 'Cube value ×$cube. Choose how many points to give your opponent.';
  }

  @override
  String get resignSingle => 'Single game';

  @override
  String get resignSingleDesc => 'Ordinary loss';

  @override
  String get resignMars => 'Mars';

  @override
  String get resignMarsDesc => 'No checker borne off';

  @override
  String get resignKoks => 'Koks';

  @override
  String get resignKoksDesc => 'A checker on the bar or in the opponent\'s home';

  @override
  String get resignKoksDescLong => 'A checker hasn\'t left the opponent\'s home yet';

  @override
  String resignPoints(int points) {
    return '−$points';
  }

  @override
  String resignConfirm(int points) {
    return 'Resign · −$points';
  }

  @override
  String get menuResume => 'Back to game';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuRules => 'Rules';

  @override
  String get menuSound => 'Sound';

  @override
  String get menuResign => 'Resign';

  @override
  String get menuLeave => 'Leave game';

  @override
  String get leaveTitle => 'Leave the game?';

  @override
  String get leaveBody => 'This game won\'t be saved.';

  @override
  String get leaveConfirm => 'Leave';

  @override
  String get ruleHeadTitle => 'Only one checker may leave the head';

  @override
  String get ruleHeadBody => 'This turn you played more than one checker from the head. Exception: a 6-6, 4-4 or 3-3 on the first roll lets you take two.';

  @override
  String get ruleSixBlockTitle => 'You can\'t block 6 points in a row';

  @override
  String ruleSixBlockBody(String from, String to) {
    return 'The move $from → $to builds a 6-point block with no opponent checker ahead of it. Choose another move.';
  }

  @override
  String get rulePointClosedTitle => 'This point is blocked';

  @override
  String get rulePointClosedShort => 'You can\'t move to a point with two or more opponent checkers.';

  @override
  String get rulePointClosedLong => 'In Long Nard you can\'t move to a point with an opponent checker.';

  @override
  String get ruleBarTitle => 'Enter the checker from the bar first';

  @override
  String get ruleBarBody => 'While you have a checker on the bar, you can\'t move any other checker.';

  @override
  String get ruleBothDiceTitle => 'You must play both dice';

  @override
  String get ruleBothDiceBody => 'This move leaves no way to play the other die. Choose a move that uses both dice.';

  @override
  String get ruleLargerDieTitle => 'Play the larger die';

  @override
  String get ruleLargerDieBody => 'If only one die can be played, you must play the larger one.';

  @override
  String get ruleBearOffTitle => 'You can\'t bear off yet';

  @override
  String get ruleBearOffBody => 'To bear off, all your checkers must be home (1–6).';

  @override
  String get ruleBearOffHigherTitle => 'Play the checker on the higher point first';

  @override
  String get ruleBearOffHigherBody => 'With a larger die you can only bear off the checker on the highest point.';

  @override
  String get ruleNoDieTitle => 'No die for this distance';

  @override
  String get ruleNoDieBody => 'You can only move a checker by the number of points shown on the dice.';

  @override
  String get ruleNoCheckerTitle => 'You have no checker on this point';

  @override
  String get ruleTurnCompleteTitle => 'All dice have been played';

  @override
  String get ruleTurnCompleteBody => 'Confirm the move or undo it.';

  @override
  String get replayListTitle => 'My games';

  @override
  String get replayEmptyTitle => 'No games yet';

  @override
  String get replayEmptyBody => 'Games you finish will appear here. With Replay you can go through every move again.';

  @override
  String replayTitle(int n) {
    return 'Replay · Game $n';
  }

  @override
  String replayPlayers(String p1, String p2) {
    return '$p1 – $p2';
  }

  @override
  String get replayStart => 'Start';

  @override
  String get replayBack => 'Back';

  @override
  String get replayPlay => 'Play';

  @override
  String get replayPause => 'Pause';

  @override
  String get replayForward => 'Forward';

  @override
  String get replayEnd => 'End';

  @override
  String replayOpening(int a, int b) {
    return 'Opening: $a – $b';
  }

  @override
  String get replayNoMove => 'no move';

  @override
  String get replayDouble => 'double offered';

  @override
  String get replayTake => 'take';

  @override
  String get replayDrop => 'drop';

  @override
  String get replayResign => 'resign';

  @override
  String replayWon(String name, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '$name won · $_temp0';
  }

  @override
  String get replayLoadError => 'Couldn\'t open the game';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGroupGame => 'GAME';

  @override
  String get settingsGroupAccessibility => 'ACCESSIBILITY';

  @override
  String get settingsGroupGeneral => 'GENERAL';

  @override
  String get settingsConfirmMove => 'Confirm moves';

  @override
  String get settingsAutoRoll => 'Auto-roll dice';

  @override
  String get settingsShowLegalMoves => 'Show legal moves';

  @override
  String get settingsPipCount => 'Pip count';

  @override
  String get settingsAnimationSpeed => 'Animation speed';

  @override
  String get animationSpeedSlow => 'Slow';

  @override
  String get animationSpeedNormal => 'Normal';

  @override
  String get animationSpeedFast => 'Fast';

  @override
  String get settingsColorBlind => 'Color-blind mode';

  @override
  String get settingsLargePips => 'Large dice pips';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsReplays => 'My games';

  @override
  String get settingsLesson => 'Replay the lesson';

  @override
  String settingsAbout(String version) {
    return 'Version $version';
  }

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorBody => 'Try again. If the problem persists, restart the app.';

  @override
  String get playVsComputer => 'Play vs computer';

  @override
  String get rulesShortBody => 'Each player has 15 checkers. Checkers move from 24 towards 1 according to the dice. Land on a lone opponent checker and you send it to the bar; a point with two or more checkers is blocked. Once all your checkers are home (1–6), you start bearing off. The first to bear off all 15 checkers wins. If the opponent has borne off none — mars (×2); if they still have a checker on the bar or in your home — koks (×3).';

  @override
  String get rulesLongBody => 'All 15 checkers start on the head (point 24). There is no hitting: you can\'t move to a point with an opponent checker. Each turn you may take only one checker from the head (except 6-6, 4-4 and 3-3 on the first roll). You can\'t block 6 points in a row unless an opponent checker is ahead of them. Once all your checkers are home, you start bearing off. If the opponent has borne off none — mars (×2); if one of their checkers hasn\'t yet passed your home — koks (×3).';
}
