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
  String get variantLongDesc => 'Bütün daşlar başda. Vurmaq yoxdur, yalnız bloklamaq.';

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
  String get lessonStep1Body => 'Ağ daşlar sənindir. Daşlar 24-cü xanadan 1-ci xanaya doğru hərəkət edir, sonra taxtadan çıxarılır. Davam etmək üçün istənilən daşa toxun.';

  @override
  String get lessonStep2Title => 'Daşı 6 xana irəli apar';

  @override
  String get lessonStep2Body => 'Zər 6 göstərir. 13-cü xanadakı daşa toxun, sonra işıqlanan 7-ci xanaya toxun və ya sürüşdür.';

  @override
  String get lessonStep3Title => 'İki zəri də oyna';

  @override
  String get lessonStep3Body => 'Zərlər 3 və 1 göstərir. 8-ci və 6-cı xanadan daşları 5-ci xanaya apar və xananı bağla.';

  @override
  String get lessonStep4Title => 'Bağlı xana';

  @override
  String get lessonStep4Body => 'Rəqibin iki və ya daha çox daşı olan xanaya getmək olmaz. Zər 5 göstərir: 13-cü xanadakı daşı 8-ci xanaya apar.';

  @override
  String get lessonStep5Title => 'Vurmaq';

  @override
  String get lessonStep5Body => 'Rəqibin tək daşına düşsən, onu bara göndərirsən. 6-cı xanadakı daşı 4-cü xanaya apar və vur.';

  @override
  String get lessonStep6Title => 'Bardan giriş';

  @override
  String get lessonStep6Body => 'Barda daşın varsa, əvvəl onu rəqibin evinə daxil etməlisən. Bardakı daşa toxun və 22-ci xanaya apar.';

  @override
  String get lessonStep7Title => 'Daşları çıxar';

  @override
  String get lessonStep7Body => 'Bütün daşlar evdədir (1–6). Zər 6 göstərir: 6-cı xanadakı daşı taxtadan çıxar.';

  @override
  String get lessonDoneTitle => 'Əla, hazırsan';

  @override
  String get lessonDoneBody => 'Qaydaları bilirsən. İndi kompüterə qarşı oynayıb məşq et.';

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
  String get ruleHeadBody => 'Bu növbədə başdan artıq bir daş oynadın. İstisna: ilk atışda 6-6, 4-4 və ya 3-3 düşəndə iki daş götürmək olar.';

  @override
  String get ruleSixBlockTitle => 'Ardıcıl 6 xananı bağlamaq olmaz';

  @override
  String ruleSixBlockBody(String from, String to) {
    return '$from → $to gedişi 6 xanalıq sədd qurur, qabağında isə rəqibin heç bir daşı yoxdur. Başqa gediş seç.';
  }

  @override
  String get rulePointClosedTitle => 'Bu xana bağlıdır';

  @override
  String get rulePointClosedShort => 'Rəqibin iki və ya daha çox daşı olan xanaya getmək olmaz.';

  @override
  String get rulePointClosedLong => 'Uzun nərddə rəqibin daşı olan xanaya getmək olmaz.';

  @override
  String get ruleBarTitle => 'Əvvəl bardakı daşı daxil et';

  @override
  String get ruleBarBody => 'Barda daşın olduqca başqa daşla oynamaq olmaz.';

  @override
  String get ruleBothDiceTitle => 'Hər iki zəri oynamaq lazımdır';

  @override
  String get ruleBothDiceBody => 'Bu gediş digər zəri oynamağa imkan vermir. Hər iki zəri işlədən gediş seç.';

  @override
  String get ruleLargerDieTitle => 'Böyük zəri oyna';

  @override
  String get ruleLargerDieBody => 'Yalnız bir zər oynana bilirsə, böyük zəri oynamaq lazımdır.';

  @override
  String get ruleBearOffTitle => 'Hələ daş çıxarmaq olmaz';

  @override
  String get ruleBearOffBody => 'Daş çıxarmaq üçün bütün daşlar evdə (1–6) olmalıdır.';

  @override
  String get ruleBearOffHigherTitle => 'Əvvəl yuxarı xanadakı daşı oyna';

  @override
  String get ruleBearOffHigherBody => 'Böyük zərlə yalnız ən yuxarı xanadakı daşı çıxarmaq olar.';

  @override
  String get ruleNoDieTitle => 'Bu məsafəyə zər yoxdur';

  @override
  String get ruleNoDieBody => 'Daşı yalnız zərlərdəki xana sayı qədər aparmaq olar.';

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
  String get replayEmptyBody => 'Bitirdiyin oyunlar burada görünəcək. Replay ilə hər gedişə yenidən baxa bilərsən.';

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
  String get errorBody => 'Yenidən cəhd et. Problem davam edərsə, tətbiqi yenidən aç.';

  @override
  String get playVsComputer => 'Kompüterə qarşı oyna';

  @override
  String get rulesShortBody => 'Hər oyunçunun 15 daşı var. Daşlar zərə görə 24-dən 1-ə doğru hərəkət edir. Rəqibin tək daşına düşsən, onu bara göndərirsən; iki və daha çox daşı olan xana bağlıdır. Bütün daşlar evə (1–6) çatanda çıxarmağa başlayırsan. İlk 15 daşı çıxaran qalib gəlir. Rəqib heç daş çıxarmayıbsa — mars (×2), daşı barda və ya sənin evindədirsə — koks (×3).';

  @override
  String get rulesLongBody => 'Bütün 15 daş başda (24-cü xana) başlayır. Vurmaq yoxdur: rəqibin daşı olan xanaya getmək olmaz. Hər növbədə başdan yalnız bir daş götürmək olar (ilk atışda 6-6, 4-4, 3-3 istisnadır). Qabağında rəqib daşı olmayan ardıcıl 6 xananı bağlamaq olmaz. Bütün daşlar evə çatanda çıxarmağa başlayırsan. Rəqib heç daş çıxarmayıbsa — mars (×2), daşı hələ sənin evindən keçməyibsə — koks (×3).';

  @override
  String get actionSave => 'Yadda saxla';

  @override
  String get copied => 'Kopyalandı';

  @override
  String get valueNone => '—';

  @override
  String get authWelcomeTitle => 'Xoş gəldin';

  @override
  String get authWelcomeBody => 'Hesab yaratsan reytinqin və matç tarixçən bütün cihazlarda saxlanacaq.';

  @override
  String get authApple => 'Apple ilə davam et';

  @override
  String get authGoogle => 'Google ilə davam et';

  @override
  String get authEmail => 'E-poçt ilə davam et';

  @override
  String get authGuest => 'Qonaq kimi oyna';

  @override
  String authLegal(String terms, String privacy) {
    return 'Davam etməklə $terms və $privacy ilə razılaşırsan.';
  }

  @override
  String get authTerms => 'İstifadə şərtləri';

  @override
  String get authPrivacy => 'Məxfilik siyasəti';

  @override
  String get authProviderUnavailable => 'Bu giriş üsulu hələ hazır deyil. E-poçt ilə və ya qonaq kimi davam et.';

  @override
  String get authOffline => 'Serverlə əlaqə yoxdur. İnterneti yoxla və yenidən cəhd et.';

  @override
  String get authTooManyTries => 'Çox cəhd etdin. Bir az sonra yenidən yoxla.';

  @override
  String get authSignIn => 'Daxil ol';

  @override
  String get emailTitle => 'E-poçtunu yaz';

  @override
  String get emailBody => 'Şifrə lazım deyil. 6 rəqəmli giriş kodu göndərəcəyik.';

  @override
  String get emailLabel => 'E-poçt';

  @override
  String get emailSend => 'Kodu göndər';

  @override
  String get emailInvalid => 'E-poçt ünvanı düzgün deyil';

  @override
  String get codeTitle => 'Kodu yaz';

  @override
  String codeBody(String email) {
    return '$email ünvanına göndərdik. Spam qovluğunu da yoxla.';
  }

  @override
  String get codeLabel => '6 rəqəmli kod';

  @override
  String codeResendIn(String time) {
    return 'Kodu yenidən göndər · $time';
  }

  @override
  String get codeResend => 'Kodu yenidən göndər';

  @override
  String get codeSent => 'Yeni kod göndərildi';

  @override
  String get codeInvalid => 'Kod yanlışdır. Yenidən yoxla.';

  @override
  String get codeExpired => 'Kodun vaxtı bitib. Yeni kod istə.';

  @override
  String get modeCasual => 'Adi';

  @override
  String get modeRanked => 'Reytinqli';

  @override
  String get searchTitle => 'Rəqib axtarılır…';

  @override
  String searchElapsed(String elapsed) {
    return 'Keçən vaxt $elapsed';
  }

  @override
  String searchTip(String tip) {
    return 'Məsləhət: $tip';
  }

  @override
  String get searchTipHeadRule => 'Uzun nərddə başdan yalnız bir daş götürülür.';

  @override
  String get searchTipPip => 'Pip sayı yarışda kimin öndə olduğunu göstərir.';

  @override
  String get searchBotSoon => '30 saniyədə canlı rəqib tapılmasa, bot ilə oynayacaqsan.';

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
    return '$rank · $rating · Qələbə $percent%';
  }

  @override
  String vsMetaNoStats(String rank, int rating) {
    return '$rank · $rating';
  }

  @override
  String get vsLabel => 'vs';

  @override
  String pointsUpper(int n) {
    return '$n XAL';
  }

  @override
  String get rankedUpper => 'REYTİNQLİ';

  @override
  String get unrankedUpper => 'REYTİNQSİZ';

  @override
  String vsStartsIn(int seconds) {
    return 'Oyun $seconds saniyəyə başlayır';
  }

  @override
  String get botBadge => 'BOT';

  @override
  String get botNoRating => 'Reytinqə təsir etmir';

  @override
  String get botFallbackNotice => '30 saniyədə canlı rəqib tapılmadı, ona görə bot ilə oynayırsan. Nəticə reytinqə təsir etmir.';

  @override
  String get gameModeCasual => 'Adi · reytinqsiz';

  @override
  String playerBotMeta(String noRating, String pip) {
    return '$noRating · $pip';
  }

  @override
  String get bannerLowTime => 'Vaxt azalır';

  @override
  String bannerTimeLeft(String time) {
    return '$time qaldı';
  }

  @override
  String get bannerOpponentOffline => 'Rəqibin bağlantısı kəsildi';

  @override
  String get bannerDisconnected => 'Bağlantı kəsildi';

  @override
  String get playerOffline => 'Oflayn';

  @override
  String reconnectTitle(String name) {
    return '$name yenidən qoşulur…';
  }

  @override
  String reconnectBody(String time) {
    return '$time qaldı · vaxt bitsə, qələbə sənindir';
  }

  @override
  String get selfReconnectTitle => 'Bağlantı bərpa olunur…';

  @override
  String get menuFairDice => 'Ədalətli zər';

  @override
  String get menuFairDiceVerify => 'Yoxla';

  @override
  String get matchRatingLabel => 'REYTİNQ';

  @override
  String matchRatingFrom(int old) {
    return '$old idi';
  }

  @override
  String matchRatingToNext(String rank, int points) {
    return '$rank üçün $points xal qaldı';
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
  String get fairTitle => 'Ədalətli zər';

  @override
  String get fairIntro => 'Hər zər atışı oyundan əvvəl kilidlənən server açarından, sənin açarından və atışın sırasından hesablanır. Oyundan sonra hər atışı özün yoxlaya bilərsən.';

  @override
  String get fairCommitment => 'Server açarının heşi (oyundan əvvəl)';

  @override
  String fairCommitmentValue(String hash) {
    return 'sha256: $hash';
  }

  @override
  String get fairServerSeed => 'Server açarı (oyundan sonra açılır)';

  @override
  String get fairYourSeed => 'Sənin açarın';

  @override
  String get fairOpponentSeed => 'Rəqibin açarı';

  @override
  String get fairRollNumber => 'Atış nömrəsi';

  @override
  String fairRollValue(int n, int a, int b) {
    return '#$n · HMAC → $a, $b';
  }

  @override
  String fairMatch(int a, int b) {
    return 'Uyğundur · $a – $b';
  }

  @override
  String fairMatchSub(int n) {
    return 'Atış #$n hesablanmış nəticə ilə eynidir';
  }

  @override
  String fairMismatch(int a, int b) {
    return 'Uyğun deyil · $a – $b';
  }

  @override
  String fairMismatchSub(int n) {
    return 'Atış #$n hesablanmış nəticədən fərqlidir';
  }

  @override
  String get fairCommitmentMismatch => 'Server açarı heşə uyğun gəlmir';

  @override
  String get fairPending => 'Oyundan sonra açılacaq';

  @override
  String get fairPendingNote => 'Server açarı oyun bitəndə açılacaq. Sonra hər atışı burada yoxlaya bilərsən.';

  @override
  String get fairNoRolls => 'Hələ atış yoxdur';

  @override
  String get fairCopy => 'Kodu kopyala';

  @override
  String get fairCheckAnother => 'Başqa atışı yoxla';

  @override
  String get fairPickTitle => 'Atışı seç';

  @override
  String fairRollRow(int n, int a, int b) {
    return '#$n · $a – $b';
  }

  @override
  String get fairOpeningTag => 'açılış';

  @override
  String get tierBronze => 'Bürünc';

  @override
  String get tierSilver => 'Gümüş';

  @override
  String get tierGold => 'Qızıl';

  @override
  String get tierPlatinum => 'Platin';

  @override
  String get tierDiamond => 'Almaz';

  @override
  String get tierMaster => 'Master';

  @override
  String get tierGrandmaster => 'Qrossmeyster';

  @override
  String rankWithSub(String tier, String sub) {
    return '$tier $sub';
  }

  @override
  String profileMeta(String rank, int rating) {
    return '$rank · $rating';
  }

  @override
  String get statRating => 'Reytinq';

  @override
  String get statWinRate => 'Qələbə faizi';

  @override
  String get statMatches => 'Matçlar';

  @override
  String get statWins => 'Qələbələr';

  @override
  String statPercent(int n) {
    return '$n%';
  }

  @override
  String get profileHistory => 'MATÇ TARİXÇƏSİ';

  @override
  String historyMeta(String variant, String format, String date) {
    return '$variant · $format · $date';
  }

  @override
  String get variantShortAbbr => 'Qısa';

  @override
  String get variantLongAbbr => 'Uzun';

  @override
  String get dateToday => 'bu gün';

  @override
  String get dateYesterday => 'dünən';

  @override
  String historyScore(int me, int opp) {
    return '$me–$opp';
  }

  @override
  String get profileEdit => 'Profili redaktə et';

  @override
  String get historyEmptyTitle => 'Hələ onlayn matç yoxdur';

  @override
  String get historyEmptyBody => 'Onlayn oynadığın matçlar burada görünəcək.';

  @override
  String get profileSignedOutTitle => 'Hesabına daxil ol';

  @override
  String get profileSignedOutBody => 'Reytinqin, statistikan və matç tarixçən burada olacaq.';

  @override
  String get nameInvalid => 'Ad 3–20 hərf, rəqəm və ya _ olmalıdır';

  @override
  String get offlineBanner => 'İnternet yoxdur · oflayn rejim';

  @override
  String get onlineOfflineTitle => 'Onlayn oyun əlçatan deyil';

  @override
  String get onlineOfflineBody => 'Kompüterə qarşı və bir cihazda oyun işləyir. Bağlantı qayıdanda yenidən cəhd et.';

  @override
  String get settingsAccountPrivacy => 'Hesab və məxfilik';

  @override
  String get accountGroupAccount => 'HESAB';

  @override
  String get accountEmail => 'E-poçt';

  @override
  String get accountNickname => 'Oyunçu adı';

  @override
  String get accountEmailAdd => 'Əlavə et';

  @override
  String get accountSignOut => 'Hesabdan çıx';

  @override
  String get accountGroupData => 'MƏLUMAT';

  @override
  String get accountExport => 'Məlumatlarımı ixrac et';

  @override
  String get accountDelete => 'Hesabı sil';

  @override
  String get exportTitle => 'Məlumatlarını ixrac et';

  @override
  String get exportBody => 'Profilin və matç tarixçən JSON faylı kimi hazırlanacaq. Hazır olanda onu kopyalaya bilərsən.';

  @override
  String get exportProfile => 'Profil və hesab';

  @override
  String get exportGames => 'Matç tarixçəsi';

  @override
  String exportGamesCount(int n) {
    return '$n matç';
  }

  @override
  String get exportFormat => 'Format';

  @override
  String get exportFormatValue => 'JSON';

  @override
  String get exportStart => 'İxracı başlat';

  @override
  String exportReady(String size) {
    return 'Fayl hazırdır · $size KB';
  }

  @override
  String get exportCopy => 'JSON-u kopyala';

  @override
  String get deleteTitle => 'Hesab silinsin?';

  @override
  String deleteItemRating(int rating) {
    return 'Reytinq ($rating), dərəcə və bütün matç tarixçəsi';
  }

  @override
  String get deleteItemHistory => 'Profil və bütün matç tarixçəsi';

  @override
  String get deleteIrreversible => 'Hesab dərhal silinir və bərpa olunmur.';

  @override
  String deleteConfirmLabel(String word) {
    return 'Təsdiq üçün $word yaz';
  }

  @override
  String get deleteConfirmWord => 'SİL';

  @override
  String get setupOnlineTitle => 'Onlayn oyun';

  @override
  String get setupTimeLabel => 'VAXT NƏZARƏTİ';

  @override
  String get timeRapid => 'Sürətli';

  @override
  String timeValue(int minutes, int delay) {
    return '$minutes dəq + ${delay}s';
  }

  @override
  String get setupRated => 'Reytinqli';

  @override
  String setupRatedSub(int rating) {
    return 'Reytinqin: $rating';
  }

  @override
  String get setupFindOpponent => 'Rəqib axtar';

  @override
  String get tabStore => 'Mağaza';

  @override
  String get lockerTitle => 'Dolab';

  @override
  String loadoutName(int n) {
    return 'Dəst $n';
  }

  @override
  String get lockerSave => 'Saxla';

  @override
  String get lockerSaved => 'Dəst yadda saxlanıldı';

  @override
  String get lockerAddLoadout => 'Yeni dəst';

  @override
  String get lockerRenameTitle => 'Dəstin adı';

  @override
  String get lockerRename => 'Adını dəyiş';

  @override
  String get lockerDelete => 'Dəsti sil';

  @override
  String lockerLoadoutLimit(int max) {
    return 'Ən çox $max dəst ola bilər.';
  }

  @override
  String get lockerEmptyTitle => 'Burada hələ heç nə yoxdur';

  @override
  String get lockerEmptyBody => 'Bu bölməyə yeni əşyalar tezliklə gələcək.';

  @override
  String get lockerShowOpponentCosmetics => 'Rəqibin kosmetikasını göstər';

  @override
  String get categoryBoard => 'Taxta';

  @override
  String get categoryCheckers => 'Daşlar';

  @override
  String get categoryDice => 'Zər';

  @override
  String get categoryDiceCup => 'Zər qabı';

  @override
  String get categoryCube => 'İkiqat kub';

  @override
  String get categoryBackground => 'Fon';

  @override
  String get categorySounds => 'Səslər';

  @override
  String get categoryEmote => 'Emote';

  @override
  String get categoryAvatarFrame => 'Avatar çərçivəsi';

  @override
  String get categoryTitle => 'Titul';

  @override
  String get categoryWinEffect => 'Qələbə effekti';

  @override
  String get categoryOther => 'Digər';

  @override
  String get itemEquipped => 'Taxılıb';

  @override
  String get itemPreviewing => 'Sınanır';

  @override
  String get itemOwned => 'Sahibsən';

  @override
  String get itemSeason => 'Sezon bileti';

  @override
  String get itemTournamentReward => 'Turnir mükafatı';

  @override
  String get itemAchievementReward => 'Nailiyyət mükafatı';

  @override
  String get rarityCommon => 'Adi';

  @override
  String get rarityRare => 'Nadir';

  @override
  String get rarityEpic => 'Epik';

  @override
  String get rarityLegendary => 'Əfsanəvi';

  @override
  String get raritySeasonal => 'Mövsümi';

  @override
  String get rarityTournament => 'Turnir';

  @override
  String get rarityCommonUpper => 'ADİ';

  @override
  String get rarityRareUpper => 'NADİR';

  @override
  String get rarityEpicUpper => 'EPİK';

  @override
  String get rarityLegendaryUpper => 'ƏFSANƏVİ';

  @override
  String get raritySeasonalUpper => 'MÖVSÜMİ';

  @override
  String get rarityTournamentUpper => 'TURNİR';

  @override
  String get itemObtainTitle => 'NECƏ ƏLDƏ EDİLİR';

  @override
  String get obtainStore => 'Mağaza';

  @override
  String get obtainSeasonPremium => 'Sezon bileti · Premium';

  @override
  String get obtainTournament => 'Turnir';

  @override
  String get obtainAchievement => 'Nailiyyət';

  @override
  String get obtainDefault => 'Standart dəst';

  @override
  String get obtainFree => 'Pulsuz';

  @override
  String priceCoins(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount sikkə',
    );
    return '$_temp0';
  }

  @override
  String priceGems(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount yaqut',
    );
    return '$_temp0';
  }

  @override
  String get itemTry => 'Sına';

  @override
  String get itemBuy => 'Al';

  @override
  String get itemEquip => 'Tax';

  @override
  String storeFeaturedOverline(int days) {
    return 'TÖVSİYƏ · $days GÜN';
  }

  @override
  String get storeDailyTitle => 'GÜNLÜK SEÇİM';

  @override
  String storeRefreshesIn(String time) {
    return 'Yenilənir $time';
  }

  @override
  String get storeGemsTitle => 'YAQUT';

  @override
  String get storePackUnavailable => 'Yaqut almaq hələ mümkün deyil. Mağaza hesabları qoşulanda açılacaq.';

  @override
  String storePackAdded(String amount) {
    return '+$amount yaqut balansına əlavə olundu';
  }

  @override
  String get accountNeededTitle => 'Hesabına daxil ol';

  @override
  String get accountNeededBody => 'Sikkə qazanmaq, dəst almaq və tapşırıqları görmək üçün hesab lazımdır.';

  @override
  String get purchasePrice => 'Qiymət';

  @override
  String get purchaseBalanceAfter => 'Balans sonra';

  @override
  String purchaseShortfall(String amount) {
    return '−$amount çatmır';
  }

  @override
  String purchaseNotEnoughGems(String pack) {
    return 'Balansın kifayət etmir. $pack yaqut paketini al və əşyanı birbaşa aç.';
  }

  @override
  String get purchaseNotEnoughCoins => 'Sikkən kifayət etmir. Sikkə yalnız qazanılır: oyna və tapşırıqları bitir.';

  @override
  String purchaseBuyPack(String amount) {
    return '$amount yaqut al';
  }

  @override
  String get purchaseToMissions => 'Tapşırıqlara bax';

  @override
  String get purchaseFailed => 'Alış alınmadı. Yenidən cəhd et.';

  @override
  String get purchaseAlreadyOwned => 'Bu əşya artıq səndədir.';

  @override
  String get purchaseNotForSale => 'Bu əşya satılmır.';

  @override
  String purchaseOwnedTitle(String item) {
    return '$item sənindir';
  }

  @override
  String get purchaseReceipt => 'Qəbz';

  @override
  String get purchasePaid => 'Ödəniş';

  @override
  String get purchaseClose => 'Bağla';

  @override
  String get purchaseEquipNow => 'İndi tax';

  @override
  String get missionsTitle => 'Tapşırıqlar';

  @override
  String streakCardTitle(int days) {
    return 'Giriş seriyası · $days gün';
  }

  @override
  String streakTomorrow(int coins) {
    return 'Sabah: +$coins';
  }

  @override
  String get missionsDaily => 'Günlük';

  @override
  String get missionsWeekly => 'Həftəlik';

  @override
  String missionsResetsIn(String time) {
    return 'Yenilənməyə $time';
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
  String get missionClaim => 'Al';

  @override
  String get missionClaimed => 'Alındı';

  @override
  String missionDoubles(int n) {
    return '$n dubl at';
  }

  @override
  String missionRankedWin(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n reytinq oyunu qazan',
      one: 'Reytinq oyunu qazan',
    );
    return '$_temp0';
  }

  @override
  String get missionCubeTakeWin => 'Kubu qəbul et və qazan';

  @override
  String get missionPlayLong => 'Uzun nərd oyna';

  @override
  String missionMars(int n) {
    return '$n oyunda mars et';
  }

  @override
  String missionPlay(int n) {
    return '$n oyun oyna';
  }

  @override
  String missionWin(int n) {
    return '$n oyun qazan';
  }

  @override
  String get missionGeneric => 'Tapşırıq';

  @override
  String dailyBonusTitle(int coins) {
    return 'Günlük bonus · +$coins';
  }

  @override
  String dailyBonusBody(int done, int total) {
    return 'Bütün günlük tapşırıqları bitir · $done / $total';
  }

  @override
  String get streakOverline => 'GİRİŞ SERİYASI';

  @override
  String get streakDay1 => '1-ci gün';

  @override
  String get streakDay2 => '2-ci gün';

  @override
  String get streakDay3 => '3-cü gün';

  @override
  String get streakDay4 => '4-cü gün';

  @override
  String get streakDay5 => '5-ci gün';

  @override
  String get streakDay6 => '6-cı gün';

  @override
  String get streakDay7 => '7-ci gün';

  @override
  String get streakBody => 'Hər gün daxil ol, 7-ci gün böyük bonusu al.';

  @override
  String streakClaim(int coins) {
    return '+$coins sikkəni al';
  }

  @override
  String get streakResetNote => 'Bir gün buraxsan, seriya 1-ci gündən başlayır.';

  @override
  String levelUpOverline(int from, int to) {
    return 'SƏVİYYƏ $from → $to';
  }

  @override
  String get levelUpTitle => 'Səviyyə yüksəldi';

  @override
  String xpProgress(String xp, String next) {
    return '$xp / $next XP';
  }

  @override
  String homeLevel(int n) {
    return 'Səv. $n';
  }

  @override
  String homeDailyMission(int done, int total) {
    return 'GÜNLÜK MİSSİYA · $done/$total';
  }

  @override
  String get homeMissionsDone => 'Bu günün tapşırıqları bitdi';

  @override
  String get matchCoins => 'sikkə';

  @override
  String get matchXp => 'təcrübə';

  @override
  String get xpBadge => 'XP';

  @override
  String get achievementsTitle => 'Nailiyyətlər';

  @override
  String achievementsCount(int done, int total) {
    return '$done / $total';
  }

  @override
  String get titlesOverline => 'TİTUL';

  @override
  String get titlesNone => 'Titulsuz';

  @override
  String get titlesLocked => 'Nailiyyətlə açılır';

  @override
  String get achFirstWin => 'İlk qələbə';

  @override
  String get achWins10 => '10 qələbə';

  @override
  String get achWins100 => '100 qələbə';

  @override
  String get achGames1000 => '1000 oyun';

  @override
  String get achMars10 => 'Mars ustası';

  @override
  String get achRankedWins25 => 'Reytinq döyüşçüsü';

  @override
  String get achStreak10 => '10 günlük seriya';

  @override
  String get achGeneric => 'Nailiyyət';

  @override
  String coinsSemantic(String amount) {
    return 'Sikkə: $amount';
  }

  @override
  String gemsSemantic(String amount) {
    return 'Yaqut: $amount';
  }

  @override
  String get emoteWheelHint => 'Sürüşdür\nvə burax';

  @override
  String get emoteButton => 'Emosiya göndər';

  @override
  String get gameChat => 'Söhbət';

  @override
  String get emoteSmile => 'Təbəssüm';

  @override
  String get emoteLaugh => 'Gülüş';

  @override
  String get emoteWow => 'Heyrət';

  @override
  String get emoteThink => 'Düşünürəm';

  @override
  String get emoteSad => 'Kədər';

  @override
  String get emoteAngry => 'Hirs';

  @override
  String get emoteTea => 'Çay';

  @override
  String get emoteClap => 'Əhsən';

  @override
  String get phraseHello => 'Salam!';

  @override
  String get phraseGoodLuck => 'Uğurlar';

  @override
  String get phraseNiceMove => 'Əla gediş';

  @override
  String get phraseDice => 'Zərlər…';

  @override
  String get phraseThanks => 'Təşəkkürlər';

  @override
  String get phraseGoodGame => 'Yaxşı oyun';

  @override
  String get phraseNiceRoll => 'Gözəl zər';

  @override
  String get phraseSorry => 'Bağışla';

  @override
  String get tabClan => 'Klan';

  @override
  String get modePrivateRoom => 'Şəxsi otaq';

  @override
  String get modeFriends => 'Dostlar';

  @override
  String get socialAccountBody => 'Dostlar, klanlar və şəxsi otaqlar üçün hesab lazımdır.';

  @override
  String get send => 'Göndər';

  @override
  String get close => 'Bağla';

  @override
  String get friendsTitle => 'Dostlar';

  @override
  String get friendsAdd => 'Əlavə et';

  @override
  String get friendsSection => 'DOSTLAR';

  @override
  String get presenceOnline => 'Onlayn';

  @override
  String get presenceInGame => 'Oyunda';

  @override
  String get presenceOffline => 'Oflayn';

  @override
  String get friendInvite => 'Çağır';

  @override
  String get friendWatch => 'İzlə';

  @override
  String get friendRequestsTitle => 'SORĞULAR';

  @override
  String get friendSentTitle => 'GÖNDƏRİLƏNLƏR';

  @override
  String get friendChallengesTitle => 'ÇAĞIRIŞLAR';

  @override
  String get friendAccept => 'Qəbul et';

  @override
  String get friendDismiss => 'Rədd et';

  @override
  String get friendCancelRequest => 'Sorğunu ləğv et';

  @override
  String challengeMeta(String variant, String format) {
    return '$variant · $format';
  }

  @override
  String get friendsEmptyTitle => 'Hələ dostun yoxdur';

  @override
  String get friendsEmptyBody => 'Adı ilə axtar və ya dost kodunu paylaş.';

  @override
  String friendInviteSent(String name) {
    return 'Dəvət göndərildi: $name';
  }

  @override
  String get friendRemoved => 'Dostluqdan çıxarıldı';

  @override
  String metaWithClan(String meta, String clan) {
    return '$meta · $clan';
  }

  @override
  String levelShort(int n) {
    return 'Səv. $n';
  }

  @override
  String get addFriendTitle => 'Dost əlavə et';

  @override
  String get addFriendSearchHint => 'Ad ilə axtar';

  @override
  String get addFriendSearchShort => 'Ən azı 3 hərf yaz';

  @override
  String get addFriendAction => 'Əlavə et';

  @override
  String get addFriendOr => 'və ya';

  @override
  String get addFriendCodeLabel => 'DOST KODUN';

  @override
  String get addFriendCodeCaption => 'Dostun bu kodu daxil etsin';

  @override
  String get addFriendCopyCode => 'Kodu kopyala';

  @override
  String get addFriendEnterCode => 'KODLA ƏLAVƏ ET';

  @override
  String get addFriendCodeHint => '8 simvollu kod';

  @override
  String get friendRequested => 'Göndərildi';

  @override
  String get friendAccepted => 'Dostsunuz';

  @override
  String get friendErrNotFound => 'Oyunçu tapılmadı';

  @override
  String get friendErrBlocked => 'Bu oyunçu ilə əlaqə mümkün deyil';

  @override
  String get friendErrAlready => 'Artıq dostsunuz';

  @override
  String get friendErrPending => 'Sorğu artıq göndərilib';

  @override
  String friendErrLimit(int max) {
    return 'Dost limiti dolub ($max)';
  }

  @override
  String get roomTitle => 'Şəxsi otaq';

  @override
  String get roomCodeLabel => 'OTAQ KODU';

  @override
  String get roomCopy => 'Kopyala';

  @override
  String get roomShare => 'Paylaş';

  @override
  String roomShareText(String code) {
    return 'NardArena-da mənimlə oyna. Otaq kodu: $code';
  }

  @override
  String get roomWaiting => 'Dost gözlənilir…';

  @override
  String roomExpiry(String time, String left) {
    return 'Bitir: $time · $left qaldı';
  }

  @override
  String roomInvited(String name) {
    return 'Dəvət: $name';
  }

  @override
  String get roomSettingVariant => 'Variant';

  @override
  String get roomSettingFormat => 'Format';

  @override
  String get roomSettingTime => 'Vaxt';

  @override
  String get roomSettingRating => 'Reytinq';

  @override
  String get roomUnrated => 'Təsir etmir';

  @override
  String get roomExpired => 'Kodun vaxtı bitdi';

  @override
  String get roomNewCode => 'Yeni kod';

  @override
  String get roomCreate => 'Otaq yarat';

  @override
  String get roomCreateSub => 'Kodu dosta göndər, o qoşulan kimi oyun başlayır';

  @override
  String get roomJoinByCode => 'Koda qoşul';

  @override
  String get roomJoinByCodeSub => 'Dostunun otağına 6 simvollu kodla gir';

  @override
  String get roomJoin => 'Qoşul';

  @override
  String get roomJoinTitle => 'Otağa qoşul';

  @override
  String get roomJoinHint => 'Dostunun göndərdiyi kodu yaz';

  @override
  String get roomJoining => 'Qoşulur…';

  @override
  String get roomCreating => 'Otaq yaradılır…';

  @override
  String get roomNotFound => 'Otaq tapılmadı və ya vaxtı bitib';

  @override
  String get roomInviteFriend => 'Dostu çağır';

  @override
  String get roomPickFriend => 'Kimi çağırırsan?';

  @override
  String get roomCancelTitle => 'Otaq bağlansın?';

  @override
  String get roomCancelBody => 'Kod etibarsız olacaq.';

  @override
  String get roomCancelConfirm => 'Bağla';

  @override
  String get spectatorLive => 'İZLƏYİCİ';

  @override
  String get spectatorLeave => 'Çıx';

  @override
  String get spectatorNoChat => 'Oyunçuların emosiyaları burada görünür';

  @override
  String get spectatorUnavailable => 'Bu oyunu izləmək mümkün deyil';

  @override
  String spectatorGameOver(String name, String score) {
    return 'Qalib: $name · $score';
  }

  @override
  String get spectatorWaiting => 'Oyun yüklənir…';

  @override
  String get playerMenuAddFriend => 'Dost əlavə et';

  @override
  String get playerMenuInvite => 'Oyuna çağır';

  @override
  String get playerMenuMute => 'Söhbəti səssizə al';

  @override
  String get playerMenuUnmute => 'Səsini aç';

  @override
  String get playerMenuReport => 'Şikayət et';

  @override
  String get playerMenuBlock => 'Blokla';

  @override
  String get playerMenuUnblock => 'Bloku götür';

  @override
  String get playerMenuUnfriend => 'Dostluqdan çıxar';

  @override
  String get playerMenuInviteClan => 'Klana dəvət et';

  @override
  String reportTitle(String name) {
    return 'Şikayət: $name';
  }

  @override
  String get reportReasonLabel => 'SƏBƏB';

  @override
  String get reportReasonAbuse => 'Təhqiramiz söhbət';

  @override
  String get reportReasonName => 'Qeyri-münasib ad və ya avatar';

  @override
  String get reportReasonCheating => 'Kömək proqramı istifadəsi';

  @override
  String get reportReasonStalling => 'Qəsdən vaxt uzatma';

  @override
  String get reportReasonLeaving => 'Oyunu qəsdən tərk etmə';

  @override
  String get reportReasonOther => 'Digər';

  @override
  String get reportNoteHint => 'Əlavə qeyd (istəyə görə)';

  @override
  String get reportAlsoBlock => 'Bu oyunçunu da blokla';

  @override
  String reportDisclosure(String name) {
    return 'Son oyunun qeydi və söhbət şikayətə avtomatik əlavə olunur. $name şikayətçinin kim olduğunu görməyəcək.';
  }

  @override
  String get reportSend => 'Şikayəti göndər';

  @override
  String get reportLimit => 'Bu gün çox şikayət göndərdin. Sabah yenidən yoxla.';

  @override
  String blockTitle(String name) {
    return '$name bloklansın?';
  }

  @override
  String get blockInfoMatchmaking => 'Təsadüfi oyunlarda səninlə qarşılaşmayacaq.';

  @override
  String get blockInfoContact => 'Sənə mesaj, dostluq və oyun dəvəti göndərə bilməyəcək.';

  @override
  String blockInfoUndo(String path) {
    return 'Bloku $path bölməsindən götürə bilərsən.';
  }

  @override
  String get privacyBlocked => 'Bloklananlar';

  @override
  String get blockConfirm => 'Blokla';

  @override
  String blockDone(String name) {
    return '$name bloklandı.';
  }

  @override
  String get unblockDone => 'Blok götürüldü';

  @override
  String get blockedEmpty => 'Bloklanan oyunçu yoxdur';

  @override
  String get reportSentTitle => 'Şikayət göndərildi';

  @override
  String get reportSentBody => 'Moderator 24 saat ərzində baxacaq. Nəticə barədə bildiriş alacaqsan.';

  @override
  String get mutedNote => 'Səssizə alındı';

  @override
  String get unmutedNote => 'Səsi açıldı';

  @override
  String get clansTitle => 'Klanlar';

  @override
  String get clanCreateShort => 'Yarat';

  @override
  String get clanSearchHint => 'Ad və ya teq axtar';

  @override
  String clanFilterLanguage(String code) {
    return 'Dil: $code';
  }

  @override
  String get clanFilterOpen => 'Açıq';

  @override
  String clanFilterMinRating(int rating) {
    return 'Min. reytinq ≤ $rating';
  }

  @override
  String clanTag(String tag) {
    return '[$tag]';
  }

  @override
  String clanListMeta(int level, int members, int max, String rating) {
    return 'Səv. $level · $members/$max · $rating';
  }

  @override
  String get clanJoin => 'Qoşul';

  @override
  String get clanApply => 'Müraciət';

  @override
  String get clanFull => 'Dolu';

  @override
  String get clanInviteOnlyShort => 'Dəvətlə';

  @override
  String get clanPending => 'Gözləyir';

  @override
  String get clanEmpty => 'Klan tapılmadı';

  @override
  String get clanEmptyBody => 'Başqa ad yoxla və ya öz klanını yarat.';

  @override
  String get clanInvitesTitle => 'DƏVƏTLƏR';

  @override
  String clanInviteFrom(String name) {
    return 'Dəvət edən: $name';
  }

  @override
  String get clanStatLevel => 'Səviyyə';

  @override
  String get clanStatMembers => 'Üzv';

  @override
  String get clanStatRating => 'Reytinq';

  @override
  String get clanStatLanguage => 'Dil';

  @override
  String clanMembersValue(int members, int max) {
    return '$members/$max';
  }

  @override
  String get clanRequirements => 'TƏLƏBLƏR';

  @override
  String get clanReqMinRating => 'Min. reytinq';

  @override
  String get clanReqPolicy => 'Qəbul';

  @override
  String get clanReqNone => 'Yoxdur';

  @override
  String get clanTopMembers => 'ƏN YAXŞI ÜZVLƏR';

  @override
  String clanMemberWithRole(String name, String role) {
    return '$name · $role';
  }

  @override
  String get clanApplyCta => 'Müraciət et';

  @override
  String get clanJoinCta => 'Qoşul';

  @override
  String get clanAppliedCta => 'Müraciət göndərildi';

  @override
  String get clanCancelApply => 'Müraciəti geri götür';

  @override
  String get clanInviteOnlyCta => 'Yalnız dəvətlə';

  @override
  String get clanFullCta => 'Klan doludur';

  @override
  String get clanReqNotMet => 'Tələblərə uyğun deyilsən';

  @override
  String get clanLeaveFirst => 'Əvvəlcə hazırkı klandan çıx';

  @override
  String get clanOpenMine => 'Klana keç';

  @override
  String get clanAcceptInvite => 'Dəvəti qəbul et';

  @override
  String get clanErrRatingLow => 'Reytinqin bu klan üçün azdır';

  @override
  String get clanErrInClan => 'Artıq klandasan';

  @override
  String get policyOpen => 'Açıq';

  @override
  String get policyOpenSub => 'Reytinq şərtinə uyğun hər kəs dərhal qoşulur';

  @override
  String get policyRequest => 'Müraciət ilə';

  @override
  String get policyRequestSub => 'Lider, müavinlər və ağsaqqallar təsdiqləyir';

  @override
  String get policyInvite => 'Yalnız dəvət';

  @override
  String get policyInviteSub => 'Siyahıda görünür, amma qoşulmaq üçün dəvət lazımdır';

  @override
  String get roleLeader => 'Lider';

  @override
  String get roleCoLeader => 'Müavin';

  @override
  String get roleElder => 'Ağsaqqal';

  @override
  String get roleMember => 'Üzv';

  @override
  String get emblemTitle => 'Emblem';

  @override
  String get emblemSave => 'Saxla';

  @override
  String get emblemTabShape => 'Forma';

  @override
  String get emblemTabSymbol => 'Simvol';

  @override
  String get emblemTabColor => 'Rəng';

  @override
  String get emblemTabPattern => 'Naxış';

  @override
  String get emblemPrimaryColor => 'ƏSAS RƏNG';

  @override
  String get emblemShapeShield => 'Qalxan';

  @override
  String get emblemShapeHexagon => 'Altıbucaq';

  @override
  String get emblemShapeOctagon => 'Səkkizbucaq';

  @override
  String get emblemShapeCircle => 'Dairə';

  @override
  String get emblemShapeDiamond => 'Romb';

  @override
  String get emblemShapeBanner => 'Bayraq';

  @override
  String get emblemShapeStar => 'Ulduz';

  @override
  String get emblemShapeArch => 'Tağ';

  @override
  String get emblemSymbolDiamond => 'Romb';

  @override
  String get emblemSymbolDiamondDot => 'Nöqtəli romb';

  @override
  String get emblemSymbolCircle => 'Halqa';

  @override
  String get emblemSymbolSquare => 'Kvadrat';

  @override
  String get emblemSymbolInitials => 'Hərflər';

  @override
  String get emblemPatternNone => 'Yoxdur';

  @override
  String get emblemPatternLattice => 'Şəbəkə';

  @override
  String get emblemColorGarnet => 'Nar';

  @override
  String get emblemColorIndigo => 'İndiqo';

  @override
  String get emblemColorEmerald => 'Zümrüd';

  @override
  String get emblemColorBrass => 'Tunc';

  @override
  String get emblemColorPurple => 'Bənövşəyi';

  @override
  String get emblemColorSlate => 'Şifer';

  @override
  String get emblemColorIvory => 'Fil sümüyü';

  @override
  String get emblemColorBlue => 'Mavi';

  @override
  String get emblemColorWalnut => 'Qoz';

  @override
  String clanOnline(int n) {
    return '$n onlayn';
  }

  @override
  String get clanTabChat => 'Söhbət';

  @override
  String get clanTabActivity => 'Fəaliyyət';

  @override
  String get clanTabWar => 'Döyüş';

  @override
  String get clanTabChest => 'Sandıq';

  @override
  String get clanChestTitle => 'Həftəlik sandıq';

  @override
  String clanChestProgress(String current, String target) {
    return '$current / $target';
  }

  @override
  String get clanChatHint => 'Mesaj yaz…';

  @override
  String get clanChatEmpty => 'Hələ mesaj yoxdur. İlk sən yaz.';

  @override
  String get clanActivityEmpty => 'Hələ hadisə yoxdur';

  @override
  String get clanChatTooFast => 'Çox tez yazırsan. Bir az gözlə.';

  @override
  String clanSysCreated(String name) {
    return 'Klan yaradıldı: $name';
  }

  @override
  String clanSysJoined(String name) {
    return '$name klana qoşuldu';
  }

  @override
  String clanSysLeft(String name) {
    return '$name klandan çıxdı';
  }

  @override
  String clanSysKicked(String name) {
    return '$name klandan çıxarıldı';
  }

  @override
  String clanSysRole(String name, String role) {
    return '$name: yeni rütbə · $role';
  }

  @override
  String clanSysLeader(String name) {
    return 'Yeni lider: $name';
  }

  @override
  String clanSysRenamed(String name, String tag) {
    return 'Klanın yeni adı: $name [$tag]';
  }

  @override
  String clanSysDonated(String name, String amount) {
    return '$name sandığa $amount sikkə qoydu';
  }

  @override
  String get clanSysChestFull => 'Həftəlik sandıq doldu';

  @override
  String clanSysWarStarted(String name, String tag) {
    return 'Klan döyüşü başladı: $name [$tag]';
  }

  @override
  String clanSysWarWin(String name, String points) {
    return '$name klan döyüşündə qalib gəldi · +$points';
  }

  @override
  String clanSysWarEnded(String mine, String theirs) {
    return 'Klan döyüşü bitdi · $mine : $theirs';
  }

  @override
  String get clanMenuMembers => 'Üzvlər';

  @override
  String get clanMenuLeaderboard => 'Klan reytinqi';

  @override
  String get clanMenuProfile => 'Klan profili';

  @override
  String get clanMenuEmblem => 'Emblemi dəyiş';

  @override
  String get clanMenuRequests => 'Müraciətlər';

  @override
  String get clanMenuInvite => 'Dost dəvət et';

  @override
  String get clanMenuLeave => 'Klandan çıx';

  @override
  String get clanLeaveTitle => 'Klandan çıxırsan?';

  @override
  String get clanLeaveBody => 'Klan söhbəti və sandığa çıxışın bağlanacaq.';

  @override
  String get clanLeaveLastBody => 'Sən sonuncu üzvsən: klan bağlanacaq.';

  @override
  String get clanTransferFirst => 'Çıxmazdan əvvəl liderliyi başqa üzvə ver.';

  @override
  String get chatDelete => 'Sil';

  @override
  String get clanChestDonate => 'Sandığa qoy';

  @override
  String clanChestMine(String amount) {
    return 'Bu həftə sənin payın: $amount';
  }

  @override
  String clanChestReward(int xp) {
    return 'Sandıq dolanda klan $xp XP qazanır';
  }

  @override
  String get clanChestFullNote => 'Bu həftə sandıq doldu';

  @override
  String get clanChestAmount => 'MƏBLƏĞ';

  @override
  String clanDonated(String amount) {
    return 'Sandığa $amount sikkə qoydun';
  }

  @override
  String get clanErrChestFull => 'Sandıq artıq doludur';

  @override
  String get clanDonors => 'BU HƏFTƏNİN PAYLARI';

  @override
  String get membersTitle => 'Üzvlər';

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
    return '$name (sən)';
  }

  @override
  String get memberViewProfile => 'Profilə bax';

  @override
  String get memberInviteFriendly => 'Dostluq matçına çağır';

  @override
  String get memberPromoteCoLeader => 'Müavin et';

  @override
  String get memberPromoteElder => 'Ağsaqqal et';

  @override
  String get memberDemote => 'Üzv et';

  @override
  String get memberTransferLead => 'Liderliyi ver';

  @override
  String get memberKick => 'Klandan çıxar';

  @override
  String memberKickConfirm(String name) {
    return '$name klandan çıxarılsın?';
  }

  @override
  String memberTransferConfirm(String name) {
    return 'Liderliyi ver: $name?';
  }

  @override
  String get memberTransferBody => 'Sən müavin olacaqsan.';

  @override
  String get requestsEmpty => 'Yeni müraciət yoxdur';

  @override
  String get clanInvited => 'Dəvət göndərildi';

  @override
  String warLive(String time) {
    return 'CANLI · BİTMƏSİNƏ $time';
  }

  @override
  String warCounted(int n, int max) {
    return '$n / $max matç sayıldı';
  }

  @override
  String get warMatches => 'MATÇLAR';

  @override
  String warFinished(int a, int b) {
    return 'Bitdi $a–$b';
  }

  @override
  String get warWon => 'BİTDİ · QƏLƏBƏ';

  @override
  String get warLost => 'BİTDİ · MƏĞLUBİYYƏT';

  @override
  String get warDraw => 'BİTDİ · HEÇ-HEÇƏ';

  @override
  String get warNoneTitle => 'Bu həftə döyüş yoxdur';

  @override
  String get warNoneBody => 'Klanlar hər bazar ertəsi cütləşdirilir. Döyüş üçün ən azı 2 aktiv üzv lazımdır.';

  @override
  String get warNoOpponent => 'Rəqib tapılmadı';

  @override
  String warHowTo(int points) {
    return 'Rəqib klanın üzvlərinə qarşı hər onlayn qələbə +$points xal gətirir.';
  }

  @override
  String get warMatchesEmpty => 'Hələ matç sayılmayıb';

  @override
  String get clanLeaderboardTitle => 'Klan reytinqi';

  @override
  String clanMyRank(int rank) {
    return 'Sənin klanın · #$rank';
  }

  @override
  String get createClanTitle => 'Klan yarat';

  @override
  String createStep(int step, int total) {
    return '$step / $total';
  }

  @override
  String get createNameLabel => 'Klanın adı';

  @override
  String createNameCounter(int n, int max) {
    return '$n / $max';
  }

  @override
  String get createTagLabel => 'Teq (3–5 hərf)';

  @override
  String get createTagFree => 'Boşdur';

  @override
  String get createTagTaken => 'Tutulub';

  @override
  String get createTagInvalid => 'Yalnız 3–5 latın hərfi';

  @override
  String get createNameInvalid => 'Ad 3–24 simvol olmalıdır';

  @override
  String get createEmblemLabel => 'EMBLEM';

  @override
  String get createEmblemMore => 'Daha çox';

  @override
  String get createColorLabel => 'RƏNG';

  @override
  String get createPolicyLabel => 'QOŞULMA';

  @override
  String get createMinRatingLabel => 'MİNİMUM REYTİNQ';

  @override
  String get createMinRatingAny => 'Hamı';

  @override
  String createMinRatingMax(int n) {
    return '$n+';
  }

  @override
  String get createLanguageLabel => 'DİL';

  @override
  String get createDescriptionLabel => 'Təsvir (istəyə görə)';

  @override
  String createBalance(String from, String to) {
    return 'Balans: $from → $to';
  }

  @override
  String createRenameNote(String price) {
    return 'Ad sonra $price sikkəyə dəyişir';
  }

  @override
  String get createSubmit => 'Klanı yarat';

  @override
  String get createErrNameTaken => 'Bu ad artıq tutulub';

  @override
  String get tabTournaments => 'Turnirlər';

  @override
  String get tournamentsTitle => 'Turnirlər';

  @override
  String get tourTabLive => 'Canlı';

  @override
  String get tourTabUpcoming => 'Gələcək';

  @override
  String get tourTabMine => 'Mənim';

  @override
  String get tourTabFinished => 'Bitmiş';

  @override
  String get tourFilterAll => 'Hamısı';

  @override
  String get tourFilterFree => 'Pulsuz';

  @override
  String tourStatusLive(int n) {
    return 'CANLI · RAUND $n';
  }

  @override
  String get tourStatusOpen => 'QEYDİYYAT AÇIQDIR';

  @override
  String get tourStatusUpcoming => 'GƏLƏCƏK';

  @override
  String get tourStatusFinished => 'BİTDİ';

  @override
  String get tourStatusCancelled => 'LƏĞV EDİLDİ';

  @override
  String tourInMinutes(int n) {
    return '$n dəq';
  }

  @override
  String tourTomorrowAt(String time) {
    return 'Sabah $time';
  }

  @override
  String get tourFormatSwiss => 'İsveç';

  @override
  String get tourFormatKnockout => 'Knockout';

  @override
  String get tourFormatRoundRobin => 'Dairəvi';

  @override
  String tourRounds(int n) {
    return '$n raund';
  }

  @override
  String tourMeta(String variant, int points) {
    return '$variant · $points xal';
  }

  @override
  String tourEntrants(int n, int max) {
    return '$n/$max';
  }

  @override
  String get tourRegistered => 'Qeydiyyatdasan';

  @override
  String tourPlace(String place) {
    return 'Yer: $place';
  }

  @override
  String tourOut(String round) {
    return 'Çıxdın · $round';
  }

  @override
  String get tournamentsOfflineTitle => 'Turnirlər oflayn görünmür';

  @override
  String get tournamentsOfflineBody => 'Kompüterə qarşı və bir cihazda oyun işləyir. Bağlantı qayıdanda siyahı yenilənəcək.';

  @override
  String get tournamentsEmptyTitle => 'Hələ turnirin yoxdur';

  @override
  String get tournamentsEmptyBody => 'Qeydiyyatdan keçdiyin turnirlər burada görünəcək.';

  @override
  String get tournamentsEmptyCta => 'Gələcək turnirlərə bax';

  @override
  String get tournamentsNoneTitle => 'Turnir yoxdur';

  @override
  String get tournamentsNoneBody => 'Bu siyahıda hələ turnir yoxdur. Bir az sonra yenidən bax.';

  @override
  String get listErrorTitle => 'Siyahı yüklənmədi';

  @override
  String get listErrorBody => 'Serverlə əlaqə qurulmadı. Bir az sonra yenidən cəhd et.';

  @override
  String get sngCardMeta => 'Dolan kimi başlayır';

  @override
  String get sngJoin => 'Qoşul';

  @override
  String get privateTourCreateChoice => 'Özəl turnir yarat';

  @override
  String get privateTourJoinByCode => 'Kodla qoşul';

  @override
  String get leaderboardTitle => 'Liderlər';

  @override
  String tourHeroMeta(String status, String type, int size) {
    return '$status · $type $size';
  }

  @override
  String get tourTypeKnockoutUpper => 'KNOCKOUT';

  @override
  String get tourTypeSwissUpper => 'İSVEÇ';

  @override
  String get tourTypeRoundRobinUpper => 'DAİRƏVİ';

  @override
  String get tourTypeSngUpper => 'SIT-AND-GO';

  @override
  String get tourStartsIn => 'Başlanğıca';

  @override
  String tourLiveRound(int n, String stage) {
    return 'Raund $n · $stage';
  }

  @override
  String tourNow(int n) {
    return 'Raund $n';
  }

  @override
  String get tourPrizeFund => 'Mükafat fondu';

  @override
  String get tourParticipants => 'İştirakçılar';

  @override
  String tourParticipantsValue(int n, int max) {
    return '$n / $max';
  }

  @override
  String tourPlaceRange(String from, String to) {
    return '$from–$to';
  }

  @override
  String get tourRuleEntry => 'Giriş';

  @override
  String get tourRuleFairDice => 'Ədalətli zər';

  @override
  String get tourRuleRating => 'Reytinq';

  @override
  String get tourRuleUnrated => 'Dəyişmir';

  @override
  String tourFormatValue(String type, int points) {
    return '$type · $points xala qədər';
  }

  @override
  String tourEntryValue(String price, int rating) {
    return '$price · min. $rating';
  }

  @override
  String get tourEntryInvite => 'Dəvətlə';

  @override
  String get tourFairDiceValue => 'Yoxlanıla bilər';

  @override
  String get tourRegister => 'Qeydiyyat';

  @override
  String get tourRegisterFree => 'Qeydiyyat · Pulsuz';

  @override
  String get tourUnregister => 'Qeydiyyatı ləğv et';

  @override
  String get tourUnregisterTitle => 'Qeydiyyat ləğv edilsin?';

  @override
  String get tourUnregisterBody => 'Giriş haqqı balansına qaytarılacaq.';

  @override
  String get tourUnregisterBodyFree => 'Yerini başqa oyunçu tuta bilər.';

  @override
  String get tourRegisteredToast => 'Qeydiyyatdan keçdin';

  @override
  String get tourUnregisteredToast => 'Qeydiyyat ləğv edildi';

  @override
  String tourMinRating(int n) {
    return 'Minimum reytinq $n';
  }

  @override
  String get tourFull => 'Yer qalmayıb';

  @override
  String get tourClosed => 'Qeydiyyat bağlıdır';

  @override
  String get tourInviteOnly => 'Dəvət kodu ilə qoşul';

  @override
  String get tourOpenBracket => 'Cədvələ bax';

  @override
  String get tourWatch => 'İzlə';

  @override
  String tourTitlePrize(String name) {
    return 'Titul: $name';
  }

  @override
  String get tourRatingTooLow => 'Bu turnir üçün reytinqin azdır.';

  @override
  String get tourInviteRequired => 'Bu turnirə yalnız dəvət kodu ilə qoşulmaq olar.';

  @override
  String get tourActionFailed => 'Alınmadı. Bir az sonra yenidən cəhd et.';

  @override
  String get tourLive => 'CANLI';

  @override
  String roundOf(int n) {
    return '1/$n';
  }

  @override
  String get roundFinal => 'Final';

  @override
  String tourNextMatch(String round) {
    return 'NÖVBƏTİ MATÇIN · $round';
  }

  @override
  String tourNextMetaOpen(int points) {
    return 'Raund açıqdır · $points xala qədər';
  }

  @override
  String tourNextMetaPending(int points) {
    return 'Raund hələ açılmayıb · $points xala qədər';
  }

  @override
  String get tourOpponentTbd => 'Rəqib bəlli deyil';

  @override
  String get tourReady => 'Hazıram';

  @override
  String get tourReadyDone => 'Hazırsan';

  @override
  String get tourWaitingOpponent => 'Rəqib gözlənilir';

  @override
  String tourEliminated(String round) {
    return 'Turnirdən çıxdın · $round';
  }

  @override
  String tourFinishedPanel(String place) {
    return 'Turnir bitdi · $place';
  }

  @override
  String get zoomIn => 'Böyüt';

  @override
  String get zoomOut => 'Kiçilt';

  @override
  String standingsTitle(String name) {
    return '$name · Cədvəl';
  }

  @override
  String get standingsRound => 'Raund';

  @override
  String get standingsColRank => '#';

  @override
  String get standingsColPlayer => 'OYUNÇU';

  @override
  String get standingsColWinLoss => 'Q–M';

  @override
  String get standingsColBuchholz => 'BUCH';

  @override
  String get standingsColPoints => 'XAL';

  @override
  String standingsWinLoss(int w, int l) {
    return '$w–$l';
  }

  @override
  String get standingsFootnoteNoPlayoff => 'Bərabərlikdə Buchholz, sonra reytinq';

  @override
  String get standingsEmpty => 'Cədvəl birinci raunddan sonra görünəcək.';

  @override
  String get championTitle => 'Çempion';

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
    return '+$amount sikkə';
  }

  @override
  String get championShare => 'Paylaş';

  @override
  String championShareText(String name, String tournament) {
    return '$name $tournament turnirinin çempionu oldu. NardArena';
  }

  @override
  String get championShareCopied => 'Mətn kopyalandı';

  @override
  String sngTitle(int size) {
    return 'Sit-and-go · $size';
  }

  @override
  String sngSize(int n) {
    return '$n oyunçu';
  }

  @override
  String get sngStartsWhenFull => 'Dolan kimi başlayır';

  @override
  String sngExpires(int n) {
    return '$n dəqiqəyə dolmasa, giriş haqqı qaytarılır';
  }

  @override
  String sngFormatValue(String variant, int points) {
    return '$variant · $points xal';
  }

  @override
  String get sngEntryFee => 'Giriş haqqı';

  @override
  String get sngTimeControl => 'Vaxt nəzarəti';

  @override
  String sngNoShowRule(int n) {
    return 'Raund açılandan sonra $n saniyə ərzində qoşulmayan oyunçu raundu texniki məğlubiyyətlə verir.';
  }

  @override
  String get sngLeave => 'Çıx · giriş haqqı qaytarılır';

  @override
  String noShowOverline(int round, int table) {
    return 'RAUND $round · MASA $table';
  }

  @override
  String get noShowTitle => 'Rəqib hələ qoşulmayıb';

  @override
  String noShowBody(String name) {
    return '$name vaxt bitənə qədər gəlməsə, raund sənin xeyrinə texniki qələbə ilə bitəcək.';
  }

  @override
  String get tourBracket => 'Turnir cədvəli';

  @override
  String get walkoverTitle => 'Növbəti raunda keçdin';

  @override
  String walkoverBody(String name) {
    return '$name vaxtında qoşulmadı. Raund texniki qələbə ilə sənə verildi. Reytinq dəyişmir.';
  }

  @override
  String walkoverNextRound(int n) {
    return 'Raund $n başlayır';
  }

  @override
  String get walkoverNextRoundWhen => 'digər matçlar bitəndə';

  @override
  String get notFilledTitle => 'Turnir başlamadı';

  @override
  String notFilledBody(int minutes, int size, int joined) {
    return '$minutes dəqiqədə $size oyunçudan yalnız $joined nəfər qoşuldu. Giriş haqqı balansına qaytarıldı.';
  }

  @override
  String get notFilledBodyScheduled => 'Kifayət qədər oyunçu yığılmadı. Giriş haqqı balansına qaytarıldı.';

  @override
  String refunded(String amount) {
    return '+$amount qaytarıldı';
  }

  @override
  String notFilledJoinSmaller(int n) {
    return '$n nəfərlik masaya qoşul';
  }

  @override
  String get backToTournaments => 'Turnirlərə qayıt';

  @override
  String get privateTourTitle => 'Özəl turnir';

  @override
  String get privateTourName => 'Ad';

  @override
  String get privateTourNameHint => 'Turnirin adı';

  @override
  String get privateTourSize => 'OYUNÇU SAYI';

  @override
  String get privateTourGame => 'Oyun';

  @override
  String get privateTourLength => 'Matç uzunluğu';

  @override
  String get privateTourStart => 'Başlama vaxtı';

  @override
  String get privateTourStartManual => 'Özün başladırsan';

  @override
  String privateTourStartValue(String weekday, String time) {
    return '$weekday, $time';
  }

  @override
  String get privateTourEntry => 'Giriş haqqı';

  @override
  String get privateTourFree => 'Pulsuz';

  @override
  String get privateTourNote => 'Yaratmaq pulsuzdur. Özəl turnirlər reytinqə təsir etmir.';

  @override
  String get privateTourCreate => 'Turniri yarat';

  @override
  String get privateTourCodeLabel => 'DƏVƏT KODU';

  @override
  String privateTourMeta(String when, String variant, int points) {
    return '$when · $variant, $points xal';
  }

  @override
  String get privateTourCopyInvite => 'Dəvəti kopyala';

  @override
  String privateTourShareText(String name, String code) {
    return 'NardArena-da \"$name\" turnirinə qoşul. Dəvət kodu: $code';
  }

  @override
  String get privateTourRegistration => 'QEYDİYYAT';

  @override
  String get privateTourOrganizer => 'Təşkilatçı';

  @override
  String get privateTourJoined => 'Qoşuldu';

  @override
  String privateTourStartNowMin(int n) {
    return 'İndi başlat · ən az $n oyunçu';
  }

  @override
  String get privateTourStartNow => 'İndi başlat';

  @override
  String get privateTourCancel => 'Turniri ləğv et';

  @override
  String get privateTourCancelTitle => 'Turnir ləğv edilsin?';

  @override
  String get privateTourCancelBody => 'Qeydiyyatdan keçən bütün oyunçular üçün turnir bağlanacaq.';

  @override
  String get privateTourRemove => 'Turnirdən çıxar';

  @override
  String get privateTourCodeHint => '6 simvollu kod';

  @override
  String get privateTourCodeNotFound => 'Bu kodla turnir tapılmadı.';

  @override
  String get privateTourTooMany => 'Eyni anda ən çox 3 özəl turnir aça bilərsən.';

  @override
  String get privateTourNotEnough => 'Başlamaq üçün ən az 2 oyunçu lazımdır.';

  @override
  String homeTourMeta(String prize) {
    return 'Mükafat fondu · $prize';
  }

  @override
  String homeTourStarts(String time, String prize) {
    return 'Başlanğıc $time · $prize';
  }

  @override
  String homeSeason(int n, int days) {
    return 'SEZON $n · $days GÜN';
  }

  @override
  String homeSeasonLevel(int level, int max) {
    return 'Səviyyə $level / $max';
  }

  @override
  String get homePuzzleOverline => 'GÜNÜN TAPMACASI';

  @override
  String homeSeasonEnded(int n) {
    return 'SEZON $n BAŞA ÇATDI';
  }

  @override
  String get homeSeasonSummaryCta => 'Nəticələrinə bax';

  @override
  String get modePuzzles => 'Tapmaca';

  @override
  String seasonN(int n) {
    return 'Sezon $n';
  }

  @override
  String get lbScopeGlobal => 'Qlobal';

  @override
  String get lbScopeCountry => 'Ölkə';

  @override
  String get lbScopeFriends => 'Dostlar';

  @override
  String get lbScopeClan => 'Klan';

  @override
  String lbRank(int n) {
    return '#$n';
  }

  @override
  String get lbEmptyTitle => 'Siyahı boşdur';

  @override
  String get lbEmptyFriends => 'Dostların hələ reytinq cədvəlində yoxdur.';

  @override
  String get lbEmptyClan => 'Klanın yoxdur və ya üzvlər hələ reytinqdə deyil.';

  @override
  String get lbEmptyCountry => 'Profilində ölkə seçilməyib və ya bu ölkədən hələ oyunçu yoxdur.';

  @override
  String lbUnranked(int n) {
    return 'Reytinqə düşmək üçün bu sezon $n reytinq oyunu oyna';
  }

  @override
  String get lbSeasonPicker => 'Sezon seç';

  @override
  String get seasonPassTitle => 'Sezon bileti';

  @override
  String seasonOverline(int n, int days, int hours) {
    return 'SEZON $n · $days GÜN $hours SAAT';
  }

  @override
  String seasonOverlineHours(int n, int hours, int minutes) {
    return 'SEZON $n · $hours SAAT $minutes DƏQ';
  }

  @override
  String seasonLevelNext(int n) {
    return 'Növbəti səviyyə: $n';
  }

  @override
  String get seasonLevelMax => 'Son səviyyə';

  @override
  String get seasonTrackFree => 'PULSUZ';

  @override
  String get seasonTrackPremium => 'PREMİUM';

  @override
  String get seasonRewardItem => 'Əşya';

  @override
  String seasonEndReward(String tier) {
    return 'Sezon sonu mükafatı · $tier';
  }

  @override
  String seasonEndRewardMeta(String reward, int points) {
    return '$reward · $points xal qaldı';
  }

  @override
  String seasonEndRewardReached(String reward) {
    return '$reward · əldə edildi';
  }

  @override
  String seasonRewardWithItem(String item, String coins) {
    return '$item + $coins';
  }

  @override
  String get seasonPremiumUnlock => 'Premium aç';

  @override
  String seasonClaimAll(int n) {
    return 'Hamısını al · $n';
  }

  @override
  String get seasonPremiumOwned => 'Premium aktivdir';

  @override
  String get seasonPremiumSheetTitle => 'Sezon bileti · Premium';

  @override
  String get seasonPremiumBody => 'Premium yol bu sezonun premium mükafatlarını açır. Çatdığın səviyyələrin mükafatları dərhal alına bilər.';

  @override
  String get seasonPremiumBought => 'Premium açıldı';

  @override
  String seasonNeedsLevel(int n) {
    return 'Səviyyə $n lazımdır';
  }

  @override
  String get seasonNeedsPremium => 'Bu mükafat premium yoldadır';

  @override
  String get seasonClaimedToast => 'Mükafat alındı';

  @override
  String get seasonUnavailable => 'Sezon məlumatı yüklənmədi';

  @override
  String seasonEnded(int n) {
    return 'SEZON $n BAŞA ÇATDI';
  }

  @override
  String get seasonStatGames => 'Oyun';

  @override
  String get seasonStatWinRate => 'Qələbə';

  @override
  String get seasonStatRank => 'Dünyada yer';

  @override
  String get seasonStatCountryRank => 'Ölkədə yer';

  @override
  String get seasonStatRatingGain => 'Reytinq dəyişimi';

  @override
  String get seasonStatRating => 'Son reytinq';

  @override
  String get seasonClaimRewards => 'Mükafatları al';

  @override
  String seasonRewardLine(String reward) {
    return 'Sezon mükafatı: $reward';
  }

  @override
  String seasonSoftReset(int rating) {
    return 'Yeni sezonda reytinqin: $rating';
  }

  @override
  String get seasonNoSummaryTitle => 'Hələ bitmiş sezon yoxdur';

  @override
  String get seasonNoSummaryBody => 'İlk sezon bitəndə nəticələrin burada görünəcək.';

  @override
  String get actionAnalysis => 'Təhlil';

  @override
  String analysisTitle(int n) {
    return 'Təhlil · Oyun $n';
  }

  @override
  String get analysisEquity => 'Qiymət';

  @override
  String get analysisNote => 'Qiymətləri sadə bot hesablayır, dəqiq qələbə şansı deyil. Neyron AI gələndə dəqiqləşəcək.';

  @override
  String analysisBest(String moves) {
    return 'Ən yaxşı: $moves';
  }

  @override
  String analysisYours(String moves, String loss) {
    return 'Sənin: $moves · $loss';
  }

  @override
  String get analysisBestPlayed => 'Ən yaxşı gediş';

  @override
  String get analysisRunning => 'Təhlil edilir…';

  @override
  String get analysisMarkGood => 'Yaxşı gediş';

  @override
  String get analysisMarkMistake => 'Səhv';

  @override
  String get analysisMarkBlunder => 'Kobud səhv';

  @override
  String get analysisNotReady => 'Matçın qeydi hələ hazır deyil. Bir az sonra yenidən cəhd et.';

  @override
  String get analysisNoGames => 'Bu matçda oynanmış oyun yoxdur.';

  @override
  String analysisGameChip(int n) {
    return 'Oyun $n';
  }

  @override
  String puzzleTitle(int n, int total) {
    return 'Tapmaca $n / $total';
  }

  @override
  String get puzzleDailyTitle => 'Günün tapmacası';

  @override
  String puzzleRating(int n) {
    return 'Reytinq $n';
  }

  @override
  String get puzzlePhaseOpening => 'Açılış';

  @override
  String get puzzlePhaseMiddle => 'Ara oyun';

  @override
  String get puzzlePhaseBearOff => 'Çıxarış';

  @override
  String get puzzleLevelEasy => 'Asan';

  @override
  String get puzzleLevelMedium => 'Orta';

  @override
  String get puzzleLevelHard => 'Çətin';

  @override
  String get puzzlePrompt => 'Ən yaxşı gedişi tap';

  @override
  String puzzleContext(String side, int d1, int d2) {
    return '$side oynayırsan. Zər: $d1 – $d2.';
  }

  @override
  String get puzzleSideWhite => 'Ağ daşlarla';

  @override
  String get puzzleSideBlack => 'Qara daşlarla';

  @override
  String get puzzleHint => 'İpucu';

  @override
  String get puzzleConfirm => 'Gedişi təsdiqlə';

  @override
  String get puzzleCorrect => 'Doğru';

  @override
  String get puzzleCorrectFirstTry => 'Ən yaxşı gediş · ilk cəhddə';

  @override
  String get puzzleCorrectSecondTry => 'Ən yaxşı gediş · ikinci cəhddə';

  @override
  String get puzzleYours => 'Sənin';

  @override
  String get puzzleSecondBest => 'İkinci yaxşı';

  @override
  String get puzzleBest => 'Ən yaxşı';

  @override
  String get puzzleHidden => 'gizli';

  @override
  String get puzzleSeeAnalysis => 'Təhlilə bax';

  @override
  String get puzzleNext => 'Növbəti tapmaca';

  @override
  String get puzzleWrong => 'Ən yaxşı gediş deyil';

  @override
  String puzzleAttemptsLeft(int n) {
    return 'Qalan cəhd: $n';
  }

  @override
  String get puzzleShowSolution => 'Həllə bax';

  @override
  String get puzzleOutOfTries => 'Cəhdlər bitdi';

  @override
  String puzzleAnswer(String move) {
    return 'Düzgün cavab: $move';
  }

  @override
  String get puzzleSetDoneTitle => 'Bütün tapmacaları həll etdin';

  @override
  String get puzzleSetDoneBody => 'Yeni tapmacalar tezliklə əlavə olunacaq.';

  @override
  String get puzzleDailyDone => 'Bugünkü tapmaca bitib. Növbəti tapmacalarla davam et.';

  @override
  String get puzzleOffline => 'Tapmacaları yoxlamaq üçün bağlantı lazımdır.';

  @override
  String missionPuzzle(int n) {
    return '$n tapmaca həll et';
  }

  @override
  String get notifTitle => 'Bildirişlər';

  @override
  String get notifReadAll => 'Hamısını oxu';

  @override
  String get notifTabAll => 'Hamısı';

  @override
  String get notifTabGame => 'Oyun';

  @override
  String get notifTabSocial => 'Sosial';

  @override
  String get notifTabTournament => 'Turnir';

  @override
  String get notifToday => 'BU GÜN';

  @override
  String get notifYesterday => 'DÜNƏN';

  @override
  String get notifEarlier => 'ƏVVƏL';

  @override
  String get notifNow => 'indi';

  @override
  String notifMinutesAgo(int n) {
    return '$n dəq';
  }

  @override
  String notifHoursAgo(int n) {
    return '$n saat';
  }

  @override
  String notifYesterdayAt(String time) {
    return 'Dünən $time';
  }

  @override
  String get notifEmptyTitle => 'Bildiriş yoxdur';

  @override
  String get notifEmptyBody => 'Dostluq sorğuları, oyun dəvətləri və turnir xəbərləri burada görünəcək.';

  @override
  String get notifDelete => 'Sil';

  @override
  String notifBellLabel(int n) {
    return 'Bildirişlər, $n oxunmamış';
  }

  @override
  String get notifGone => 'Bu dəvət artıq keçərli deyil';

  @override
  String get notifFriendRequest => 'dostluq sorğusu göndərdi';

  @override
  String get notifFriendAccepted => 'dostluq sorğunu qəbul etdi';

  @override
  String notifChallenge(String variant, int points) {
    return 'səni oyuna çağırır · $variant, $points xal';
  }

  @override
  String notifClanInvite(String clan, String tag) {
    return 'səni $clan [$tag] klanına dəvət edir';
  }

  @override
  String get notifClanJoined => 'klanına qəbul olundun';

  @override
  String get notifClanWarWho => 'Klan döyüşü:';

  @override
  String notifClanWar(String opponent, String tag) {
    return 'rəqib $opponent [$tag]. Hər qələbə klana xal gətirir';
  }

  @override
  String notifTournamentReminder(int n) {
    return '$n dəqiqəyə başlayır';
  }

  @override
  String get notifTournamentStarted => 'başladı. İlk oyunun hazırdır';

  @override
  String notifTournamentRound(int round, String opponent) {
    return '· Raund $round hazırdır. Rəqib: $opponent';
  }

  @override
  String notifTournamentEliminated(int round) {
    return '· Raund $round: mübarizə bitdi';
  }

  @override
  String get notifTournamentWon => '· Çempionsan! Mükafat hesabındadır';

  @override
  String notifTournamentFinished(int place) {
    return 'bitdi · Yerin: $place';
  }

  @override
  String notifSeasonEndWho(int n) {
    return 'Sezon $n';
  }

  @override
  String notifSeasonEnd(String tier) {
    return 'bitdi · Dərəcən: $tier. Nəticələrə bax';
  }

  @override
  String notifLevelUpWho(int level) {
    return 'Səviyyə $level!';
  }

  @override
  String notifLevelUp(int coins) {
    return '+$coins sikkə qazandın';
  }

  @override
  String get notifUnknown => 'Yeni bildiriş';

  @override
  String get notifGroupGame => 'OYUN';

  @override
  String get notifGroupTournament => 'TURNİR';

  @override
  String get notifGroupSocial => 'SOSİAL';

  @override
  String get notifGroupRewards => 'MÜKAFATLAR';

  @override
  String get notifPush => 'Push bildirişləri';

  @override
  String get notifPushUnavailable => 'Bu versiyada push hələ işləmir; hamısı qutuda görünür';

  @override
  String get notifQuietHours => 'Sakit saatlar';

  @override
  String notifQuietRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get notifQuietOff => 'Söndürülüb';

  @override
  String get notifQuietBody => 'Bu saatlarda push gəlmir, bildirişlər qutuda qalır.';

  @override
  String get notifQuietFrom => 'Başlanğıc';

  @override
  String get notifQuietTo => 'Son';

  @override
  String get notifQuietSave => 'Yadda saxla';

  @override
  String get notifEarlierHour => 'Bir saat əvvəl';

  @override
  String get notifLaterHour => 'Bir saat sonra';

  @override
  String get notifGameInvites => 'Oyun dəvətləri';

  @override
  String get notifTournamentStart => 'Turnir başlayır';

  @override
  String notifTournamentStartSub(int n) {
    return '$n dəqiqə əvvəl';
  }

  @override
  String get notifRoundReady => 'Raund hazırdır';

  @override
  String get notifRoundReadySub => 'Və turnir nəticələri';

  @override
  String get notifFriendRequests => 'Dostluq sorğuları';

  @override
  String get notifClanInvites => 'Klan dəvətləri';

  @override
  String get notifClanWars => 'Klan müharibəsi';

  @override
  String get notifSeasonResults => 'Sezon nəticələri';

  @override
  String get notifPromptTitle => 'Növbəni qaçırma';

  @override
  String get notifPromptBody => 'Turnir başlayanda, raundun hazır olanda və dost dəvət göndərəndə xəbər verək. Hər kateqoriyanı ayarlardan söndürə bilərsən.';

  @override
  String get notifPromptSample1 => 'Nigar səni oyuna çağırır · Qısa nərd, 5 xal';

  @override
  String get notifPromptSample2 => 'Bakı Cümə Kuboku 15 dəqiqəyə başlayır.';

  @override
  String get notifPromptAllow => 'Bildirişləri aç';

  @override
  String get notifPromptLater => 'İndi yox';
}
