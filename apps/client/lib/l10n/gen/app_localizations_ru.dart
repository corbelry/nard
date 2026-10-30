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
  String get variantShortDesc => 'Классический бэкгаммон: бой, бар, куб удвоения.';

  @override
  String get variantLongDesc => 'Все шашки на голове. Бить нельзя, только блокировать.';

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
  String get lessonStep1Body => 'Белые шашки — твои. Они идут с 24-го пункта к 1-му, а затем выбрасываются с доски. Коснись любой шашки, чтобы продолжить.';

  @override
  String get lessonStep2Title => 'Передвинь шашку на 6 пунктов';

  @override
  String get lessonStep2Body => 'На кубике 6. Коснись шашки на 13-м пункте, затем коснись подсвеченного 7-го пункта или перетащи шашку туда.';

  @override
  String get lessonStep3Title => 'Сыграй оба кубика';

  @override
  String get lessonStep3Body => 'На кубиках 3 и 1. Передвинь шашки с 8-го и 6-го пунктов на 5-й и закрой пункт.';

  @override
  String get lessonStep4Title => 'Закрытый пункт';

  @override
  String get lessonStep4Body => 'Нельзя ходить на пункт, где стоят две и более шашки соперника. На кубике 5: передвинь шашку с 13-го пункта на 8-й.';

  @override
  String get lessonStep5Title => 'Бой';

  @override
  String get lessonStep5Body => 'Если встанешь на одиночную шашку соперника, она уходит на бар. Передвинь шашку с 6-го пункта на 4-й и побей.';

  @override
  String get lessonStep6Title => 'Ввод с бара';

  @override
  String get lessonStep6Body => 'Если у тебя есть шашка на баре, сначала нужно ввести её в дом соперника. Коснись шашки на баре и передвинь её на 22-й пункт.';

  @override
  String get lessonStep7Title => 'Выброси шашки';

  @override
  String get lessonStep7Body => 'Все шашки в доме (1–6). На кубике 6: выброси шашку с 6-го пункта.';

  @override
  String get lessonDoneTitle => 'Отлично, можно играть';

  @override
  String get lessonDoneBody => 'Ты знаешь правила. Теперь потренируйся против компьютера.';

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
  String get ruleHeadBody => 'В этот ход с головы сыграно больше одной шашки. Исключение: при первом броске 6-6, 4-4 или 3-3 можно взять две.';

  @override
  String get ruleSixBlockTitle => 'Нельзя закрывать 6 пунктов подряд';

  @override
  String ruleSixBlockBody(String from, String to) {
    return 'Ход $from → $to строит заграждение из 6 пунктов, а впереди нет ни одной шашки соперника. Выбери другой ход.';
  }

  @override
  String get rulePointClosedTitle => 'Этот пункт закрыт';

  @override
  String get rulePointClosedShort => 'Нельзя ходить на пункт, где стоят две и более шашки соперника.';

  @override
  String get rulePointClosedLong => 'В длинных нардах нельзя ходить на пункт с шашкой соперника.';

  @override
  String get ruleBarTitle => 'Сначала введи шашку с бара';

  @override
  String get ruleBarBody => 'Пока у тебя есть шашка на баре, другими шашками ходить нельзя.';

  @override
  String get ruleBothDiceTitle => 'Нужно сыграть оба кубика';

  @override
  String get ruleBothDiceBody => 'Этот ход не даёт сыграть второй кубик. Выбери ход, который использует оба кубика.';

  @override
  String get ruleLargerDieTitle => 'Сыграй больший кубик';

  @override
  String get ruleLargerDieBody => 'Если можно сыграть только один кубик, нужно сыграть больший.';

  @override
  String get ruleBearOffTitle => 'Выбрасывать ещё нельзя';

  @override
  String get ruleBearOffBody => 'Чтобы выбрасывать шашки, все они должны быть в доме (1–6).';

  @override
  String get ruleBearOffHigherTitle => 'Сначала сыграй шашку с более высокого пункта';

  @override
  String get ruleBearOffHigherBody => 'Большим кубиком можно выбросить только шашку с самого высокого пункта.';

  @override
  String get ruleNoDieTitle => 'Нет кубика на это расстояние';

  @override
  String get ruleNoDieBody => 'Шашку можно передвинуть только на число пунктов, выпавшее на кубиках.';

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
  String get replayEmptyBody => 'Завершённые игры появятся здесь. В повторе можно заново просмотреть каждый ход.';

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
  String get errorBody => 'Попробуй ещё раз. Если проблема не исчезнет, перезапусти приложение.';

  @override
  String get playVsComputer => 'Играть с компьютером';

  @override
  String get rulesShortBody => 'У каждого игрока 15 шашек. Шашки ходят по кубикам от 24 к 1. Если встанешь на одиночную шашку соперника, она уходит на бар; пункт с двумя и более шашками закрыт. Когда все шашки в доме (1–6), начинается выброс. Побеждает тот, кто первым выбросит все 15 шашек. Если соперник не выбросил ни одной шашки — марс (×2), если его шашка на баре или в твоём доме — кокс (×3).';

  @override
  String get rulesLongBody => 'Все 15 шашек начинают с головы (24-й пункт). Боя нет: на пункт с шашкой соперника ходить нельзя. За ход с головы можно взять только одну шашку (исключение — 6-6, 4-4, 3-3 при первом броске). Нельзя закрывать 6 пунктов подряд, если впереди нет ни одной шашки соперника. Когда все шашки в доме, начинается выброс. Если соперник не выбросил ни одной шашки — марс (×2), если его шашка ещё не прошла твой дом — кокс (×3).';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get copied => 'Скопировано';

  @override
  String get valueNone => '—';

  @override
  String get authWelcomeTitle => 'Добро пожаловать';

  @override
  String get authWelcomeBody => 'С аккаунтом твой рейтинг и история матчей сохранятся на всех устройствах.';

  @override
  String get authApple => 'Продолжить с Apple';

  @override
  String get authGoogle => 'Продолжить с Google';

  @override
  String get authEmail => 'Продолжить с e-mail';

  @override
  String get authGuest => 'Играть как гость';

  @override
  String authLegal(String terms, String privacy) {
    return 'Продолжая, ты принимаешь $terms и $privacy.';
  }

  @override
  String get authTerms => 'Условия использования';

  @override
  String get authPrivacy => 'Политику конфиденциальности';

  @override
  String get authProviderUnavailable => 'Этот способ входа пока недоступен. Продолжи через e-mail или как гость.';

  @override
  String get authOffline => 'Нет связи с сервером. Проверь интернет и попробуй снова.';

  @override
  String get authTooManyTries => 'Слишком много попыток. Попробуй чуть позже.';

  @override
  String get authSignIn => 'Войти';

  @override
  String get emailTitle => 'Введи свой e-mail';

  @override
  String get emailBody => 'Пароль не нужен. Мы пришлём 6-значный код для входа.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailSend => 'Отправить код';

  @override
  String get emailInvalid => 'Неверный адрес e-mail';

  @override
  String get codeTitle => 'Введи код';

  @override
  String codeBody(String email) {
    return 'Мы отправили его на $email. Проверь и папку «Спам».';
  }

  @override
  String get codeLabel => '6-значный код';

  @override
  String codeResendIn(String time) {
    return 'Отправить код снова · $time';
  }

  @override
  String get codeResend => 'Отправить код снова';

  @override
  String get codeSent => 'Новый код отправлен';

  @override
  String get codeInvalid => 'Неверный код. Проверь и попробуй снова.';

  @override
  String get codeExpired => 'Срок действия кода истёк. Запроси новый.';

  @override
  String get modeCasual => 'Обычная';

  @override
  String get modeRanked => 'Рейтинговая';

  @override
  String get searchTitle => 'Ищем соперника…';

  @override
  String searchElapsed(String elapsed) {
    return 'Прошло $elapsed';
  }

  @override
  String searchTip(String tip) {
    return 'Совет: $tip';
  }

  @override
  String get searchTipHeadRule => 'В длинных нардах с головы за ход снимают только одну шашку.';

  @override
  String get searchTipPip => 'Счёт пипов показывает, кто впереди в гонке.';

  @override
  String get searchBotSoon => 'Если за 30 секунд живой соперник не найдётся, сыграешь с ботом.';

  @override
  String timeControlShort(int minutes, int delay) {
    return '$minutes+$delay с';
  }

  @override
  String ratingRange(int min, int max) {
    return '$min–$max';
  }

  @override
  String vsMeta(String rank, int rating, int percent) {
    return '$rank · $rating · Побед $percent%';
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
      other: '$n ОЧКА',
      many: '$n ОЧКОВ',
      few: '$n ОЧКА',
      one: '$n ОЧКО',
    );
    return '$_temp0';
  }

  @override
  String get rankedUpper => 'РЕЙТИНГОВАЯ';

  @override
  String get unrankedUpper => 'БЕЗ РЕЙТИНГА';

  @override
  String vsStartsIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds секунды',
      many: '$seconds секунд',
      few: '$seconds секунды',
      one: '$seconds секунду',
    );
    return 'Игра начнётся через $_temp0';
  }

  @override
  String get botBadge => 'BOT';

  @override
  String get botNoRating => 'Не влияет на рейтинг';

  @override
  String get botFallbackNotice => 'За 30 секунд живой соперник не нашёлся, поэтому ты играешь с ботом. Результат не влияет на рейтинг.';

  @override
  String get gameModeCasual => 'Обычная · без рейтинга';

  @override
  String playerBotMeta(String noRating, String pip) {
    return '$noRating · $pip';
  }

  @override
  String get bannerLowTime => 'Время на исходе';

  @override
  String bannerTimeLeft(String time) {
    return 'Осталось $time';
  }

  @override
  String get bannerOpponentOffline => 'Соперник отключился';

  @override
  String get bannerDisconnected => 'Соединение потеряно';

  @override
  String get playerOffline => 'Офлайн';

  @override
  String reconnectTitle(String name) {
    return '$name переподключается…';
  }

  @override
  String reconnectBody(String time) {
    return 'Осталось $time · если время выйдет, победа твоя';
  }

  @override
  String get selfReconnectTitle => 'Восстанавливаем соединение…';

  @override
  String get menuFairDice => 'Честные кости';

  @override
  String get menuFairDiceVerify => 'Проверить';

  @override
  String get matchRatingLabel => 'РЕЙТИНГ';

  @override
  String matchRatingFrom(int old) {
    return 'было $old';
  }

  @override
  String matchRatingToNext(String rank, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points очка',
      many: '$points очков',
      few: '$points очка',
      one: '$points очко',
    );
    return 'До ранга $rank: $_temp0';
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
  String get fairTitle => 'Честные кости';

  @override
  String get fairIntro => 'Каждый бросок вычисляется из серверного ключа, зафиксированного до игры, твоего ключа и номера броска. После игры ты можешь сам проверить любой бросок.';

  @override
  String get fairCommitment => 'Хеш серверного ключа (до игры)';

  @override
  String fairCommitmentValue(String hash) {
    return 'sha256: $hash';
  }

  @override
  String get fairServerSeed => 'Серверный ключ (раскрывается после игры)';

  @override
  String get fairYourSeed => 'Твой ключ';

  @override
  String get fairOpponentSeed => 'Ключ соперника';

  @override
  String get fairRollNumber => 'Номер броска';

  @override
  String fairRollValue(int n, int a, int b) {
    return '#$n · HMAC → $a, $b';
  }

  @override
  String fairMatch(int a, int b) {
    return 'Совпадает · $a – $b';
  }

  @override
  String fairMatchSub(int n) {
    return 'Бросок #$n совпадает с расчётом';
  }

  @override
  String fairMismatch(int a, int b) {
    return 'Не совпадает · $a – $b';
  }

  @override
  String fairMismatchSub(int n) {
    return 'Бросок #$n отличается от расчёта';
  }

  @override
  String get fairCommitmentMismatch => 'Серверный ключ не совпадает с хешем';

  @override
  String get fairPending => 'Откроется после игры';

  @override
  String get fairPendingNote => 'Серверный ключ откроется после окончания игры. Тогда здесь можно будет проверить каждый бросок.';

  @override
  String get fairNoRolls => 'Бросков пока нет';

  @override
  String get fairCopy => 'Скопировать данные';

  @override
  String get fairCheckAnother => 'Проверить другой бросок';

  @override
  String get fairPickTitle => 'Выбери бросок';

  @override
  String fairRollRow(int n, int a, int b) {
    return '#$n · $a – $b';
  }

  @override
  String get fairOpeningTag => 'первый бросок';

  @override
  String get tierBronze => 'Бронза';

  @override
  String get tierSilver => 'Серебро';

  @override
  String get tierGold => 'Золото';

  @override
  String get tierPlatinum => 'Платина';

  @override
  String get tierDiamond => 'Алмаз';

  @override
  String get tierMaster => 'Мастер';

  @override
  String get tierGrandmaster => 'Гроссмейстер';

  @override
  String rankWithSub(String tier, String sub) {
    return '$tier $sub';
  }

  @override
  String profileMeta(String rank, int rating) {
    return '$rank · $rating';
  }

  @override
  String get statRating => 'Рейтинг';

  @override
  String get statWinRate => 'Процент побед';

  @override
  String get statMatches => 'Матчи';

  @override
  String get statWins => 'Победы';

  @override
  String statPercent(int n) {
    return '$n%';
  }

  @override
  String get profileHistory => 'ИСТОРИЯ МАТЧЕЙ';

  @override
  String historyMeta(String variant, String format, String date) {
    return '$variant · $format · $date';
  }

  @override
  String get variantShortAbbr => 'Короткие';

  @override
  String get variantLongAbbr => 'Длинные';

  @override
  String get dateToday => 'сегодня';

  @override
  String get dateYesterday => 'вчера';

  @override
  String historyScore(int me, int opp) {
    return '$me–$opp';
  }

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String get historyEmptyTitle => 'Пока нет онлайн-матчей';

  @override
  String get historyEmptyBody => 'Здесь появятся матчи, сыгранные онлайн.';

  @override
  String get profileSignedOutTitle => 'Войди в аккаунт';

  @override
  String get profileSignedOutBody => 'Здесь будут твой рейтинг, статистика и история матчей.';

  @override
  String get nameInvalid => 'Имя: 3–20 букв, цифр или _';

  @override
  String get offlineBanner => 'Нет сети · офлайн-режим';

  @override
  String get onlineOfflineTitle => 'Онлайн-игра недоступна';

  @override
  String get onlineOfflineBody => 'Игра с компьютером и на одном устройстве работает. Попробуй снова, когда связь вернётся.';

  @override
  String get settingsAccountPrivacy => 'Аккаунт и конфиденциальность';

  @override
  String get accountGroupAccount => 'АККАУНТ';

  @override
  String get accountEmail => 'E-mail';

  @override
  String get accountNickname => 'Имя игрока';

  @override
  String get accountEmailAdd => 'Добавить';

  @override
  String get accountSignOut => 'Выйти из аккаунта';

  @override
  String get accountGroupData => 'ДАННЫЕ';

  @override
  String get accountExport => 'Экспортировать мои данные';

  @override
  String get accountDelete => 'Удалить аккаунт';

  @override
  String get exportTitle => 'Экспорт данных';

  @override
  String get exportBody => 'Профиль и история матчей будут собраны в JSON-файл. Когда он будет готов, его можно скопировать.';

  @override
  String get exportProfile => 'Профиль и аккаунт';

  @override
  String get exportGames => 'История матчей';

  @override
  String exportGamesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n матча',
      many: '$n матчей',
      few: '$n матча',
      one: '$n матч',
    );
    return '$_temp0';
  }

  @override
  String get exportFormat => 'Формат';

  @override
  String get exportFormatValue => 'JSON';

  @override
  String get exportStart => 'Начать экспорт';

  @override
  String exportReady(String size) {
    return 'Файл готов · $size КБ';
  }

  @override
  String get exportCopy => 'Скопировать JSON';

  @override
  String get deleteTitle => 'Удалить аккаунт?';

  @override
  String deleteItemRating(int rating) {
    return 'Рейтинг ($rating), ранг и вся история матчей';
  }

  @override
  String get deleteItemHistory => 'Профиль и вся история матчей';

  @override
  String get deleteIrreversible => 'Аккаунт будет удалён навсегда через 30 дней. Войди раньше, чтобы отменить удаление.';

  @override
  String deleteConfirmLabel(String word) {
    return 'Введи $word для подтверждения';
  }

  @override
  String get deleteConfirmWord => 'УДАЛИТЬ';

  @override
  String get setupOnlineTitle => 'Онлайн-игра';

  @override
  String get setupTimeLabel => 'КОНТРОЛЬ ВРЕМЕНИ';

  @override
  String get timeBlitz => 'Блиц';

  @override
  String get timeRapid => 'Рапид';

  @override
  String get timeClassic => 'Классика';

  @override
  String get timeDaily => 'Заочная';

  @override
  String timeValue(int minutes, int delay) {
    return '$minutes мин + $delay с';
  }

  @override
  String get setupRated => 'Рейтинговая игра';

  @override
  String setupRatedSub(int rating) {
    return 'Твой рейтинг: $rating';
  }

  @override
  String get setupFindOpponent => 'Найти соперника';

  @override
  String get tabStore => 'Магазин';

  @override
  String get lockerTitle => 'Шкафчик';

  @override
  String loadoutName(int n) {
    return 'Набор $n';
  }

  @override
  String get lockerSave => 'Сохранить';

  @override
  String get lockerSaved => 'Набор сохранён';

  @override
  String get lockerAddLoadout => 'Новый набор';

  @override
  String get lockerRenameTitle => 'Название набора';

  @override
  String get lockerRename => 'Переименовать';

  @override
  String get lockerDelete => 'Удалить набор';

  @override
  String lockerLoadoutLimit(int max) {
    return 'Можно хранить до $max наборов.';
  }

  @override
  String get lockerEmptyTitle => 'Здесь пока пусто';

  @override
  String get lockerEmptyBody => 'Новые предметы для этого раздела скоро появятся.';

  @override
  String get lockerShowOpponentCosmetics => 'Показывать косметику соперника';

  @override
  String get categoryBoard => 'Доска';

  @override
  String get categoryCheckers => 'Шашки';

  @override
  String get categoryDice => 'Кости';

  @override
  String get categoryDiceCup => 'Стакан';

  @override
  String get categoryCube => 'Куб удвоения';

  @override
  String get categoryBackground => 'Фон';

  @override
  String get categorySounds => 'Звуки';

  @override
  String get categoryEmote => 'Эмоции';

  @override
  String get categoryAvatarFrame => 'Рамка аватара';

  @override
  String get categoryTitle => 'Титул';

  @override
  String get categoryWinEffect => 'Эффект победы';

  @override
  String get categoryOther => 'Другое';

  @override
  String get itemEquipped => 'Надето';

  @override
  String get itemPreviewing => 'Примерка';

  @override
  String get itemOwned => 'Есть у тебя';

  @override
  String get itemSeason => 'Сезонный пропуск';

  @override
  String get itemTournamentReward => 'Награда турнира';

  @override
  String get itemAchievementReward => 'Награда за достижение';

  @override
  String get rarityCommon => 'Обычный';

  @override
  String get rarityRare => 'Редкий';

  @override
  String get rarityEpic => 'Эпический';

  @override
  String get rarityLegendary => 'Легендарный';

  @override
  String get raritySeasonal => 'Сезонный';

  @override
  String get rarityTournament => 'Турнирный';

  @override
  String get rarityCommonUpper => 'ОБЫЧНЫЙ';

  @override
  String get rarityRareUpper => 'РЕДКИЙ';

  @override
  String get rarityEpicUpper => 'ЭПИЧЕСКИЙ';

  @override
  String get rarityLegendaryUpper => 'ЛЕГЕНДАРНЫЙ';

  @override
  String get raritySeasonalUpper => 'СЕЗОННЫЙ';

  @override
  String get rarityTournamentUpper => 'ТУРНИРНЫЙ';

  @override
  String get itemObtainTitle => 'КАК ПОЛУЧИТЬ';

  @override
  String get obtainStore => 'Магазин';

  @override
  String get obtainSeasonPremium => 'Сезонный пропуск · Премиум';

  @override
  String get obtainTournament => 'Турнир';

  @override
  String get obtainAchievement => 'Достижение';

  @override
  String get obtainDefault => 'Стандартный набор';

  @override
  String get obtainFree => 'Бесплатно';

  @override
  String priceCoins(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount монеты',
      many: '$amount монет',
      few: '$amount монеты',
      one: '$amount монета',
    );
    return '$_temp0';
  }

  @override
  String priceGems(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount рубина',
      many: '$amount рубинов',
      few: '$amount рубина',
      one: '$amount рубин',
    );
    return '$_temp0';
  }

  @override
  String get itemTry => 'Примерить';

  @override
  String get itemBuy => 'Купить';

  @override
  String get itemEquip => 'Надеть';

  @override
  String storeFeaturedOverline(int days) {
    return 'РЕКОМЕНДУЕМ · $days ДН.';
  }

  @override
  String get storeDailyTitle => 'ВЫБОР ДНЯ';

  @override
  String storeRefreshesIn(String time) {
    return 'Обновится через $time';
  }

  @override
  String get storeGemsTitle => 'РУБИНЫ';

  @override
  String get storePackUnavailable => 'Покупка рубинов пока недоступна. Она откроется после подключения магазинов.';

  @override
  String storePackAdded(String amount) {
    return 'На баланс зачислено рубинов: $amount';
  }

  @override
  String get accountNeededTitle => 'Войди в аккаунт';

  @override
  String get accountNeededBody => 'Чтобы зарабатывать монеты, покупать наборы и видеть задания, нужен аккаунт.';

  @override
  String get purchasePrice => 'Цена';

  @override
  String get purchaseBalanceAfter => 'Баланс после';

  @override
  String purchaseShortfall(String amount) {
    return 'не хватает $amount';
  }

  @override
  String purchaseNotEnoughGems(String pack) {
    return 'Не хватает рубинов. Купи пакет на $pack и сразу открой предмет.';
  }

  @override
  String get purchaseNotEnoughCoins => 'Не хватает монет. Монеты только зарабатываются: играй и выполняй задания.';

  @override
  String purchaseBuyPack(String amount) {
    return 'Купить рубины: $amount';
  }

  @override
  String get purchaseToMissions => 'К заданиям';

  @override
  String get purchaseFailed => 'Покупка не прошла. Попробуй ещё раз.';

  @override
  String get purchaseAlreadyOwned => 'Этот предмет уже у тебя.';

  @override
  String get purchaseNotForSale => 'Этот предмет не продаётся.';

  @override
  String purchaseOwnedTitle(String item) {
    return 'Теперь у тебя: $item';
  }

  @override
  String get purchaseReceipt => 'Чек';

  @override
  String get purchasePaid => 'Оплачено';

  @override
  String get purchaseClose => 'Закрыть';

  @override
  String get purchaseEquipNow => 'Надеть сейчас';

  @override
  String get missionsTitle => 'Задания';

  @override
  String streakCardTitle(int days) {
    return 'Серия входов · $days дн.';
  }

  @override
  String streakTomorrow(int coins) {
    return 'Завтра: +$coins';
  }

  @override
  String get missionsDaily => 'Ежедневные';

  @override
  String get missionsWeekly => 'Еженедельные';

  @override
  String missionsResetsIn(String time) {
    return 'Сброс через $time';
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
  String get missionClaim => 'Забрать';

  @override
  String get missionClaimed => 'Получено';

  @override
  String missionDoubles(int n) {
    return 'Выброси $n дубля';
  }

  @override
  String missionRankedWin(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Выиграй рейтинговые игры: $n',
      one: 'Выиграй рейтинговую игру',
    );
    return '$_temp0';
  }

  @override
  String get missionCubeTakeWin => 'Прими куб и выиграй';

  @override
  String get missionPlayLong => 'Сыграй в длинные нарды';

  @override
  String missionMars(int n) {
    return 'Сделай марс в играх: $n';
  }

  @override
  String missionPlay(int n) {
    return 'Сыграй игр: $n';
  }

  @override
  String missionWin(int n) {
    return 'Выиграй игр: $n';
  }

  @override
  String get missionGeneric => 'Задание';

  @override
  String dailyBonusTitle(int coins) {
    return 'Ежедневный бонус · +$coins';
  }

  @override
  String dailyBonusBody(int done, int total) {
    return 'Выполни все ежедневные задания · $done / $total';
  }

  @override
  String get streakOverline => 'СЕРИЯ ВХОДОВ';

  @override
  String get streakDay1 => 'День 1';

  @override
  String get streakDay2 => 'День 2';

  @override
  String get streakDay3 => 'День 3';

  @override
  String get streakDay4 => 'День 4';

  @override
  String get streakDay5 => 'День 5';

  @override
  String get streakDay6 => 'День 6';

  @override
  String get streakDay7 => 'День 7';

  @override
  String get streakBody => 'Заходи каждый день и забери большой бонус седьмого дня.';

  @override
  String streakClaim(int coins) {
    return 'Забрать монеты: +$coins';
  }

  @override
  String get streakResetNote => 'Пропустишь день, и серия начнётся с первого дня.';

  @override
  String levelUpOverline(int from, int to) {
    return 'УРОВЕНЬ $from → $to';
  }

  @override
  String get levelUpTitle => 'Новый уровень';

  @override
  String xpProgress(String xp, String next) {
    return '$xp / $next XP';
  }

  @override
  String homeLevel(int n) {
    return 'Ур. $n';
  }

  @override
  String homeDailyMission(int done, int total) {
    return 'ЗАДАНИЕ ДНЯ · $done/$total';
  }

  @override
  String get homeMissionsDone => 'Задания на сегодня выполнены';

  @override
  String get matchCoins => 'монет';

  @override
  String get matchXp => 'опыта';

  @override
  String get xpBadge => 'XP';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String achievementsCount(int done, int total) {
    return '$done / $total';
  }

  @override
  String get titlesOverline => 'ТИТУЛ';

  @override
  String get titlesNone => 'Без титула';

  @override
  String get titlesLocked => 'Открывается достижением';

  @override
  String get achFirstWin => 'Первая победа';

  @override
  String get achWins10 => '10 побед';

  @override
  String get achWins100 => '100 побед';

  @override
  String get achGames1000 => '1000 игр';

  @override
  String get achMars10 => 'Мастер марса';

  @override
  String get achRankedWins25 => 'Рейтинговый боец';

  @override
  String get achStreak10 => 'Серия 10 дней';

  @override
  String get achGeneric => 'Достижение';

  @override
  String coinsSemantic(String amount) {
    return 'Монеты: $amount';
  }

  @override
  String gemsSemantic(String amount) {
    return 'Рубины: $amount';
  }

  @override
  String get emoteWheelHint => 'Проведи\nи отпусти';

  @override
  String get emoteButton => 'Отправить эмоцию';

  @override
  String get gameChat => 'Чат';

  @override
  String get emoteSmile => 'Улыбка';

  @override
  String get emoteLaugh => 'Смех';

  @override
  String get emoteWow => 'Ого';

  @override
  String get emoteThink => 'Думаю';

  @override
  String get emoteSad => 'Грусть';

  @override
  String get emoteAngry => 'Злость';

  @override
  String get emoteTea => 'Чай';

  @override
  String get emoteClap => 'Браво';

  @override
  String get phraseHello => 'Привет!';

  @override
  String get phraseGoodLuck => 'Удачи';

  @override
  String get phraseNiceMove => 'Отличный ход';

  @override
  String get phraseDice => 'Ну и кости…';

  @override
  String get phraseThanks => 'Спасибо';

  @override
  String get phraseGoodGame => 'Хорошая игра';

  @override
  String get phraseNiceRoll => 'Хороший бросок';

  @override
  String get phraseSorry => 'Извини';

  @override
  String get tabClan => 'Клан';

  @override
  String get modePrivateRoom => 'Своя комната';

  @override
  String get modeFriends => 'Друзья';

  @override
  String get socialAccountBody => 'Для друзей, кланов и своих комнат нужен аккаунт.';

  @override
  String get send => 'Отправить';

  @override
  String get close => 'Закрыть';

  @override
  String get friendsTitle => 'Друзья';

  @override
  String get friendsAdd => 'Добавить';

  @override
  String get friendsSection => 'ДРУЗЬЯ';

  @override
  String get presenceOnline => 'В сети';

  @override
  String get presenceInGame => 'В игре';

  @override
  String get presenceOffline => 'Не в сети';

  @override
  String get friendInvite => 'Позвать';

  @override
  String get friendWatch => 'Смотреть';

  @override
  String get friendRequestsTitle => 'ЗАПРОСЫ';

  @override
  String get friendSentTitle => 'ОТПРАВЛЕННЫЕ';

  @override
  String get friendChallengesTitle => 'ВЫЗОВЫ';

  @override
  String get friendAccept => 'Принять';

  @override
  String get friendDismiss => 'Отклонить';

  @override
  String get friendCancelRequest => 'Отменить запрос';

  @override
  String challengeMeta(String variant, String format) {
    return '$variant · $format';
  }

  @override
  String get friendsEmptyTitle => 'Друзей пока нет';

  @override
  String get friendsEmptyBody => 'Найди по имени или поделись кодом друга.';

  @override
  String friendInviteSent(String name) {
    return 'Приглашение отправлено: $name';
  }

  @override
  String get friendRemoved => 'Удалён из друзей';

  @override
  String metaWithClan(String meta, String clan) {
    return '$meta · $clan';
  }

  @override
  String levelShort(int n) {
    return 'Ур. $n';
  }

  @override
  String get addFriendTitle => 'Добавить друга';

  @override
  String get addFriendSearchHint => 'Поиск по имени';

  @override
  String get addFriendSearchShort => 'Введи хотя бы 3 буквы';

  @override
  String get addFriendAction => 'Добавить';

  @override
  String get addFriendOr => 'или';

  @override
  String get addFriendCodeLabel => 'ТВОЙ КОД ДРУГА';

  @override
  String get addFriendCodeCaption => 'Пусть друг введёт этот код';

  @override
  String get addFriendCopyCode => 'Скопировать код';

  @override
  String get addFriendEnterCode => 'ДОБАВИТЬ ПО КОДУ';

  @override
  String get addFriendCodeHint => 'Код из 8 символов';

  @override
  String get friendRequested => 'Отправлено';

  @override
  String get friendAccepted => 'Вы друзья';

  @override
  String get friendErrNotFound => 'Игрок не найден';

  @override
  String get friendErrBlocked => 'С этим игроком нельзя связаться';

  @override
  String get friendErrAlready => 'Вы уже друзья';

  @override
  String get friendErrPending => 'Запрос уже отправлен';

  @override
  String friendErrLimit(int max) {
    return 'Достигнут лимит друзей ($max)';
  }

  @override
  String get roomTitle => 'Своя комната';

  @override
  String get roomCodeLabel => 'КОД КОМНАТЫ';

  @override
  String get roomCopy => 'Копировать';

  @override
  String get roomShare => 'Поделиться';

  @override
  String roomShareText(String code) {
    return 'Сыграй со мной в NardArena. Код комнаты: $code';
  }

  @override
  String get roomWaiting => 'Ждём друга…';

  @override
  String roomExpiry(String time, String left) {
    return 'Истекает в $time · осталось $left';
  }

  @override
  String roomInvited(String name) {
    return 'Приглашён: $name';
  }

  @override
  String get roomSettingVariant => 'Вариант';

  @override
  String get roomSettingFormat => 'Формат';

  @override
  String get roomSettingTime => 'Время';

  @override
  String get roomSettingRating => 'Рейтинг';

  @override
  String get roomUnrated => 'Не меняется';

  @override
  String get roomExpired => 'Срок кода истёк';

  @override
  String get roomNewCode => 'Новый код';

  @override
  String get roomCreate => 'Создать комнату';

  @override
  String get roomCreateSub => 'Отправь код: игра начнётся, когда друг войдёт';

  @override
  String get roomJoinByCode => 'Войти по коду';

  @override
  String get roomJoinByCodeSub => 'Войди в комнату друга по коду из 6 символов';

  @override
  String get roomJoin => 'Войти';

  @override
  String get roomJoinTitle => 'Войти в комнату';

  @override
  String get roomJoinHint => 'Введи код, который прислал друг';

  @override
  String get roomJoining => 'Подключение…';

  @override
  String get roomCreating => 'Создаём комнату…';

  @override
  String get roomNotFound => 'Комната не найдена или истекла';

  @override
  String get roomInviteFriend => 'Позвать друга';

  @override
  String get roomPickFriend => 'Кого позовёшь?';

  @override
  String get roomCancelTitle => 'Закрыть комнату?';

  @override
  String get roomCancelBody => 'Код перестанет действовать.';

  @override
  String get roomCancelConfirm => 'Закрыть';

  @override
  String get spectatorLive => 'ЗРИТЕЛЬ';

  @override
  String get spectatorLeave => 'Выйти';

  @override
  String get spectatorNoChat => 'Здесь видны эмоции игроков';

  @override
  String get spectatorUnavailable => 'Эту игру нельзя смотреть';

  @override
  String spectatorGameOver(String name, String score) {
    return 'Победа: $name · $score';
  }

  @override
  String get spectatorWaiting => 'Загрузка игры…';

  @override
  String get playerMenuAddFriend => 'Добавить в друзья';

  @override
  String get playerMenuInvite => 'Позвать в игру';

  @override
  String get playerMenuMute => 'Отключить чат';

  @override
  String get playerMenuUnmute => 'Включить чат';

  @override
  String get playerMenuReport => 'Пожаловаться';

  @override
  String get playerMenuBlock => 'Заблокировать';

  @override
  String get playerMenuUnblock => 'Разблокировать';

  @override
  String get playerMenuUnfriend => 'Удалить из друзей';

  @override
  String get playerMenuInviteClan => 'Пригласить в клан';

  @override
  String reportTitle(String name) {
    return 'Жалоба: $name';
  }

  @override
  String get reportReasonLabel => 'ПРИЧИНА';

  @override
  String get reportReasonAbuse => 'Оскорбления в чате';

  @override
  String get reportReasonName => 'Неприемлемое имя или аватар';

  @override
  String get reportReasonCheating => 'Использование программ-помощников';

  @override
  String get reportReasonStalling => 'Намеренное затягивание';

  @override
  String get reportReasonLeaving => 'Намеренный выход из игры';

  @override
  String get reportReasonOther => 'Другое';

  @override
  String get reportNoteHint => 'Комментарий (необязательно)';

  @override
  String get reportAlsoBlock => 'Также заблокировать игрока';

  @override
  String reportDisclosure(String name) {
    return 'Запись последней игры и чат прикрепляются автоматически. $name не узнает, кто пожаловался.';
  }

  @override
  String get reportSend => 'Отправить жалобу';

  @override
  String get reportLimit => 'Сегодня ты отправил много жалоб. Попробуй завтра.';

  @override
  String blockTitle(String name) {
    return 'Заблокировать $name?';
  }

  @override
  String get blockInfoMatchmaking => 'Вы не встретитесь в случайных играх.';

  @override
  String get blockInfoContact => 'Не сможет отправлять тебе сообщения, запросы в друзья и приглашения.';

  @override
  String blockInfoUndo(String path) {
    return 'Снять блокировку можно в разделе $path.';
  }

  @override
  String get privacyBlocked => 'Заблокированные';

  @override
  String get blockConfirm => 'Заблокировать';

  @override
  String blockDone(String name) {
    return 'Игрок $name заблокирован.';
  }

  @override
  String get unblockDone => 'Блокировка снята';

  @override
  String get blockedEmpty => 'Заблокированных игроков нет';

  @override
  String get reportSentTitle => 'Жалоба отправлена';

  @override
  String get reportSentBody => 'Модератор рассмотрит её в течение 24 часов. Ты получишь уведомление о решении.';

  @override
  String get mutedNote => 'Чат отключён';

  @override
  String get unmutedNote => 'Чат включён';

  @override
  String get clansTitle => 'Кланы';

  @override
  String get clanCreateShort => 'Создать';

  @override
  String get clanSearchHint => 'Поиск по названию или тегу';

  @override
  String clanFilterLanguage(String code) {
    return 'Язык: $code';
  }

  @override
  String get clanFilterOpen => 'Открытые';

  @override
  String clanFilterMinRating(int rating) {
    return 'Мин. рейтинг ≤ $rating';
  }

  @override
  String clanTag(String tag) {
    return '[$tag]';
  }

  @override
  String clanListMeta(int level, int members, int max, String rating) {
    return 'Ур. $level · $members/$max · $rating';
  }

  @override
  String get clanJoin => 'Вступить';

  @override
  String get clanApply => 'Заявка';

  @override
  String get clanFull => 'Полон';

  @override
  String get clanInviteOnlyShort => 'По приглашению';

  @override
  String get clanPending => 'Ожидает';

  @override
  String get clanEmpty => 'Кланы не найдены';

  @override
  String get clanEmptyBody => 'Попробуй другое название или создай свой клан.';

  @override
  String get clanInvitesTitle => 'ПРИГЛАШЕНИЯ';

  @override
  String clanInviteFrom(String name) {
    return 'Приглашение от $name';
  }

  @override
  String get clanStatLevel => 'Уровень';

  @override
  String get clanStatMembers => 'Участники';

  @override
  String get clanStatRating => 'Рейтинг';

  @override
  String get clanStatLanguage => 'Язык';

  @override
  String clanMembersValue(int members, int max) {
    return '$members/$max';
  }

  @override
  String get clanRequirements => 'ТРЕБОВАНИЯ';

  @override
  String get clanReqMinRating => 'Мин. рейтинг';

  @override
  String get clanReqPolicy => 'Приём';

  @override
  String get clanReqNone => 'Нет';

  @override
  String get clanTopMembers => 'ЛУЧШИЕ УЧАСТНИКИ';

  @override
  String clanMemberWithRole(String name, String role) {
    return '$name · $role';
  }

  @override
  String get clanApplyCta => 'Подать заявку';

  @override
  String get clanJoinCta => 'Вступить';

  @override
  String get clanAppliedCta => 'Заявка отправлена';

  @override
  String get clanCancelApply => 'Отозвать заявку';

  @override
  String get clanInviteOnlyCta => 'Только по приглашению';

  @override
  String get clanFullCta => 'Клан заполнен';

  @override
  String get clanReqNotMet => 'Ты не подходишь по требованиям';

  @override
  String get clanLeaveFirst => 'Сначала выйди из текущего клана';

  @override
  String get clanOpenMine => 'Перейти в клан';

  @override
  String get clanAcceptInvite => 'Принять приглашение';

  @override
  String get clanErrRatingLow => 'Твой рейтинг ниже требуемого';

  @override
  String get clanErrInClan => 'Ты уже в клане';

  @override
  String get policyOpen => 'Открытый';

  @override
  String get policyOpenSub => 'Любой, кто подходит по рейтингу, вступает сразу';

  @override
  String get policyRequest => 'По заявке';

  @override
  String get policyRequestSub => 'Одобряют лидер, заместители и старейшины';

  @override
  String get policyInvite => 'Только приглашение';

  @override
  String get policyInviteSub => 'Виден в списке, но вступить можно только по приглашению';

  @override
  String get roleLeader => 'Лидер';

  @override
  String get roleCoLeader => 'Заместитель';

  @override
  String get roleElder => 'Старейшина';

  @override
  String get roleMember => 'Участник';

  @override
  String get emblemTitle => 'Эмблема';

  @override
  String get emblemSave => 'Сохранить';

  @override
  String get emblemTabShape => 'Форма';

  @override
  String get emblemTabSymbol => 'Символ';

  @override
  String get emblemTabColor => 'Цвет';

  @override
  String get emblemTabPattern => 'Узор';

  @override
  String get emblemPrimaryColor => 'ОСНОВНОЙ ЦВЕТ';

  @override
  String get emblemShapeShield => 'Щит';

  @override
  String get emblemShapeHexagon => 'Шестиугольник';

  @override
  String get emblemShapeOctagon => 'Восьмиугольник';

  @override
  String get emblemShapeCircle => 'Круг';

  @override
  String get emblemShapeDiamond => 'Ромб';

  @override
  String get emblemShapeBanner => 'Знамя';

  @override
  String get emblemShapeStar => 'Звезда';

  @override
  String get emblemShapeArch => 'Арка';

  @override
  String get emblemSymbolDiamond => 'Ромб';

  @override
  String get emblemSymbolDiamondDot => 'Ромб с точкой';

  @override
  String get emblemSymbolCircle => 'Кольцо';

  @override
  String get emblemSymbolSquare => 'Квадрат';

  @override
  String get emblemSymbolInitials => 'Инициалы';

  @override
  String get emblemPatternNone => 'Нет';

  @override
  String get emblemPatternLattice => 'Решётка';

  @override
  String get emblemColorGarnet => 'Гранат';

  @override
  String get emblemColorIndigo => 'Индиго';

  @override
  String get emblemColorEmerald => 'Изумруд';

  @override
  String get emblemColorBrass => 'Латунь';

  @override
  String get emblemColorPurple => 'Фиолетовый';

  @override
  String get emblemColorSlate => 'Сланец';

  @override
  String get emblemColorIvory => 'Слоновая кость';

  @override
  String get emblemColorBlue => 'Синий';

  @override
  String get emblemColorWalnut => 'Орех';

  @override
  String clanOnline(int n) {
    return 'В сети: $n';
  }

  @override
  String get clanTabChat => 'Чат';

  @override
  String get clanTabActivity => 'События';

  @override
  String get clanTabWar => 'Война';

  @override
  String get clanTabChest => 'Сундук';

  @override
  String get clanChestTitle => 'Сундук недели';

  @override
  String clanChestProgress(String current, String target) {
    return '$current / $target';
  }

  @override
  String get clanChatHint => 'Напиши сообщение…';

  @override
  String get clanChatEmpty => 'Сообщений пока нет. Напиши первым.';

  @override
  String get clanActivityEmpty => 'Пока ничего не произошло';

  @override
  String get clanChatTooFast => 'Слишком часто. Подожди немного.';

  @override
  String clanSysCreated(String name) {
    return 'Клан создан: $name';
  }

  @override
  String clanSysJoined(String name) {
    return 'Новый участник: $name';
  }

  @override
  String clanSysLeft(String name) {
    return 'Покинул клан: $name';
  }

  @override
  String clanSysKicked(String name) {
    return 'Исключён из клана: $name';
  }

  @override
  String clanSysRole(String name, String role) {
    return '$name: новая роль · $role';
  }

  @override
  String clanSysLeader(String name) {
    return 'Новый лидер: $name';
  }

  @override
  String clanSysRenamed(String name, String tag) {
    return 'Новое название клана: $name [$tag]';
  }

  @override
  String clanSysDonated(String name, String amount) {
    return '$name: +$amount монет в сундук';
  }

  @override
  String get clanSysChestFull => 'Сундук недели заполнен';

  @override
  String clanSysWarStarted(String name, String tag) {
    return 'Война кланов началась: $name [$tag]';
  }

  @override
  String clanSysWarWin(String name, String points) {
    return 'Победа в войне: $name · +$points';
  }

  @override
  String clanSysWarEnded(String mine, String theirs) {
    return 'Война кланов окончена · $mine : $theirs';
  }

  @override
  String get clanMenuMembers => 'Участники';

  @override
  String get clanMenuLeaderboard => 'Рейтинг кланов';

  @override
  String get clanMenuProfile => 'Профиль клана';

  @override
  String get clanMenuEmblem => 'Сменить эмблему';

  @override
  String get clanMenuRequests => 'Заявки';

  @override
  String get clanMenuInvite => 'Пригласить друзей';

  @override
  String get clanMenuLeave => 'Покинуть клан';

  @override
  String get clanLeaveTitle => 'Покинуть клан?';

  @override
  String get clanLeaveBody => 'Ты потеряешь доступ к чату и сундуку клана.';

  @override
  String get clanLeaveLastBody => 'Ты последний участник: клан будет распущен.';

  @override
  String get clanTransferFirst => 'Перед выходом передай лидерство.';

  @override
  String get chatDelete => 'Удалить';

  @override
  String get clanChestDonate => 'Пожертвовать';

  @override
  String clanChestMine(String amount) {
    return 'Твой вклад за неделю: $amount';
  }

  @override
  String clanChestReward(int xp) {
    return 'Полный сундук даёт клану $xp XP';
  }

  @override
  String get clanChestFullNote => 'Сундук на этой неделе заполнен';

  @override
  String get clanChestAmount => 'СУММА';

  @override
  String clanDonated(String amount) {
    return 'Пожертвовано монет: $amount';
  }

  @override
  String get clanErrChestFull => 'Сундук уже полон';

  @override
  String get clanDonors => 'ВКЛАДЫ НЕДЕЛИ';

  @override
  String get membersTitle => 'Участники';

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
    return '$name (ты)';
  }

  @override
  String get memberViewProfile => 'Открыть профиль';

  @override
  String get memberInviteFriendly => 'Позвать на товарищеский матч';

  @override
  String get memberPromoteCoLeader => 'Сделать заместителем';

  @override
  String get memberPromoteElder => 'Сделать старейшиной';

  @override
  String get memberDemote => 'Сделать участником';

  @override
  String get memberTransferLead => 'Передать лидерство';

  @override
  String get memberKick => 'Исключить из клана';

  @override
  String memberKickConfirm(String name) {
    return 'Исключить $name из клана?';
  }

  @override
  String memberTransferConfirm(String name) {
    return 'Передать лидерство: $name?';
  }

  @override
  String get memberTransferBody => 'Ты станешь заместителем.';

  @override
  String get requestsEmpty => 'Новых заявок нет';

  @override
  String get clanInvited => 'Приглашение отправлено';

  @override
  String warLive(String time) {
    return 'ИДЁТ · ДО КОНЦА $time';
  }

  @override
  String warCounted(int n, int max) {
    return 'Засчитано матчей: $n / $max';
  }

  @override
  String get warMatches => 'МАТЧИ';

  @override
  String warFinished(int a, int b) {
    return 'Итог $a–$b';
  }

  @override
  String get warWon => 'ОКОНЧЕНА · ПОБЕДА';

  @override
  String get warLost => 'ОКОНЧЕНА · ПОРАЖЕНИЕ';

  @override
  String get warDraw => 'ОКОНЧЕНА · НИЧЬЯ';

  @override
  String get warNoneTitle => 'На этой неделе войны нет';

  @override
  String get warNoneBody => 'Кланы подбираются каждый понедельник. Для войны нужно минимум 2 активных участника.';

  @override
  String get warNoOpponent => 'Соперник не найден';

  @override
  String warHowTo(int points) {
    return 'Каждая онлайн-победа над участниками клана-соперника приносит +$points.';
  }

  @override
  String get warMatchesEmpty => 'Засчитанных матчей пока нет';

  @override
  String get clanLeaderboardTitle => 'Рейтинг кланов';

  @override
  String clanMyRank(int rank) {
    return 'Твой клан · #$rank';
  }

  @override
  String get createClanTitle => 'Создать клан';

  @override
  String createStep(int step, int total) {
    return '$step / $total';
  }

  @override
  String get createNameLabel => 'Название клана';

  @override
  String createNameCounter(int n, int max) {
    return '$n / $max';
  }

  @override
  String get createTagLabel => 'Тег (3–5 букв)';

  @override
  String get createTagFree => 'Свободен';

  @override
  String get createTagTaken => 'Занят';

  @override
  String get createTagInvalid => 'Только 3–5 латинских букв';

  @override
  String get createNameInvalid => 'Название: от 3 до 24 символов';

  @override
  String get createEmblemLabel => 'ЭМБЛЕМА';

  @override
  String get createEmblemMore => 'Ещё';

  @override
  String get createColorLabel => 'ЦВЕТ';

  @override
  String get createPolicyLabel => 'ВСТУПЛЕНИЕ';

  @override
  String get createMinRatingLabel => 'МИНИМАЛЬНЫЙ РЕЙТИНГ';

  @override
  String get createMinRatingAny => 'Все';

  @override
  String createMinRatingMax(int n) {
    return '$n+';
  }

  @override
  String get createLanguageLabel => 'ЯЗЫК';

  @override
  String get createDescriptionLabel => 'Описание (необязательно)';

  @override
  String createBalance(String from, String to) {
    return 'Баланс: $from → $to';
  }

  @override
  String createRenameNote(String price) {
    return 'Смена названия потом: $price монет';
  }

  @override
  String get createSubmit => 'Создать клан';

  @override
  String get createErrNameTaken => 'Это название занято';

  @override
  String get tabTournaments => 'Турниры';

  @override
  String get tournamentsTitle => 'Турниры';

  @override
  String get tourTabLive => 'Сейчас';

  @override
  String get tourTabUpcoming => 'Скоро';

  @override
  String get tourTabMine => 'Мои';

  @override
  String get tourTabFinished => 'Завершённые';

  @override
  String get tourFilterAll => 'Все';

  @override
  String get tourFilterFree => 'Бесплатные';

  @override
  String tourStatusLive(int n) {
    return 'ИДЁТ · РАУНД $n';
  }

  @override
  String get tourStatusOpen => 'РЕГИСТРАЦИЯ ОТКРЫТА';

  @override
  String get tourStatusUpcoming => 'СКОРО';

  @override
  String get tourStatusFinished => 'ЗАВЕРШЁН';

  @override
  String get tourStatusCancelled => 'ОТМЕНЁН';

  @override
  String tourInMinutes(int n) {
    return '$n мин';
  }

  @override
  String tourTomorrowAt(String time) {
    return 'Завтра $time';
  }

  @override
  String get tourFormatSwiss => 'Швейцарка';

  @override
  String get tourFormatKnockout => 'Олимпийка';

  @override
  String get tourFormatRoundRobin => 'Круговой';

  @override
  String tourRounds(int n) {
    return 'раундов: $n';
  }

  @override
  String tourMeta(String variant, int points) {
    return '$variant · $points оч.';
  }

  @override
  String tourEntrants(int n, int max) {
    return '$n/$max';
  }

  @override
  String get tourRegistered => 'Ты записан';

  @override
  String tourPlace(String place) {
    return 'Место: $place';
  }

  @override
  String tourOut(String round) {
    return 'Выбыл · $round';
  }

  @override
  String get tournamentsOfflineTitle => 'Турниры недоступны офлайн';

  @override
  String get tournamentsOfflineBody => 'Игра с компьютером и на одном устройстве работает. Список обновится, когда связь вернётся.';

  @override
  String get tournamentsEmptyTitle => 'Пока нет турниров';

  @override
  String get tournamentsEmptyBody => 'Здесь появятся турниры, на которые ты записался.';

  @override
  String get tournamentsEmptyCta => 'Смотреть ближайшие турниры';

  @override
  String get tournamentsNoneTitle => 'Турниров нет';

  @override
  String get tournamentsNoneBody => 'В этом списке пока пусто. Загляни чуть позже.';

  @override
  String get listErrorTitle => 'Список не загрузился';

  @override
  String get listErrorBody => 'Не удалось связаться с сервером. Попробуй чуть позже.';

  @override
  String get sngCardMeta => 'Старт, когда все места заняты';

  @override
  String get sngJoin => 'Войти';

  @override
  String get privateTourCreateChoice => 'Создать частный турнир';

  @override
  String get privateTourJoinByCode => 'Войти по коду';

  @override
  String get leaderboardTitle => 'Лидеры';

  @override
  String tourHeroMeta(String status, String type, int size) {
    return '$status · $type $size';
  }

  @override
  String get tourTypeKnockoutUpper => 'ОЛИМПИЙКА';

  @override
  String get tourTypeSwissUpper => 'ШВЕЙЦАРКА';

  @override
  String get tourTypeRoundRobinUpper => 'КРУГОВОЙ';

  @override
  String get tourTypeSngUpper => 'SIT-AND-GO';

  @override
  String get tourStartsIn => 'До старта';

  @override
  String tourLiveRound(int n, String stage) {
    return 'Раунд $n · $stage';
  }

  @override
  String tourNow(int n) {
    return 'Раунд $n';
  }

  @override
  String get tourPrizeFund => 'Призовой фонд';

  @override
  String get tourParticipants => 'Участники';

  @override
  String tourParticipantsValue(int n, int max) {
    return '$n / $max';
  }

  @override
  String tourPlaceRange(String from, String to) {
    return '$from–$to';
  }

  @override
  String get tourRuleEntry => 'Вход';

  @override
  String get tourRuleFairDice => 'Честные кости';

  @override
  String get tourRuleRating => 'Рейтинг';

  @override
  String get tourRuleUnrated => 'Не меняется';

  @override
  String tourFormatValue(String type, int points) {
    return '$type · до $points очков';
  }

  @override
  String tourEntryValue(String price, int rating) {
    return '$price · мин. $rating';
  }

  @override
  String get tourEntryInvite => 'По приглашению';

  @override
  String get tourFairDiceValue => 'Проверяемые';

  @override
  String get tourRegister => 'Записаться';

  @override
  String get tourRegisterFree => 'Записаться · бесплатно';

  @override
  String get tourUnregister => 'Отменить запись';

  @override
  String get tourUnregisterTitle => 'Отменить запись?';

  @override
  String get tourUnregisterBody => 'Взнос вернётся на баланс.';

  @override
  String get tourUnregisterBodyFree => 'Твоё место смогут занять.';

  @override
  String get tourRegisteredToast => 'Ты записан';

  @override
  String get tourUnregisteredToast => 'Запись отменена';

  @override
  String tourMinRating(int n) {
    return 'Минимальный рейтинг $n';
  }

  @override
  String get tourFull => 'Мест нет';

  @override
  String get tourClosed => 'Регистрация закрыта';

  @override
  String get tourInviteOnly => 'Войти по коду приглашения';

  @override
  String get tourOpenBracket => 'Открыть сетку';

  @override
  String get tourWatch => 'Смотреть';

  @override
  String tourTitlePrize(String name) {
    return 'Титул: $name';
  }

  @override
  String get tourRatingTooLow => 'Твой рейтинг ниже минимума турнира.';

  @override
  String get tourInviteRequired => 'В этот турнир можно войти только по коду.';

  @override
  String get tourActionFailed => 'Не получилось. Попробуй чуть позже.';

  @override
  String get tourLive => 'ИДЁТ';

  @override
  String roundOf(int n) {
    return '1/$n';
  }

  @override
  String get roundFinal => 'Финал';

  @override
  String tourNextMatch(String round) {
    return 'ТВОЙ СЛЕДУЮЩИЙ МАТЧ · $round';
  }

  @override
  String tourNextMetaOpen(int points) {
    return 'Раунд открыт · до $points очков';
  }

  @override
  String tourNextMetaPending(int points) {
    return 'Раунд ещё не открыт · до $points очков';
  }

  @override
  String get tourOpponentTbd => 'Соперник определяется';

  @override
  String get tourReady => 'Я готов';

  @override
  String get tourReadyDone => 'Ты готов';

  @override
  String get tourWaitingOpponent => 'Ждём соперника';

  @override
  String tourEliminated(String round) {
    return 'Ты выбыл · $round';
  }

  @override
  String tourFinishedPanel(String place) {
    return 'Турнир окончен · $place';
  }

  @override
  String get zoomIn => 'Приблизить';

  @override
  String get zoomOut => 'Отдалить';

  @override
  String standingsTitle(String name) {
    return '$name · Таблица';
  }

  @override
  String get standingsRound => 'Раунд';

  @override
  String get standingsColRank => '#';

  @override
  String get standingsColPlayer => 'ИГРОК';

  @override
  String get standingsColWinLoss => 'В–П';

  @override
  String get standingsColBuchholz => 'БУХ';

  @override
  String get standingsColPoints => 'ОЧК';

  @override
  String standingsWinLoss(int w, int l) {
    return '$w–$l';
  }

  @override
  String get standingsFootnoteNoPlayoff => 'При равенстве: Бухгольц, затем рейтинг';

  @override
  String get standingsEmpty => 'Таблица появится после первого раунда.';

  @override
  String get championTitle => 'Чемпион';

  @override
  String championLine(String name, String tournament) {
    return '$name · $tournament';
  }

  @override
  String championFinal(String score, String opponent) {
    return 'Финал: $score · $opponent';
  }

  @override
  String rewardCoins(String amount) {
    return '+$amount монет';
  }

  @override
  String get championShare => 'Поделиться';

  @override
  String championShareText(String name, String tournament) {
    return '$name стал чемпионом турнира $tournament. NardArena';
  }

  @override
  String get championShareCopied => 'Текст скопирован';

  @override
  String sngTitle(int size) {
    return 'Sit-and-go · $size';
  }

  @override
  String sngSize(int n) {
    return '$n игроков';
  }

  @override
  String get sngStartsWhenFull => 'Старт, как только места заполнятся';

  @override
  String sngExpires(int n) {
    return 'Не наберётся за $n мин — взнос вернётся';
  }

  @override
  String sngFormatValue(String variant, int points) {
    return '$variant · $points очк.';
  }

  @override
  String get sngEntryFee => 'Взнос';

  @override
  String get sngTimeControl => 'Контроль времени';

  @override
  String sngNoShowRule(int n) {
    return 'Кто не подключится за $n секунд после начала раунда, получает техническое поражение.';
  }

  @override
  String get sngLeave => 'Выйти · взнос вернётся';

  @override
  String noShowOverline(int round, int table) {
    return 'РАУНД $round · СТОЛ $table';
  }

  @override
  String get noShowTitle => 'Соперник ещё не подключился';

  @override
  String noShowBody(String name) {
    return 'Если $name не придёт до конца отсчёта, раунд засчитают тебе.';
  }

  @override
  String get tourBracket => 'Турнирная сетка';

  @override
  String get walkoverTitle => 'Ты проходишь дальше';

  @override
  String walkoverBody(String name) {
    return '$name не подключился вовремя. Раунд засчитан тебе. Рейтинг не меняется.';
  }

  @override
  String walkoverNextRound(int n) {
    return 'Раунд $n начнётся';
  }

  @override
  String get walkoverNextRoundWhen => 'после остальных матчей';

  @override
  String get notFilledTitle => 'Турнир не начался';

  @override
  String notFilledBody(int minutes, int size, int joined) {
    return 'За $minutes минут собралось только $joined из $size игроков. Взнос вернулся на баланс.';
  }

  @override
  String get notFilledBodyScheduled => 'Игроков набралось слишком мало. Взнос вернулся на баланс.';

  @override
  String refunded(String amount) {
    return '+$amount возвращено';
  }

  @override
  String notFilledJoinSmaller(int n) {
    return 'Сесть за стол на $n';
  }

  @override
  String get backToTournaments => 'К турнирам';

  @override
  String get privateTourTitle => 'Частный турнир';

  @override
  String get privateTourName => 'Название';

  @override
  String get privateTourNameHint => 'Название турнира';

  @override
  String get privateTourSize => 'ИГРОКОВ';

  @override
  String get privateTourGame => 'Игра';

  @override
  String get privateTourLength => 'Длина матча';

  @override
  String get privateTourStart => 'Время старта';

  @override
  String get privateTourStartManual => 'Запускаешь сам';

  @override
  String privateTourStartValue(String weekday, String time) {
    return '$weekday, $time';
  }

  @override
  String get privateTourEntry => 'Взнос';

  @override
  String get privateTourFree => 'Бесплатно';

  @override
  String get privateTourNote => 'Создание бесплатно. Частные турниры не влияют на рейтинг.';

  @override
  String get privateTourCreate => 'Создать турнир';

  @override
  String get privateTourCodeLabel => 'КОД ПРИГЛАШЕНИЯ';

  @override
  String privateTourMeta(String when, String variant, int points) {
    return '$when · $variant, $points очк.';
  }

  @override
  String get privateTourCopyInvite => 'Копировать приглашение';

  @override
  String privateTourShareText(String name, String code) {
    return 'Присоединяйся к турниру «$name» в NardArena. Код: $code';
  }

  @override
  String get privateTourRegistration => 'РЕГИСТРАЦИЯ';

  @override
  String get privateTourOrganizer => 'Организатор';

  @override
  String get privateTourJoined => 'В списке';

  @override
  String privateTourStartNowMin(int n) {
    return 'Начать · нужно минимум $n';
  }

  @override
  String get privateTourStartNow => 'Начать сейчас';

  @override
  String get privateTourCancel => 'Отменить турнир';

  @override
  String get privateTourCancelTitle => 'Отменить турнир?';

  @override
  String get privateTourCancelBody => 'Турнир закроется для всех, кто записался.';

  @override
  String get privateTourRemove => 'Убрать из турнира';

  @override
  String get privateTourCodeHint => 'Код из 6 символов';

  @override
  String get privateTourCodeNotFound => 'Турнир с таким кодом не найден.';

  @override
  String get privateTourTooMany => 'Можно держать открытыми не больше 3 частных турниров.';

  @override
  String get privateTourNotEnough => 'Для старта нужно минимум 2 игрока.';

  @override
  String homeTourMeta(String prize) {
    return 'Призовой фонд · $prize';
  }

  @override
  String homeTourStarts(String time, String prize) {
    return 'Старт $time · $prize';
  }

  @override
  String homeSeason(int n, int days) {
    return 'СЕЗОН $n · $days ДН.';
  }

  @override
  String homeSeasonLevel(int level, int max) {
    return 'Уровень $level / $max';
  }

  @override
  String get homePuzzleOverline => 'ЗАДАЧА ДНЯ';

  @override
  String homeSeasonEnded(int n) {
    return 'СЕЗОН $n ЗАВЕРШЁН';
  }

  @override
  String get homeSeasonSummaryCta => 'Смотреть итоги';

  @override
  String get modePuzzles => 'Задачи';

  @override
  String seasonN(int n) {
    return 'Сезон $n';
  }

  @override
  String get lbScopeGlobal => 'Мир';

  @override
  String get lbScopeCountry => 'Страна';

  @override
  String get lbScopeFriends => 'Друзья';

  @override
  String get lbScopeClan => 'Клан';

  @override
  String lbRank(int n) {
    return '#$n';
  }

  @override
  String get lbEmptyTitle => 'Пока пусто';

  @override
  String get lbEmptyFriends => 'Твоих друзей пока нет в рейтинге.';

  @override
  String get lbEmptyClan => 'У тебя нет клана, или его участников ещё нет в рейтинге.';

  @override
  String get lbEmptyCountry => 'В профиле не выбрана страна или из неё ещё никого нет в рейтинге.';

  @override
  String lbUnranked(int n) {
    return 'Сыграй $n рейтинговых игр в этом сезоне, чтобы попасть в таблицу';
  }

  @override
  String get lbSeasonPicker => 'Выбери сезон';

  @override
  String get seasonPassTitle => 'Сезонный пропуск';

  @override
  String seasonOverline(int n, int days, int hours) {
    return 'СЕЗОН $n · $days ДН. $hours Ч';
  }

  @override
  String seasonOverlineHours(int n, int hours, int minutes) {
    return 'СЕЗОН $n · $hours Ч $minutes МИН';
  }

  @override
  String seasonLevelNext(int n) {
    return 'Следующий уровень: $n';
  }

  @override
  String get seasonLevelMax => 'Последний уровень';

  @override
  String get seasonTrackFree => 'БЕСПЛАТНО';

  @override
  String get seasonTrackPremium => 'ПРЕМИУМ';

  @override
  String get seasonRewardItem => 'Предмет';

  @override
  String seasonEndReward(String tier) {
    return 'Награда за сезон · $tier';
  }

  @override
  String seasonEndRewardMeta(String reward, int points) {
    return '$reward · осталось $points очк.';
  }

  @override
  String seasonEndRewardReached(String reward) {
    return '$reward · получено';
  }

  @override
  String seasonRewardWithItem(String item, String coins) {
    return '$item + $coins';
  }

  @override
  String get seasonPremiumUnlock => 'Открыть премиум';

  @override
  String seasonClaimAll(int n) {
    return 'Забрать всё · $n';
  }

  @override
  String get seasonPremiumOwned => 'Премиум активен';

  @override
  String get seasonPremiumSheetTitle => 'Сезонный пропуск · Премиум';

  @override
  String get seasonPremiumBody => 'Премиум открывает премиум-награды сезона. Награды уже пройденных уровней можно забрать сразу.';

  @override
  String get seasonPremiumBought => 'Премиум открыт';

  @override
  String seasonNeedsLevel(int n) {
    return 'Нужен уровень $n';
  }

  @override
  String get seasonNeedsPremium => 'Эта награда на премиум-дорожке';

  @override
  String get seasonClaimedToast => 'Награда получена';

  @override
  String get seasonUnavailable => 'Данные сезона не загрузились';

  @override
  String seasonEnded(int n) {
    return 'СЕЗОН $n ЗАВЕРШЁН';
  }

  @override
  String get seasonStatGames => 'Игр';

  @override
  String get seasonStatWinRate => 'Побед';

  @override
  String get seasonStatRank => 'Место в мире';

  @override
  String get seasonStatCountryRank => 'Место в стране';

  @override
  String get seasonStatRatingGain => 'Изменение рейтинга';

  @override
  String get seasonStatRating => 'Итоговый рейтинг';

  @override
  String get seasonClaimRewards => 'Забрать награды';

  @override
  String seasonRewardLine(String reward) {
    return 'Награда сезона: $reward';
  }

  @override
  String seasonSoftReset(int rating) {
    return 'Рейтинг в новом сезоне: $rating';
  }

  @override
  String get seasonNoSummaryTitle => 'Завершённых сезонов пока нет';

  @override
  String get seasonNoSummaryBody => 'Итоги появятся здесь после первого сезона.';

  @override
  String get actionAnalysis => 'Анализ';

  @override
  String analysisTitle(int n) {
    return 'Анализ · Партия $n';
  }

  @override
  String get analysisEquity => 'Оценка';

  @override
  String get analysisNote => 'Оценки считает эвристический бот, это не точные шансы на победу. С нейросетевым ИИ станут точнее.';

  @override
  String analysisBest(String moves) {
    return 'Лучший: $moves';
  }

  @override
  String analysisYours(String moves, String loss) {
    return 'Твой: $moves · $loss';
  }

  @override
  String get analysisBestPlayed => 'Лучший ход';

  @override
  String get analysisRunning => 'Идёт анализ…';

  @override
  String get analysisMarkGood => 'Хороший ход';

  @override
  String get analysisMarkMistake => 'Ошибка';

  @override
  String get analysisMarkBlunder => 'Грубая ошибка';

  @override
  String get analysisNotReady => 'Запись матча ещё не готова. Попробуй чуть позже.';

  @override
  String get analysisNoGames => 'В этом матче не было сыгранных партий.';

  @override
  String analysisGameChip(int n) {
    return 'Партия $n';
  }

  @override
  String puzzleTitle(int n, int total) {
    return 'Задача $n / $total';
  }

  @override
  String get puzzleDailyTitle => 'Задача дня';

  @override
  String puzzleRating(int n) {
    return 'Рейтинг $n';
  }

  @override
  String get puzzlePhaseOpening => 'Дебют';

  @override
  String get puzzlePhaseMiddle => 'Середина игры';

  @override
  String get puzzlePhaseBearOff => 'Выброс';

  @override
  String get puzzleLevelEasy => 'Лёгкая';

  @override
  String get puzzleLevelMedium => 'Средняя';

  @override
  String get puzzleLevelHard => 'Сложная';

  @override
  String get puzzlePrompt => 'Найди лучший ход';

  @override
  String puzzleContext(String side, int d1, int d2) {
    return 'Ты играешь $side. Кости: $d1 – $d2.';
  }

  @override
  String get puzzleSideWhite => 'белыми';

  @override
  String get puzzleSideBlack => 'чёрными';

  @override
  String get puzzleHint => 'Подсказка';

  @override
  String get puzzleConfirm => 'Подтвердить ход';

  @override
  String get puzzleCorrect => 'Верно';

  @override
  String get puzzleCorrectFirstTry => 'Лучший ход · с первой попытки';

  @override
  String get puzzleCorrectSecondTry => 'Лучший ход · со второй попытки';

  @override
  String get puzzleYours => 'Твой';

  @override
  String get puzzleSecondBest => 'Второй по силе';

  @override
  String get puzzleBest => 'Лучший';

  @override
  String get puzzleHidden => 'скрыт';

  @override
  String get puzzleSeeAnalysis => 'Смотреть анализ';

  @override
  String get puzzleNext => 'Следующая задача';

  @override
  String get puzzleWrong => 'Это не лучший ход';

  @override
  String puzzleAttemptsLeft(int n) {
    return 'Осталось попыток: $n';
  }

  @override
  String get puzzleShowSolution => 'Показать решение';

  @override
  String get puzzleOutOfTries => 'Попытки закончились';

  @override
  String puzzleAnswer(String move) {
    return 'Ответ: $move';
  }

  @override
  String get puzzleSetDoneTitle => 'Ты прошёл все задачи';

  @override
  String get puzzleSetDoneBody => 'Скоро появятся новые задачи.';

  @override
  String get puzzleDailyDone => 'Задача дня решена. Продолжай со следующими.';

  @override
  String get puzzleOffline => 'Для проверки задач нужна связь.';

  @override
  String missionPuzzle(int n) {
    return 'Реши задач: $n';
  }

  @override
  String get notifTitle => 'Уведомления';

  @override
  String get notifReadAll => 'Прочитать все';

  @override
  String get notifTabAll => 'Все';

  @override
  String get notifTabGame => 'Игра';

  @override
  String get notifTabSocial => 'Друзья';

  @override
  String get notifTabTournament => 'Турниры';

  @override
  String get notifToday => 'СЕГОДНЯ';

  @override
  String get notifYesterday => 'ВЧЕРА';

  @override
  String get notifEarlier => 'РАНЕЕ';

  @override
  String get notifNow => 'сейчас';

  @override
  String notifMinutesAgo(int n) {
    return '$n мин';
  }

  @override
  String notifHoursAgo(int n) {
    return '$n ч';
  }

  @override
  String notifYesterdayAt(String time) {
    return 'Вчера $time';
  }

  @override
  String get notifEmptyTitle => 'Уведомлений нет';

  @override
  String get notifEmptyBody => 'Здесь появятся заявки в друзья, приглашения в игру и новости турниров.';

  @override
  String get notifDelete => 'Удалить';

  @override
  String notifBellLabel(int n) {
    return 'Уведомления, непрочитанных: $n';
  }

  @override
  String get notifGone => 'Это приглашение уже недействительно';

  @override
  String get notifFriendRequest => 'отправил(а) вам заявку в друзья';

  @override
  String get notifFriendAccepted => 'принял(а) вашу заявку в друзья';

  @override
  String notifChallenge(String variant, int points) {
    return 'зовёт вас сыграть · $variant, до $points очков';
  }

  @override
  String notifClanInvite(String clan, String tag) {
    return 'приглашает вас в клан $clan [$tag]';
  }

  @override
  String get notifClanJoined => 'принял вас в клан';

  @override
  String get notifClanWarWho => 'Война кланов:';

  @override
  String notifClanWar(String opponent, String tag) {
    return 'соперник $opponent [$tag]. Каждая победа приносит очки клану';
  }

  @override
  String notifTournamentReminder(int n) {
    return 'начнётся через $n мин.';
  }

  @override
  String get notifTournamentStarted => 'начался. Ваш первый матч готов';

  @override
  String notifTournamentRound(int round, String opponent) {
    return '· Раунд $round готов. Соперник: $opponent';
  }

  @override
  String notifTournamentEliminated(int round) {
    return '· Раунд $round: вы выбыли';
  }

  @override
  String get notifTournamentWon => '· Вы чемпион! Приз уже на счёте';

  @override
  String notifTournamentFinished(int place) {
    return 'завершён · Ваше место: $place';
  }

  @override
  String notifSeasonEndWho(int n) {
    return 'Сезон $n';
  }

  @override
  String notifSeasonEnd(String tier) {
    return 'завершён · Ваша лига: $tier. Посмотрите итоги';
  }

  @override
  String notifLevelUpWho(int level) {
    return 'Уровень $level!';
  }

  @override
  String notifLevelUp(int coins) {
    return 'Вы получили $coins монет';
  }

  @override
  String get notifUnknown => 'Новое уведомление';

  @override
  String get notifGroupGame => 'ИГРА';

  @override
  String get notifGroupTournament => 'ТУРНИРЫ';

  @override
  String get notifGroupSocial => 'ДРУЗЬЯ И КЛАН';

  @override
  String get notifGroupRewards => 'НАГРАДЫ';

  @override
  String get notifPush => 'Push-уведомления';

  @override
  String get notifPushUnavailable => 'В этой версии push пока не работает; всё видно во входящих';

  @override
  String get notifQuietHours => 'Тихие часы';

  @override
  String notifQuietRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get notifQuietOff => 'Выкл.';

  @override
  String get notifQuietBody => 'В эти часы push не приходят, уведомления остаются во входящих.';

  @override
  String get notifQuietFrom => 'С';

  @override
  String get notifQuietTo => 'До';

  @override
  String get notifQuietSave => 'Сохранить';

  @override
  String get notifEarlierHour => 'На час раньше';

  @override
  String get notifLaterHour => 'На час позже';

  @override
  String get notifGameInvites => 'Приглашения в игру';

  @override
  String get notifTournamentStart => 'Начало турнира';

  @override
  String notifTournamentStartSub(int n) {
    return 'За $n минут';
  }

  @override
  String get notifRoundReady => 'Раунд готов';

  @override
  String get notifRoundReadySub => 'И итоги турнира';

  @override
  String get notifFriendRequests => 'Заявки в друзья';

  @override
  String get notifClanInvites => 'Приглашения в клан';

  @override
  String get notifClanWars => 'Война кланов';

  @override
  String get notifSeasonResults => 'Итоги сезона';

  @override
  String get notifPromptTitle => 'Не пропустите свой ход';

  @override
  String get notifPromptBody => 'Мы сообщим, когда начнётся турнир, будет готов ваш раунд или друг пригласит вас в игру. Каждую категорию можно отключить в настройках.';

  @override
  String get notifPromptSample1 => 'Нигяр зовёт вас сыграть · Короткие нарды, до 5 очков';

  @override
  String get notifPromptSample2 => 'Бакинский кубок пятницы начнётся через 15 мин.';

  @override
  String get notifPromptAllow => 'Включить уведомления';

  @override
  String get notifPromptLater => 'Не сейчас';

  @override
  String get bannedTitle => 'Аккаунт заблокирован';

  @override
  String bannedBodyUntil(String date) {
    return 'Ваш аккаунт заблокирован до $date за нарушение правил честной игры.';
  }

  @override
  String get bannedBodyPermanent => 'Ваш аккаунт заблокирован бессрочно за нарушение правил честной игры.';

  @override
  String bannedContact(String email) {
    return 'Если вы считаете, что это ошибка, напишите на $email.';
  }

  @override
  String get bannedOffline => 'Вы можете выйти из аккаунта и продолжить играть офлайн с компьютером или с другом.';

  @override
  String get bannedOverTitle => 'Блокировка снята';

  @override
  String get bannedOverBody => 'Ваш аккаунт снова активен. Спасибо за честную игру.';

  @override
  String get bannedContinue => 'Продолжить';

  @override
  String get authBanned => 'Этот аккаунт заблокирован';

  @override
  String clanChatMuted(String time) {
    return 'Вы не можете писать в чат до $time.';
  }

  @override
  String get clanChatMutedNoTime => 'Пока вы не можете писать в чат.';

  @override
  String get queueCooldownTitle => 'Поиск приостановлен';

  @override
  String queueCooldownBody(String time) {
    return 'Из-за нескольких незавершённых матчей общая очередь откроется через $time. Приватные комнаты и турниры доступны.';
  }

  @override
  String get queueCooldownOverBody => 'Очередь снова открыта.';

  @override
  String get queueCooldownSearch => 'Искать снова';

  @override
  String get notifModerationWarningWho => 'Предупреждение модераторов:';

  @override
  String notifModerationWarning(String reason) {
    return 'пожалуйста, соблюдайте правила честной игры. Причина: $reason';
  }

  @override
  String get notifModerationWarningPlain => 'пожалуйста, соблюдайте правила честной игры';
}
