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
  String get variantLongDesc => 'Tüm pullar başta. Pul kırılmaz, sadece bloklanır.';

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
  String get lessonStep1Body => 'Beyaz pullar senin. Pullar 24. haneden 1. haneye doğru ilerler, sonra tahtadan toplanır. Devam etmek için herhangi bir pula dokun.';

  @override
  String get lessonStep2Title => 'Pulu 6 hane ilerlet';

  @override
  String get lessonStep2Body => 'Zar 6 gösteriyor. 13. hanedeki pula dokun, sonra parlayan 7. haneye dokun ya da pulu oraya sürükle.';

  @override
  String get lessonStep3Title => 'İki zarı da oyna';

  @override
  String get lessonStep3Body => 'Zarlar 3 ve 1 gösteriyor. 8. ve 6. hanedeki pulları 5. haneye götür ve haneyi kapat.';

  @override
  String get lessonStep4Title => 'Kapalı hane';

  @override
  String get lessonStep4Body => 'Rakibin iki veya daha fazla pulu olan haneye gidemezsin. Zar 5 gösteriyor: 13. hanedeki pulu 8. haneye götür.';

  @override
  String get lessonStep5Title => 'Kırmak';

  @override
  String get lessonStep5Body => 'Rakibin tek pulunun üstüne gelirsen onu bara gönderirsin. 6. hanedeki pulu 4. haneye götür ve kır.';

  @override
  String get lessonStep6Title => 'Bardan giriş';

  @override
  String get lessonStep6Body => 'Barda pulun varsa, önce onu rakibin evine sokmalısın. Bardaki pula dokun ve 22. haneye götür.';

  @override
  String get lessonStep7Title => 'Pulları topla';

  @override
  String get lessonStep7Body => 'Tüm pullar evde (1–6). Zar 6 gösteriyor: 6. hanedeki pulu topla.';

  @override
  String get lessonDoneTitle => 'Harika, hazırsın';

  @override
  String get lessonDoneBody => 'Kuralları biliyorsun. Şimdi bilgisayara karşı oynayıp pratik yap.';

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
  String get ruleHeadBody => 'Bu sırada baştan birden fazla pul oynadın. İstisna: ilk atışta 6-6, 4-4 veya 3-3 gelirse iki pul alınabilir.';

  @override
  String get ruleSixBlockTitle => 'Art arda 6 hane kapatılamaz';

  @override
  String ruleSixBlockBody(String from, String to) {
    return '$from → $to hamlesi 6 hanelik bir set kuruyor ve önünde rakibin hiç pulu yok. Başka bir hamle seç.';
  }

  @override
  String get rulePointClosedTitle => 'Bu hane kapalı';

  @override
  String get rulePointClosedShort => 'Rakibin iki veya daha fazla pulu olan haneye gidilemez.';

  @override
  String get rulePointClosedLong => 'Uzun tavlada rakibin pulu olan haneye gidilemez.';

  @override
  String get ruleBarTitle => 'Önce bardaki pulu sok';

  @override
  String get ruleBarBody => 'Barda pulun varken başka pulla oynayamazsın.';

  @override
  String get ruleBothDiceTitle => 'İki zarı da oynamalısın';

  @override
  String get ruleBothDiceBody => 'Bu hamle diğer zarı oynamana izin vermiyor. İki zarı da kullanan bir hamle seç.';

  @override
  String get ruleLargerDieTitle => 'Büyük zarı oyna';

  @override
  String get ruleLargerDieBody => 'Yalnızca bir zar oynanabiliyorsa büyük zarı oynamalısın.';

  @override
  String get ruleBearOffTitle => 'Henüz pul toplanamaz';

  @override
  String get ruleBearOffBody => 'Pul toplamak için tüm pullar evde (1–6) olmalı.';

  @override
  String get ruleBearOffHigherTitle => 'Önce üst hanedeki pulu oyna';

  @override
  String get ruleBearOffHigherBody => 'Büyük zarla yalnızca en üst hanedeki pul toplanabilir.';

  @override
  String get ruleNoDieTitle => 'Bu mesafe için zar yok';

  @override
  String get ruleNoDieBody => 'Pul yalnızca zarlardaki sayı kadar ilerletilebilir.';

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
  String get replayEmptyBody => 'Bitirdiğin oyunlar burada görünecek. Tekrar izleyerek her hamleye yeniden bakabilirsin.';

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
  String get errorBody => 'Tekrar dene. Sorun devam ederse uygulamayı yeniden aç.';

  @override
  String get playVsComputer => 'Bilgisayara karşı oyna';

  @override
  String get rulesShortBody => 'Her oyuncunun 15 pulu var. Pullar zara göre 24\'ten 1\'e doğru ilerler. Rakibin tek pulunun üstüne gelirsen onu bara gönderirsin; iki veya daha fazla pulu olan hane kapalıdır. Tüm pullar eve (1–6) ulaşınca toplamaya başlarsın. 15 pulun hepsini ilk toplayan kazanır. Rakip hiç pul toplamamışsa — mars (×2), pulu barda veya senin evindeyse — koks (×3).';

  @override
  String get rulesLongBody => '15 pulun hepsi baştan (24. hane) başlar. Kırma yoktur: rakibin pulu olan haneye gidilemez. Her sırada baştan yalnızca bir pul alınabilir (ilk atışta 6-6, 4-4, 3-3 istisnadır). Önünde rakip pulu olmayan art arda 6 hane kapatılamaz. Tüm pullar eve ulaşınca toplamaya başlarsın. Rakip hiç pul toplamamışsa — mars (×2), pulu henüz senin evinden geçmemişse — koks (×3).';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get copied => 'Kopyalandı';

  @override
  String get valueNone => '—';

  @override
  String get authWelcomeTitle => 'Hoş geldin';

  @override
  String get authWelcomeBody => 'Hesap oluşturursan puanın ve maç geçmişin tüm cihazlarında saklanır.';

  @override
  String get authApple => 'Apple ile devam et';

  @override
  String get authGoogle => 'Google ile devam et';

  @override
  String get authEmail => 'E-posta ile devam et';

  @override
  String get authGuest => 'Misafir olarak oyna';

  @override
  String authLegal(String terms, String privacy) {
    return 'Devam ederek $terms ve $privacy metinlerini kabul edersin.';
  }

  @override
  String get authTerms => 'Kullanım Koşulları';

  @override
  String get authPrivacy => 'Gizlilik Politikası';

  @override
  String get authProviderUnavailable => 'Bu giriş yöntemi henüz hazır değil. E-posta ile ya da misafir olarak devam et.';

  @override
  String get authOffline => 'Sunucuya ulaşılamıyor. Bağlantını kontrol edip tekrar dene.';

  @override
  String get authTooManyTries => 'Çok fazla deneme yaptın. Biraz sonra tekrar dene.';

  @override
  String get authSignIn => 'Giriş yap';

  @override
  String get emailTitle => 'E-postanı yaz';

  @override
  String get emailBody => 'Şifre gerekmez. 6 haneli bir giriş kodu göndereceğiz.';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get emailSend => 'Kodu gönder';

  @override
  String get emailInvalid => 'E-posta adresi geçersiz';

  @override
  String get codeTitle => 'Kodu yaz';

  @override
  String codeBody(String email) {
    return '$email adresine gönderdik. Spam klasörünü de kontrol et.';
  }

  @override
  String get codeLabel => '6 haneli kod';

  @override
  String codeResendIn(String time) {
    return 'Kodu tekrar gönder · $time';
  }

  @override
  String get codeResend => 'Kodu tekrar gönder';

  @override
  String get codeSent => 'Yeni kod gönderildi';

  @override
  String get codeInvalid => 'Kod yanlış. Tekrar kontrol et.';

  @override
  String get codeExpired => 'Kodun süresi doldu. Yeni kod iste.';

  @override
  String get modeCasual => 'Normal';

  @override
  String get modeRanked => 'Dereceli';

  @override
  String get searchTitle => 'Rakip aranıyor…';

  @override
  String searchElapsed(String elapsed) {
    return 'Geçen süre $elapsed';
  }

  @override
  String searchTip(String tip) {
    return 'İpucu: $tip';
  }

  @override
  String get searchTipHeadRule => 'Uzun tavlada her sırada baştan yalnızca bir pul alınır.';

  @override
  String get searchTipPip => 'Pip sayısı yarışta kimin önde olduğunu gösterir.';

  @override
  String get searchBotSoon => '30 saniye içinde canlı rakip bulunmazsa bir botla oynarsın.';

  @override
  String timeControlShort(int minutes, int delay) {
    return '$minutes+$delay sn';
  }

  @override
  String ratingRange(int min, int max) {
    return '$min–$max';
  }

  @override
  String vsMeta(String rank, int rating, int percent) {
    return '$rank · $rating · Galibiyet %$percent';
  }

  @override
  String vsMetaNoStats(String rank, int rating) {
    return '$rank · $rating';
  }

  @override
  String get vsLabel => 'vs';

  @override
  String pointsUpper(int n) {
    return '$n PUAN';
  }

  @override
  String get rankedUpper => 'DERECELİ';

  @override
  String get unrankedUpper => 'DERECESİZ';

  @override
  String vsStartsIn(int seconds) {
    return 'Oyun $seconds saniye içinde başlıyor';
  }

  @override
  String get botBadge => 'BOT';

  @override
  String get botNoRating => 'Puanı etkilemez';

  @override
  String get botFallbackNotice => '30 saniye içinde canlı rakip bulunamadı, bu yüzden bir botla oynuyorsun. Sonuç puanını etkilemez.';

  @override
  String get gameModeCasual => 'Normal · puansız';

  @override
  String playerBotMeta(String noRating, String pip) {
    return '$noRating · $pip';
  }

  @override
  String get bannerLowTime => 'Süre azalıyor';

  @override
  String bannerTimeLeft(String time) {
    return '$time kaldı';
  }

  @override
  String get bannerOpponentOffline => 'Rakibin bağlantısı koptu';

  @override
  String get bannerDisconnected => 'Bağlantı koptu';

  @override
  String get playerOffline => 'Çevrimdışı';

  @override
  String reconnectTitle(String name) {
    return '$name yeniden bağlanıyor…';
  }

  @override
  String reconnectBody(String time) {
    return '$time kaldı · süre biterse kazanan sensin';
  }

  @override
  String get selfReconnectTitle => 'Bağlantı yeniden kuruluyor…';

  @override
  String get menuFairDice => 'Adil zar';

  @override
  String get menuFairDiceVerify => 'Doğrula';

  @override
  String get matchRatingLabel => 'PUAN';

  @override
  String matchRatingFrom(int old) {
    return 'önceki $old';
  }

  @override
  String matchRatingToNext(String rank, int points) {
    return '$rank için $points puan kaldı';
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
  String get fairTitle => 'Adil zar';

  @override
  String get fairIntro => 'Her zar atışı, oyundan önce kilitlenen sunucu anahtarından, senin anahtarından ve atışın sırasından hesaplanır. Oyundan sonra her atışı kendin doğrulayabilirsin.';

  @override
  String get fairCommitment => 'Sunucu anahtarının özeti (oyundan önce)';

  @override
  String fairCommitmentValue(String hash) {
    return 'sha256: $hash';
  }

  @override
  String get fairServerSeed => 'Sunucu anahtarı (oyundan sonra açılır)';

  @override
  String get fairYourSeed => 'Senin anahtarın';

  @override
  String get fairOpponentSeed => 'Rakibin anahtarı';

  @override
  String get fairRollNumber => 'Atış numarası';

  @override
  String fairRollValue(int n, int a, int b) {
    return '#$n · HMAC → $a, $b';
  }

  @override
  String fairMatch(int a, int b) {
    return 'Eşleşiyor · $a – $b';
  }

  @override
  String fairMatchSub(int n) {
    return 'Atış #$n hesaplanan sonuçla aynı';
  }

  @override
  String fairMismatch(int a, int b) {
    return 'Eşleşmiyor · $a – $b';
  }

  @override
  String fairMismatchSub(int n) {
    return 'Atış #$n hesaplanan sonuçtan farklı';
  }

  @override
  String get fairCommitmentMismatch => 'Sunucu anahtarı özetle eşleşmiyor';

  @override
  String get fairPending => 'Oyundan sonra açılacak';

  @override
  String get fairPendingNote => 'Sunucu anahtarı oyun bitince açılır. Sonra her atışı burada doğrulayabilirsin.';

  @override
  String get fairNoRolls => 'Henüz atış yok';

  @override
  String get fairCopy => 'Verileri kopyala';

  @override
  String get fairCheckAnother => 'Başka atışı doğrula';

  @override
  String get fairPickTitle => 'Atış seç';

  @override
  String fairRollRow(int n, int a, int b) {
    return '#$n · $a – $b';
  }

  @override
  String get fairOpeningTag => 'açılış';

  @override
  String get tierBronze => 'Bronz';

  @override
  String get tierSilver => 'Gümüş';

  @override
  String get tierGold => 'Altın';

  @override
  String get tierPlatinum => 'Platin';

  @override
  String get tierDiamond => 'Elmas';

  @override
  String get tierMaster => 'Usta';

  @override
  String get tierGrandmaster => 'Büyük Usta';

  @override
  String rankWithSub(String tier, String sub) {
    return '$tier $sub';
  }

  @override
  String profileMeta(String rank, int rating) {
    return '$rank · $rating';
  }

  @override
  String get statRating => 'Puan';

  @override
  String get statWinRate => 'Galibiyet oranı';

  @override
  String get statMatches => 'Maçlar';

  @override
  String get statWins => 'Galibiyetler';

  @override
  String statPercent(int n) {
    return '%$n';
  }

  @override
  String get profileHistory => 'MAÇ GEÇMİŞİ';

  @override
  String historyMeta(String variant, String format, String date) {
    return '$variant · $format · $date';
  }

  @override
  String get variantShortAbbr => 'Tavla';

  @override
  String get variantLongAbbr => 'Uzun';

  @override
  String get dateToday => 'bugün';

  @override
  String get dateYesterday => 'dün';

  @override
  String historyScore(int me, int opp) {
    return '$me–$opp';
  }

  @override
  String get profileEdit => 'Profili düzenle';

  @override
  String get historyEmptyTitle => 'Henüz çevrimiçi maç yok';

  @override
  String get historyEmptyBody => 'Çevrimiçi oynadığın maçlar burada görünecek.';

  @override
  String get profileSignedOutTitle => 'Hesabına giriş yap';

  @override
  String get profileSignedOutBody => 'Puanın, istatistiklerin ve maç geçmişin burada olacak.';

  @override
  String get nameInvalid => 'Ad 3–20 harf, rakam ya da _ olmalı';

  @override
  String get offlineBanner => 'Bağlantı yok · çevrimdışı mod';

  @override
  String get onlineOfflineTitle => 'Çevrimiçi oyun kullanılamıyor';

  @override
  String get onlineOfflineBody => 'Bilgisayara karşı ve tek cihazda oyun çalışıyor. Bağlantı geri gelince tekrar dene.';

  @override
  String get settingsAccountPrivacy => 'Hesap ve gizlilik';

  @override
  String get accountGroupAccount => 'HESAP';

  @override
  String get accountEmail => 'E-posta';

  @override
  String get accountNickname => 'Oyuncu adı';

  @override
  String get accountEmailAdd => 'Ekle';

  @override
  String get accountSignOut => 'Çıkış yap';

  @override
  String get accountGroupData => 'VERİLER';

  @override
  String get accountExport => 'Verilerimi dışa aktar';

  @override
  String get accountDelete => 'Hesabı sil';

  @override
  String get exportTitle => 'Verilerini dışa aktar';

  @override
  String get exportBody => 'Profilin ve maç geçmişin bir JSON dosyası olarak hazırlanır. Hazır olunca kopyalayabilirsin.';

  @override
  String get exportProfile => 'Profil ve hesap';

  @override
  String get exportGames => 'Maç geçmişi';

  @override
  String exportGamesCount(int n) {
    return '$n maç';
  }

  @override
  String get exportFormat => 'Biçim';

  @override
  String get exportFormatValue => 'JSON';

  @override
  String get exportStart => 'Dışa aktarmayı başlat';

  @override
  String exportReady(String size) {
    return 'Dosya hazır · $size KB';
  }

  @override
  String get exportCopy => 'JSON\'u kopyala';

  @override
  String get deleteTitle => 'Hesap silinsin mi?';

  @override
  String deleteItemRating(int rating) {
    return 'Puan ($rating), derece ve tüm maç geçmişi';
  }

  @override
  String get deleteItemHistory => 'Profil ve tüm maç geçmişi';

  @override
  String get deleteIrreversible => 'Hesap hemen silinir ve geri getirilemez.';

  @override
  String deleteConfirmLabel(String word) {
    return 'Onaylamak için $word yaz';
  }

  @override
  String get deleteConfirmWord => 'SİL';

  @override
  String get setupOnlineTitle => 'Çevrimiçi oyun';

  @override
  String get setupTimeLabel => 'SÜRE KONTROLÜ';

  @override
  String get timeRapid => 'Hızlı';

  @override
  String timeValue(int minutes, int delay) {
    return '$minutes dk + $delay sn';
  }

  @override
  String get setupRated => 'Dereceli';

  @override
  String setupRatedSub(int rating) {
    return 'Puanın: $rating';
  }

  @override
  String get setupFindOpponent => 'Rakip bul';

  @override
  String get tabStore => 'Mağaza';

  @override
  String get lockerTitle => 'Dolap';

  @override
  String loadoutName(int n) {
    return 'Set $n';
  }

  @override
  String get lockerSave => 'Kaydet';

  @override
  String get lockerSaved => 'Set kaydedildi';

  @override
  String get lockerAddLoadout => 'Yeni set';

  @override
  String get lockerRenameTitle => 'Set adı';

  @override
  String get lockerRename => 'Yeniden adlandır';

  @override
  String get lockerDelete => 'Seti sil';

  @override
  String lockerLoadoutLimit(int max) {
    return 'En fazla $max set olabilir.';
  }

  @override
  String get lockerEmptyTitle => 'Burada henüz bir şey yok';

  @override
  String get lockerEmptyBody => 'Bu bölüme yeni eşyalar yakında gelecek.';

  @override
  String get lockerShowOpponentCosmetics => 'Rakibin kozmetiğini göster';

  @override
  String get categoryBoard => 'Tahta';

  @override
  String get categoryCheckers => 'Pullar';

  @override
  String get categoryDice => 'Zar';

  @override
  String get categoryDiceCup => 'Zar kabı';

  @override
  String get categoryCube => 'Katlama küpü';

  @override
  String get categoryBackground => 'Arka plan';

  @override
  String get categorySounds => 'Sesler';

  @override
  String get categoryEmote => 'İfadeler';

  @override
  String get categoryAvatarFrame => 'Avatar çerçevesi';

  @override
  String get categoryTitle => 'Unvan';

  @override
  String get categoryWinEffect => 'Zafer efekti';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get itemEquipped => 'Takılı';

  @override
  String get itemPreviewing => 'Deneniyor';

  @override
  String get itemOwned => 'Sende var';

  @override
  String get itemSeason => 'Sezon bileti';

  @override
  String get itemTournamentReward => 'Turnuva ödülü';

  @override
  String get itemAchievementReward => 'Başarım ödülü';

  @override
  String get rarityCommon => 'Sıradan';

  @override
  String get rarityRare => 'Nadir';

  @override
  String get rarityEpic => 'Destansı';

  @override
  String get rarityLegendary => 'Efsanevi';

  @override
  String get raritySeasonal => 'Sezonluk';

  @override
  String get rarityTournament => 'Turnuva';

  @override
  String get rarityCommonUpper => 'SIRADAN';

  @override
  String get rarityRareUpper => 'NADİR';

  @override
  String get rarityEpicUpper => 'DESTANSI';

  @override
  String get rarityLegendaryUpper => 'EFSANEVİ';

  @override
  String get raritySeasonalUpper => 'SEZONLUK';

  @override
  String get rarityTournamentUpper => 'TURNUVA';

  @override
  String get itemObtainTitle => 'NASIL ALINIR';

  @override
  String get obtainStore => 'Mağaza';

  @override
  String get obtainSeasonPremium => 'Sezon bileti · Premium';

  @override
  String get obtainTournament => 'Turnuva';

  @override
  String get obtainAchievement => 'Başarım';

  @override
  String get obtainDefault => 'Standart set';

  @override
  String get obtainFree => 'Ücretsiz';

  @override
  String priceCoins(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount jeton',
    );
    return '$_temp0';
  }

  @override
  String priceGems(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount yakut',
    );
    return '$_temp0';
  }

  @override
  String get itemTry => 'Dene';

  @override
  String get itemBuy => 'Satın al';

  @override
  String get itemEquip => 'Tak';

  @override
  String storeFeaturedOverline(int days) {
    return 'ÖNE ÇIKAN · $days GÜN';
  }

  @override
  String get storeDailyTitle => 'GÜNLÜK SEÇİM';

  @override
  String storeRefreshesIn(String time) {
    return 'Yenilenme $time';
  }

  @override
  String get storeGemsTitle => 'YAKUT';

  @override
  String get storePackUnavailable => 'Yakut satın alma henüz mümkün değil. Mağaza hesapları bağlanınca açılacak.';

  @override
  String storePackAdded(String amount) {
    return '+$amount yakut bakiyene eklendi';
  }

  @override
  String get accountNeededTitle => 'Hesabına giriş yap';

  @override
  String get accountNeededBody => 'Jeton kazanmak, set almak ve görevleri görmek için hesap gerekir.';

  @override
  String get purchasePrice => 'Fiyat';

  @override
  String get purchaseBalanceAfter => 'Sonraki bakiye';

  @override
  String purchaseShortfall(String amount) {
    return '$amount eksik';
  }

  @override
  String purchaseNotEnoughGems(String pack) {
    return 'Bakiyen yetmiyor. $pack yakut paketini al ve eşyayı hemen aç.';
  }

  @override
  String get purchaseNotEnoughCoins => 'Jetonun yetmiyor. Jeton yalnızca kazanılır: oyna ve görevleri bitir.';

  @override
  String purchaseBuyPack(String amount) {
    return '$amount yakut al';
  }

  @override
  String get purchaseToMissions => 'Görevlere bak';

  @override
  String get purchaseFailed => 'Satın alma gerçekleşmedi. Tekrar dene.';

  @override
  String get purchaseAlreadyOwned => 'Bu eşya zaten sende.';

  @override
  String get purchaseNotForSale => 'Bu eşya satılmıyor.';

  @override
  String purchaseOwnedTitle(String item) {
    return '$item artık senin';
  }

  @override
  String get purchaseReceipt => 'Fiş';

  @override
  String get purchasePaid => 'Ödenen';

  @override
  String get purchaseClose => 'Kapat';

  @override
  String get purchaseEquipNow => 'Şimdi tak';

  @override
  String get missionsTitle => 'Görevler';

  @override
  String streakCardTitle(int days) {
    return 'Giriş serisi · $days gün';
  }

  @override
  String streakTomorrow(int coins) {
    return 'Yarın: +$coins';
  }

  @override
  String get missionsDaily => 'Günlük';

  @override
  String get missionsWeekly => 'Haftalık';

  @override
  String missionsResetsIn(String time) {
    return 'Yenilenmeye $time';
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
    return '$n çift at';
  }

  @override
  String missionRankedWin(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dereceli oyun kazan',
      one: 'Dereceli oyun kazan',
    );
    return '$_temp0';
  }

  @override
  String get missionCubeTakeWin => 'Küpü kabul et ve kazan';

  @override
  String get missionPlayLong => 'Uzun tavla oyna';

  @override
  String missionMars(int n) {
    return '$n oyunda mars yap';
  }

  @override
  String missionPlay(int n) {
    return '$n oyun oyna';
  }

  @override
  String missionWin(int n) {
    return '$n oyun kazan';
  }

  @override
  String get missionGeneric => 'Görev';

  @override
  String dailyBonusTitle(int coins) {
    return 'Günlük bonus · +$coins';
  }

  @override
  String dailyBonusBody(int done, int total) {
    return 'Tüm günlük görevleri bitir · $done / $total';
  }

  @override
  String get streakOverline => 'GİRİŞ SERİSİ';

  @override
  String get streakDay1 => '1. gün';

  @override
  String get streakDay2 => '2. gün';

  @override
  String get streakDay3 => '3. gün';

  @override
  String get streakDay4 => '4. gün';

  @override
  String get streakDay5 => '5. gün';

  @override
  String get streakDay6 => '6. gün';

  @override
  String get streakDay7 => '7. gün';

  @override
  String get streakBody => 'Her gün giriş yap, 7. gün büyük bonusu al.';

  @override
  String streakClaim(int coins) {
    return '$coins jetonu al';
  }

  @override
  String get streakResetNote => 'Bir gün kaçırırsan seri 1. günden başlar.';

  @override
  String levelUpOverline(int from, int to) {
    return 'SEVİYE $from → $to';
  }

  @override
  String get levelUpTitle => 'Seviye atladın';

  @override
  String xpProgress(String xp, String next) {
    return '$xp / $next XP';
  }

  @override
  String homeLevel(int n) {
    return 'Sv. $n';
  }

  @override
  String homeDailyMission(int done, int total) {
    return 'GÜNLÜK GÖREV · $done/$total';
  }

  @override
  String get homeMissionsDone => 'Bugünün görevleri bitti';

  @override
  String get matchCoins => 'jeton';

  @override
  String get matchXp => 'deneyim';

  @override
  String get xpBadge => 'XP';

  @override
  String get achievementsTitle => 'Başarımlar';

  @override
  String achievementsCount(int done, int total) {
    return '$done / $total';
  }

  @override
  String get titlesOverline => 'UNVAN';

  @override
  String get titlesNone => 'Unvansız';

  @override
  String get titlesLocked => 'Başarımla açılır';

  @override
  String get achFirstWin => 'İlk galibiyet';

  @override
  String get achWins10 => '10 galibiyet';

  @override
  String get achWins100 => '100 galibiyet';

  @override
  String get achGames1000 => '1000 oyun';

  @override
  String get achMars10 => 'Mars ustası';

  @override
  String get achRankedWins25 => 'Dereceli savaşçı';

  @override
  String get achStreak10 => '10 günlük seri';

  @override
  String get achGeneric => 'Başarım';

  @override
  String coinsSemantic(String amount) {
    return 'Jeton: $amount';
  }

  @override
  String gemsSemantic(String amount) {
    return 'Yakut: $amount';
  }

  @override
  String get emoteWheelHint => 'Kaydır\nve bırak';

  @override
  String get emoteButton => 'İfade gönder';

  @override
  String get gameChat => 'Sohbet';

  @override
  String get emoteSmile => 'Gülümseme';

  @override
  String get emoteLaugh => 'Kahkaha';

  @override
  String get emoteWow => 'Vay';

  @override
  String get emoteThink => 'Düşünüyorum';

  @override
  String get emoteSad => 'Üzgün';

  @override
  String get emoteAngry => 'Kızgın';

  @override
  String get emoteTea => 'Çay';

  @override
  String get emoteClap => 'Bravo';

  @override
  String get phraseHello => 'Selam!';

  @override
  String get phraseGoodLuck => 'İyi şanslar';

  @override
  String get phraseNiceMove => 'Güzel hamle';

  @override
  String get phraseDice => 'Şu zarlar…';

  @override
  String get phraseThanks => 'Teşekkürler';

  @override
  String get phraseGoodGame => 'İyi oyundu';

  @override
  String get phraseNiceRoll => 'Güzel zar';

  @override
  String get phraseSorry => 'Pardon';

  @override
  String get tabClan => 'Klan';

  @override
  String get modePrivateRoom => 'Özel oda';

  @override
  String get modeFriends => 'Arkadaşlar';

  @override
  String get socialAccountBody => 'Arkadaşlar, klanlar ve özel odalar için hesap gerekir.';

  @override
  String get send => 'Gönder';

  @override
  String get close => 'Kapat';

  @override
  String get friendsTitle => 'Arkadaşlar';

  @override
  String get friendsAdd => 'Ekle';

  @override
  String get friendsSection => 'ARKADAŞLAR';

  @override
  String get presenceOnline => 'Çevrimiçi';

  @override
  String get presenceInGame => 'Oyunda';

  @override
  String get presenceOffline => 'Çevrimdışı';

  @override
  String get friendInvite => 'Davet et';

  @override
  String get friendWatch => 'İzle';

  @override
  String get friendRequestsTitle => 'İSTEKLER';

  @override
  String get friendSentTitle => 'GÖNDERİLENLER';

  @override
  String get friendChallengesTitle => 'MEYDAN OKUMALAR';

  @override
  String get friendAccept => 'Kabul et';

  @override
  String get friendDismiss => 'Reddet';

  @override
  String get friendCancelRequest => 'İsteği iptal et';

  @override
  String challengeMeta(String variant, String format) {
    return '$variant · $format';
  }

  @override
  String get friendsEmptyTitle => 'Henüz arkadaşın yok';

  @override
  String get friendsEmptyBody => 'Adıyla ara ya da arkadaş kodunu paylaş.';

  @override
  String friendInviteSent(String name) {
    return 'Davet gönderildi: $name';
  }

  @override
  String get friendRemoved => 'Arkadaşlıktan çıkarıldı';

  @override
  String metaWithClan(String meta, String clan) {
    return '$meta · $clan';
  }

  @override
  String levelShort(int n) {
    return 'Sv. $n';
  }

  @override
  String get addFriendTitle => 'Arkadaş ekle';

  @override
  String get addFriendSearchHint => 'Adla ara';

  @override
  String get addFriendSearchShort => 'En az 3 harf yaz';

  @override
  String get addFriendAction => 'Ekle';

  @override
  String get addFriendOr => 'veya';

  @override
  String get addFriendCodeLabel => 'ARKADAŞ KODUN';

  @override
  String get addFriendCodeCaption => 'Arkadaşın bu kodu girsin';

  @override
  String get addFriendCopyCode => 'Kodu kopyala';

  @override
  String get addFriendEnterCode => 'KODLA EKLE';

  @override
  String get addFriendCodeHint => '8 karakterli kod';

  @override
  String get friendRequested => 'Gönderildi';

  @override
  String get friendAccepted => 'Arkadaşsınız';

  @override
  String get friendErrNotFound => 'Oyuncu bulunamadı';

  @override
  String get friendErrBlocked => 'Bu oyuncuyla iletişim kurulamıyor';

  @override
  String get friendErrAlready => 'Zaten arkadaşsınız';

  @override
  String get friendErrPending => 'İstek zaten gönderildi';

  @override
  String friendErrLimit(int max) {
    return 'Arkadaş sınırı doldu ($max)';
  }

  @override
  String get roomTitle => 'Özel oda';

  @override
  String get roomCodeLabel => 'ODA KODU';

  @override
  String get roomCopy => 'Kopyala';

  @override
  String get roomShare => 'Paylaş';

  @override
  String roomShareText(String code) {
    return 'NardArena\'da benimle oyna. Oda kodu: $code';
  }

  @override
  String get roomWaiting => 'Arkadaş bekleniyor…';

  @override
  String roomExpiry(String time, String left) {
    return 'Bitiş: $time · $left kaldı';
  }

  @override
  String roomInvited(String name) {
    return 'Davet edildi: $name';
  }

  @override
  String get roomSettingVariant => 'Oyun';

  @override
  String get roomSettingFormat => 'Format';

  @override
  String get roomSettingTime => 'Süre';

  @override
  String get roomSettingRating => 'Puan';

  @override
  String get roomUnrated => 'Etkilenmez';

  @override
  String get roomExpired => 'Kodun süresi doldu';

  @override
  String get roomNewCode => 'Yeni kod';

  @override
  String get roomCreate => 'Oda oluştur';

  @override
  String get roomCreateSub => 'Kodu gönder; arkadaşın katılınca oyun başlar';

  @override
  String get roomJoinByCode => 'Kodla katıl';

  @override
  String get roomJoinByCodeSub => 'Arkadaşının odasına 6 karakterli kodla gir';

  @override
  String get roomJoin => 'Katıl';

  @override
  String get roomJoinTitle => 'Odaya katıl';

  @override
  String get roomJoinHint => 'Arkadaşının gönderdiği kodu gir';

  @override
  String get roomJoining => 'Katılıyor…';

  @override
  String get roomCreating => 'Oda oluşturuluyor…';

  @override
  String get roomNotFound => 'Oda bulunamadı ya da süresi doldu';

  @override
  String get roomInviteFriend => 'Arkadaş davet et';

  @override
  String get roomPickFriend => 'Kimi davet ediyorsun?';

  @override
  String get roomCancelTitle => 'Oda kapatılsın mı?';

  @override
  String get roomCancelBody => 'Kod geçersiz olacak.';

  @override
  String get roomCancelConfirm => 'Kapat';

  @override
  String get spectatorLive => 'İZLEYİCİ';

  @override
  String get spectatorLeave => 'Çık';

  @override
  String get spectatorNoChat => 'Oyuncuların ifadeleri burada görünür';

  @override
  String get spectatorUnavailable => 'Bu oyun izlenemiyor';

  @override
  String spectatorGameOver(String name, String score) {
    return 'Kazanan: $name · $score';
  }

  @override
  String get spectatorWaiting => 'Oyun yükleniyor…';

  @override
  String get playerMenuAddFriend => 'Arkadaş ekle';

  @override
  String get playerMenuInvite => 'Oyuna davet et';

  @override
  String get playerMenuMute => 'Sohbeti sessize al';

  @override
  String get playerMenuUnmute => 'Sesini aç';

  @override
  String get playerMenuReport => 'Şikâyet et';

  @override
  String get playerMenuBlock => 'Engelle';

  @override
  String get playerMenuUnblock => 'Engeli kaldır';

  @override
  String get playerMenuUnfriend => 'Arkadaşlıktan çıkar';

  @override
  String get playerMenuInviteClan => 'Klana davet et';

  @override
  String reportTitle(String name) {
    return 'Şikâyet: $name';
  }

  @override
  String get reportReasonLabel => 'SEBEP';

  @override
  String get reportReasonAbuse => 'Hakaret içeren sohbet';

  @override
  String get reportReasonName => 'Uygunsuz ad veya avatar';

  @override
  String get reportReasonCheating => 'Yardımcı program kullanımı';

  @override
  String get reportReasonStalling => 'Kasıtlı oyalama';

  @override
  String get reportReasonLeaving => 'Oyunu kasıtlı terk etme';

  @override
  String get reportReasonOther => 'Diğer';

  @override
  String get reportNoteHint => 'Ek not (isteğe bağlı)';

  @override
  String get reportAlsoBlock => 'Bu oyuncuyu da engelle';

  @override
  String reportDisclosure(String name) {
    return 'Son oyunun kaydı ve sohbet şikâyete otomatik eklenir. $name şikâyet edenin kim olduğunu görmeyecek.';
  }

  @override
  String get reportSend => 'Şikâyeti gönder';

  @override
  String get reportLimit => 'Bugün çok şikâyet gönderdin. Yarın tekrar dene.';

  @override
  String blockTitle(String name) {
    return '$name engellensin mi?';
  }

  @override
  String get blockInfoMatchmaking => 'Rastgele oyunlarda seninle eşleşmeyecek.';

  @override
  String get blockInfoContact => 'Sana mesaj, arkadaşlık ve oyun daveti gönderemeyecek.';

  @override
  String blockInfoUndo(String path) {
    return 'Engeli $path bölümünden kaldırabilirsin.';
  }

  @override
  String get privacyBlocked => 'Engellenenler';

  @override
  String get blockConfirm => 'Engelle';

  @override
  String blockDone(String name) {
    return '$name engellendi.';
  }

  @override
  String get unblockDone => 'Engel kaldırıldı';

  @override
  String get blockedEmpty => 'Engellenen oyuncu yok';

  @override
  String get reportSentTitle => 'Şikâyet gönderildi';

  @override
  String get reportSentBody => 'Bir moderatör 24 saat içinde inceleyecek. Sonuç hakkında bildirim alacaksın.';

  @override
  String get mutedNote => 'Sessize alındı';

  @override
  String get unmutedNote => 'Sesi açıldı';

  @override
  String get clansTitle => 'Klanlar';

  @override
  String get clanCreateShort => 'Kur';

  @override
  String get clanSearchHint => 'Ad veya etiket ara';

  @override
  String clanFilterLanguage(String code) {
    return 'Dil: $code';
  }

  @override
  String get clanFilterOpen => 'Açık';

  @override
  String clanFilterMinRating(int rating) {
    return 'Min. puan ≤ $rating';
  }

  @override
  String clanTag(String tag) {
    return '[$tag]';
  }

  @override
  String clanListMeta(int level, int members, int max, String rating) {
    return 'Sv. $level · $members/$max · $rating';
  }

  @override
  String get clanJoin => 'Katıl';

  @override
  String get clanApply => 'Başvur';

  @override
  String get clanFull => 'Dolu';

  @override
  String get clanInviteOnlyShort => 'Davetle';

  @override
  String get clanPending => 'Bekliyor';

  @override
  String get clanEmpty => 'Klan bulunamadı';

  @override
  String get clanEmptyBody => 'Başka bir ad dene ya da kendi klanını kur.';

  @override
  String get clanInvitesTitle => 'DAVETLER';

  @override
  String clanInviteFrom(String name) {
    return 'Davet eden: $name';
  }

  @override
  String get clanStatLevel => 'Seviye';

  @override
  String get clanStatMembers => 'Üye';

  @override
  String get clanStatRating => 'Puan';

  @override
  String get clanStatLanguage => 'Dil';

  @override
  String clanMembersValue(int members, int max) {
    return '$members/$max';
  }

  @override
  String get clanRequirements => 'ŞARTLAR';

  @override
  String get clanReqMinRating => 'Min. puan';

  @override
  String get clanReqPolicy => 'Kabul';

  @override
  String get clanReqNone => 'Yok';

  @override
  String get clanTopMembers => 'EN İYİ ÜYELER';

  @override
  String clanMemberWithRole(String name, String role) {
    return '$name · $role';
  }

  @override
  String get clanApplyCta => 'Başvur';

  @override
  String get clanJoinCta => 'Katıl';

  @override
  String get clanAppliedCta => 'Başvuru gönderildi';

  @override
  String get clanCancelApply => 'Başvuruyu geri çek';

  @override
  String get clanInviteOnlyCta => 'Yalnızca davetle';

  @override
  String get clanFullCta => 'Klan dolu';

  @override
  String get clanReqNotMet => 'Şartları karşılamıyorsun';

  @override
  String get clanLeaveFirst => 'Önce mevcut klandan ayrıl';

  @override
  String get clanOpenMine => 'Klana git';

  @override
  String get clanAcceptInvite => 'Daveti kabul et';

  @override
  String get clanErrRatingLow => 'Puanın bu klan için düşük';

  @override
  String get clanErrInClan => 'Zaten bir klandasın';

  @override
  String get policyOpen => 'Açık';

  @override
  String get policyOpenSub => 'Puan şartını karşılayan herkes hemen katılır';

  @override
  String get policyRequest => 'Başvuruyla';

  @override
  String get policyRequestSub => 'Lider, yardımcılar ve kıdemliler onaylar';

  @override
  String get policyInvite => 'Yalnızca davet';

  @override
  String get policyInviteSub => 'Listede görünür ama katılmak için davet gerekir';

  @override
  String get roleLeader => 'Lider';

  @override
  String get roleCoLeader => 'Yardımcı';

  @override
  String get roleElder => 'Kıdemli';

  @override
  String get roleMember => 'Üye';

  @override
  String get emblemTitle => 'Amblem';

  @override
  String get emblemSave => 'Kaydet';

  @override
  String get emblemTabShape => 'Şekil';

  @override
  String get emblemTabSymbol => 'Sembol';

  @override
  String get emblemTabColor => 'Renk';

  @override
  String get emblemTabPattern => 'Desen';

  @override
  String get emblemPrimaryColor => 'ANA RENK';

  @override
  String get emblemShapeShield => 'Kalkan';

  @override
  String get emblemShapeHexagon => 'Altıgen';

  @override
  String get emblemShapeOctagon => 'Sekizgen';

  @override
  String get emblemShapeCircle => 'Daire';

  @override
  String get emblemShapeDiamond => 'Baklava';

  @override
  String get emblemShapeBanner => 'Sancak';

  @override
  String get emblemShapeStar => 'Yıldız';

  @override
  String get emblemShapeArch => 'Kemer';

  @override
  String get emblemSymbolDiamond => 'Baklava';

  @override
  String get emblemSymbolDiamondDot => 'Noktalı baklava';

  @override
  String get emblemSymbolCircle => 'Halka';

  @override
  String get emblemSymbolSquare => 'Kare';

  @override
  String get emblemSymbolInitials => 'Baş harfler';

  @override
  String get emblemPatternNone => 'Yok';

  @override
  String get emblemPatternLattice => 'Kafes';

  @override
  String get emblemColorGarnet => 'Lal';

  @override
  String get emblemColorIndigo => 'Çivit';

  @override
  String get emblemColorEmerald => 'Zümrüt';

  @override
  String get emblemColorBrass => 'Pirinç';

  @override
  String get emblemColorPurple => 'Mor';

  @override
  String get emblemColorSlate => 'Arduvaz';

  @override
  String get emblemColorIvory => 'Fildişi';

  @override
  String get emblemColorBlue => 'Mavi';

  @override
  String get emblemColorWalnut => 'Ceviz';

  @override
  String clanOnline(int n) {
    return '$n çevrimiçi';
  }

  @override
  String get clanTabChat => 'Sohbet';

  @override
  String get clanTabActivity => 'Etkinlik';

  @override
  String get clanTabWar => 'Savaş';

  @override
  String get clanTabChest => 'Sandık';

  @override
  String get clanChestTitle => 'Haftalık sandık';

  @override
  String clanChestProgress(String current, String target) {
    return '$current / $target';
  }

  @override
  String get clanChatHint => 'Mesaj yaz…';

  @override
  String get clanChatEmpty => 'Henüz mesaj yok. İlk sen yaz.';

  @override
  String get clanActivityEmpty => 'Henüz bir şey olmadı';

  @override
  String get clanChatTooFast => 'Çok hızlı yazıyorsun. Biraz bekle.';

  @override
  String clanSysCreated(String name) {
    return 'Klanı kuran: $name';
  }

  @override
  String clanSysJoined(String name) {
    return '$name klana katıldı';
  }

  @override
  String clanSysLeft(String name) {
    return '$name klandan ayrıldı';
  }

  @override
  String clanSysKicked(String name) {
    return '$name klandan çıkarıldı';
  }

  @override
  String clanSysRole(String name, String role) {
    return '$name: yeni rütbe · $role';
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
    return '$name sandığa $amount jeton koydu';
  }

  @override
  String get clanSysChestFull => 'Haftalık sandık doldu';

  @override
  String clanSysWarStarted(String name, String tag) {
    return 'Klan savaşı başladı: $name [$tag]';
  }

  @override
  String clanSysWarWin(String name, String points) {
    return '$name klan savaşında kazandı · +$points';
  }

  @override
  String clanSysWarEnded(String mine, String theirs) {
    return 'Klan savaşı bitti · $mine : $theirs';
  }

  @override
  String get clanMenuMembers => 'Üyeler';

  @override
  String get clanMenuLeaderboard => 'Klan sıralaması';

  @override
  String get clanMenuProfile => 'Klan profili';

  @override
  String get clanMenuEmblem => 'Amblemi değiştir';

  @override
  String get clanMenuRequests => 'Başvurular';

  @override
  String get clanMenuInvite => 'Arkadaş davet et';

  @override
  String get clanMenuLeave => 'Klandan ayrıl';

  @override
  String get clanLeaveTitle => 'Klandan ayrılıyor musun?';

  @override
  String get clanLeaveBody => 'Klan sohbetine ve sandığa erişimin kapanacak.';

  @override
  String get clanLeaveLastBody => 'Son üye sensin: klan dağıtılacak.';

  @override
  String get clanTransferFirst => 'Ayrılmadan önce liderliği devret.';

  @override
  String get chatDelete => 'Sil';

  @override
  String get clanChestDonate => 'Bağışla';

  @override
  String clanChestMine(String amount) {
    return 'Bu haftaki payın: $amount';
  }

  @override
  String clanChestReward(int xp) {
    return 'Sandık dolunca klan $xp XP kazanır';
  }

  @override
  String get clanChestFullNote => 'Bu hafta sandık doldu';

  @override
  String get clanChestAmount => 'MİKTAR';

  @override
  String clanDonated(String amount) {
    return 'Sandığa $amount jeton koydun';
  }

  @override
  String get clanErrChestFull => 'Sandık zaten dolu';

  @override
  String get clanDonors => 'BU HAFTANIN BAĞIŞLARI';

  @override
  String get membersTitle => 'Üyeler';

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
    return '$name (sen)';
  }

  @override
  String get memberViewProfile => 'Profili gör';

  @override
  String get memberInviteFriendly => 'Dostluk maçına davet et';

  @override
  String get memberPromoteCoLeader => 'Yardımcı yap';

  @override
  String get memberPromoteElder => 'Kıdemli yap';

  @override
  String get memberDemote => 'Üye yap';

  @override
  String get memberTransferLead => 'Liderliği devret';

  @override
  String get memberKick => 'Klandan çıkar';

  @override
  String memberKickConfirm(String name) {
    return '$name klandan çıkarılsın mı?';
  }

  @override
  String memberTransferConfirm(String name) {
    return 'Liderliği devret: $name?';
  }

  @override
  String get memberTransferBody => 'Sen yardımcı olacaksın.';

  @override
  String get requestsEmpty => 'Yeni başvuru yok';

  @override
  String get clanInvited => 'Davet gönderildi';

  @override
  String warLive(String time) {
    return 'CANLI · BİTİŞE $time';
  }

  @override
  String warCounted(int n, int max) {
    return '$n / $max maç sayıldı';
  }

  @override
  String get warMatches => 'MAÇLAR';

  @override
  String warFinished(int a, int b) {
    return 'Bitti $a–$b';
  }

  @override
  String get warWon => 'BİTTİ · ZAFER';

  @override
  String get warLost => 'BİTTİ · YENİLGİ';

  @override
  String get warDraw => 'BİTTİ · BERABERE';

  @override
  String get warNoneTitle => 'Bu hafta savaş yok';

  @override
  String get warNoneBody => 'Klanlar her pazartesi eşleştirilir. Savaş için en az 2 aktif üye gerekir.';

  @override
  String get warNoOpponent => 'Rakip bulunamadı';

  @override
  String warHowTo(int points) {
    return 'Rakip klanın üyelerine karşı her çevrimiçi galibiyet +$points puan getirir.';
  }

  @override
  String get warMatchesEmpty => 'Henüz sayılan maç yok';

  @override
  String get clanLeaderboardTitle => 'Klan sıralaması';

  @override
  String clanMyRank(int rank) {
    return 'Klanın · #$rank';
  }

  @override
  String get createClanTitle => 'Klan kur';

  @override
  String createStep(int step, int total) {
    return '$step / $total';
  }

  @override
  String get createNameLabel => 'Klan adı';

  @override
  String createNameCounter(int n, int max) {
    return '$n / $max';
  }

  @override
  String get createTagLabel => 'Etiket (3–5 harf)';

  @override
  String get createTagFree => 'Uygun';

  @override
  String get createTagTaken => 'Alınmış';

  @override
  String get createTagInvalid => 'Yalnızca 3–5 Latin harfi';

  @override
  String get createNameInvalid => 'Ad 3–24 karakter olmalı';

  @override
  String get createEmblemLabel => 'AMBLEM';

  @override
  String get createEmblemMore => 'Daha fazla';

  @override
  String get createColorLabel => 'RENK';

  @override
  String get createPolicyLabel => 'KATILIM';

  @override
  String get createMinRatingLabel => 'MİNİMUM PUAN';

  @override
  String get createMinRatingAny => 'Herkes';

  @override
  String createMinRatingMax(int n) {
    return '$n+';
  }

  @override
  String get createLanguageLabel => 'DİL';

  @override
  String get createDescriptionLabel => 'Açıklama (isteğe bağlı)';

  @override
  String createBalance(String from, String to) {
    return 'Bakiye: $from → $to';
  }

  @override
  String createRenameNote(String price) {
    return 'Ad sonra $price jetona değişir';
  }

  @override
  String get createSubmit => 'Klanı kur';

  @override
  String get createErrNameTaken => 'Bu ad alınmış';

  @override
  String get tabTournaments => 'Turnuvalar';

  @override
  String get tournamentsTitle => 'Turnuvalar';

  @override
  String get tourTabLive => 'Canlı';

  @override
  String get tourTabUpcoming => 'Yaklaşan';

  @override
  String get tourTabMine => 'Benim';

  @override
  String get tourTabFinished => 'Biten';

  @override
  String get tourFilterAll => 'Tümü';

  @override
  String get tourFilterFree => 'Ücretsiz';

  @override
  String tourStatusLive(int n) {
    return 'CANLI · TUR $n';
  }

  @override
  String get tourStatusOpen => 'KAYIT AÇIK';

  @override
  String get tourStatusUpcoming => 'YAKLAŞAN';

  @override
  String get tourStatusFinished => 'BİTTİ';

  @override
  String get tourStatusCancelled => 'İPTAL EDİLDİ';

  @override
  String tourInMinutes(int n) {
    return '$n dk';
  }

  @override
  String tourTomorrowAt(String time) {
    return 'Yarın $time';
  }

  @override
  String get tourFormatSwiss => 'İsviçre';

  @override
  String get tourFormatKnockout => 'Eleme';

  @override
  String get tourFormatRoundRobin => 'Lig usulü';

  @override
  String tourRounds(int n) {
    return '$n tur';
  }

  @override
  String tourMeta(String variant, int points) {
    return '$variant · $points sayı';
  }

  @override
  String tourEntrants(int n, int max) {
    return '$n/$max';
  }

  @override
  String get tourRegistered => 'Kayıtlısın';

  @override
  String tourPlace(String place) {
    return 'Sıra: $place';
  }

  @override
  String tourOut(String round) {
    return 'Elendin · $round';
  }

  @override
  String get tournamentsOfflineTitle => 'Turnuvalar çevrimdışı görünmez';

  @override
  String get tournamentsOfflineBody => 'Bilgisayara karşı ve tek cihazda oyun çalışır. Bağlantı gelince liste yenilenir.';

  @override
  String get tournamentsEmptyTitle => 'Henüz turnuvan yok';

  @override
  String get tournamentsEmptyBody => 'Kaydolduğun turnuvalar burada görünür.';

  @override
  String get tournamentsEmptyCta => 'Yaklaşan turnuvalara bak';

  @override
  String get tournamentsNoneTitle => 'Turnuva yok';

  @override
  String get tournamentsNoneBody => 'Bu listede şimdilik turnuva yok. Biraz sonra yine bak.';

  @override
  String get listErrorTitle => 'Liste yüklenmedi';

  @override
  String get listErrorBody => 'Sunucuya ulaşılamadı. Biraz sonra yeniden dene.';

  @override
  String get sngCardMeta => 'Dolunca başlar';

  @override
  String get sngJoin => 'Katıl';

  @override
  String get privateTourCreateChoice => 'Özel turnuva oluştur';

  @override
  String get privateTourJoinByCode => 'Kodla katıl';

  @override
  String get leaderboardTitle => 'Liderler';

  @override
  String tourHeroMeta(String status, String type, int size) {
    return '$status · $type $size';
  }

  @override
  String get tourTypeKnockoutUpper => 'ELEME';

  @override
  String get tourTypeSwissUpper => 'İSVİÇRE';

  @override
  String get tourTypeRoundRobinUpper => 'LİG';

  @override
  String get tourTypeSngUpper => 'SIT-AND-GO';

  @override
  String get tourStartsIn => 'Başlamaya';

  @override
  String tourLiveRound(int n, String stage) {
    return 'Tur $n · $stage';
  }

  @override
  String tourNow(int n) {
    return 'Tur $n';
  }

  @override
  String get tourPrizeFund => 'Ödül havuzu';

  @override
  String get tourParticipants => 'Oyuncular';

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
  String get tourRuleFairDice => 'Adil zar';

  @override
  String get tourRuleRating => 'Puan';

  @override
  String get tourRuleUnrated => 'Değişmez';

  @override
  String tourFormatValue(String type, int points) {
    return '$type · $points sayıya kadar';
  }

  @override
  String tourEntryValue(String price, int rating) {
    return '$price · min. $rating';
  }

  @override
  String get tourEntryInvite => 'Davetle';

  @override
  String get tourFairDiceValue => 'Doğrulanabilir';

  @override
  String get tourRegister => 'Kayıt ol';

  @override
  String get tourRegisterFree => 'Kayıt ol · Ücretsiz';

  @override
  String get tourUnregister => 'Kaydı iptal et';

  @override
  String get tourUnregisterTitle => 'Kayıt iptal edilsin mi?';

  @override
  String get tourUnregisterBody => 'Giriş ücreti bakiyene iade edilecek.';

  @override
  String get tourUnregisterBodyFree => 'Yerini başka bir oyuncu alabilir.';

  @override
  String get tourRegisteredToast => 'Kaydoldun';

  @override
  String get tourUnregisteredToast => 'Kayıt iptal edildi';

  @override
  String tourMinRating(int n) {
    return 'En düşük puan $n';
  }

  @override
  String get tourFull => 'Yer kalmadı';

  @override
  String get tourClosed => 'Kayıt kapalı';

  @override
  String get tourInviteOnly => 'Davet koduyla katıl';

  @override
  String get tourOpenBracket => 'Tabloya bak';

  @override
  String get tourWatch => 'İzle';

  @override
  String tourTitlePrize(String name) {
    return 'Unvan: $name';
  }

  @override
  String get tourRatingTooLow => 'Puanın bu turnuvanın alt sınırının altında.';

  @override
  String get tourInviteRequired => 'Bu turnuvaya yalnızca davet koduyla katılınır.';

  @override
  String get tourActionFailed => 'Olmadı. Biraz sonra yeniden dene.';

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
    return 'SIRADAKİ MAÇIN · $round';
  }

  @override
  String tourNextMetaOpen(int points) {
    return 'Tur açık · $points sayıya kadar';
  }

  @override
  String tourNextMetaPending(int points) {
    return 'Tur henüz açılmadı · $points sayıya kadar';
  }

  @override
  String get tourOpponentTbd => 'Rakip belli değil';

  @override
  String get tourReady => 'Hazırım';

  @override
  String get tourReadyDone => 'Hazırsın';

  @override
  String get tourWaitingOpponent => 'Rakip bekleniyor';

  @override
  String tourEliminated(String round) {
    return 'Elendin · $round';
  }

  @override
  String tourFinishedPanel(String place) {
    return 'Turnuva bitti · $place';
  }

  @override
  String get zoomIn => 'Yakınlaştır';

  @override
  String get zoomOut => 'Uzaklaştır';

  @override
  String standingsTitle(String name) {
    return '$name · Puan durumu';
  }

  @override
  String get standingsRound => 'Tur';

  @override
  String get standingsColRank => '#';

  @override
  String get standingsColPlayer => 'OYUNCU';

  @override
  String get standingsColWinLoss => 'G–M';

  @override
  String get standingsColBuchholz => 'BUCH';

  @override
  String get standingsColPoints => 'PUAN';

  @override
  String standingsWinLoss(int w, int l) {
    return '$w–$l';
  }

  @override
  String get standingsFootnoteNoPlayoff => 'Eşitlikte Buchholz, sonra puan';

  @override
  String get standingsEmpty => 'Puan durumu ilk turdan sonra görünür.';

  @override
  String get championTitle => 'Şampiyon';

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
    return '+$amount jeton';
  }

  @override
  String get championShare => 'Paylaş';

  @override
  String championShareText(String name, String tournament) {
    return '$name, $tournament turnuvasının şampiyonu oldu. NardArena';
  }

  @override
  String get championShareCopied => 'Metin kopyalandı';

  @override
  String sngTitle(int size) {
    return 'Sit-and-go · $size';
  }

  @override
  String sngSize(int n) {
    return '$n oyuncu';
  }

  @override
  String get sngStartsWhenFull => 'Dolar dolmaz başlar';

  @override
  String sngExpires(int n) {
    return '$n dakikada dolmazsa giriş ücreti iade edilir';
  }

  @override
  String sngFormatValue(String variant, int points) {
    return '$variant · $points sayı';
  }

  @override
  String get sngEntryFee => 'Giriş ücreti';

  @override
  String get sngTimeControl => 'Süre kontrolü';

  @override
  String sngNoShowRule(int n) {
    return 'Tur açıldıktan sonra $n saniye içinde katılmayan oyuncu turu hükmen kaybeder.';
  }

  @override
  String get sngLeave => 'Çık · giriş ücreti iade edilir';

  @override
  String noShowOverline(int round, int table) {
    return 'TUR $round · MASA $table';
  }

  @override
  String get noShowTitle => 'Rakibin henüz katılmadı';

  @override
  String noShowBody(String name) {
    return '$name süre bitene kadar gelmezse tur hükmen senin olur.';
  }

  @override
  String get tourBracket => 'Turnuva tablosu';

  @override
  String get walkoverTitle => 'Sonraki tura geçtin';

  @override
  String walkoverBody(String name) {
    return '$name zamanında katılmadı. Tur hükmen senin. Puanın değişmez.';
  }

  @override
  String walkoverNextRound(int n) {
    return 'Tur $n başlıyor';
  }

  @override
  String get walkoverNextRoundWhen => 'diğer maçlar bitince';

  @override
  String get notFilledTitle => 'Turnuva başlamadı';

  @override
  String notFilledBody(int minutes, int size, int joined) {
    return '$minutes dakikada $size oyuncudan yalnızca $joined kişi katıldı. Giriş ücreti bakiyene iade edildi.';
  }

  @override
  String get notFilledBodyScheduled => 'Yeterli oyuncu toplanmadı. Giriş ücreti bakiyene iade edildi.';

  @override
  String refunded(String amount) {
    return '+$amount iade edildi';
  }

  @override
  String notFilledJoinSmaller(int n) {
    return '$n kişilik masaya katıl';
  }

  @override
  String get backToTournaments => 'Turnuvalara dön';

  @override
  String get privateTourTitle => 'Özel turnuva';

  @override
  String get privateTourName => 'Ad';

  @override
  String get privateTourNameHint => 'Turnuva adı';

  @override
  String get privateTourSize => 'OYUNCU SAYISI';

  @override
  String get privateTourGame => 'Oyun';

  @override
  String get privateTourLength => 'Maç uzunluğu';

  @override
  String get privateTourStart => 'Başlama saati';

  @override
  String get privateTourStartManual => 'Sen başlatırsın';

  @override
  String privateTourStartValue(String weekday, String time) {
    return '$weekday, $time';
  }

  @override
  String get privateTourEntry => 'Giriş ücreti';

  @override
  String get privateTourFree => 'Ücretsiz';

  @override
  String get privateTourNote => 'Oluşturmak ücretsiz. Özel turnuvalar puanını etkilemez.';

  @override
  String get privateTourCreate => 'Turnuvayı oluştur';

  @override
  String get privateTourCodeLabel => 'DAVET KODU';

  @override
  String privateTourMeta(String when, String variant, int points) {
    return '$when · $variant, $points sayı';
  }

  @override
  String get privateTourCopyInvite => 'Daveti kopyala';

  @override
  String privateTourShareText(String name, String code) {
    return 'NardArena\'da \"$name\" turnuvasına katıl. Davet kodu: $code';
  }

  @override
  String get privateTourRegistration => 'KAYIT';

  @override
  String get privateTourOrganizer => 'Organizatör';

  @override
  String get privateTourJoined => 'Katıldı';

  @override
  String privateTourStartNowMin(int n) {
    return 'Şimdi başlat · en az $n oyuncu';
  }

  @override
  String get privateTourStartNow => 'Şimdi başlat';

  @override
  String get privateTourCancel => 'Turnuvayı iptal et';

  @override
  String get privateTourCancelTitle => 'Turnuva iptal edilsin mi?';

  @override
  String get privateTourCancelBody => 'Turnuva kaydolan herkes için kapanacak.';

  @override
  String get privateTourRemove => 'Turnuvadan çıkar';

  @override
  String get privateTourCodeHint => '6 karakterli kod';

  @override
  String get privateTourCodeNotFound => 'Bu kodla turnuva bulunamadı.';

  @override
  String get privateTourTooMany => 'Aynı anda en fazla 3 özel turnuva açabilirsin.';

  @override
  String get privateTourNotEnough => 'Başlamak için en az 2 oyuncu gerekir.';

  @override
  String homeTourMeta(String prize) {
    return 'Ödül havuzu · $prize';
  }

  @override
  String homeTourStarts(String time, String prize) {
    return 'Başlangıç $time · $prize';
  }

  @override
  String homeSeason(int n, int days) {
    return 'SEZON $n · $days GÜN';
  }

  @override
  String homeSeasonLevel(int level, int max) {
    return 'Seviye $level / $max';
  }

  @override
  String get homePuzzleOverline => 'GÜNÜN BULMACASI';

  @override
  String homeSeasonEnded(int n) {
    return 'SEZON $n BİTTİ';
  }

  @override
  String get homeSeasonSummaryCta => 'Sonuçlarına bak';

  @override
  String get modePuzzles => 'Bulmaca';

  @override
  String seasonN(int n) {
    return 'Sezon $n';
  }

  @override
  String get lbScopeGlobal => 'Küresel';

  @override
  String get lbScopeCountry => 'Ülke';

  @override
  String get lbScopeFriends => 'Arkadaşlar';

  @override
  String get lbScopeClan => 'Klan';

  @override
  String lbRank(int n) {
    return '#$n';
  }

  @override
  String get lbEmptyTitle => 'Liste boş';

  @override
  String get lbEmptyFriends => 'Arkadaşların henüz sıralamada değil.';

  @override
  String get lbEmptyClan => 'Klanın yok ya da üyeleri henüz sıralamada değil.';

  @override
  String get lbEmptyCountry => 'Profilinde ülke seçili değil ya da bu ülkeden henüz oyuncu yok.';

  @override
  String lbUnranked(int n) {
    return 'Sıralamaya girmek için bu sezon $n dereceli oyun oyna';
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
    return 'SEZON $n · $hours SAAT $minutes DK';
  }

  @override
  String seasonLevelNext(int n) {
    return 'Sonraki seviye: $n';
  }

  @override
  String get seasonLevelMax => 'Son seviye';

  @override
  String get seasonTrackFree => 'ÜCRETSİZ';

  @override
  String get seasonTrackPremium => 'PREMİUM';

  @override
  String get seasonRewardItem => 'Eşya';

  @override
  String seasonEndReward(String tier) {
    return 'Sezon sonu ödülü · $tier';
  }

  @override
  String seasonEndRewardMeta(String reward, int points) {
    return '$reward · $points puan kaldı';
  }

  @override
  String seasonEndRewardReached(String reward) {
    return '$reward · kazanıldı';
  }

  @override
  String seasonRewardWithItem(String item, String coins) {
    return '$item + $coins';
  }

  @override
  String get seasonPremiumUnlock => 'Premium\'u aç';

  @override
  String seasonClaimAll(int n) {
    return 'Hepsini al · $n';
  }

  @override
  String get seasonPremiumOwned => 'Premium aktif';

  @override
  String get seasonPremiumSheetTitle => 'Sezon bileti · Premium';

  @override
  String get seasonPremiumBody => 'Premium bu sezonun premium ödüllerini açar. Ulaştığın seviyelerin ödülleri hemen alınabilir.';

  @override
  String get seasonPremiumBought => 'Premium açıldı';

  @override
  String seasonNeedsLevel(int n) {
    return 'Seviye $n gerekli';
  }

  @override
  String get seasonNeedsPremium => 'Bu ödül premium yolda';

  @override
  String get seasonClaimedToast => 'Ödül alındı';

  @override
  String get seasonUnavailable => 'Sezon bilgisi yüklenmedi';

  @override
  String seasonEnded(int n) {
    return 'SEZON $n BİTTİ';
  }

  @override
  String get seasonStatGames => 'Oyun';

  @override
  String get seasonStatWinRate => 'Galibiyet';

  @override
  String get seasonStatRank => 'Dünya sırası';

  @override
  String get seasonStatCountryRank => 'Ülke sırası';

  @override
  String get seasonStatRatingGain => 'Puan değişimi';

  @override
  String get seasonStatRating => 'Son puan';

  @override
  String get seasonClaimRewards => 'Ödülleri al';

  @override
  String seasonRewardLine(String reward) {
    return 'Sezon ödülü: $reward';
  }

  @override
  String seasonSoftReset(int rating) {
    return 'Yeni sezonda puanın: $rating';
  }

  @override
  String get seasonNoSummaryTitle => 'Henüz biten sezon yok';

  @override
  String get seasonNoSummaryBody => 'İlk sezon bitince sonuçların burada görünür.';

  @override
  String get actionAnalysis => 'Analiz';

  @override
  String analysisTitle(int n) {
    return 'Analiz · Oyun $n';
  }

  @override
  String get analysisEquity => 'Değer';

  @override
  String get analysisNote => 'Değerleri sezgisel bot hesaplar, kesin kazanma şansı değildir. Sinir ağı yapay zekâsı gelince netleşecek.';

  @override
  String analysisBest(String moves) {
    return 'En iyi: $moves';
  }

  @override
  String analysisYours(String moves, String loss) {
    return 'Senin: $moves · $loss';
  }

  @override
  String get analysisBestPlayed => 'En iyi hamle';

  @override
  String get analysisRunning => 'Analiz ediliyor…';

  @override
  String get analysisMarkGood => 'İyi hamle';

  @override
  String get analysisMarkMistake => 'Hata';

  @override
  String get analysisMarkBlunder => 'Büyük hata';

  @override
  String get analysisNotReady => 'Maç kaydı henüz hazır değil. Biraz sonra yeniden dene.';

  @override
  String get analysisNoGames => 'Bu maçta oynanmış oyun yok.';

  @override
  String analysisGameChip(int n) {
    return 'Oyun $n';
  }

  @override
  String puzzleTitle(int n, int total) {
    return 'Bulmaca $n / $total';
  }

  @override
  String get puzzleDailyTitle => 'Günün bulmacası';

  @override
  String puzzleRating(int n) {
    return 'Puan $n';
  }

  @override
  String get puzzlePhaseOpening => 'Açılış';

  @override
  String get puzzlePhaseMiddle => 'Oyun ortası';

  @override
  String get puzzlePhaseBearOff => 'Toplama';

  @override
  String get puzzleLevelEasy => 'Kolay';

  @override
  String get puzzleLevelMedium => 'Orta';

  @override
  String get puzzleLevelHard => 'Zor';

  @override
  String get puzzlePrompt => 'En iyi hamleyi bul';

  @override
  String puzzleContext(String side, int d1, int d2) {
    return '$side oynuyorsun. Zar: $d1 – $d2.';
  }

  @override
  String get puzzleSideWhite => 'Beyaz taşlarla';

  @override
  String get puzzleSideBlack => 'Siyah taşlarla';

  @override
  String get puzzleHint => 'İpucu';

  @override
  String get puzzleConfirm => 'Hamleyi onayla';

  @override
  String get puzzleCorrect => 'Doğru';

  @override
  String get puzzleCorrectFirstTry => 'En iyi hamle · ilk denemede';

  @override
  String get puzzleCorrectSecondTry => 'En iyi hamle · ikinci denemede';

  @override
  String get puzzleYours => 'Senin';

  @override
  String get puzzleSecondBest => 'İkinci en iyi';

  @override
  String get puzzleBest => 'En iyi';

  @override
  String get puzzleHidden => 'gizli';

  @override
  String get puzzleSeeAnalysis => 'Analize bak';

  @override
  String get puzzleNext => 'Sonraki bulmaca';

  @override
  String get puzzleWrong => 'En iyi hamle değil';

  @override
  String puzzleAttemptsLeft(int n) {
    return 'Kalan deneme: $n';
  }

  @override
  String get puzzleShowSolution => 'Çözümü göster';

  @override
  String get puzzleOutOfTries => 'Deneme hakkın bitti';

  @override
  String puzzleAnswer(String move) {
    return 'Doğru cevap: $move';
  }

  @override
  String get puzzleSetDoneTitle => 'Tüm bulmacaları bitirdin';

  @override
  String get puzzleSetDoneBody => 'Yeni bulmacalar yakında eklenecek.';

  @override
  String get puzzleDailyDone => 'Bugünün bulmacası bitti. Sonrakilerle devam et.';

  @override
  String get puzzleOffline => 'Bulmacaları kontrol etmek için bağlantı gerekir.';

  @override
  String missionPuzzle(int n) {
    return '$n bulmaca çöz';
  }
}
