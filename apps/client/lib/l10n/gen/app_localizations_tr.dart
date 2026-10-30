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
}
