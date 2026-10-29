// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'NardArena';

  @override
  String get continueAction => 'Devam et';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get back => 'Geri';

  @override
  String get cancel => 'İptal';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get valueOn => 'Açık';

  @override
  String get valueOff => 'Kapalı';

  @override
  String get variantShort => 'Tavla';

  @override
  String get variantLong => 'Uzun tavla';

  @override
  String get variantShortUpper => 'TAVLA';

  @override
  String get variantLongUpper => 'UZUN TAVLA';

  @override
  String matchToPointsUpper(int n) {
    return '$n PUANA KADAR';
  }

  @override
  String get oneGameUpper => '1 OYUN';

  @override
  String get tabHome => 'Ana sayfa';

  @override
  String get tabProfile => 'Profil';

  @override
  String get playerWhite => 'Beyaz';

  @override
  String get playerBlack => 'Siyah';

  @override
  String get computerName => 'Bilgisayar';

  @override
  String get you => 'Sen';

  @override
  String get languageTitle => 'Dil seç';

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
    return 'ADIM $current / $total';
  }

  @override
  String get variantQuestionTitle => 'Hangi tavlayı oynuyorsun?';

  @override
  String get variantShortDesc => 'Klasik tavla: kırma, bar, katlama küpü.';

  @override
  String get variantLongDesc =>
      'Tüm pullar başta. Pul kırılmaz, sadece bloklanır.';

  @override
  String get variantLearnTitle => 'Öğrenmek istiyorum';

  @override
  String variantLearnDesc(int steps) {
    return '$steps adımlık etkileşimli ders, 5 dakika.';
  }

  @override
  String get lessonSkip => 'Geç';

  @override
  String lessonProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get lessonStep1Title => 'Bu senin tahtan';

  @override
  String get lessonStep1Body =>
      'Beyaz pullar senin. Pullar 24. haneden 1. haneye doğru ilerler, sonra tahtadan toplanır. Devam etmek için herhangi bir pula dokun.';

  @override
  String get lessonStep2Title => 'Pulu 6 hane ilerlet';

  @override
  String get lessonStep2Body =>
      'Zar 6 gösteriyor. 13. hanedeki pula dokun, sonra parlayan 7. haneye dokun ya da pulu oraya sürükle.';

  @override
  String get lessonStep3Title => 'İki zarı da oyna';

  @override
  String get lessonStep3Body =>
      'Zarlar 3 ve 1 gösteriyor. 8. ve 6. hanedeki pulları 5. haneye götür ve haneyi kapat.';

  @override
  String get lessonStep4Title => 'Kapalı hane';

  @override
  String get lessonStep4Body =>
      'Rakibin iki veya daha fazla pulu olan haneye gidemezsin. Zar 5 gösteriyor: 13. hanedeki pulu 8. haneye götür.';

  @override
  String get lessonStep5Title => 'Kırmak';

  @override
  String get lessonStep5Body =>
      'Rakibin tek pulunun üstüne gelirsen onu bara gönderirsin. 6. hanedeki pulu 4. haneye götür ve kır.';

  @override
  String get lessonStep6Title => 'Bardan giriş';

  @override
  String get lessonStep6Body =>
      'Barda pulun varsa, önce onu rakibin evine sokmalısın. Bardaki pula dokun ve 22. haneye götür.';

  @override
  String get lessonStep7Title => 'Pulları topla';

  @override
  String get lessonStep7Body =>
      'Tüm pullar evde (1–6). Zar 6 gösteriyor: 6. hanedeki pulu topla.';

  @override
  String get lessonDoneTitle => 'Harika, hazırsın';

  @override
  String get lessonDoneBody =>
      'Kuralları biliyorsun. Şimdi bilgisayara karşı oynayıp pratik yap.';

  @override
  String get lessonFinish => 'Oynamaya başla';

  @override
  String get homePlay => 'Oyna';

  @override
  String get homeChangeMode => 'Modu değiştir';

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
    return 'Bilgisayara karşı · $level';
  }

  @override
  String get modeComputer => 'Bilgisayar';

  @override
  String get modeSameDevice => 'Tek cihaz';

  @override
  String get modeLesson => 'Ders';

  @override
  String get modeReplays => 'Oyunlarım';

  @override
  String get setupTitle => 'Yeni oyun';

  @override
  String get setupVariantLabel => 'VARYANT';

  @override
  String get setupFormatLabel => 'FORMAT';

  @override
  String get formatOneGame => '1 oyun';

  @override
  String formatPoints(int n) {
    return '$n puan';
  }

  @override
  String get setupCube => 'Katlama küpü';

  @override
  String get aiTitle => 'Bilgisayara karşı';

  @override
  String get aiLevelBeginner => 'Başlangıç';

  @override
  String get aiLevelAmateur => 'Amatör';

  @override
  String get aiLevelMedium => 'Orta';

  @override
  String get aiLevelStrong => 'Güçlü';

  @override
  String get aiLevelMaster => 'Usta';

  @override
  String get aiLevelGrandmaster => 'Büyükusta';

  @override
  String get aiLevelBeginnerDesc => 'Kuralları öğrenenler için';

  @override
  String get aiLevelAmateurDesc => 'Basit hatalar yapar';

  @override
  String get aiLevelMediumDesc => 'Temel stratejiyi bilir';

  @override
  String get aiLevelStrongDesc => 'Nadiren hata yapar, küpü doğru kullanır';

  @override
  String get aiLevelMasterDesc => 'Kulüp oyuncusu seviyesi';

  @override
  String get aiLevelGrandmasterDesc => 'En güçlü mod, hata yapmaz';

  @override
  String aiStart(String level) {
    return 'Başla · $level';
  }

  @override
  String get hotseatTitle => 'Tek cihazda';

  @override
  String get hotseatWhite => 'Beyaz pullar';

  @override
  String get hotseatBlack => 'Siyah pullar';

  @override
  String get hotseatGameSection => 'OYUN';

  @override
  String get hotseatHideBetweenTurns => 'Sıra arasında ekranı gizle';

  @override
  String get hotseatHideBetweenTurnsSub => '“Telefonu rakibe ver” ekranı';

  @override
  String get hotseatFlipBoard => 'Tahtayı çevir';

  @override
  String get hotseatFlipBoardSub => 'Her sırada sıradaki oyuncuya doğru';

  @override
  String get hotseatAllowUndo => 'Hamleyi geri alma';

  @override
  String get hotseatAllowUndoSub => 'Rakip hazır diyene kadar';

  @override
  String get hotseatStart => 'Oyuna başla';

  @override
  String get hotseatEditName => 'Adı değiştir';

  @override
  String get hotseatNameHint => 'Oyuncu adı';

  @override
  String get hotseatDefaultWhite => 'Oyuncu 1';

  @override
  String get hotseatDefaultBlack => 'Oyuncu 2';

  @override
  String get handoffOverline => 'SIRA DEĞİŞTİ';

  @override
  String handoffTitle(String name) {
    return 'Sıra: $name';
  }

  @override
  String handoffBody(String side, String prevName, String moves) {
    return '$side. $prevName son hamleyi yaptı: $moves.';
  }

  @override
  String handoffBodyNoMove(String side, String prevName) {
    return '$side. $prevName oynayamadı.';
  }

  @override
  String handoffFirst(String side) {
    return '$side. Oyuna sen başlıyorsun.';
  }

  @override
  String handoffReady(String name) {
    return '$name, hazırım';
  }

  @override
  String handoffUndo(String prevName) {
    return '$prevName: hamleyi geri al';
  }

  @override
  String gameModeTo(String variant, int points) {
    return '$variant · $points puana kadar';
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
  String get bannerYourTurn => 'Sıra sende';

  @override
  String bannerTurnOf(String name) {
    return 'Sıra: $name';
  }

  @override
  String get bannerRollHint => 'Zar at veya katlama teklif et';

  @override
  String bannerLegalMoveCount(int count) {
    return '$count olası hamle';
  }

  @override
  String get bannerRolling => 'Zarlar atılıyor';

  @override
  String get bannerOpening => 'Kim başlıyor?';

  @override
  String get bannerOpeningTie => 'Beraberlik · yeniden atılıyor';

  @override
  String bannerOpeningWinner(String name) {
    return '$name başlıyor';
  }

  @override
  String get bannerOpponentThinking => 'Rakip düşünüyor';

  @override
  String bannerDice(int a, int b) {
    return 'Zarlar $a – $b';
  }

  @override
  String get bannerCubeOffer => 'Katlama teklifi';

  @override
  String get bannerCubeWaiting => 'Yanıt bekleniyor';

  @override
  String get bannerNoMoves => 'Hamle yok';

  @override
  String get bannerGameOver => 'Oyun bitti';

  @override
  String get bannerHeadRuleHint => 'Baştan yalnızca bir pul';

  @override
  String get bannerIllegalMove => 'Geçersiz hamle';

  @override
  String get bannerOpponentNeedsOne => 'Rakibe 1 puan kaldı';

  @override
  String get bannerYouNeedOne => 'Sana 1 puan kaldı';

  @override
  String get crawfordChip => 'Crawford oyunu · küp yok';

  @override
  String get actionRoll => 'Zar at';

  @override
  String get actionConfirm => 'Onayla';

  @override
  String actionMovesProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get actionPass => 'Pas';

  @override
  String get actionNextGame => 'Sonraki oyun';

  @override
  String get actionUndo => 'Geri al';

  @override
  String get actionDouble => 'Katla';

  @override
  String get actionMenu => 'Menü';

  @override
  String playerPip(int pip) {
    return 'Pip $pip';
  }

  @override
  String playerBotLevel(String level) {
    return 'Bilgisayar · $level';
  }

  @override
  String get noMovesTitle => 'Olası hamle yok';

  @override
  String noMovesBody(int a, int b, String reason) {
    return '$a – $b · $reason. Sıra 2 saniye içinde rakibe geçiyor.';
  }

  @override
  String get noMovesReasonBar => 'bardan giriş kapalı';

  @override
  String get noMovesReasonBlocked => 'tüm yollar kapalı';

  @override
  String cubeOfferTitle(String name) {
    return '$name katlama teklif ediyor';
  }

  @override
  String cubeOfferBody(int from, int to) {
    return 'Oyunun değeri $from → $to puan. Kabul edersen küp sana geçer.';
  }

  @override
  String get cubeDecline => 'Reddet';

  @override
  String cubeDeclineSub(int points) {
    return '−$points puan, oyun biter';
  }

  @override
  String get cubeAccept => 'Kabul et';

  @override
  String cubeAcceptSub(int points) {
    return 'Değeri $points puan';
  }

  @override
  String cubeBotTook(int points) {
    return 'Bilgisayar katlamayı kabul etti · değeri $points puan';
  }

  @override
  String get gameWonTitle => 'ZAFER';

  @override
  String get gameLostTitle => 'YENİLGİ';

  @override
  String gameWinnerTitle(String name) {
    return '$name KAZANDI';
  }

  @override
  String resultSingle(int points) {
    return '+$points puan';
  }

  @override
  String resultMars(int points) {
    return 'Mars · +$points puan';
  }

  @override
  String resultKoks(int points) {
    return 'Koks · +$points puan';
  }

  @override
  String resultDropped(int points) {
    return 'Katlama reddedildi · +$points puan';
  }

  @override
  String resultResigned(int points) {
    return 'Pes etti · +$points puan';
  }

  @override
  String gameMatchProgress(int target, int left) {
    return '$target puana kadar · maça $left puan kaldı';
  }

  @override
  String get actionViewReplay => 'Tekrar izle';

  @override
  String get matchWonTitle => 'Maç galibiyeti';

  @override
  String get matchLostTitle => 'Maç yenilgisi';

  @override
  String matchWinnerTitle(String name) {
    return '$name maçı kazandı';
  }

  @override
  String matchMeta(String me, String opp, int points) {
    return '$me · $opp · $points puana kadar';
  }

  @override
  String matchMetaSingle(String me, String opp) {
    return '$me · $opp · 1 oyun';
  }

  @override
  String get matchRematch => 'Rövanş';

  @override
  String get matchHome => 'Ana sayfa';

  @override
  String get resignTitle => 'Pes et';

  @override
  String resignBody(int cube) {
    return 'Küp değeri ×$cube. Rakibe vereceğin puanı seç.';
  }

  @override
  String get resignSingle => 'Tek oyun';

  @override
  String get resignSingleDesc => 'Normal yenilgi';

  @override
  String get resignMars => 'Mars';

  @override
  String get resignMarsDesc => 'Hiç pul toplanmamış';

  @override
  String get resignKoks => 'Koks';

  @override
  String get resignKoksDesc => 'Barda veya rakibin evinde pul var';

  @override
  String get resignKoksDescLong => 'Bir pul henüz rakibin evinden çıkmamış';

  @override
  String resignPoints(int points) {
    return '−$points';
  }

  @override
  String resignConfirm(int points) {
    return 'Pes et · −$points';
  }

  @override
  String get menuResume => 'Oyuna dön';

  @override
  String get menuSettings => 'Ayarlar';

  @override
  String get menuRules => 'Kurallar';

  @override
  String get menuSound => 'Ses';

  @override
  String get menuResign => 'Pes et';

  @override
  String get menuLeave => 'Oyundan çık';

  @override
  String get leaveTitle => 'Oyundan çıkıyor musun?';

  @override
  String get leaveBody => 'Bu oyun kaydedilmeyecek.';

  @override
  String get leaveConfirm => 'Çık';

  @override
  String get ruleHeadTitle => 'Baştan yalnızca bir pul alınabilir';

  @override
  String get ruleHeadBody =>
      'Bu sırada baştan birden fazla pul oynadın. İstisna: ilk atışta 6-6, 4-4 veya 3-3 gelirse iki pul alınabilir.';

  @override
  String get ruleSixBlockTitle => 'Art arda 6 hane kapatılamaz';

  @override
  String ruleSixBlockBody(String from, String to) {
    return '$from → $to hamlesi 6 hanelik bir set kuruyor ve önünde rakibin hiç pulu yok. Başka bir hamle seç.';
  }

  @override
  String get rulePointClosedTitle => 'Bu hane kapalı';

  @override
  String get rulePointClosedShort =>
      'Rakibin iki veya daha fazla pulu olan haneye gidilemez.';

  @override
  String get rulePointClosedLong =>
      'Uzun tavlada rakibin pulu olan haneye gidilemez.';

  @override
  String get ruleBarTitle => 'Önce bardaki pulu sok';

  @override
  String get ruleBarBody => 'Barda pulun varken başka pulla oynayamazsın.';

  @override
  String get ruleBothDiceTitle => 'İki zarı da oynamalısın';

  @override
  String get ruleBothDiceBody =>
      'Bu hamle diğer zarı oynamana izin vermiyor. İki zarı da kullanan bir hamle seç.';

  @override
  String get ruleLargerDieTitle => 'Büyük zarı oyna';

  @override
  String get ruleLargerDieBody =>
      'Yalnızca bir zar oynanabiliyorsa büyük zarı oynamalısın.';

  @override
  String get ruleBearOffTitle => 'Henüz pul toplanamaz';

  @override
  String get ruleBearOffBody =>
      'Pul toplamak için tüm pullar evde (1–6) olmalı.';

  @override
  String get ruleBearOffHigherTitle => 'Önce üst hanedeki pulu oyna';

  @override
  String get ruleBearOffHigherBody =>
      'Büyük zarla yalnızca en üst hanedeki pul toplanabilir.';

  @override
  String get ruleNoDieTitle => 'Bu mesafe için zar yok';

  @override
  String get ruleNoDieBody =>
      'Pul yalnızca zarlardaki sayı kadar ilerletilebilir.';

  @override
  String get ruleNoCheckerTitle => 'Bu hanede senin pulun yok';

  @override
  String get ruleTurnCompleteTitle => 'Tüm zarlar oynandı';

  @override
  String get ruleTurnCompleteBody => 'Hamleyi onayla veya geri al.';

  @override
  String get replayListTitle => 'Oyunlarım';

  @override
  String get replayEmptyTitle => 'Henüz oyun yok';

  @override
  String get replayEmptyBody =>
      'Bitirdiğin oyunlar burada görünecek. Tekrar izleyerek her hamleye yeniden bakabilirsin.';

  @override
  String replayTitle(int n) {
    return 'Tekrar · Oyun $n';
  }

  @override
  String replayPlayers(String p1, String p2) {
    return '$p1 – $p2';
  }

  @override
  String get replayStart => 'Başlangıç';

  @override
  String get replayBack => 'Geri';

  @override
  String get replayPlay => 'Oynat';

  @override
  String get replayPause => 'Duraklat';

  @override
  String get replayForward => 'İleri';

  @override
  String get replayEnd => 'Son';

  @override
  String replayOpening(int a, int b) {
    return 'Açılış: $a – $b';
  }

  @override
  String get replayNoMove => 'hamle yok';

  @override
  String get replayDouble => 'katlama teklifi';

  @override
  String get replayTake => 'kabul';

  @override
  String get replayDrop => 'ret';

  @override
  String get replayResign => 'pes';

  @override
  String replayWon(String name, int points) {
    return '$name kazandı · $points puan';
  }

  @override
  String get replayLoadError => 'Oyun açılamadı';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsGroupGame => 'OYUN';

  @override
  String get settingsGroupAccessibility => 'ERİŞİLEBİLİRLİK';

  @override
  String get settingsGroupGeneral => 'GENEL';

  @override
  String get settingsConfirmMove => 'Hamleyi onayla';

  @override
  String get settingsAutoRoll => 'Otomatik zar at';

  @override
  String get settingsShowLegalMoves => 'Olası hamleleri göster';

  @override
  String get settingsPipCount => 'Pip sayısı';

  @override
  String get settingsAnimationSpeed => 'Animasyon hızı';

  @override
  String get animationSpeedSlow => 'Yavaş';

  @override
  String get animationSpeedNormal => 'Normal';

  @override
  String get animationSpeedFast => 'Hızlı';

  @override
  String get settingsColorBlind => 'Renk körlüğü modu';

  @override
  String get settingsLargePips => 'Büyük zar noktaları';

  @override
  String get settingsReduceMotion => 'Hareketi azalt';

  @override
  String get settingsSound => 'Ses';

  @override
  String get settingsHaptics => 'Titreşim';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsReplays => 'Oyunlarım';

  @override
  String get settingsLesson => 'Dersi tekrarla';

  @override
  String settingsAbout(String version) {
    return 'Sürüm $version';
  }

  @override
  String get errorTitle => 'Bir şeyler ters gitti';

  @override
  String get errorBody =>
      'Tekrar dene. Sorun devam ederse uygulamayı yeniden aç.';

  @override
  String get playVsComputer => 'Bilgisayara karşı oyna';

  @override
  String get rulesShortBody =>
      'Her oyuncunun 15 pulu var. Pullar zara göre 24\'ten 1\'e doğru ilerler. Rakibin tek pulunun üstüne gelirsen onu bara gönderirsin; iki veya daha fazla pulu olan hane kapalıdır. Tüm pullar eve (1–6) ulaşınca toplamaya başlarsın. 15 pulun hepsini ilk toplayan kazanır. Rakip hiç pul toplamamışsa — mars (×2), pulu barda veya senin evindeyse — koks (×3).';

  @override
  String get rulesLongBody =>
      '15 pulun hepsi baştan (24. hane) başlar. Kırma yoktur: rakibin pulu olan haneye gidilemez. Her sırada baştan yalnızca bir pul alınabilir (ilk atışta 6-6, 4-4, 3-3 istisnadır). Önünde rakip pulu olmayan art arda 6 hane kapatılamaz. Tüm pullar eve ulaşınca toplamaya başlarsın. Rakip hiç pul toplamamışsa — mars (×2), pulu henüz senin evinden geçmemişse — koks (×3).';
}
