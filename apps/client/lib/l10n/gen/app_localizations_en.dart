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
  String get exportBody => 'Your profile and match history are packed into a JSON file. When it\'s ready you can copy it.';

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
  String get exportFormat => 'Format';

  @override
  String get exportFormatValue => 'JSON';

  @override
  String get exportStart => 'Start export';

  @override
  String exportReady(String size) {
    return 'File ready · $size KB';
  }

  @override
  String get exportCopy => 'Copy JSON';

  @override
  String get deleteTitle => 'Delete your account?';

  @override
  String deleteItemRating(int rating) {
    return 'Your rating ($rating), rank and full match history';
  }

  @override
  String get deleteItemHistory => 'Your profile and full match history';

  @override
  String get deleteIrreversible => 'The account is deleted right away and can\'t be restored.';

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
  String get timeRapid => 'Rapid';

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
}
