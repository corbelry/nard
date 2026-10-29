// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'NardArena';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get back => 'Назад';

  @override
  String get cancel => 'Отмена';

  @override
  String get retry => 'Повторить';

  @override
  String get valueOn => 'Вкл.';

  @override
  String get valueOff => 'Выкл.';

  @override
  String get variantShort => 'Короткие нарды';

  @override
  String get variantLong => 'Длинные нарды';

  @override
  String get variantShortUpper => 'КОРОТКИЕ НАРДЫ';

  @override
  String get variantLongUpper => 'ДЛИННЫЕ НАРДЫ';

  @override
  String matchToPointsUpper(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ОЧКОВ',
      one: '$n ОЧКА',
    );
    return 'ДО $_temp0';
  }

  @override
  String get oneGameUpper => '1 ПАРТИЯ';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get playerWhite => 'Белые';

  @override
  String get playerBlack => 'Чёрные';

  @override
  String get computerName => 'Компьютер';

  @override
  String get you => 'Ты';

  @override
  String get languageTitle => 'Выбери язык';

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
    return 'ШАГ $current / $total';
  }

  @override
  String get variantQuestionTitle => 'В какие нарды ты играешь?';

  @override
  String get variantShortDesc =>
      'Классический бэкгаммон: бой, бар, куб удвоения.';

  @override
  String get variantLongDesc =>
      'Все шашки на голове. Бить нельзя, только блокировать.';

  @override
  String get variantLearnTitle => 'Хочу научиться';

  @override
  String variantLearnDesc(int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps шагов',
      one: '$steps шага',
    );
    return 'Интерактивный урок из $_temp0, 5 минут.';
  }

  @override
  String get lessonSkip => 'Пропустить';

  @override
  String lessonProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get lessonStep1Title => 'Это твоя доска';

  @override
  String get lessonStep1Body =>
      'Белые шашки — твои. Они идут с 24-го пункта к 1-му, а затем выбрасываются с доски. Коснись любой шашки, чтобы продолжить.';

  @override
  String get lessonStep2Title => 'Передвинь шашку на 6 пунктов';

  @override
  String get lessonStep2Body =>
      'На кубике 6. Коснись шашки на 13-м пункте, затем коснись подсвеченного 7-го пункта или перетащи шашку туда.';

  @override
  String get lessonStep3Title => 'Сыграй оба кубика';

  @override
  String get lessonStep3Body =>
      'На кубиках 3 и 1. Передвинь шашки с 8-го и 6-го пунктов на 5-й и закрой пункт.';

  @override
  String get lessonStep4Title => 'Закрытый пункт';

  @override
  String get lessonStep4Body =>
      'Нельзя ходить на пункт, где стоят две и более шашки соперника. На кубике 5: передвинь шашку с 13-го пункта на 8-й.';

  @override
  String get lessonStep5Title => 'Бой';

  @override
  String get lessonStep5Body =>
      'Если встанешь на одиночную шашку соперника, она уходит на бар. Передвинь шашку с 6-го пункта на 4-й и побей.';

  @override
  String get lessonStep6Title => 'Ввод с бара';

  @override
  String get lessonStep6Body =>
      'Если у тебя есть шашка на баре, сначала нужно ввести её в дом соперника. Коснись шашки на баре и передвинь её на 22-й пункт.';

  @override
  String get lessonStep7Title => 'Выброси шашки';

  @override
  String get lessonStep7Body =>
      'Все шашки в доме (1–6). На кубике 6: выброси шашку с 6-го пункта.';

  @override
  String get lessonDoneTitle => 'Отлично, можно играть';

  @override
  String get lessonDoneBody =>
      'Ты знаешь правила. Теперь потренируйся против компьютера.';

  @override
  String get lessonFinish => 'Начать игру';

  @override
  String get homePlay => 'Играть';

  @override
  String get homeChangeMode => 'Сменить режим';

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
    return 'Против компьютера · $level';
  }

  @override
  String get modeComputer => 'Компьютер';

  @override
  String get modeSameDevice => 'Одно устройство';

  @override
  String get modeLesson => 'Урок';

  @override
  String get modeReplays => 'Мои игры';

  @override
  String get setupTitle => 'Новая игра';

  @override
  String get setupVariantLabel => 'ВАРИАНТ';

  @override
  String get setupFormatLabel => 'ФОРМАТ';

  @override
  String get formatOneGame => '1 партия';

  @override
  String formatPoints(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n очка',
      many: '$n очков',
      few: '$n очка',
      one: '$n очко',
    );
    return '$_temp0';
  }

  @override
  String get setupCube => 'Куб удвоения';

  @override
  String get aiTitle => 'Против компьютера';

  @override
  String get aiLevelBeginner => 'Новичок';

  @override
  String get aiLevelAmateur => 'Любитель';

  @override
  String get aiLevelMedium => 'Средний';

  @override
  String get aiLevelStrong => 'Сильный';

  @override
  String get aiLevelMaster => 'Мастер';

  @override
  String get aiLevelGrandmaster => 'Гроссмейстер';

  @override
  String get aiLevelBeginnerDesc => 'Для тех, кто учит правила';

  @override
  String get aiLevelAmateurDesc => 'Допускает простые ошибки';

  @override
  String get aiLevelMediumDesc => 'Знает базовую стратегию';

  @override
  String get aiLevelStrongDesc => 'Редко ошибается, верно работает с кубом';

  @override
  String get aiLevelMasterDesc => 'Уровень клубного игрока';

  @override
  String get aiLevelGrandmasterDesc => 'Самый сильный режим, не ошибается';

  @override
  String aiStart(String level) {
    return 'Начать · $level';
  }

  @override
  String get hotseatTitle => 'На одном устройстве';

  @override
  String get hotseatWhite => 'Белые шашки';

  @override
  String get hotseatBlack => 'Чёрные шашки';

  @override
  String get hotseatGameSection => 'ИГРА';

  @override
  String get hotseatHideBetweenTurns => 'Скрывать экран между ходами';

  @override
  String get hotseatHideBetweenTurnsSub => 'Экран «Передай телефон сопернику»';

  @override
  String get hotseatFlipBoard => 'Переворачивать доску';

  @override
  String get hotseatFlipBoardSub => 'Каждый ход — к следующему игроку';

  @override
  String get hotseatAllowUndo => 'Отмена хода';

  @override
  String get hotseatAllowUndoSub => 'Пока соперник не готов';

  @override
  String get hotseatStart => 'Начать игру';

  @override
  String get hotseatEditName => 'Изменить имя';

  @override
  String get hotseatNameHint => 'Имя игрока';

  @override
  String get hotseatDefaultWhite => 'Игрок 1';

  @override
  String get hotseatDefaultBlack => 'Игрок 2';

  @override
  String get handoffOverline => 'СМЕНА ХОДА';

  @override
  String handoffTitle(String name) {
    return 'Ход: $name';
  }

  @override
  String handoffBody(String side, String prevName, String moves) {
    return '$side. $prevName — последний ход: $moves.';
  }

  @override
  String handoffBodyNoMove(String side, String prevName) {
    return '$side. $prevName — ходов не было.';
  }

  @override
  String handoffFirst(String side) {
    return '$side. Ты начинаешь игру.';
  }

  @override
  String handoffReady(String name) {
    return '$name: мой ход';
  }

  @override
  String handoffUndo(String prevName) {
    return '$prevName: отменить ход';
  }

  @override
  String gameModeTo(String variant, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очков',
      one: '$points очка',
    );
    return '$variant · до $_temp0';
  }

  @override
  String gameModeSingle(String variant) {
    return '$variant · 1 партия';
  }

  @override
  String gameScore(int me, int opp) {
    return '$me – $opp';
  }

  @override
  String get bannerYourTurn => 'Твой ход';

  @override
  String bannerTurnOf(String name) {
    return 'Ход: $name';
  }

  @override
  String get bannerRollHint => 'Брось кости или предложи удвоение';

  @override
  String bannerLegalMoveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count возможного хода',
      many: '$count возможных ходов',
      few: '$count возможных хода',
      one: '$count возможный ход',
    );
    return '$_temp0';
  }

  @override
  String get bannerRolling => 'Бросок костей';

  @override
  String get bannerOpening => 'Кто начинает?';

  @override
  String get bannerOpeningTie => 'Ничья · переброс';

  @override
  String bannerOpeningWinner(String name) {
    return '$name начинает';
  }

  @override
  String get bannerOpponentThinking => 'Соперник думает';

  @override
  String bannerDice(int a, int b) {
    return 'Кости $a – $b';
  }

  @override
  String get bannerCubeOffer => 'Предложение удвоения';

  @override
  String get bannerCubeWaiting => 'Ждём ответа';

  @override
  String get bannerNoMoves => 'Нет ходов';

  @override
  String get bannerGameOver => 'Партия окончена';

  @override
  String get bannerHeadRuleHint => 'С головы — только одна шашка';

  @override
  String get bannerIllegalMove => 'Недопустимый ход';

  @override
  String get bannerOpponentNeedsOne => 'Сопернику остаётся 1 очко';

  @override
  String get bannerYouNeedOne => 'Тебе остаётся 1 очко';

  @override
  String get crawfordChip => 'Партия Crawford · без куба';

  @override
  String get actionRoll => 'Бросить кости';

  @override
  String get actionConfirm => 'Подтвердить';

  @override
  String actionMovesProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get actionPass => 'Пас';

  @override
  String get actionNextGame => 'Следующая партия';

  @override
  String get actionUndo => 'Отменить ход';

  @override
  String get actionDouble => 'Удвоить';

  @override
  String get actionMenu => 'Меню';

  @override
  String playerPip(int pip) {
    return 'Pip $pip';
  }

  @override
  String playerBotLevel(String level) {
    return 'Компьютер · $level';
  }

  @override
  String get noMovesTitle => 'Нет возможных ходов';

  @override
  String noMovesBody(int a, int b, String reason) {
    return '$a – $b · $reason. Через 2 секунды ход перейдёт к сопернику.';
  }

  @override
  String get noMovesReasonBar => 'вход с бара закрыт';

  @override
  String get noMovesReasonBlocked => 'все пути закрыты';

  @override
  String cubeOfferTitle(String name) {
    return '$name предлагает удвоение';
  }

  @override
  String cubeOfferBody(int from, int to) {
    return 'Стоимость партии: $from → $to. Если примешь, куб перейдёт к тебе.';
  }

  @override
  String get cubeDecline => 'Отказаться';

  @override
  String cubeDeclineSub(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return '−$_temp0, партия окончена';
  }

  @override
  String get cubeAccept => 'Принять';

  @override
  String cubeAcceptSub(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return 'Ставка: $_temp0';
  }

  @override
  String cubeBotTook(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return 'Компьютер принял удвоение · ставка: $_temp0';
  }

  @override
  String get gameWonTitle => 'ПОБЕДА';

  @override
  String get gameLostTitle => 'ПОРАЖЕНИЕ';

  @override
  String gameWinnerTitle(String name) {
    return 'ПОБЕДА: $name';
  }

  @override
  String resultSingle(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return '+$_temp0';
  }

  @override
  String resultMars(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return 'Марс · +$_temp0';
  }

  @override
  String resultKoks(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return 'Кокс · +$_temp0';
  }

  @override
  String resultDropped(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return 'Удвоение отклонено · +$_temp0';
  }

  @override
  String resultResigned(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return 'Сдача · +$_temp0';
  }

  @override
  String gameMatchProgress(int target, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target очков',
      one: '$target очка',
    );
    String _temp1 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left очка',
      many: '$left очков',
      few: '$left очка',
      one: '$left очко',
    );
    return 'До $_temp0 · до победы в матче: $_temp1';
  }

  @override
  String get actionViewReplay => 'Повтор';

  @override
  String get matchWonTitle => 'Победа в матче';

  @override
  String get matchLostTitle => 'Поражение в матче';

  @override
  String matchWinnerTitle(String name) {
    return '$name выигрывает матч';
  }

  @override
  String matchMeta(String me, String opp, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очков',
      one: '$points очка',
    );
    return '$me · $opp · до $_temp0';
  }

  @override
  String matchMetaSingle(String me, String opp) {
    return '$me · $opp · 1 партия';
  }

  @override
  String get matchRematch => 'Реванш';

  @override
  String get matchHome => 'На главную';

  @override
  String get resignTitle => 'Сдаться';

  @override
  String resignBody(int cube) {
    return 'Куб: ×$cube. Выбери, сколько очков отдать сопернику.';
  }

  @override
  String get resignSingle => 'Одиночная';

  @override
  String get resignSingleDesc => 'Обычное поражение';

  @override
  String get resignMars => 'Марс';

  @override
  String get resignMarsDesc => 'Ни одна шашка не выброшена';

  @override
  String get resignKoks => 'Кокс';

  @override
  String get resignKoksDesc => 'Шашка на баре или в доме соперника';

  @override
  String get resignKoksDescLong => 'Шашка ещё не вышла из дома соперника';

  @override
  String resignPoints(int points) {
    return '−$points';
  }

  @override
  String resignConfirm(int points) {
    return 'Сдаться · −$points';
  }

  @override
  String get menuResume => 'Вернуться в игру';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get menuRules => 'Правила';

  @override
  String get menuSound => 'Звук';

  @override
  String get menuResign => 'Сдаться';

  @override
  String get menuLeave => 'Выйти из игры';

  @override
  String get leaveTitle => 'Выйти из игры?';

  @override
  String get leaveBody => 'Эта игра не сохранится.';

  @override
  String get leaveConfirm => 'Выйти';

  @override
  String get ruleHeadTitle => 'С головы можно взять только одну шашку';

  @override
  String get ruleHeadBody =>
      'В этот ход с головы сыграно больше одной шашки. Исключение: при первом броске 6-6, 4-4 или 3-3 можно взять две.';

  @override
  String get ruleSixBlockTitle => 'Нельзя закрывать 6 пунктов подряд';

  @override
  String ruleSixBlockBody(String from, String to) {
    return 'Ход $from → $to строит заграждение из 6 пунктов, а впереди нет ни одной шашки соперника. Выбери другой ход.';
  }

  @override
  String get rulePointClosedTitle => 'Этот пункт закрыт';

  @override
  String get rulePointClosedShort =>
      'Нельзя ходить на пункт, где стоят две и более шашки соперника.';

  @override
  String get rulePointClosedLong =>
      'В длинных нардах нельзя ходить на пункт с шашкой соперника.';

  @override
  String get ruleBarTitle => 'Сначала введи шашку с бара';

  @override
  String get ruleBarBody =>
      'Пока у тебя есть шашка на баре, другими шашками ходить нельзя.';

  @override
  String get ruleBothDiceTitle => 'Нужно сыграть оба кубика';

  @override
  String get ruleBothDiceBody =>
      'Этот ход не даёт сыграть второй кубик. Выбери ход, который использует оба кубика.';

  @override
  String get ruleLargerDieTitle => 'Сыграй больший кубик';

  @override
  String get ruleLargerDieBody =>
      'Если можно сыграть только один кубик, нужно сыграть больший.';

  @override
  String get ruleBearOffTitle => 'Выбрасывать ещё нельзя';

  @override
  String get ruleBearOffBody =>
      'Чтобы выбрасывать шашки, все они должны быть в доме (1–6).';

  @override
  String get ruleBearOffHigherTitle =>
      'Сначала сыграй шашку с более высокого пункта';

  @override
  String get ruleBearOffHigherBody =>
      'Большим кубиком можно выбросить только шашку с самого высокого пункта.';

  @override
  String get ruleNoDieTitle => 'Нет кубика на это расстояние';

  @override
  String get ruleNoDieBody =>
      'Шашку можно передвинуть только на число пунктов, выпавшее на кубиках.';

  @override
  String get ruleNoCheckerTitle => 'На этом пункте нет твоей шашки';

  @override
  String get ruleTurnCompleteTitle => 'Все кубики сыграны';

  @override
  String get ruleTurnCompleteBody => 'Подтверди ход или отмени его.';

  @override
  String get replayListTitle => 'Мои игры';

  @override
  String get replayEmptyTitle => 'Пока нет игр';

  @override
  String get replayEmptyBody =>
      'Завершённые игры появятся здесь. В повторе можно заново просмотреть каждый ход.';

  @override
  String replayTitle(int n) {
    return 'Повтор · Партия $n';
  }

  @override
  String replayPlayers(String p1, String p2) {
    return '$p1 – $p2';
  }

  @override
  String get replayStart => 'Начало';

  @override
  String get replayBack => 'Назад';

  @override
  String get replayPlay => 'Пуск';

  @override
  String get replayPause => 'Пауза';

  @override
  String get replayForward => 'Вперёд';

  @override
  String get replayEnd => 'Конец';

  @override
  String replayOpening(int a, int b) {
    return 'Первый бросок: $a – $b';
  }

  @override
  String get replayNoMove => 'нет хода';

  @override
  String get replayDouble => 'предложено удвоение';

  @override
  String get replayTake => 'принято';

  @override
  String get replayDrop => 'отказ';

  @override
  String get replayResign => 'сдача';

  @override
  String replayWon(String name, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return 'Победа: $name · $_temp0';
  }

  @override
  String get replayLoadError => 'Не удалось открыть игру';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsGroupGame => 'ИГРА';

  @override
  String get settingsGroupAccessibility => 'ДОСТУПНОСТЬ';

  @override
  String get settingsGroupGeneral => 'ОБЩИЕ';

  @override
  String get settingsConfirmMove => 'Подтверждать ход';

  @override
  String get settingsAutoRoll => 'Автоматический бросок';

  @override
  String get settingsShowLegalMoves => 'Показывать возможные ходы';

  @override
  String get settingsPipCount => 'Счёт Pip';

  @override
  String get settingsAnimationSpeed => 'Скорость анимации';

  @override
  String get animationSpeedSlow => 'Медленно';

  @override
  String get animationSpeedNormal => 'Обычно';

  @override
  String get animationSpeedFast => 'Быстро';

  @override
  String get settingsColorBlind => 'Режим для дальтоников';

  @override
  String get settingsLargePips => 'Крупные точки на кубиках';

  @override
  String get settingsReduceMotion => 'Уменьшить движение';

  @override
  String get settingsSound => 'Звук';

  @override
  String get settingsHaptics => 'Вибрация';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsReplays => 'Мои игры';

  @override
  String get settingsLesson => 'Пройти урок заново';

  @override
  String settingsAbout(String version) {
    return 'Версия $version';
  }

  @override
  String get errorTitle => 'Что-то пошло не так';

  @override
  String get errorBody =>
      'Попробуй ещё раз. Если проблема не исчезнет, перезапусти приложение.';

  @override
  String get playVsComputer => 'Играть с компьютером';

  @override
  String get rulesShortBody =>
      'У каждого игрока 15 шашек. Шашки ходят по кубикам от 24 к 1. Если встанешь на одиночную шашку соперника, она уходит на бар; пункт с двумя и более шашками закрыт. Когда все шашки в доме (1–6), начинается выброс. Побеждает тот, кто первым выбросит все 15 шашек. Если соперник не выбросил ни одной шашки — марс (×2), если его шашка на баре или в твоём доме — кокс (×3).';

  @override
  String get rulesLongBody =>
      'Все 15 шашек начинают с головы (24-й пункт). Боя нет: на пункт с шашкой соперника ходить нельзя. За ход с головы можно взять только одну шашку (исключение — 6-6, 4-4, 3-3 при первом броске). Нельзя закрывать 6 пунктов подряд, если впереди нет ни одной шашки соперника. Когда все шашки в доме, начинается выброс. Если соперник не выбросил ни одной шашки — марс (×2), если его шашка ещё не прошла твой дом — кокс (×3).';
}
