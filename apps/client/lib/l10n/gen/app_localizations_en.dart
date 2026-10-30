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

  @override
  String get actionSave => 'Save';

  @override
  String get copied => 'Copied';

  @override
  String get valueNone => '—';

  @override
  String get authWelcomeTitle => 'Welcome';

  @override
  String get authWelcomeBody => 'With an account your rating and match history follow you to every device.';

  @override
  String get authApple => 'Continue with Apple';

  @override
  String get authGoogle => 'Continue with Google';

  @override
  String get authEmail => 'Continue with e-mail';

  @override
  String get authGuest => 'Play as a guest';

  @override
  String authLegal(String terms, String privacy) {
    return 'By continuing you accept the $terms and the $privacy.';
  }

  @override
  String get authTerms => 'Terms of Use';

  @override
  String get authPrivacy => 'Privacy Policy';

  @override
  String get authProviderUnavailable => 'This sign-in option isn\'t available yet. Continue with e-mail or as a guest.';

  @override
  String get authOffline => 'Can\'t reach the server. Check your connection and try again.';

  @override
  String get authTooManyTries => 'Too many attempts. Try again in a little while.';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get emailTitle => 'Enter your e-mail';

  @override
  String get emailBody => 'No password needed. We\'ll send you a 6-digit sign-in code.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailSend => 'Send code';

  @override
  String get emailInvalid => 'That e-mail address isn\'t valid';

  @override
  String get codeTitle => 'Enter the code';

  @override
  String codeBody(String email) {
    return 'We sent it to $email. Check your spam folder too.';
  }

  @override
  String get codeLabel => '6-digit code';

  @override
  String codeResendIn(String time) {
    return 'Resend code · $time';
  }

  @override
  String get codeResend => 'Resend code';

  @override
  String get codeSent => 'A new code is on its way';

  @override
  String get codeInvalid => 'That code is wrong. Check it and try again.';

  @override
  String get codeExpired => 'The code has expired. Ask for a new one.';

  @override
  String get modeCasual => 'Casual';

  @override
  String get modeRanked => 'Ranked';

  @override
  String get searchTitle => 'Finding an opponent…';

  @override
  String searchElapsed(String elapsed) {
    return 'Elapsed $elapsed';
  }

  @override
  String searchTip(String tip) {
    return 'Tip: $tip';
  }

  @override
  String get searchTipHeadRule => 'In Long Nard you may take only one checker from the head per turn.';

  @override
  String get searchTipPip => 'The pip count shows who is ahead in the race.';

  @override
  String get searchBotSoon => 'If no live opponent turns up within 30 seconds, you\'ll play a bot.';

  @override
  String timeControlShort(int minutes, int delay) {
    return '$minutes+${delay}s';
  }

  @override
  String ratingRange(int min, int max) {
    return '$min–$max';
  }

  @override
  String vsMeta(String rank, int rating, int percent) {
    return '$rank · $rating · $percent% wins';
  }

  @override
  String vsMetaNoStats(String rank, int rating) {
    return '$rank · $rating';
  }

  @override
  String get vsLabel => 'vs';

  @override
  String pointsUpper(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n POINTS',
      one: '1 POINT',
    );
    return '$_temp0';
  }

  @override
  String get rankedUpper => 'RANKED';

  @override
  String get unrankedUpper => 'UNRANKED';

  @override
  String vsStartsIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return 'The game starts in $_temp0';
  }

  @override
  String get botBadge => 'BOT';

  @override
  String get botNoRating => 'Doesn\'t affect rating';

  @override
  String get botFallbackNotice => 'No live opponent turned up within 30 seconds, so you\'re playing a bot. The result doesn\'t affect your rating.';

  @override
  String get gameModeCasual => 'Casual · unranked';

  @override
  String playerBotMeta(String noRating, String pip) {
    return '$noRating · $pip';
  }

  @override
  String get bannerLowTime => 'Time is running out';

  @override
  String bannerTimeLeft(String time) {
    return '$time left';
  }

  @override
  String get bannerOpponentOffline => 'Opponent disconnected';

  @override
  String get bannerDisconnected => 'Connection lost';

  @override
  String get playerOffline => 'Offline';

  @override
  String reconnectTitle(String name) {
    return '$name is reconnecting…';
  }

  @override
  String reconnectBody(String time) {
    return '$time left · if time runs out, you win';
  }

  @override
  String get selfReconnectTitle => 'Reconnecting…';

  @override
  String get menuFairDice => 'Fair dice';

  @override
  String get menuFairDiceVerify => 'Verify';

  @override
  String get matchRatingLabel => 'RATING';

  @override
  String matchRatingFrom(int old) {
    return 'from $old';
  }

  @override
  String matchRatingToNext(String rank, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '$_temp0 to $rank';
  }

  @override
  String ratingDeltaUp(int n) {
    return '+$n';
  }

  @override
  String ratingDeltaDown(int n) {
    return '−$n';
  }

  @override
  String get fairTitle => 'Fair dice';

  @override
  String get fairIntro => 'Every roll is computed from a server key locked before the game, your key and the roll\'s number. After the game you can check every roll yourself.';

  @override
  String get fairCommitment => 'Server key hash (before the game)';

  @override
  String fairCommitmentValue(String hash) {
    return 'sha256: $hash';
  }

  @override
  String get fairServerSeed => 'Server key (revealed after the game)';

  @override
  String get fairYourSeed => 'Your key';

  @override
  String get fairOpponentSeed => 'Opponent\'s key';

  @override
  String get fairRollNumber => 'Roll number';

  @override
  String fairRollValue(int n, int a, int b) {
    return '#$n · HMAC → $a, $b';
  }

  @override
  String fairMatch(int a, int b) {
    return 'Matches · $a – $b';
  }

  @override
  String fairMatchSub(int n) {
    return 'Roll #$n equals the computed result';
  }

  @override
  String fairMismatch(int a, int b) {
    return 'Doesn\'t match · $a – $b';
  }

  @override
  String fairMismatchSub(int n) {
    return 'Roll #$n differs from the computed result';
  }

  @override
  String get fairCommitmentMismatch => 'The server key doesn\'t match its hash';

  @override
  String get fairPending => 'Revealed after the game';

  @override
  String get fairPendingNote => 'The server key is revealed when the game ends. Then you can check every roll here.';

  @override
  String get fairNoRolls => 'No rolls yet';

  @override
  String get fairCopy => 'Copy data';

  @override
  String get fairCheckAnother => 'Check another roll';

  @override
  String get fairPickTitle => 'Pick a roll';

  @override
  String fairRollRow(int n, int a, int b) {
    return '#$n · $a – $b';
  }

  @override
  String get fairOpeningTag => 'opening';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get tierDiamond => 'Diamond';

  @override
  String get tierMaster => 'Master';

  @override
  String get tierGrandmaster => 'Grandmaster';

  @override
  String rankWithSub(String tier, String sub) {
    return '$tier $sub';
  }

  @override
  String profileMeta(String rank, int rating) {
    return '$rank · $rating';
  }

  @override
  String get statRating => 'Rating';

  @override
  String get statWinRate => 'Win rate';

  @override
  String get statMatches => 'Matches';

  @override
  String get statWins => 'Wins';

  @override
  String statPercent(int n) {
    return '$n%';
  }

  @override
  String get profileHistory => 'MATCH HISTORY';

  @override
  String historyMeta(String variant, String format, String date) {
    return '$variant · $format · $date';
  }

  @override
  String get variantShortAbbr => 'Short';

  @override
  String get variantLongAbbr => 'Long';

  @override
  String get dateToday => 'today';

  @override
  String get dateYesterday => 'yesterday';

  @override
  String historyScore(int me, int opp) {
    return '$me–$opp';
  }

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get historyEmptyTitle => 'No online matches yet';

  @override
  String get historyEmptyBody => 'Matches you play online will show up here.';

  @override
  String get profileSignedOutTitle => 'Sign in to your account';

  @override
  String get profileSignedOutBody => 'Your rating, stats and match history will live here.';

  @override
  String get nameInvalid => 'Use 3–20 letters, digits or _';

  @override
  String get offlineBanner => 'No connection · offline mode';

  @override
  String get onlineOfflineTitle => 'Online play isn\'t available';

  @override
  String get onlineOfflineBody => 'Games against the computer and on one device still work. Try again when the connection is back.';

  @override
  String get settingsAccountPrivacy => 'Account & privacy';

  @override
  String get accountGroupAccount => 'ACCOUNT';

  @override
  String get accountEmail => 'E-mail';

  @override
  String get accountNickname => 'Player name';

  @override
  String get accountEmailAdd => 'Add';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountGroupData => 'DATA';

  @override
  String get accountExport => 'Export my data';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get exportTitle => 'Export your data';

  @override
  String exportBody(String email) {
    return 'We\'ll e-mail all your data as a ZIP file to $email within 24 hours.';
  }

  @override
  String get exportNeedsEmail => 'To receive your data, link an e-mail to your account first. Your progress stays as it is.';

  @override
  String get exportLinkEmail => 'Link e-mail';

  @override
  String get exportProfile => 'Profile and account';

  @override
  String get exportGames => 'Match history';

  @override
  String exportGamesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get exportPurchases => 'Purchases and balance';

  @override
  String get exportSocial => 'Friends and clan';

  @override
  String get exportFormat => 'Format';

  @override
  String get exportFormatValue => 'ZIP · JSON';

  @override
  String get exportStart => 'Start export';

  @override
  String exportSent(String email) {
    return 'Sent to $email';
  }

  @override
  String get deleteTitle => 'Delete your account?';

  @override
  String deleteItemRating(int rating) {
    return 'Your rating ($rating), rank and full match history';
  }

  @override
  String get deleteItemHistory => 'Your profile and full match history';

  @override
  String get deleteIrreversible => 'Your account is deleted for good after 30 days. Sign in before then to cancel.';

  @override
  String deleteConfirmLabel(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get deleteConfirmWord => 'DELETE';

  @override
  String get setupOnlineTitle => 'Online game';

  @override
  String get setupTimeLabel => 'TIME CONTROL';

  @override
  String get timeBlitz => 'Blitz';

  @override
  String get timeRapid => 'Rapid';

  @override
  String get timeClassic => 'Classic';

  @override
  String get timeDaily => 'Daily';

  @override
  String timeValue(int minutes, int delay) {
    return '$minutes min + ${delay}s';
  }

  @override
  String get setupRated => 'Ranked';

  @override
  String setupRatedSub(int rating) {
    return 'Your rating: $rating';
  }

  @override
  String get setupFindOpponent => 'Find an opponent';

  @override
  String get tabStore => 'Store';

  @override
  String get lockerTitle => 'Locker';

  @override
  String loadoutName(int n) {
    return 'Set $n';
  }

  @override
  String get lockerSave => 'Save';

  @override
  String get lockerSaved => 'Set saved';

  @override
  String get lockerAddLoadout => 'New set';

  @override
  String get lockerRenameTitle => 'Set name';

  @override
  String get lockerRename => 'Rename';

  @override
  String get lockerDelete => 'Delete set';

  @override
  String lockerLoadoutLimit(int max) {
    return 'You can have up to $max sets.';
  }

  @override
  String get lockerEmptyTitle => 'Nothing here yet';

  @override
  String get lockerEmptyBody => 'New items for this section are on their way.';

  @override
  String get lockerShowOpponentCosmetics => 'Show opponent\'s cosmetics';

  @override
  String get categoryBoard => 'Board';

  @override
  String get categoryCheckers => 'Checkers';

  @override
  String get categoryDice => 'Dice';

  @override
  String get categoryDiceCup => 'Dice cup';

  @override
  String get categoryCube => 'Doubling cube';

  @override
  String get categoryBackground => 'Background';

  @override
  String get categorySounds => 'Sounds';

  @override
  String get categoryEmote => 'Emotes';

  @override
  String get categoryAvatarFrame => 'Avatar frame';

  @override
  String get categoryTitle => 'Title';

  @override
  String get categoryWinEffect => 'Win effect';

  @override
  String get categoryOther => 'Other';

  @override
  String get itemEquipped => 'Equipped';

  @override
  String get itemPreviewing => 'Trying on';

  @override
  String get itemOwned => 'Owned';

  @override
  String get itemSeason => 'Season pass';

  @override
  String get itemTournamentReward => 'Tournament reward';

  @override
  String get itemAchievementReward => 'Achievement reward';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get raritySeasonal => 'Seasonal';

  @override
  String get rarityTournament => 'Tournament';

  @override
  String get rarityCommonUpper => 'COMMON';

  @override
  String get rarityRareUpper => 'RARE';

  @override
  String get rarityEpicUpper => 'EPIC';

  @override
  String get rarityLegendaryUpper => 'LEGENDARY';

  @override
  String get raritySeasonalUpper => 'SEASONAL';

  @override
  String get rarityTournamentUpper => 'TOURNAMENT';

  @override
  String get itemObtainTitle => 'HOW TO GET IT';

  @override
  String get obtainStore => 'Store';

  @override
  String get obtainSeasonPremium => 'Season pass · Premium';

  @override
  String get obtainTournament => 'Tournament';

  @override
  String get obtainAchievement => 'Achievement';

  @override
  String get obtainDefault => 'Standard set';

  @override
  String get obtainFree => 'Free';

  @override
  String priceCoins(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount coins',
      one: '$amount coin',
    );
    return '$_temp0';
  }

  @override
  String priceGems(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount rubies',
      one: '$amount ruby',
    );
    return '$_temp0';
  }

  @override
  String get itemTry => 'Try on';

  @override
  String get itemBuy => 'Buy';

  @override
  String get itemEquip => 'Equip';

  @override
  String storeFeaturedOverline(int days) {
    return 'FEATURED · $days D';
  }

  @override
  String get storeDailyTitle => 'DAILY PICKS';

  @override
  String storeRefreshesIn(String time) {
    return 'Refreshes in $time';
  }

  @override
  String get storeGemsTitle => 'RUBIES';

  @override
  String get storePackUnavailable => 'Buying rubies isn\'t available yet. It opens once the store accounts are connected.';

  @override
  String storePackAdded(String amount) {
    return '+$amount rubies added to your balance';
  }

  @override
  String get accountNeededTitle => 'Sign in to your account';

  @override
  String get accountNeededBody => 'You need an account to earn coins, buy sets and see your missions.';

  @override
  String get purchasePrice => 'Price';

  @override
  String get purchaseBalanceAfter => 'Balance after';

  @override
  String purchaseShortfall(String amount) {
    return '$amount short';
  }

  @override
  String purchaseNotEnoughGems(String pack) {
    return 'Not enough rubies. Get the $pack pack and unlock the item right away.';
  }

  @override
  String get purchaseNotEnoughCoins => 'Not enough coins. Coins are only earned: play and finish missions.';

  @override
  String purchaseBuyPack(String amount) {
    return 'Get $amount rubies';
  }

  @override
  String get purchaseToMissions => 'See missions';

  @override
  String get purchaseFailed => 'The purchase didn\'t go through. Try again.';

  @override
  String get purchaseAlreadyOwned => 'You already own this item.';

  @override
  String get purchaseNotForSale => 'This item isn\'t for sale.';

  @override
  String purchaseOwnedTitle(String item) {
    return '$item is yours';
  }

  @override
  String get purchaseReceipt => 'Receipt';

  @override
  String get purchasePaid => 'Paid';

  @override
  String get purchaseClose => 'Close';

  @override
  String get purchaseEquipNow => 'Equip now';

  @override
  String get missionsTitle => 'Missions';

  @override
  String streakCardTitle(int days) {
    return 'Login streak · $days d';
  }

  @override
  String streakTomorrow(int coins) {
    return 'Tomorrow: +$coins';
  }

  @override
  String get missionsDaily => 'Daily';

  @override
  String get missionsWeekly => 'Weekly';

  @override
  String missionsResetsIn(String time) {
    return 'Resets in $time';
  }

  @override
  String missionProgress(int done, int target) {
    return '$done / $target';
  }

  @override
  String missionProgressCompact(int done, int target) {
    return '$done/$target';
  }

  @override
  String missionReward(int n) {
    return '+$n';
  }

  @override
  String get missionClaim => 'Claim';

  @override
  String get missionClaimed => 'Claimed';

  @override
  String missionDoubles(int n) {
    return 'Roll $n doubles';
  }

  @override
  String missionRankedWin(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Win $n ranked games',
      one: 'Win a ranked game',
    );
    return '$_temp0';
  }

  @override
  String get missionCubeTakeWin => 'Take the cube and win';

  @override
  String get missionPlayLong => 'Play Long Nard';

  @override
  String missionMars(int n) {
    return 'Win $n games by mars';
  }

  @override
  String missionPlay(int n) {
    return 'Play $n games';
  }

  @override
  String missionWin(int n) {
    return 'Win $n games';
  }

  @override
  String get missionGeneric => 'Mission';

  @override
  String dailyBonusTitle(int coins) {
    return 'Daily bonus · +$coins';
  }

  @override
  String dailyBonusBody(int done, int total) {
    return 'Finish every daily mission · $done / $total';
  }

  @override
  String get streakOverline => 'LOGIN STREAK';

  @override
  String get streakDay1 => 'Day 1';

  @override
  String get streakDay2 => 'Day 2';

  @override
  String get streakDay3 => 'Day 3';

  @override
  String get streakDay4 => 'Day 4';

  @override
  String get streakDay5 => 'Day 5';

  @override
  String get streakDay6 => 'Day 6';

  @override
  String get streakDay7 => 'Day 7';

  @override
  String get streakBody => 'Sign in every day and collect the big day-7 bonus.';

  @override
  String streakClaim(int coins) {
    return 'Collect $coins coins';
  }

  @override
  String get streakResetNote => 'Miss a day and the streak starts again from day 1.';

  @override
  String levelUpOverline(int from, int to) {
    return 'LEVEL $from → $to';
  }

  @override
  String get levelUpTitle => 'Level up';

  @override
  String xpProgress(String xp, String next) {
    return '$xp / $next XP';
  }

  @override
  String homeLevel(int n) {
    return 'Lv. $n';
  }

  @override
  String homeDailyMission(int done, int total) {
    return 'DAILY MISSION · $done/$total';
  }

  @override
  String get homeMissionsDone => 'Today\'s missions are done';

  @override
  String get matchCoins => 'coins';

  @override
  String get matchXp => 'experience';

  @override
  String get xpBadge => 'XP';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achievementsCount(int done, int total) {
    return '$done / $total';
  }

  @override
  String get titlesOverline => 'TITLE';

  @override
  String get titlesNone => 'No title';

  @override
  String get titlesLocked => 'Unlocked by an achievement';

  @override
  String get achFirstWin => 'First win';

  @override
  String get achWins10 => '10 wins';

  @override
  String get achWins100 => '100 wins';

  @override
  String get achGames1000 => '1000 games';

  @override
  String get achMars10 => 'Mars master';

  @override
  String get achRankedWins25 => 'Ranked contender';

  @override
  String get achStreak10 => '10-day streak';

  @override
  String get achGeneric => 'Achievement';

  @override
  String coinsSemantic(String amount) {
    return 'Coins: $amount';
  }

  @override
  String gemsSemantic(String amount) {
    return 'Rubies: $amount';
  }

  @override
  String get emoteWheelHint => 'Slide\nand release';

  @override
  String get emoteButton => 'Send an emote';

  @override
  String get gameChat => 'Chat';

  @override
  String get emoteSmile => 'Smile';

  @override
  String get emoteLaugh => 'Laugh';

  @override
  String get emoteWow => 'Wow';

  @override
  String get emoteThink => 'Thinking';

  @override
  String get emoteSad => 'Sad';

  @override
  String get emoteAngry => 'Angry';

  @override
  String get emoteTea => 'Tea';

  @override
  String get emoteClap => 'Well done';

  @override
  String get phraseHello => 'Hello!';

  @override
  String get phraseGoodLuck => 'Good luck';

  @override
  String get phraseNiceMove => 'Nice move';

  @override
  String get phraseDice => 'Those dice…';

  @override
  String get phraseThanks => 'Thanks';

  @override
  String get phraseGoodGame => 'Good game';

  @override
  String get phraseNiceRoll => 'Nice roll';

  @override
  String get phraseSorry => 'Sorry';

  @override
  String get tabClan => 'Clan';

  @override
  String get modePrivateRoom => 'Private room';

  @override
  String get modeFriends => 'Friends';

  @override
  String get socialAccountBody => 'Friends, clans and private rooms need an account.';

  @override
  String get send => 'Send';

  @override
  String get close => 'Close';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendsAdd => 'Add';

  @override
  String get friendsSection => 'FRIENDS';

  @override
  String get presenceOnline => 'Online';

  @override
  String get presenceInGame => 'In a game';

  @override
  String get presenceOffline => 'Offline';

  @override
  String get friendInvite => 'Invite';

  @override
  String get friendWatch => 'Watch';

  @override
  String get friendRequestsTitle => 'REQUESTS';

  @override
  String get friendSentTitle => 'SENT';

  @override
  String get friendChallengesTitle => 'CHALLENGES';

  @override
  String get friendAccept => 'Accept';

  @override
  String get friendDismiss => 'Decline';

  @override
  String get friendCancelRequest => 'Cancel request';

  @override
  String challengeMeta(String variant, String format) {
    return '$variant · $format';
  }

  @override
  String get friendsEmptyTitle => 'No friends yet';

  @override
  String get friendsEmptyBody => 'Search by name or share your friend code.';

  @override
  String friendInviteSent(String name) {
    return 'Invite sent: $name';
  }

  @override
  String get friendRemoved => 'Removed from friends';

  @override
  String metaWithClan(String meta, String clan) {
    return '$meta · $clan';
  }

  @override
  String levelShort(int n) {
    return 'Lv. $n';
  }

  @override
  String get addFriendTitle => 'Add a friend';

  @override
  String get addFriendSearchHint => 'Search by name';

  @override
  String get addFriendSearchShort => 'Type at least 3 letters';

  @override
  String get addFriendAction => 'Add';

  @override
  String get addFriendOr => 'or';

  @override
  String get addFriendCodeLabel => 'YOUR FRIEND CODE';

  @override
  String get addFriendCodeCaption => 'Your friend enters this code';

  @override
  String get addFriendCopyCode => 'Copy code';

  @override
  String get addFriendEnterCode => 'ADD BY CODE';

  @override
  String get addFriendCodeHint => '8-character code';

  @override
  String get friendRequested => 'Sent';

  @override
  String get friendAccepted => 'Friends';

  @override
  String get friendErrNotFound => 'Player not found';

  @override
  String get friendErrBlocked => 'You can\'t contact this player';

  @override
  String get friendErrAlready => 'You\'re already friends';

  @override
  String get friendErrPending => 'Request already sent';

  @override
  String friendErrLimit(int max) {
    return 'Friend limit reached ($max)';
  }

  @override
  String get roomTitle => 'Private room';

  @override
  String get roomCodeLabel => 'ROOM CODE';

  @override
  String get roomCopy => 'Copy';

  @override
  String get roomShare => 'Share';

  @override
  String roomShareText(String code) {
    return 'Play with me on NardArena. Room code: $code';
  }

  @override
  String get roomWaiting => 'Waiting for a friend…';

  @override
  String roomExpiry(String time, String left) {
    return 'Expires $time · $left left';
  }

  @override
  String roomInvited(String name) {
    return 'Invited: $name';
  }

  @override
  String get roomSettingVariant => 'Variant';

  @override
  String get roomSettingFormat => 'Format';

  @override
  String get roomSettingTime => 'Time';

  @override
  String get roomSettingRating => 'Rating';

  @override
  String get roomUnrated => 'Not affected';

  @override
  String get roomExpired => 'The code expired';

  @override
  String get roomNewCode => 'New code';

  @override
  String get roomCreate => 'Create a room';

  @override
  String get roomCreateSub => 'Send the code; the game starts when your friend joins';

  @override
  String get roomJoinByCode => 'Join by code';

  @override
  String get roomJoinByCodeSub => 'Enter a friend\'s room with a 6-character code';

  @override
  String get roomJoin => 'Join';

  @override
  String get roomJoinTitle => 'Join a room';

  @override
  String get roomJoinHint => 'Enter the code your friend sent';

  @override
  String get roomJoining => 'Joining…';

  @override
  String get roomCreating => 'Creating the room…';

  @override
  String get roomNotFound => 'Room not found or expired';

  @override
  String get roomInviteFriend => 'Invite a friend';

  @override
  String get roomPickFriend => 'Who do you invite?';

  @override
  String get roomCancelTitle => 'Close the room?';

  @override
  String get roomCancelBody => 'The code will stop working.';

  @override
  String get roomCancelConfirm => 'Close';

  @override
  String get spectatorLive => 'SPECTATING';

  @override
  String get spectatorLeave => 'Leave';

  @override
  String get spectatorNoChat => 'The players\' emotes show here';

  @override
  String get spectatorUnavailable => 'This game can\'t be watched';

  @override
  String spectatorGameOver(String name, String score) {
    return 'Winner: $name · $score';
  }

  @override
  String get spectatorWaiting => 'Loading the game…';

  @override
  String get playerMenuAddFriend => 'Add friend';

  @override
  String get playerMenuInvite => 'Invite to a game';

  @override
  String get playerMenuMute => 'Mute chat';

  @override
  String get playerMenuUnmute => 'Unmute';

  @override
  String get playerMenuReport => 'Report';

  @override
  String get playerMenuBlock => 'Block';

  @override
  String get playerMenuUnblock => 'Unblock';

  @override
  String get playerMenuUnfriend => 'Remove friend';

  @override
  String get playerMenuInviteClan => 'Invite to clan';

  @override
  String reportTitle(String name) {
    return 'Report $name';
  }

  @override
  String get reportReasonLabel => 'REASON';

  @override
  String get reportReasonAbuse => 'Abusive chat';

  @override
  String get reportReasonName => 'Inappropriate name or avatar';

  @override
  String get reportReasonCheating => 'Using assistance software';

  @override
  String get reportReasonStalling => 'Stalling on purpose';

  @override
  String get reportReasonLeaving => 'Leaving games on purpose';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportNoteHint => 'Extra note (optional)';

  @override
  String get reportAlsoBlock => 'Also block this player';

  @override
  String reportDisclosure(String name) {
    return 'The record of your last game and the chat are attached automatically. $name won\'t see who reported them.';
  }

  @override
  String get reportSend => 'Send report';

  @override
  String get reportLimit => 'You\'ve sent many reports today. Try again tomorrow.';

  @override
  String blockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get blockInfoMatchmaking => 'They won\'t be matched with you in casual games.';

  @override
  String get blockInfoContact => 'They can\'t send you messages, friend requests or game invites.';

  @override
  String blockInfoUndo(String path) {
    return 'You can unblock them in $path.';
  }

  @override
  String get privacyBlocked => 'Blocked players';

  @override
  String get blockConfirm => 'Block';

  @override
  String blockDone(String name) {
    return '$name is blocked.';
  }

  @override
  String get unblockDone => 'Unblocked';

  @override
  String get blockedEmpty => 'No blocked players';

  @override
  String get reportSentTitle => 'Report sent';

  @override
  String get reportSentBody => 'A moderator will review it within 24 hours. You\'ll be notified of the outcome.';

  @override
  String get mutedNote => 'Muted';

  @override
  String get unmutedNote => 'Unmuted';

  @override
  String get clansTitle => 'Clans';

  @override
  String get clanCreateShort => 'Create';

  @override
  String get clanSearchHint => 'Search name or tag';

  @override
  String clanFilterLanguage(String code) {
    return 'Language: $code';
  }

  @override
  String get clanFilterOpen => 'Open';

  @override
  String clanFilterMinRating(int rating) {
    return 'Min. rating ≤ $rating';
  }

  @override
  String clanTag(String tag) {
    return '[$tag]';
  }

  @override
  String clanListMeta(int level, int members, int max, String rating) {
    return 'Lv. $level · $members/$max · $rating';
  }

  @override
  String get clanJoin => 'Join';

  @override
  String get clanApply => 'Apply';

  @override
  String get clanFull => 'Full';

  @override
  String get clanInviteOnlyShort => 'Invite only';

  @override
  String get clanPending => 'Pending';

  @override
  String get clanEmpty => 'No clans found';

  @override
  String get clanEmptyBody => 'Try another name or create your own clan.';

  @override
  String get clanInvitesTitle => 'INVITES';

  @override
  String clanInviteFrom(String name) {
    return 'Invited by $name';
  }

  @override
  String get clanStatLevel => 'Level';

  @override
  String get clanStatMembers => 'Members';

  @override
  String get clanStatRating => 'Rating';

  @override
  String get clanStatLanguage => 'Language';

  @override
  String clanMembersValue(int members, int max) {
    return '$members/$max';
  }

  @override
  String get clanRequirements => 'REQUIREMENTS';

  @override
  String get clanReqMinRating => 'Min. rating';

  @override
  String get clanReqPolicy => 'Admission';

  @override
  String get clanReqNone => 'None';

  @override
  String get clanTopMembers => 'TOP MEMBERS';

  @override
  String clanMemberWithRole(String name, String role) {
    return '$name · $role';
  }

  @override
  String get clanApplyCta => 'Apply';

  @override
  String get clanJoinCta => 'Join';

  @override
  String get clanAppliedCta => 'Request sent';

  @override
  String get clanCancelApply => 'Withdraw request';

  @override
  String get clanInviteOnlyCta => 'Invite only';

  @override
  String get clanFullCta => 'The clan is full';

  @override
  String get clanReqNotMet => 'You don\'t meet the requirements';

  @override
  String get clanLeaveFirst => 'Leave your current clan first';

  @override
  String get clanOpenMine => 'Go to clan';

  @override
  String get clanAcceptInvite => 'Accept invite';

  @override
  String get clanErrRatingLow => 'Your rating is too low for this clan';

  @override
  String get clanErrInClan => 'You\'re already in a clan';

  @override
  String get policyOpen => 'Open';

  @override
  String get policyOpenSub => 'Anyone who meets the rating joins at once';

  @override
  String get policyRequest => 'By request';

  @override
  String get policyRequestSub => 'The leader, co-leaders and elders approve';

  @override
  String get policyInvite => 'Invite only';

  @override
  String get policyInviteSub => 'Listed, but joining needs an invite';

  @override
  String get roleLeader => 'Leader';

  @override
  String get roleCoLeader => 'Co-leader';

  @override
  String get roleElder => 'Elder';

  @override
  String get roleMember => 'Member';

  @override
  String get emblemTitle => 'Emblem';

  @override
  String get emblemSave => 'Save';

  @override
  String get emblemTabShape => 'Shape';

  @override
  String get emblemTabSymbol => 'Symbol';

  @override
  String get emblemTabColor => 'Colour';

  @override
  String get emblemTabPattern => 'Pattern';

  @override
  String get emblemPrimaryColor => 'MAIN COLOUR';

  @override
  String get emblemShapeShield => 'Shield';

  @override
  String get emblemShapeHexagon => 'Hexagon';

  @override
  String get emblemShapeOctagon => 'Octagon';

  @override
  String get emblemShapeCircle => 'Circle';

  @override
  String get emblemShapeDiamond => 'Diamond';

  @override
  String get emblemShapeBanner => 'Banner';

  @override
  String get emblemShapeStar => 'Star';

  @override
  String get emblemShapeArch => 'Arch';

  @override
  String get emblemSymbolDiamond => 'Diamond';

  @override
  String get emblemSymbolDiamondDot => 'Dotted diamond';

  @override
  String get emblemSymbolCircle => 'Ring';

  @override
  String get emblemSymbolSquare => 'Square';

  @override
  String get emblemSymbolInitials => 'Initials';

  @override
  String get emblemPatternNone => 'None';

  @override
  String get emblemPatternLattice => 'Lattice';

  @override
  String get emblemColorGarnet => 'Garnet';

  @override
  String get emblemColorIndigo => 'Indigo';

  @override
  String get emblemColorEmerald => 'Emerald';

  @override
  String get emblemColorBrass => 'Brass';

  @override
  String get emblemColorPurple => 'Purple';

  @override
  String get emblemColorSlate => 'Slate';

  @override
  String get emblemColorIvory => 'Ivory';

  @override
  String get emblemColorBlue => 'Blue';

  @override
  String get emblemColorWalnut => 'Walnut';

  @override
  String clanOnline(int n) {
    return '$n online';
  }

  @override
  String get clanTabChat => 'Chat';

  @override
  String get clanTabActivity => 'Activity';

  @override
  String get clanTabWar => 'War';

  @override
  String get clanTabChest => 'Chest';

  @override
  String get clanChestTitle => 'Weekly chest';

  @override
  String clanChestProgress(String current, String target) {
    return '$current / $target';
  }

  @override
  String get clanChatHint => 'Write a message…';

  @override
  String get clanChatEmpty => 'No messages yet. Be the first.';

  @override
  String get clanActivityEmpty => 'Nothing has happened yet';

  @override
  String get clanChatTooFast => 'You\'re writing too fast. Wait a moment.';

  @override
  String clanSysCreated(String name) {
    return 'Clan created by $name';
  }

  @override
  String clanSysJoined(String name) {
    return '$name joined the clan';
  }

  @override
  String clanSysLeft(String name) {
    return '$name left the clan';
  }

  @override
  String clanSysKicked(String name) {
    return '$name was removed from the clan';
  }

  @override
  String clanSysRole(String name, String role) {
    return '$name is now $role';
  }

  @override
  String clanSysLeader(String name) {
    return 'New leader: $name';
  }

  @override
  String clanSysRenamed(String name, String tag) {
    return 'The clan is now $name [$tag]';
  }

  @override
  String clanSysDonated(String name, String amount) {
    return '$name put $amount coins in the chest';
  }

  @override
  String get clanSysChestFull => 'The weekly chest is full';

  @override
  String clanSysWarStarted(String name, String tag) {
    return 'Clan war started: $name [$tag]';
  }

  @override
  String clanSysWarWin(String name, String points) {
    return '$name won a war match · +$points';
  }

  @override
  String clanSysWarEnded(String mine, String theirs) {
    return 'Clan war over · $mine : $theirs';
  }

  @override
  String get clanMenuMembers => 'Members';

  @override
  String get clanMenuLeaderboard => 'Clan ranking';

  @override
  String get clanMenuProfile => 'Clan profile';

  @override
  String get clanMenuEmblem => 'Change emblem';

  @override
  String get clanMenuRequests => 'Requests';

  @override
  String get clanMenuInvite => 'Invite friends';

  @override
  String get clanMenuLeave => 'Leave clan';

  @override
  String get clanLeaveTitle => 'Leave the clan?';

  @override
  String get clanLeaveBody => 'You\'ll lose access to the clan chat and chest.';

  @override
  String get clanLeaveLastBody => 'You\'re the last member: the clan will be disbanded.';

  @override
  String get clanTransferFirst => 'Hand over leadership before leaving.';

  @override
  String get chatDelete => 'Delete';

  @override
  String get clanChestDonate => 'Donate';

  @override
  String clanChestMine(String amount) {
    return 'Your share this week: $amount';
  }

  @override
  String clanChestReward(int xp) {
    return 'When the chest is full, the clan gets $xp XP';
  }

  @override
  String get clanChestFullNote => 'The chest is full this week';

  @override
  String get clanChestAmount => 'AMOUNT';

  @override
  String clanDonated(String amount) {
    return 'You donated $amount coins';
  }

  @override
  String get clanErrChestFull => 'The chest is already full';

  @override
  String get clanDonors => 'THIS WEEK\'S DONATIONS';

  @override
  String get membersTitle => 'Members';

  @override
  String membersCount(int members, int max) {
    return '$members / $max';
  }

  @override
  String memberMeta(String presence, String rating) {
    return '$presence · $rating';
  }

  @override
  String memberMe(String name) {
    return '$name (you)';
  }

  @override
  String get memberViewProfile => 'View profile';

  @override
  String get memberInviteFriendly => 'Invite to a friendly';

  @override
  String get memberPromoteCoLeader => 'Make co-leader';

  @override
  String get memberPromoteElder => 'Make elder';

  @override
  String get memberDemote => 'Make member';

  @override
  String get memberTransferLead => 'Make leader';

  @override
  String get memberKick => 'Remove from clan';

  @override
  String memberKickConfirm(String name) {
    return 'Remove $name from the clan?';
  }

  @override
  String memberTransferConfirm(String name) {
    return 'Make $name the leader?';
  }

  @override
  String get memberTransferBody => 'You\'ll become a co-leader.';

  @override
  String get requestsEmpty => 'No new requests';

  @override
  String get clanInvited => 'Invite sent';

  @override
  String warLive(String time) {
    return 'LIVE · ENDS IN $time';
  }

  @override
  String warCounted(int n, int max) {
    return '$n / $max matches counted';
  }

  @override
  String get warMatches => 'MATCHES';

  @override
  String warFinished(int a, int b) {
    return 'Final $a–$b';
  }

  @override
  String get warWon => 'OVER · VICTORY';

  @override
  String get warLost => 'OVER · DEFEAT';

  @override
  String get warDraw => 'OVER · DRAW';

  @override
  String get warNoneTitle => 'No war this week';

  @override
  String get warNoneBody => 'Clans are paired every Monday. A war needs at least 2 active members.';

  @override
  String get warNoOpponent => 'No opponent found';

  @override
  String warHowTo(int points) {
    return 'Every online win against the rival clan\'s members scores +$points.';
  }

  @override
  String get warMatchesEmpty => 'No matches counted yet';

  @override
  String get clanLeaderboardTitle => 'Clan ranking';

  @override
  String clanMyRank(int rank) {
    return 'Your clan · #$rank';
  }

  @override
  String get createClanTitle => 'Create a clan';

  @override
  String createStep(int step, int total) {
    return '$step / $total';
  }

  @override
  String get createNameLabel => 'Clan name';

  @override
  String createNameCounter(int n, int max) {
    return '$n / $max';
  }

  @override
  String get createTagLabel => 'Tag (3–5 letters)';

  @override
  String get createTagFree => 'Available';

  @override
  String get createTagTaken => 'Taken';

  @override
  String get createTagInvalid => '3–5 Latin letters only';

  @override
  String get createNameInvalid => 'The name must be 3–24 characters';

  @override
  String get createEmblemLabel => 'EMBLEM';

  @override
  String get createEmblemMore => 'More';

  @override
  String get createColorLabel => 'COLOUR';

  @override
  String get createPolicyLabel => 'JOINING';

  @override
  String get createMinRatingLabel => 'MINIMUM RATING';

  @override
  String get createMinRatingAny => 'Anyone';

  @override
  String createMinRatingMax(int n) {
    return '$n+';
  }

  @override
  String get createLanguageLabel => 'LANGUAGE';

  @override
  String get createDescriptionLabel => 'Description (optional)';

  @override
  String createBalance(String from, String to) {
    return 'Balance: $from → $to';
  }

  @override
  String createRenameNote(String price) {
    return 'Renaming later costs $price coins';
  }

  @override
  String get createSubmit => 'Create clan';

  @override
  String get createErrNameTaken => 'This name is taken';

  @override
  String get tabTournaments => 'Tournaments';

  @override
  String get tournamentsTitle => 'Tournaments';

  @override
  String get tourTabLive => 'Live';

  @override
  String get tourTabUpcoming => 'Upcoming';

  @override
  String get tourTabMine => 'Mine';

  @override
  String get tourTabFinished => 'Finished';

  @override
  String get tourFilterAll => 'All';

  @override
  String get tourFilterFree => 'Free';

  @override
  String tourStatusLive(int n) {
    return 'LIVE · ROUND $n';
  }

  @override
  String get tourStatusOpen => 'REGISTRATION OPEN';

  @override
  String get tourStatusUpcoming => 'UPCOMING';

  @override
  String get tourStatusFinished => 'FINISHED';

  @override
  String get tourStatusCancelled => 'CANCELLED';

  @override
  String tourInMinutes(int n) {
    return '$n min';
  }

  @override
  String tourTomorrowAt(String time) {
    return 'Tomorrow $time';
  }

  @override
  String get tourFormatSwiss => 'Swiss';

  @override
  String get tourFormatKnockout => 'Knockout';

  @override
  String get tourFormatRoundRobin => 'Round robin';

  @override
  String tourRounds(int n) {
    return '$n rounds';
  }

  @override
  String tourMeta(String variant, int points) {
    return '$variant · $points pts';
  }

  @override
  String tourEntrants(int n, int max) {
    return '$n/$max';
  }

  @override
  String get tourRegistered => 'Registered';

  @override
  String tourPlace(String place) {
    return 'Place: $place';
  }

  @override
  String tourOut(String round) {
    return 'Out · $round';
  }

  @override
  String get tournamentsOfflineTitle => 'Tournaments need a connection';

  @override
  String get tournamentsOfflineBody => 'Games against the computer and on one device still work. The list updates when you are back online.';

  @override
  String get tournamentsEmptyTitle => 'No tournaments yet';

  @override
  String get tournamentsEmptyBody => 'Tournaments you register for show up here.';

  @override
  String get tournamentsEmptyCta => 'See upcoming tournaments';

  @override
  String get tournamentsNoneTitle => 'No tournaments';

  @override
  String get tournamentsNoneBody => 'Nothing in this list right now. Check back a little later.';

  @override
  String get listErrorTitle => 'The list didn\'t load';

  @override
  String get listErrorBody => 'Couldn\'t reach the server. Try again in a moment.';

  @override
  String get sngCardMeta => 'Starts when full';

  @override
  String get sngJoin => 'Join';

  @override
  String get privateTourCreateChoice => 'Create a private tournament';

  @override
  String get privateTourJoinByCode => 'Join with a code';

  @override
  String get leaderboardTitle => 'Leaders';

  @override
  String tourHeroMeta(String status, String type, int size) {
    return '$status · $type $size';
  }

  @override
  String get tourTypeKnockoutUpper => 'KNOCKOUT';

  @override
  String get tourTypeSwissUpper => 'SWISS';

  @override
  String get tourTypeRoundRobinUpper => 'ROUND ROBIN';

  @override
  String get tourTypeSngUpper => 'SIT-AND-GO';

  @override
  String get tourStartsIn => 'Starts in';

  @override
  String tourLiveRound(int n, String stage) {
    return 'Round $n · $stage';
  }

  @override
  String tourNow(int n) {
    return 'Round $n';
  }

  @override
  String get tourPrizeFund => 'Prize pool';

  @override
  String get tourParticipants => 'Players';

  @override
  String tourParticipantsValue(int n, int max) {
    return '$n / $max';
  }

  @override
  String tourPlaceRange(String from, String to) {
    return '$from–$to';
  }

  @override
  String get tourRuleEntry => 'Entry';

  @override
  String get tourRuleFairDice => 'Fair dice';

  @override
  String get tourRuleRating => 'Rating';

  @override
  String get tourRuleUnrated => 'Not affected';

  @override
  String tourFormatValue(String type, int points) {
    return '$type · to $points points';
  }

  @override
  String tourEntryValue(String price, int rating) {
    return '$price · min. $rating';
  }

  @override
  String get tourEntryInvite => 'By invite';

  @override
  String get tourFairDiceValue => 'Verifiable';

  @override
  String get tourRegister => 'Register';

  @override
  String get tourRegisterFree => 'Register · Free';

  @override
  String get tourUnregister => 'Cancel registration';

  @override
  String get tourUnregisterTitle => 'Cancel your registration?';

  @override
  String get tourUnregisterBody => 'The entry fee goes back to your balance.';

  @override
  String get tourUnregisterBodyFree => 'Someone else can take your place.';

  @override
  String get tourRegisteredToast => 'You\'re registered';

  @override
  String get tourUnregisteredToast => 'Registration cancelled';

  @override
  String tourMinRating(int n) {
    return 'Minimum rating $n';
  }

  @override
  String get tourFull => 'No places left';

  @override
  String get tourClosed => 'Registration closed';

  @override
  String get tourInviteOnly => 'Join with an invite code';

  @override
  String get tourOpenBracket => 'View bracket';

  @override
  String get tourWatch => 'Watch';

  @override
  String tourTitlePrize(String name) {
    return 'Title: $name';
  }

  @override
  String get tourRatingTooLow => 'Your rating is below this tournament\'s minimum.';

  @override
  String get tourInviteRequired => 'This tournament needs an invite code.';

  @override
  String get tourActionFailed => 'That didn\'t work. Try again in a moment.';

  @override
  String get tourLive => 'LIVE';

  @override
  String roundOf(int n) {
    return '1/$n';
  }

  @override
  String get roundFinal => 'Final';

  @override
  String tourNextMatch(String round) {
    return 'YOUR NEXT MATCH · $round';
  }

  @override
  String tourNextMetaOpen(int points) {
    return 'Round open · to $points points';
  }

  @override
  String tourNextMetaPending(int points) {
    return 'Round not open yet · to $points points';
  }

  @override
  String get tourOpponentTbd => 'Opponent to be decided';

  @override
  String get tourReady => 'I\'m ready';

  @override
  String get tourReadyDone => 'You\'re ready';

  @override
  String get tourWaitingOpponent => 'Waiting for your opponent';

  @override
  String tourEliminated(String round) {
    return 'You\'re out · $round';
  }

  @override
  String tourFinishedPanel(String place) {
    return 'Tournament over · $place';
  }

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String standingsTitle(String name) {
    return '$name · Standings';
  }

  @override
  String get standingsRound => 'Round';

  @override
  String get standingsColRank => '#';

  @override
  String get standingsColPlayer => 'PLAYER';

  @override
  String get standingsColWinLoss => 'W–L';

  @override
  String get standingsColBuchholz => 'BUCH';

  @override
  String get standingsColPoints => 'PTS';

  @override
  String standingsWinLoss(int w, int l) {
    return '$w–$l';
  }

  @override
  String get standingsFootnoteNoPlayoff => 'Ties: Buchholz, then rating';

  @override
  String get standingsEmpty => 'The table appears after the first round.';

  @override
  String get championTitle => 'Champion';

  @override
  String championLine(String name, String tournament) {
    return '$name · $tournament';
  }

  @override
  String championFinal(String score, String opponent) {
    return 'Final: $score · $opponent';
  }

  @override
  String rewardCoins(String amount) {
    return '+$amount coins';
  }

  @override
  String get championShare => 'Share';

  @override
  String championShareText(String name, String tournament) {
    return '$name won $tournament. NardArena';
  }

  @override
  String get championShareCopied => 'Text copied';

  @override
  String sngTitle(int size) {
    return 'Sit-and-go · $size';
  }

  @override
  String sngSize(int n) {
    return '$n players';
  }

  @override
  String get sngStartsWhenFull => 'Starts as soon as it\'s full';

  @override
  String sngExpires(int n) {
    return 'Not full within $n min: the entry fee comes back';
  }

  @override
  String sngFormatValue(String variant, int points) {
    return '$variant · $points points';
  }

  @override
  String get sngEntryFee => 'Entry fee';

  @override
  String get sngTimeControl => 'Time control';

  @override
  String sngNoShowRule(int n) {
    return 'A player who hasn\'t joined $n seconds after the round opens loses the round by walkover.';
  }

  @override
  String get sngLeave => 'Leave · entry fee refunded';

  @override
  String noShowOverline(int round, int table) {
    return 'ROUND $round · TABLE $table';
  }

  @override
  String get noShowTitle => 'Your opponent hasn\'t joined yet';

  @override
  String noShowBody(String name) {
    return 'If $name doesn\'t arrive before the time runs out, you win the round by walkover.';
  }

  @override
  String get tourBracket => 'Tournament bracket';

  @override
  String get walkoverTitle => 'You\'re through to the next round';

  @override
  String walkoverBody(String name) {
    return '$name didn\'t join in time. The round is yours by walkover. Your rating doesn\'t change.';
  }

  @override
  String walkoverNextRound(int n) {
    return 'Round $n starts';
  }

  @override
  String get walkoverNextRoundWhen => 'when the other matches end';

  @override
  String get notFilledTitle => 'The tournament didn\'t start';

  @override
  String notFilledBody(int minutes, int size, int joined) {
    return 'Only $joined of $size players joined in $minutes minutes. Your entry fee is back on your balance.';
  }

  @override
  String get notFilledBodyScheduled => 'Not enough players joined. Your entry fee is back on your balance.';

  @override
  String refunded(String amount) {
    return '+$amount refunded';
  }

  @override
  String notFilledJoinSmaller(int n) {
    return 'Join the $n-player table';
  }

  @override
  String get backToTournaments => 'Back to tournaments';

  @override
  String get privateTourTitle => 'Private tournament';

  @override
  String get privateTourName => 'Name';

  @override
  String get privateTourNameHint => 'Tournament name';

  @override
  String get privateTourSize => 'PLAYERS';

  @override
  String get privateTourGame => 'Game';

  @override
  String get privateTourLength => 'Match length';

  @override
  String get privateTourStart => 'Start time';

  @override
  String get privateTourStartManual => 'You start it';

  @override
  String privateTourStartValue(String weekday, String time) {
    return '$weekday, $time';
  }

  @override
  String get privateTourEntry => 'Entry fee';

  @override
  String get privateTourFree => 'Free';

  @override
  String get privateTourNote => 'Creating is free. Private tournaments don\'t affect your rating.';

  @override
  String get privateTourCreate => 'Create tournament';

  @override
  String get privateTourCodeLabel => 'INVITE CODE';

  @override
  String privateTourMeta(String when, String variant, int points) {
    return '$when · $variant, $points points';
  }

  @override
  String get privateTourCopyInvite => 'Copy invite';

  @override
  String privateTourShareText(String name, String code) {
    return 'Join \"$name\" on NardArena. Invite code: $code';
  }

  @override
  String get privateTourRegistration => 'REGISTRATION';

  @override
  String get privateTourOrganizer => 'Organiser';

  @override
  String get privateTourJoined => 'Joined';

  @override
  String privateTourStartNowMin(int n) {
    return 'Start now · at least $n players';
  }

  @override
  String get privateTourStartNow => 'Start now';

  @override
  String get privateTourCancel => 'Cancel tournament';

  @override
  String get privateTourCancelTitle => 'Cancel the tournament?';

  @override
  String get privateTourCancelBody => 'The tournament closes for everyone who registered.';

  @override
  String get privateTourRemove => 'Remove from tournament';

  @override
  String get privateTourCodeHint => '6-character code';

  @override
  String get privateTourCodeNotFound => 'No tournament with this code.';

  @override
  String get privateTourTooMany => 'You can have at most 3 open private tournaments.';

  @override
  String get privateTourNotEnough => 'You need at least 2 players to start.';

  @override
  String homeTourMeta(String prize) {
    return 'Prize pool · $prize';
  }

  @override
  String homeTourStarts(String time, String prize) {
    return 'Starts $time · $prize';
  }

  @override
  String homeSeason(int n, int days) {
    return 'SEASON $n · $days DAYS';
  }

  @override
  String homeSeasonLevel(int level, int max) {
    return 'Level $level / $max';
  }

  @override
  String get homePuzzleOverline => 'DAILY PUZZLE';

  @override
  String homeSeasonEnded(int n) {
    return 'SEASON $n IS OVER';
  }

  @override
  String get homeSeasonSummaryCta => 'See your results';

  @override
  String get modePuzzles => 'Puzzles';

  @override
  String seasonN(int n) {
    return 'Season $n';
  }

  @override
  String get lbScopeGlobal => 'Global';

  @override
  String get lbScopeCountry => 'Country';

  @override
  String get lbScopeFriends => 'Friends';

  @override
  String get lbScopeClan => 'Clan';

  @override
  String lbRank(int n) {
    return '#$n';
  }

  @override
  String get lbEmptyTitle => 'Nobody here yet';

  @override
  String get lbEmptyFriends => 'None of your friends are ranked yet.';

  @override
  String get lbEmptyClan => 'You have no clan, or its members aren\'t ranked yet.';

  @override
  String get lbEmptyCountry => 'No country on your profile, or nobody from it is ranked yet.';

  @override
  String lbUnranked(int n) {
    return 'Play $n ranked games this season to be listed';
  }

  @override
  String get lbSeasonPicker => 'Choose a season';

  @override
  String get seasonPassTitle => 'Season pass';

  @override
  String seasonOverline(int n, int days, int hours) {
    return 'SEASON $n · $days D $hours H';
  }

  @override
  String seasonOverlineHours(int n, int hours, int minutes) {
    return 'SEASON $n · $hours H $minutes MIN';
  }

  @override
  String seasonLevelNext(int n) {
    return 'Next level: $n';
  }

  @override
  String get seasonLevelMax => 'Top level';

  @override
  String get seasonTrackFree => 'FREE';

  @override
  String get seasonTrackPremium => 'PREMIUM';

  @override
  String get seasonRewardItem => 'Item';

  @override
  String seasonEndReward(String tier) {
    return 'Season-end reward · $tier';
  }

  @override
  String seasonEndRewardMeta(String reward, int points) {
    return '$reward · $points points to go';
  }

  @override
  String seasonEndRewardReached(String reward) {
    return '$reward · reached';
  }

  @override
  String seasonRewardWithItem(String item, String coins) {
    return '$item + $coins';
  }

  @override
  String get seasonPremiumUnlock => 'Unlock premium';

  @override
  String seasonClaimAll(int n) {
    return 'Claim all · $n';
  }

  @override
  String get seasonPremiumOwned => 'Premium is active';

  @override
  String get seasonPremiumSheetTitle => 'Season pass · Premium';

  @override
  String get seasonPremiumBody => 'Premium opens this season\'s premium track. Rewards for levels you\'ve reached can be claimed right away.';

  @override
  String get seasonPremiumBought => 'Premium unlocked';

  @override
  String seasonNeedsLevel(int n) {
    return 'Needs level $n';
  }

  @override
  String get seasonNeedsPremium => 'This reward is on the premium track';

  @override
  String get seasonClaimedToast => 'Reward claimed';

  @override
  String get seasonUnavailable => 'Season info didn\'t load';

  @override
  String seasonEnded(int n) {
    return 'SEASON $n IS OVER';
  }

  @override
  String get seasonStatGames => 'Games';

  @override
  String get seasonStatWinRate => 'Wins';

  @override
  String get seasonStatRank => 'Global rank';

  @override
  String get seasonStatCountryRank => 'Country rank';

  @override
  String get seasonStatRatingGain => 'Rating change';

  @override
  String get seasonStatRating => 'Final rating';

  @override
  String get seasonClaimRewards => 'Collect rewards';

  @override
  String seasonRewardLine(String reward) {
    return 'Season reward: $reward';
  }

  @override
  String seasonSoftReset(int rating) {
    return 'Your rating this season: $rating';
  }

  @override
  String get seasonNoSummaryTitle => 'No finished season yet';

  @override
  String get seasonNoSummaryBody => 'Your results show up here when the first season ends.';

  @override
  String get actionAnalysis => 'Analysis';

  @override
  String analysisTitle(int n) {
    return 'Analysis · Game $n';
  }

  @override
  String get analysisEquity => 'Eval';

  @override
  String get analysisNote => 'Evaluations come from the heuristic bot, not exact winning chances. They get sharper when the neural AI arrives.';

  @override
  String analysisBest(String moves) {
    return 'Best: $moves';
  }

  @override
  String analysisYours(String moves, String loss) {
    return 'Yours: $moves · $loss';
  }

  @override
  String get analysisBestPlayed => 'Best move';

  @override
  String get analysisRunning => 'Analysing…';

  @override
  String get analysisMarkGood => 'Good move';

  @override
  String get analysisMarkMistake => 'Mistake';

  @override
  String get analysisMarkBlunder => 'Blunder';

  @override
  String get analysisNotReady => 'The match record isn\'t ready yet. Try again in a moment.';

  @override
  String get analysisNoGames => 'No games were played in this match.';

  @override
  String analysisGameChip(int n) {
    return 'Game $n';
  }

  @override
  String puzzleTitle(int n, int total) {
    return 'Puzzle $n / $total';
  }

  @override
  String get puzzleDailyTitle => 'Daily puzzle';

  @override
  String puzzleRating(int n) {
    return 'Rating $n';
  }

  @override
  String get puzzlePhaseOpening => 'Opening';

  @override
  String get puzzlePhaseMiddle => 'Middle game';

  @override
  String get puzzlePhaseBearOff => 'Bear-off';

  @override
  String get puzzleLevelEasy => 'Easy';

  @override
  String get puzzleLevelMedium => 'Medium';

  @override
  String get puzzleLevelHard => 'Hard';

  @override
  String get puzzlePrompt => 'Find the best move';

  @override
  String puzzleContext(String side, int d1, int d2) {
    return 'You play $side. Dice: $d1 – $d2.';
  }

  @override
  String get puzzleSideWhite => 'white';

  @override
  String get puzzleSideBlack => 'black';

  @override
  String get puzzleHint => 'Hint';

  @override
  String get puzzleConfirm => 'Confirm move';

  @override
  String get puzzleCorrect => 'Correct';

  @override
  String get puzzleCorrectFirstTry => 'Best move · first try';

  @override
  String get puzzleCorrectSecondTry => 'Best move · second try';

  @override
  String get puzzleYours => 'Yours';

  @override
  String get puzzleSecondBest => 'Second best';

  @override
  String get puzzleBest => 'Best';

  @override
  String get puzzleHidden => 'hidden';

  @override
  String get puzzleSeeAnalysis => 'See analysis';

  @override
  String get puzzleNext => 'Next puzzle';

  @override
  String get puzzleWrong => 'Not the best move';

  @override
  String puzzleAttemptsLeft(int n) {
    return 'Attempts left: $n';
  }

  @override
  String get puzzleShowSolution => 'Show solution';

  @override
  String get puzzleOutOfTries => 'No attempts left';

  @override
  String puzzleAnswer(String move) {
    return 'Answer: $move';
  }

  @override
  String get puzzleSetDoneTitle => 'You\'ve done every puzzle';

  @override
  String get puzzleSetDoneBody => 'New puzzles are on the way.';

  @override
  String get puzzleDailyDone => 'Today\'s puzzle is done. Carry on with the next ones.';

  @override
  String get puzzleOffline => 'Checking puzzles needs a connection.';

  @override
  String missionPuzzle(int n) {
    return 'Solve $n puzzles';
  }

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifReadAll => 'Mark all read';

  @override
  String get notifTabAll => 'All';

  @override
  String get notifTabGame => 'Game';

  @override
  String get notifTabSocial => 'Social';

  @override
  String get notifTabTournament => 'Tournament';

  @override
  String get notifToday => 'TODAY';

  @override
  String get notifYesterday => 'YESTERDAY';

  @override
  String get notifEarlier => 'EARLIER';

  @override
  String get notifNow => 'now';

  @override
  String notifMinutesAgo(int n) {
    return '$n min';
  }

  @override
  String notifHoursAgo(int n) {
    return '$n h';
  }

  @override
  String notifYesterdayAt(String time) {
    return 'Yesterday $time';
  }

  @override
  String get notifEmptyTitle => 'No notifications';

  @override
  String get notifEmptyBody => 'Friend requests, game invites and tournament news will show up here.';

  @override
  String get notifDelete => 'Delete';

  @override
  String notifBellLabel(int n) {
    return 'Notifications, $n unread';
  }

  @override
  String get notifGone => 'This invite is no longer valid';

  @override
  String get notifFriendRequest => 'sent you a friend request';

  @override
  String get notifFriendAccepted => 'accepted your friend request';

  @override
  String notifChallenge(String variant, int points) {
    return 'invites you to play · $variant, $points points';
  }

  @override
  String notifClanInvite(String clan, String tag) {
    return 'invites you to the clan $clan [$tag]';
  }

  @override
  String get notifClanJoined => 'accepted you as a member';

  @override
  String get notifClanWarWho => 'Clan war:';

  @override
  String notifClanWar(String opponent, String tag) {
    return 'opponent $opponent [$tag]. Every win scores for your clan';
  }

  @override
  String notifTournamentReminder(int n) {
    return 'starts in $n minutes';
  }

  @override
  String get notifTournamentStarted => 'has started. Your first match is ready';

  @override
  String notifTournamentRound(int round, String opponent) {
    return '· Round $round is ready. Opponent: $opponent';
  }

  @override
  String notifTournamentEliminated(int round) {
    return '· Round $round: your run is over';
  }

  @override
  String get notifTournamentWon => '· You are the champion! The prize is in your account';

  @override
  String notifTournamentFinished(int place) {
    return 'is over · Your place: $place';
  }

  @override
  String notifSeasonEndWho(int n) {
    return 'Season $n';
  }

  @override
  String notifSeasonEnd(String tier) {
    return 'is over · Your tier: $tier. See your results';
  }

  @override
  String notifLevelUpWho(int level) {
    return 'Level $level!';
  }

  @override
  String notifLevelUp(int coins) {
    return 'You earned $coins coins';
  }

  @override
  String get notifUnknown => 'New notification';

  @override
  String get notifGroupGame => 'GAME';

  @override
  String get notifGroupTournament => 'TOURNAMENTS';

  @override
  String get notifGroupSocial => 'SOCIAL';

  @override
  String get notifGroupRewards => 'REWARDS';

  @override
  String get notifPush => 'Push notifications';

  @override
  String get notifPushUnavailable => 'Push is not live in this version yet; everything shows in the inbox';

  @override
  String get notifQuietHours => 'Quiet hours';

  @override
  String notifQuietRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get notifQuietOff => 'Off';

  @override
  String get notifQuietBody => 'No pushes during these hours; notifications stay in the inbox.';

  @override
  String get notifQuietFrom => 'From';

  @override
  String get notifQuietTo => 'To';

  @override
  String get notifQuietSave => 'Save';

  @override
  String get notifEarlierHour => 'One hour earlier';

  @override
  String get notifLaterHour => 'One hour later';

  @override
  String get notifGameInvites => 'Game invites';

  @override
  String get notifTournamentStart => 'Tournament starting';

  @override
  String notifTournamentStartSub(int n) {
    return '$n minutes before';
  }

  @override
  String get notifRoundReady => 'Round ready';

  @override
  String get notifRoundReadySub => 'And tournament results';

  @override
  String get notifFriendRequests => 'Friend requests';

  @override
  String get notifClanInvites => 'Clan invites';

  @override
  String get notifClanWars => 'Clan war';

  @override
  String get notifSeasonResults => 'Season results';

  @override
  String get notifPromptTitle => 'Never miss your turn';

  @override
  String get notifPromptBody => 'We will let you know when a tournament starts, your round is ready or a friend invites you. You can turn off each category in settings.';

  @override
  String get notifPromptSample1 => 'Nigar invites you to play · Short Nard, 5 points';

  @override
  String get notifPromptSample2 => 'Baku Friday Cup starts in 15 minutes.';

  @override
  String get notifPromptAllow => 'Turn on notifications';

  @override
  String get notifPromptLater => 'Not now';

  @override
  String get bannedTitle => 'Account suspended';

  @override
  String bannedBodyUntil(String date) {
    return 'Your account is suspended until $date for breaking the fair-play rules.';
  }

  @override
  String get bannedBodyPermanent => 'Your account is suspended permanently for breaking the fair-play rules.';

  @override
  String bannedContact(String email) {
    return 'If you think this is a mistake, write to $email.';
  }

  @override
  String get bannedOffline => 'You can sign out and keep playing offline against the computer or with a friend.';

  @override
  String get bannedOverTitle => 'Suspension over';

  @override
  String get bannedOverBody => 'Your account is active again. Thank you for playing fair.';

  @override
  String get bannedContinue => 'Continue';

  @override
  String get authBanned => 'This account is suspended';

  @override
  String clanChatMuted(String time) {
    return 'You cannot post in chat until $time.';
  }

  @override
  String get clanChatMutedNoTime => 'You cannot post in chat for now.';

  @override
  String get queueCooldownTitle => 'Matchmaking paused';

  @override
  String queueCooldownBody(String time) {
    return 'After several unfinished matches, the public queue reopens in $time. Private rooms and tournaments are open.';
  }

  @override
  String get queueCooldownOverBody => 'The queue is open again.';

  @override
  String get queueCooldownSearch => 'Search again';

  @override
  String get notifModerationWarningWho => 'Warning from the moderators:';

  @override
  String notifModerationWarning(String reason) {
    return 'please follow the fair-play rules. Reason: $reason';
  }

  @override
  String get notifModerationWarningPlain => 'please follow the fair-play rules';
}
