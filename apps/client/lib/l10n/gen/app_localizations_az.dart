// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get appName => 'NardArena';

  @override
  String get continueAction => 'Davam et';

  @override
  String get comingSoon => 'Tezliklə';

  @override
  String get back => 'Geri';

  @override
  String get cancel => 'Ləğv et';

  @override
  String get retry => 'Yenidən cəhd et';

  @override
  String get valueOn => 'Açıq';

  @override
  String get valueOff => 'Bağlı';

  @override
  String get variantShort => 'Qısa nərd';

  @override
  String get variantLong => 'Uzun nərd';

  @override
  String get variantShortUpper => 'QISA NƏRD';

  @override
  String get variantLongUpper => 'UZUN NƏRD';

  @override
  String matchToPointsUpper(int n) {
    return '$n XALA QƏDƏR';
  }

  @override
  String get oneGameUpper => '1 OYUN';

  @override
  String get tabHome => 'Əsas';

  @override
  String get tabProfile => 'Profil';

  @override
  String get playerWhite => 'Ağ';

  @override
  String get playerBlack => 'Qara';

  @override
  String get computerName => 'Kompüter';

  @override
  String get you => 'Sən';

  @override
  String get languageTitle => 'Dil seçin';

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
    return 'ADDIM $current / $total';
  }

  @override
  String get variantQuestionTitle => 'Hansı nərdi oynayırsan?';

  @override
  String get variantShortDesc => 'Klassik backgammon: vurmaq, bar, ikiqat kub.';

  @override
  String get variantLongDesc =>
      'Bütün daşlar başda. Vurmaq yoxdur, yalnız bloklamaq.';

  @override
  String get variantLearnTitle => 'Öyrənmək istəyirəm';

  @override
  String variantLearnDesc(int steps) {
    return '$steps addımlıq interaktiv dərs, 5 dəqiqə.';
  }

  @override
  String get lessonSkip => 'Keç';

  @override
  String lessonProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get lessonStep1Title => 'Bu sənin taxtandır';

  @override
  String get lessonStep1Body =>
      'Ağ daşlar sənindir. Daşlar 24-cü xanadan 1-ci xanaya doğru hərəkət edir, sonra taxtadan çıxarılır. Davam etmək üçün istənilən daşa toxun.';

  @override
  String get lessonStep2Title => 'Daşı 6 xana irəli apar';

  @override
  String get lessonStep2Body =>
      'Zər 6 göstərir. 13-cü xanadakı daşa toxun, sonra işıqlanan 7-ci xanaya toxun və ya sürüşdür.';

  @override
  String get lessonStep3Title => 'İki zəri də oyna';

  @override
  String get lessonStep3Body =>
      'Zərlər 3 və 1 göstərir. 8-ci və 6-cı xanadan daşları 5-ci xanaya apar və xananı bağla.';

  @override
  String get lessonStep4Title => 'Bağlı xana';

  @override
  String get lessonStep4Body =>
      'Rəqibin iki və ya daha çox daşı olan xanaya getmək olmaz. Zər 5 göstərir: 13-cü xanadakı daşı 8-ci xanaya apar.';

  @override
  String get lessonStep5Title => 'Vurmaq';

  @override
  String get lessonStep5Body =>
      'Rəqibin tək daşına düşsən, onu bara göndərirsən. 6-cı xanadakı daşı 4-cü xanaya apar və vur.';

  @override
  String get lessonStep6Title => 'Bardan giriş';

  @override
  String get lessonStep6Body =>
      'Barda daşın varsa, əvvəl onu rəqibin evinə daxil etməlisən. Bardakı daşa toxun və 22-ci xanaya apar.';

  @override
  String get lessonStep7Title => 'Daşları çıxar';

  @override
  String get lessonStep7Body =>
      'Bütün daşlar evdədir (1–6). Zər 6 göstərir: 6-cı xanadakı daşı taxtadan çıxar.';

  @override
  String get lessonDoneTitle => 'Əla, hazırsan';

  @override
  String get lessonDoneBody =>
      'Qaydaları bilirsən. İndi kompüterə qarşı oynayıb məşq et.';

  @override
  String get lessonFinish => 'Oynamağa başla';

  @override
  String get homePlay => 'Oyna';

  @override
  String get homeChangeMode => 'Rejimi dəyiş';

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
    return 'Kompüterə qarşı · $level';
  }

  @override
  String get modeComputer => 'Kompüter';

  @override
  String get modeSameDevice => 'Bir cihazda';

  @override
  String get modeLesson => 'Dərs';

  @override
  String get modeReplays => 'Oyunlarım';

  @override
  String get setupTitle => 'Yeni oyun';

  @override
  String get setupVariantLabel => 'VARİANT';

  @override
  String get setupFormatLabel => 'FORMAT';

  @override
  String get formatOneGame => '1 oyun';

  @override
  String formatPoints(int n) {
    return '$n xal';
  }

  @override
  String get setupCube => 'İkiqat kub';

  @override
  String get aiTitle => 'Kompüterə qarşı';

  @override
  String get aiLevelBeginner => 'Başlanğıc';

  @override
  String get aiLevelAmateur => 'Həvəskar';

  @override
  String get aiLevelMedium => 'Orta';

  @override
  String get aiLevelStrong => 'Güclü';

  @override
  String get aiLevelMaster => 'Usta';

  @override
  String get aiLevelGrandmaster => 'Qrossmeyster';

  @override
  String get aiLevelBeginnerDesc => 'Qaydaları öyrənənlər üçün';

  @override
  String get aiLevelAmateurDesc => 'Sadə səhvlər edir';

  @override
  String get aiLevelMediumDesc => 'Əsas strategiyanı bilir';

  @override
  String get aiLevelStrongDesc => 'Nadir səhv, kubu düzgün işlədir';

  @override
  String get aiLevelMasterDesc => 'Klub oyunçusu səviyyəsi';

  @override
  String get aiLevelGrandmasterDesc => 'Ən güclü rejim, səhv etmir';

  @override
  String aiStart(String level) {
    return 'Başla · $level';
  }

  @override
  String get hotseatTitle => 'Bir cihazda';

  @override
  String get hotseatWhite => 'Ağ daşlar';

  @override
  String get hotseatBlack => 'Qara daşlar';

  @override
  String get hotseatGameSection => 'OYUN';

  @override
  String get hotseatHideBetweenTurns => 'Növbələr arası ekranı gizlət';

  @override
  String get hotseatHideBetweenTurnsSub => '“Telefonu rəqibə ver” ekranı';

  @override
  String get hotseatFlipBoard => 'Taxtanı çevir';

  @override
  String get hotseatFlipBoardSub => 'Hər növbədə növbəti oyunçuya tərəf';

  @override
  String get hotseatAllowUndo => 'Gedişi geri almaq';

  @override
  String get hotseatAllowUndoSub => 'Rəqib hazıram deyənə qədər';

  @override
  String get hotseatStart => 'Oyuna başla';

  @override
  String get hotseatEditName => 'Adı dəyiş';

  @override
  String get hotseatNameHint => 'Oyunçunun adı';

  @override
  String get hotseatDefaultWhite => 'Oyunçu 1';

  @override
  String get hotseatDefaultBlack => 'Oyunçu 2';

  @override
  String get handoffOverline => 'NÖVBƏ DƏYİŞDİ';

  @override
  String handoffTitle(String name) {
    return 'Növbə: $name';
  }

  @override
  String handoffBody(String side, String prevName, String moves) {
    return '$side. $prevName son gedişi etdi: $moves.';
  }

  @override
  String handoffBodyNoMove(String side, String prevName) {
    return '$side. $prevName oynaya bilmədi.';
  }

  @override
  String handoffFirst(String side) {
    return '$side. Oyunu sən başlayırsan.';
  }

  @override
  String handoffReady(String name) {
    return '$name, hazıram';
  }

  @override
  String handoffUndo(String prevName) {
    return '$prevName: gedişi geri al';
  }

  @override
  String gameModeTo(String variant, int points) {
    return '$variant · $points xala qədər';
  }

  @override
  String gameModeSingle(String variant) {
    return '$variant · 1 oyun';
  }

  @override
  String gameScore(int me, int opp) {
    return '$me – $opp';
  }

  @override
  String get bannerYourTurn => 'Sənin növbən';

  @override
  String bannerTurnOf(String name) {
    return 'Növbə: $name';
  }

  @override
  String get bannerRollHint => 'Zər at və ya ikiqat təklif et';

  @override
  String bannerLegalMoveCount(int count) {
    return '$count mümkün gediş';
  }

  @override
  String get bannerRolling => 'Zərlər atılır';

  @override
  String get bannerOpening => 'Kim başlayır?';

  @override
  String get bannerOpeningTie => 'Bərabər · yenidən atılır';

  @override
  String bannerOpeningWinner(String name) {
    return '$name başlayır';
  }

  @override
  String get bannerOpponentThinking => 'Rəqib düşünür';

  @override
  String bannerDice(int a, int b) {
    return 'Zərlər $a – $b';
  }

  @override
  String get bannerCubeOffer => 'İkiqat təklifi';

  @override
  String get bannerCubeWaiting => 'Cavab gözlənilir';

  @override
  String get bannerNoMoves => 'Gediş yoxdur';

  @override
  String get bannerGameOver => 'Oyun bitdi';

  @override
  String get bannerHeadRuleHint => 'Başdan yalnız bir daş';

  @override
  String get bannerIllegalMove => 'Qeyri-qanuni gediş';

  @override
  String get bannerOpponentNeedsOne => 'Rəqibə 1 xal qalıb';

  @override
  String get bannerYouNeedOne => 'Sənə 1 xal qalıb';

  @override
  String get crawfordChip => 'Crawford oyunu · kub yoxdur';

  @override
  String get actionRoll => 'Zər at';

  @override
  String get actionConfirm => 'Təsdiqlə';

  @override
  String actionMovesProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get actionPass => 'Keç';

  @override
  String get actionNextGame => 'Növbəti oyun';

  @override
  String get actionUndo => 'Geri al';

  @override
  String get actionDouble => 'İkiqat';

  @override
  String get actionMenu => 'Menyu';

  @override
  String playerPip(int pip) {
    return 'Pip $pip';
  }

  @override
  String playerBotLevel(String level) {
    return 'Kompüter · $level';
  }

  @override
  String get noMovesTitle => 'Mümkün gediş yoxdur';

  @override
  String noMovesBody(int a, int b, String reason) {
    return '$a – $b · $reason. Növbə 2 saniyəyə rəqibə keçir.';
  }

  @override
  String get noMovesReasonBar => 'bar bağlıdır';

  @override
  String get noMovesReasonBlocked => 'bütün yollar bağlıdır';

  @override
  String cubeOfferTitle(String name) {
    return '$name ikiqat təklif edir';
  }

  @override
  String cubeOfferBody(int from, int to) {
    return 'Oyunun dəyəri $from → $to xal. Qəbul etsən, kub sənə keçir.';
  }

  @override
  String get cubeDecline => 'İmtina et';

  @override
  String cubeDeclineSub(int points) {
    return '−$points xal, oyun bitir';
  }

  @override
  String get cubeAccept => 'Qəbul et';

  @override
  String cubeAcceptSub(int points) {
    return 'Dəyər $points xal';
  }

  @override
  String cubeBotTook(int points) {
    return 'Kompüter ikiqatı qəbul etdi · dəyər $points xal';
  }

  @override
  String get gameWonTitle => 'QƏLƏBƏ';

  @override
  String get gameLostTitle => 'MƏĞLUBİYYƏT';

  @override
  String gameWinnerTitle(String name) {
    return '$name QAZANDI';
  }

  @override
  String resultSingle(int points) {
    return '+$points xal';
  }

  @override
  String resultMars(int points) {
    return 'Mars · +$points xal';
  }

  @override
  String resultKoks(int points) {
    return 'Koks · +$points xal';
  }

  @override
  String resultDropped(int points) {
    return 'İkiqat rədd edildi · +$points xal';
  }

  @override
  String resultResigned(int points) {
    return 'Təslim oldu · +$points xal';
  }

  @override
  String gameMatchProgress(int target, int left) {
    return '$target xala qədər · matça $left xal qaldı';
  }

  @override
  String get actionViewReplay => 'Replay';

  @override
  String get matchWonTitle => 'Matç qələbəsi';

  @override
  String get matchLostTitle => 'Matç məğlubiyyəti';

  @override
  String matchWinnerTitle(String name) {
    return '$name matçı qazandı';
  }

  @override
  String matchMeta(String me, String opp, int points) {
    return '$me · $opp · $points xala qədər';
  }

  @override
  String matchMetaSingle(String me, String opp) {
    return '$me · $opp · 1 oyun';
  }

  @override
  String get matchRematch => 'Revanş';

  @override
  String get matchHome => 'Ana səhifə';

  @override
  String get resignTitle => 'Təslim ol';

  @override
  String resignBody(int cube) {
    return 'Kubun dəyəri ×$cube. Rəqibə verəcəyin xalı seç.';
  }

  @override
  String get resignSingle => 'Tək oyun';

  @override
  String get resignSingleDesc => 'Adi məğlubiyyət';

  @override
  String get resignMars => 'Mars';

  @override
  String get resignMarsDesc => 'Heç daş çıxarılmayıb';

  @override
  String get resignKoks => 'Koks';

  @override
  String get resignKoksDesc => 'Daş barda və ya rəqib evində';

  @override
  String get resignKoksDescLong => 'Daş hələ rəqibin evindən keçməyib';

  @override
  String resignPoints(int points) {
    return '−$points';
  }

  @override
  String resignConfirm(int points) {
    return 'Təslim ol · −$points';
  }

  @override
  String get menuResume => 'Oyuna qayıt';

  @override
  String get menuSettings => 'Ayarlar';

  @override
  String get menuRules => 'Qaydalar';

  @override
  String get menuSound => 'Səs';

  @override
  String get menuResign => 'Təslim ol';

  @override
  String get menuLeave => 'Oyundan çıx';

  @override
  String get leaveTitle => 'Oyundan çıxırsan?';

  @override
  String get leaveBody => 'Bu oyun yadda saxlanmayacaq.';

  @override
  String get leaveConfirm => 'Çıx';

  @override
  String get ruleHeadTitle => 'Başdan yalnız bir daş götürmək olar';

  @override
  String get ruleHeadBody =>
      'Bu növbədə başdan artıq bir daş oynadın. İstisna: ilk atışda 6-6, 4-4 və ya 3-3 düşəndə iki daş götürmək olar.';

  @override
  String get ruleSixBlockTitle => 'Ardıcıl 6 xananı bağlamaq olmaz';

  @override
  String ruleSixBlockBody(String from, String to) {
    return '$from → $to gedişi 6 xanalıq sədd qurur, qabağında isə rəqibin heç bir daşı yoxdur. Başqa gediş seç.';
  }

  @override
  String get rulePointClosedTitle => 'Bu xana bağlıdır';

  @override
  String get rulePointClosedShort =>
      'Rəqibin iki və ya daha çox daşı olan xanaya getmək olmaz.';

  @override
  String get rulePointClosedLong =>
      'Uzun nərddə rəqibin daşı olan xanaya getmək olmaz.';

  @override
  String get ruleBarTitle => 'Əvvəl bardakı daşı daxil et';

  @override
  String get ruleBarBody => 'Barda daşın olduqca başqa daşla oynamaq olmaz.';

  @override
  String get ruleBothDiceTitle => 'Hər iki zəri oynamaq lazımdır';

  @override
  String get ruleBothDiceBody =>
      'Bu gediş digər zəri oynamağa imkan vermir. Hər iki zəri işlədən gediş seç.';

  @override
  String get ruleLargerDieTitle => 'Böyük zəri oyna';

  @override
  String get ruleLargerDieBody =>
      'Yalnız bir zər oynana bilirsə, böyük zəri oynamaq lazımdır.';

  @override
  String get ruleBearOffTitle => 'Hələ daş çıxarmaq olmaz';

  @override
  String get ruleBearOffBody =>
      'Daş çıxarmaq üçün bütün daşlar evdə (1–6) olmalıdır.';

  @override
  String get ruleBearOffHigherTitle => 'Əvvəl yuxarı xanadakı daşı oyna';

  @override
  String get ruleBearOffHigherBody =>
      'Böyük zərlə yalnız ən yuxarı xanadakı daşı çıxarmaq olar.';

  @override
  String get ruleNoDieTitle => 'Bu məsafəyə zər yoxdur';

  @override
  String get ruleNoDieBody =>
      'Daşı yalnız zərlərdəki xana sayı qədər aparmaq olar.';

  @override
  String get ruleNoCheckerTitle => 'Bu xanada sənin daşın yoxdur';

  @override
  String get ruleTurnCompleteTitle => 'Bütün zərlər oynanıb';

  @override
  String get ruleTurnCompleteBody => 'Gedişi təsdiqlə və ya geri al.';

  @override
  String get replayListTitle => 'Oyunlarım';

  @override
  String get replayEmptyTitle => 'Hələ oyun yoxdur';

  @override
  String get replayEmptyBody =>
      'Bitirdiyin oyunlar burada görünəcək. Replay ilə hər gedişə yenidən baxa bilərsən.';

  @override
  String replayTitle(int n) {
    return 'Replay · Oyun $n';
  }

  @override
  String replayPlayers(String p1, String p2) {
    return '$p1 – $p2';
  }

  @override
  String get replayStart => 'Başlanğıc';

  @override
  String get replayBack => 'Geri';

  @override
  String get replayPlay => 'Oynat';

  @override
  String get replayPause => 'Dayandır';

  @override
  String get replayForward => 'İrəli';

  @override
  String get replayEnd => 'Son';

  @override
  String replayOpening(int a, int b) {
    return 'Açılış: $a – $b';
  }

  @override
  String get replayNoMove => 'gediş yoxdur';

  @override
  String get replayDouble => 'ikiqat təklif';

  @override
  String get replayTake => 'qəbul';

  @override
  String get replayDrop => 'rədd';

  @override
  String get replayResign => 'təslim';

  @override
  String replayWon(String name, int points) {
    return '$name qazandı · $points xal';
  }

  @override
  String get replayLoadError => 'Oyun açılmadı';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsGroupGame => 'OYUN';

  @override
  String get settingsGroupAccessibility => 'ƏLÇATANLIQ';

  @override
  String get settingsGroupGeneral => 'ÜMUMİ';

  @override
  String get settingsConfirmMove => 'Gedişi təsdiqlə';

  @override
  String get settingsAutoRoll => 'Avtomatik zər at';

  @override
  String get settingsShowLegalMoves => 'Mümkün gedişləri göstər';

  @override
  String get settingsPipCount => 'Pip sayı';

  @override
  String get settingsAnimationSpeed => 'Animasiya sürəti';

  @override
  String get animationSpeedSlow => 'Yavaş';

  @override
  String get animationSpeedNormal => 'Normal';

  @override
  String get animationSpeedFast => 'Sürətli';

  @override
  String get settingsColorBlind => 'Rəng korluğu rejimi';

  @override
  String get settingsLargePips => 'Böyük zər xalları';

  @override
  String get settingsReduceMotion => 'Hərəkəti azalt';

  @override
  String get settingsSound => 'Səs';

  @override
  String get settingsHaptics => 'Vibrasiya';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsReplays => 'Oyunlarım';

  @override
  String get settingsLesson => 'Dərsi təkrarla';

  @override
  String settingsAbout(String version) {
    return 'Versiya $version';
  }

  @override
  String get errorTitle => 'Nəsə alınmadı';

  @override
  String get errorBody =>
      'Yenidən cəhd et. Problem davam edərsə, tətbiqi yenidən aç.';

  @override
  String get playVsComputer => 'Kompüterə qarşı oyna';

  @override
  String get rulesShortBody =>
      'Hər oyunçunun 15 daşı var. Daşlar zərə görə 24-dən 1-ə doğru hərəkət edir. Rəqibin tək daşına düşsən, onu bara göndərirsən; iki və daha çox daşı olan xana bağlıdır. Bütün daşlar evə (1–6) çatanda çıxarmağa başlayırsan. İlk 15 daşı çıxaran qalib gəlir. Rəqib heç daş çıxarmayıbsa — mars (×2), daşı barda və ya sənin evindədirsə — koks (×3).';

  @override
  String get rulesLongBody =>
      'Bütün 15 daş başda (24-cü xana) başlayır. Vurmaq yoxdur: rəqibin daşı olan xanaya getmək olmaz. Hər növbədə başdan yalnız bir daş götürmək olar (ilk atışda 6-6, 4-4, 3-3 istisnadır). Qabağında rəqib daşı olmayan ardıcıl 6 xananı bağlamaq olmaz. Bütün daşlar evə çatanda çıxarmağa başlayırsan. Rəqib heç daş çıxarmayıbsa — mars (×2), daşı hələ sənin evindən keçməyibsə — koks (×3).';
}
