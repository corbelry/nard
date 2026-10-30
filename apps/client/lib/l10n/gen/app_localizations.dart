import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_az.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('az'),
    Locale('en'),
    Locale('ru'),
    Locale('tr')
  ];

  /// Brand name; placeholder, not translated.
  ///
  /// In az, this message translates to:
  /// **'NardArena'**
  String get appName;

  /// No description provided for @continueAction.
  ///
  /// In az, this message translates to:
  /// **'Davam et'**
  String get continueAction;

  /// No description provided for @comingSoon.
  ///
  /// In az, this message translates to:
  /// **'Tezliklə'**
  String get comingSoon;

  /// Accessibility label of back buttons.
  ///
  /// In az, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In az, this message translates to:
  /// **'Ləğv et'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In az, this message translates to:
  /// **'Yenidən cəhd et'**
  String get retry;

  /// No description provided for @valueOn.
  ///
  /// In az, this message translates to:
  /// **'Açıq'**
  String get valueOn;

  /// No description provided for @valueOff.
  ///
  /// In az, this message translates to:
  /// **'Bağlı'**
  String get valueOff;

  /// No description provided for @variantShort.
  ///
  /// In az, this message translates to:
  /// **'Qısa nərd'**
  String get variantShort;

  /// No description provided for @variantLong.
  ///
  /// In az, this message translates to:
  /// **'Uzun nərd'**
  String get variantLong;

  /// Uppercase overline; stored uppercased (no toUpperCase).
  ///
  /// In az, this message translates to:
  /// **'QISA NƏRD'**
  String get variantShortUpper;

  /// No description provided for @variantLongUpper.
  ///
  /// In az, this message translates to:
  /// **'UZUN NƏRD'**
  String get variantLongUpper;

  /// No description provided for @matchToPointsUpper.
  ///
  /// In az, this message translates to:
  /// **'{n} XALA QƏDƏR'**
  String matchToPointsUpper(int n);

  /// No description provided for @oneGameUpper.
  ///
  /// In az, this message translates to:
  /// **'1 OYUN'**
  String get oneGameUpper;

  /// No description provided for @tabHome.
  ///
  /// In az, this message translates to:
  /// **'Əsas'**
  String get tabHome;

  /// No description provided for @tabProfile.
  ///
  /// In az, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @playerWhite.
  ///
  /// In az, this message translates to:
  /// **'Ağ'**
  String get playerWhite;

  /// No description provided for @playerBlack.
  ///
  /// In az, this message translates to:
  /// **'Qara'**
  String get playerBlack;

  /// No description provided for @computerName.
  ///
  /// In az, this message translates to:
  /// **'Kompüter'**
  String get computerName;

  /// No description provided for @you.
  ///
  /// In az, this message translates to:
  /// **'Sən'**
  String get you;

  /// No description provided for @languageTitle.
  ///
  /// In az, this message translates to:
  /// **'Dil seçin'**
  String get languageTitle;

  /// Same text in every locale.
  ///
  /// In az, this message translates to:
  /// **'Choose language · Выберите язык · Dil seçin'**
  String get languageSubtitle;

  /// No description provided for @languageNameAz.
  ///
  /// In az, this message translates to:
  /// **'Azərbaycanca'**
  String get languageNameAz;

  /// No description provided for @languageNameTr.
  ///
  /// In az, this message translates to:
  /// **'Türkçe'**
  String get languageNameTr;

  /// No description provided for @languageNameRu.
  ///
  /// In az, this message translates to:
  /// **'Русский'**
  String get languageNameRu;

  /// No description provided for @languageNameEn.
  ///
  /// In az, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// English name under the endonym; same in every locale.
  ///
  /// In az, this message translates to:
  /// **'Azerbaijani'**
  String get languageSubAz;

  /// No description provided for @languageSubTr.
  ///
  /// In az, this message translates to:
  /// **'Turkish'**
  String get languageSubTr;

  /// No description provided for @languageSubRu.
  ///
  /// In az, this message translates to:
  /// **'Russian'**
  String get languageSubRu;

  /// No description provided for @languageSubEn.
  ///
  /// In az, this message translates to:
  /// **'English'**
  String get languageSubEn;

  /// No description provided for @onboardingStep.
  ///
  /// In az, this message translates to:
  /// **'ADDIM {current} / {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @variantQuestionTitle.
  ///
  /// In az, this message translates to:
  /// **'Hansı nərdi oynayırsan?'**
  String get variantQuestionTitle;

  /// No description provided for @variantShortDesc.
  ///
  /// In az, this message translates to:
  /// **'Klassik backgammon: vurmaq, bar, ikiqat kub.'**
  String get variantShortDesc;

  /// No description provided for @variantLongDesc.
  ///
  /// In az, this message translates to:
  /// **'Bütün daşlar başda. Vurmaq yoxdur, yalnız bloklamaq.'**
  String get variantLongDesc;

  /// No description provided for @variantLearnTitle.
  ///
  /// In az, this message translates to:
  /// **'Öyrənmək istəyirəm'**
  String get variantLearnTitle;

  /// No description provided for @variantLearnDesc.
  ///
  /// In az, this message translates to:
  /// **'{steps} addımlıq interaktiv dərs, 5 dəqiqə.'**
  String variantLearnDesc(int steps);

  /// No description provided for @lessonSkip.
  ///
  /// In az, this message translates to:
  /// **'Keç'**
  String get lessonSkip;

  /// No description provided for @lessonProgress.
  ///
  /// In az, this message translates to:
  /// **'{current}/{total}'**
  String lessonProgress(int current, int total);

  /// No description provided for @lessonStep1Title.
  ///
  /// In az, this message translates to:
  /// **'Bu sənin taxtandır'**
  String get lessonStep1Title;

  /// No description provided for @lessonStep1Body.
  ///
  /// In az, this message translates to:
  /// **'Ağ daşlar sənindir. Daşlar 24-cü xanadan 1-ci xanaya doğru hərəkət edir, sonra taxtadan çıxarılır. Davam etmək üçün istənilən daşa toxun.'**
  String get lessonStep1Body;

  /// No description provided for @lessonStep2Title.
  ///
  /// In az, this message translates to:
  /// **'Daşı 6 xana irəli apar'**
  String get lessonStep2Title;

  /// No description provided for @lessonStep2Body.
  ///
  /// In az, this message translates to:
  /// **'Zər 6 göstərir. 13-cü xanadakı daşa toxun, sonra işıqlanan 7-ci xanaya toxun və ya sürüşdür.'**
  String get lessonStep2Body;

  /// No description provided for @lessonStep3Title.
  ///
  /// In az, this message translates to:
  /// **'İki zəri də oyna'**
  String get lessonStep3Title;

  /// No description provided for @lessonStep3Body.
  ///
  /// In az, this message translates to:
  /// **'Zərlər 3 və 1 göstərir. 8-ci və 6-cı xanadan daşları 5-ci xanaya apar və xananı bağla.'**
  String get lessonStep3Body;

  /// No description provided for @lessonStep4Title.
  ///
  /// In az, this message translates to:
  /// **'Bağlı xana'**
  String get lessonStep4Title;

  /// No description provided for @lessonStep4Body.
  ///
  /// In az, this message translates to:
  /// **'Rəqibin iki və ya daha çox daşı olan xanaya getmək olmaz. Zər 5 göstərir: 13-cü xanadakı daşı 8-ci xanaya apar.'**
  String get lessonStep4Body;

  /// No description provided for @lessonStep5Title.
  ///
  /// In az, this message translates to:
  /// **'Vurmaq'**
  String get lessonStep5Title;

  /// No description provided for @lessonStep5Body.
  ///
  /// In az, this message translates to:
  /// **'Rəqibin tək daşına düşsən, onu bara göndərirsən. 6-cı xanadakı daşı 4-cü xanaya apar və vur.'**
  String get lessonStep5Body;

  /// No description provided for @lessonStep6Title.
  ///
  /// In az, this message translates to:
  /// **'Bardan giriş'**
  String get lessonStep6Title;

  /// No description provided for @lessonStep6Body.
  ///
  /// In az, this message translates to:
  /// **'Barda daşın varsa, əvvəl onu rəqibin evinə daxil etməlisən. Bardakı daşa toxun və 22-ci xanaya apar.'**
  String get lessonStep6Body;

  /// No description provided for @lessonStep7Title.
  ///
  /// In az, this message translates to:
  /// **'Daşları çıxar'**
  String get lessonStep7Title;

  /// No description provided for @lessonStep7Body.
  ///
  /// In az, this message translates to:
  /// **'Bütün daşlar evdədir (1–6). Zər 6 göstərir: 6-cı xanadakı daşı taxtadan çıxar.'**
  String get lessonStep7Body;

  /// No description provided for @lessonDoneTitle.
  ///
  /// In az, this message translates to:
  /// **'Əla, hazırsan'**
  String get lessonDoneTitle;

  /// No description provided for @lessonDoneBody.
  ///
  /// In az, this message translates to:
  /// **'Qaydaları bilirsən. İndi kompüterə qarşı oynayıb məşq et.'**
  String get lessonDoneBody;

  /// No description provided for @lessonFinish.
  ///
  /// In az, this message translates to:
  /// **'Oynamağa başla'**
  String get lessonFinish;

  /// No description provided for @homePlay.
  ///
  /// In az, this message translates to:
  /// **'Oyna'**
  String get homePlay;

  /// No description provided for @homeChangeMode.
  ///
  /// In az, this message translates to:
  /// **'Rejimi dəyiş'**
  String get homeChangeMode;

  /// No description provided for @homeOtherVariant.
  ///
  /// In az, this message translates to:
  /// **'{variant} →'**
  String homeOtherVariant(String variant);

  /// Pieces are already uppercase.
  ///
  /// In az, this message translates to:
  /// **'{variant} · {format}'**
  String homeHeroMeta(String variant, String format);

  /// No description provided for @homeHeroMode.
  ///
  /// In az, this message translates to:
  /// **'Kompüterə qarşı · {level}'**
  String homeHeroMode(String level);

  /// No description provided for @modeComputer.
  ///
  /// In az, this message translates to:
  /// **'Kompüter'**
  String get modeComputer;

  /// No description provided for @modeSameDevice.
  ///
  /// In az, this message translates to:
  /// **'Bir cihazda'**
  String get modeSameDevice;

  /// No description provided for @modeLesson.
  ///
  /// In az, this message translates to:
  /// **'Dərs'**
  String get modeLesson;

  /// No description provided for @modeReplays.
  ///
  /// In az, this message translates to:
  /// **'Oyunlarım'**
  String get modeReplays;

  /// No description provided for @setupTitle.
  ///
  /// In az, this message translates to:
  /// **'Yeni oyun'**
  String get setupTitle;

  /// No description provided for @setupVariantLabel.
  ///
  /// In az, this message translates to:
  /// **'VARİANT'**
  String get setupVariantLabel;

  /// No description provided for @setupFormatLabel.
  ///
  /// In az, this message translates to:
  /// **'FORMAT'**
  String get setupFormatLabel;

  /// No description provided for @formatOneGame.
  ///
  /// In az, this message translates to:
  /// **'1 oyun'**
  String get formatOneGame;

  /// No description provided for @formatPoints.
  ///
  /// In az, this message translates to:
  /// **'{n} xal'**
  String formatPoints(int n);

  /// No description provided for @setupCube.
  ///
  /// In az, this message translates to:
  /// **'İkiqat kub'**
  String get setupCube;

  /// No description provided for @aiTitle.
  ///
  /// In az, this message translates to:
  /// **'Kompüterə qarşı'**
  String get aiTitle;

  /// No description provided for @aiLevelBeginner.
  ///
  /// In az, this message translates to:
  /// **'Başlanğıc'**
  String get aiLevelBeginner;

  /// No description provided for @aiLevelAmateur.
  ///
  /// In az, this message translates to:
  /// **'Həvəskar'**
  String get aiLevelAmateur;

  /// No description provided for @aiLevelMedium.
  ///
  /// In az, this message translates to:
  /// **'Orta'**
  String get aiLevelMedium;

  /// No description provided for @aiLevelStrong.
  ///
  /// In az, this message translates to:
  /// **'Güclü'**
  String get aiLevelStrong;

  /// No description provided for @aiLevelMaster.
  ///
  /// In az, this message translates to:
  /// **'Usta'**
  String get aiLevelMaster;

  /// No description provided for @aiLevelGrandmaster.
  ///
  /// In az, this message translates to:
  /// **'Qrossmeyster'**
  String get aiLevelGrandmaster;

  /// No description provided for @aiLevelBeginnerDesc.
  ///
  /// In az, this message translates to:
  /// **'Qaydaları öyrənənlər üçün'**
  String get aiLevelBeginnerDesc;

  /// No description provided for @aiLevelAmateurDesc.
  ///
  /// In az, this message translates to:
  /// **'Sadə səhvlər edir'**
  String get aiLevelAmateurDesc;

  /// No description provided for @aiLevelMediumDesc.
  ///
  /// In az, this message translates to:
  /// **'Əsas strategiyanı bilir'**
  String get aiLevelMediumDesc;

  /// No description provided for @aiLevelStrongDesc.
  ///
  /// In az, this message translates to:
  /// **'Nadir səhv, kubu düzgün işlədir'**
  String get aiLevelStrongDesc;

  /// No description provided for @aiLevelMasterDesc.
  ///
  /// In az, this message translates to:
  /// **'Klub oyunçusu səviyyəsi'**
  String get aiLevelMasterDesc;

  /// No description provided for @aiLevelGrandmasterDesc.
  ///
  /// In az, this message translates to:
  /// **'Ən güclü rejim, səhv etmir'**
  String get aiLevelGrandmasterDesc;

  /// No description provided for @aiStart.
  ///
  /// In az, this message translates to:
  /// **'Başla · {level}'**
  String aiStart(String level);

  /// No description provided for @hotseatTitle.
  ///
  /// In az, this message translates to:
  /// **'Bir cihazda'**
  String get hotseatTitle;

  /// No description provided for @hotseatWhite.
  ///
  /// In az, this message translates to:
  /// **'Ağ daşlar'**
  String get hotseatWhite;

  /// No description provided for @hotseatBlack.
  ///
  /// In az, this message translates to:
  /// **'Qara daşlar'**
  String get hotseatBlack;

  /// No description provided for @hotseatGameSection.
  ///
  /// In az, this message translates to:
  /// **'OYUN'**
  String get hotseatGameSection;

  /// No description provided for @hotseatHideBetweenTurns.
  ///
  /// In az, this message translates to:
  /// **'Növbələr arası ekranı gizlət'**
  String get hotseatHideBetweenTurns;

  /// No description provided for @hotseatHideBetweenTurnsSub.
  ///
  /// In az, this message translates to:
  /// **'“Telefonu rəqibə ver” ekranı'**
  String get hotseatHideBetweenTurnsSub;

  /// No description provided for @hotseatFlipBoard.
  ///
  /// In az, this message translates to:
  /// **'Taxtanı çevir'**
  String get hotseatFlipBoard;

  /// No description provided for @hotseatFlipBoardSub.
  ///
  /// In az, this message translates to:
  /// **'Hər növbədə növbəti oyunçuya tərəf'**
  String get hotseatFlipBoardSub;

  /// No description provided for @hotseatAllowUndo.
  ///
  /// In az, this message translates to:
  /// **'Gedişi geri almaq'**
  String get hotseatAllowUndo;

  /// No description provided for @hotseatAllowUndoSub.
  ///
  /// In az, this message translates to:
  /// **'Rəqib hazıram deyənə qədər'**
  String get hotseatAllowUndoSub;

  /// No description provided for @hotseatStart.
  ///
  /// In az, this message translates to:
  /// **'Oyuna başla'**
  String get hotseatStart;

  /// No description provided for @hotseatEditName.
  ///
  /// In az, this message translates to:
  /// **'Adı dəyiş'**
  String get hotseatEditName;

  /// No description provided for @hotseatNameHint.
  ///
  /// In az, this message translates to:
  /// **'Oyunçunun adı'**
  String get hotseatNameHint;

  /// No description provided for @hotseatDefaultWhite.
  ///
  /// In az, this message translates to:
  /// **'Oyunçu 1'**
  String get hotseatDefaultWhite;

  /// No description provided for @hotseatDefaultBlack.
  ///
  /// In az, this message translates to:
  /// **'Oyunçu 2'**
  String get hotseatDefaultBlack;

  /// No description provided for @handoffOverline.
  ///
  /// In az, this message translates to:
  /// **'NÖVBƏ DƏYİŞDİ'**
  String get handoffOverline;

  /// Neutral wording avoids Azerbaijani suffix harmony on names.
  ///
  /// In az, this message translates to:
  /// **'Növbə: {name}'**
  String handoffTitle(String name);

  /// No description provided for @handoffBody.
  ///
  /// In az, this message translates to:
  /// **'{side}. {prevName} son gedişi etdi: {moves}.'**
  String handoffBody(String side, String prevName, String moves);

  /// No description provided for @handoffBodyNoMove.
  ///
  /// In az, this message translates to:
  /// **'{side}. {prevName} oynaya bilmədi.'**
  String handoffBodyNoMove(String side, String prevName);

  /// No description provided for @handoffFirst.
  ///
  /// In az, this message translates to:
  /// **'{side}. Oyunu sən başlayırsan.'**
  String handoffFirst(String side);

  /// No description provided for @handoffReady.
  ///
  /// In az, this message translates to:
  /// **'{name}, hazıram'**
  String handoffReady(String name);

  /// No description provided for @handoffUndo.
  ///
  /// In az, this message translates to:
  /// **'{prevName}: gedişi geri al'**
  String handoffUndo(String prevName);

  /// No description provided for @gameModeTo.
  ///
  /// In az, this message translates to:
  /// **'{variant} · {points} xala qədər'**
  String gameModeTo(String variant, int points);

  /// No description provided for @gameModeSingle.
  ///
  /// In az, this message translates to:
  /// **'{variant} · 1 oyun'**
  String gameModeSingle(String variant);

  /// No description provided for @gameScore.
  ///
  /// In az, this message translates to:
  /// **'{me} – {opp}'**
  String gameScore(int me, int opp);

  /// No description provided for @bannerYourTurn.
  ///
  /// In az, this message translates to:
  /// **'Sənin növbən'**
  String get bannerYourTurn;

  /// No description provided for @bannerTurnOf.
  ///
  /// In az, this message translates to:
  /// **'Növbə: {name}'**
  String bannerTurnOf(String name);

  /// No description provided for @bannerRollHint.
  ///
  /// In az, this message translates to:
  /// **'Zər at və ya ikiqat təklif et'**
  String get bannerRollHint;

  /// No description provided for @bannerLegalMoveCount.
  ///
  /// In az, this message translates to:
  /// **'{count} mümkün gediş'**
  String bannerLegalMoveCount(int count);

  /// No description provided for @bannerRolling.
  ///
  /// In az, this message translates to:
  /// **'Zərlər atılır'**
  String get bannerRolling;

  /// No description provided for @bannerOpening.
  ///
  /// In az, this message translates to:
  /// **'Kim başlayır?'**
  String get bannerOpening;

  /// No description provided for @bannerOpeningTie.
  ///
  /// In az, this message translates to:
  /// **'Bərabər · yenidən atılır'**
  String get bannerOpeningTie;

  /// No description provided for @bannerOpeningWinner.
  ///
  /// In az, this message translates to:
  /// **'{name} başlayır'**
  String bannerOpeningWinner(String name);

  /// No description provided for @bannerOpponentThinking.
  ///
  /// In az, this message translates to:
  /// **'Rəqib düşünür'**
  String get bannerOpponentThinking;

  /// No description provided for @bannerDice.
  ///
  /// In az, this message translates to:
  /// **'Zərlər {a} – {b}'**
  String bannerDice(int a, int b);

  /// No description provided for @bannerCubeOffer.
  ///
  /// In az, this message translates to:
  /// **'İkiqat təklifi'**
  String get bannerCubeOffer;

  /// No description provided for @bannerCubeWaiting.
  ///
  /// In az, this message translates to:
  /// **'Cavab gözlənilir'**
  String get bannerCubeWaiting;

  /// No description provided for @bannerNoMoves.
  ///
  /// In az, this message translates to:
  /// **'Gediş yoxdur'**
  String get bannerNoMoves;

  /// No description provided for @bannerGameOver.
  ///
  /// In az, this message translates to:
  /// **'Oyun bitdi'**
  String get bannerGameOver;

  /// No description provided for @bannerHeadRuleHint.
  ///
  /// In az, this message translates to:
  /// **'Başdan yalnız bir daş'**
  String get bannerHeadRuleHint;

  /// No description provided for @bannerIllegalMove.
  ///
  /// In az, this message translates to:
  /// **'Qeyri-qanuni gediş'**
  String get bannerIllegalMove;

  /// No description provided for @bannerOpponentNeedsOne.
  ///
  /// In az, this message translates to:
  /// **'Rəqibə 1 xal qalıb'**
  String get bannerOpponentNeedsOne;

  /// No description provided for @bannerYouNeedOne.
  ///
  /// In az, this message translates to:
  /// **'Sənə 1 xal qalıb'**
  String get bannerYouNeedOne;

  /// No description provided for @crawfordChip.
  ///
  /// In az, this message translates to:
  /// **'Crawford oyunu · kub yoxdur'**
  String get crawfordChip;

  /// No description provided for @actionRoll.
  ///
  /// In az, this message translates to:
  /// **'Zər at'**
  String get actionRoll;

  /// No description provided for @actionConfirm.
  ///
  /// In az, this message translates to:
  /// **'Təsdiqlə'**
  String get actionConfirm;

  /// No description provided for @actionMovesProgress.
  ///
  /// In az, this message translates to:
  /// **'{done} / {total}'**
  String actionMovesProgress(int done, int total);

  /// No description provided for @actionPass.
  ///
  /// In az, this message translates to:
  /// **'Keç'**
  String get actionPass;

  /// No description provided for @actionNextGame.
  ///
  /// In az, this message translates to:
  /// **'Növbəti oyun'**
  String get actionNextGame;

  /// No description provided for @actionUndo.
  ///
  /// In az, this message translates to:
  /// **'Geri al'**
  String get actionUndo;

  /// No description provided for @actionDouble.
  ///
  /// In az, this message translates to:
  /// **'İkiqat'**
  String get actionDouble;

  /// Accessibility label.
  ///
  /// In az, this message translates to:
  /// **'Menyu'**
  String get actionMenu;

  /// No description provided for @playerPip.
  ///
  /// In az, this message translates to:
  /// **'Pip {pip}'**
  String playerPip(int pip);

  /// No description provided for @playerBotLevel.
  ///
  /// In az, this message translates to:
  /// **'Kompüter · {level}'**
  String playerBotLevel(String level);

  /// No description provided for @noMovesTitle.
  ///
  /// In az, this message translates to:
  /// **'Mümkün gediş yoxdur'**
  String get noMovesTitle;

  /// No description provided for @noMovesBody.
  ///
  /// In az, this message translates to:
  /// **'{a} – {b} · {reason}. Növbə 2 saniyəyə rəqibə keçir.'**
  String noMovesBody(int a, int b, String reason);

  /// No description provided for @noMovesReasonBar.
  ///
  /// In az, this message translates to:
  /// **'bar bağlıdır'**
  String get noMovesReasonBar;

  /// No description provided for @noMovesReasonBlocked.
  ///
  /// In az, this message translates to:
  /// **'bütün yollar bağlıdır'**
  String get noMovesReasonBlocked;

  /// No description provided for @cubeOfferTitle.
  ///
  /// In az, this message translates to:
  /// **'{name} ikiqat təklif edir'**
  String cubeOfferTitle(String name);

  /// No description provided for @cubeOfferBody.
  ///
  /// In az, this message translates to:
  /// **'Oyunun dəyəri {from} → {to} xal. Qəbul etsən, kub sənə keçir.'**
  String cubeOfferBody(int from, int to);

  /// No description provided for @cubeDecline.
  ///
  /// In az, this message translates to:
  /// **'İmtina et'**
  String get cubeDecline;

  /// No description provided for @cubeDeclineSub.
  ///
  /// In az, this message translates to:
  /// **'−{points} xal, oyun bitir'**
  String cubeDeclineSub(int points);

  /// No description provided for @cubeAccept.
  ///
  /// In az, this message translates to:
  /// **'Qəbul et'**
  String get cubeAccept;

  /// No description provided for @cubeAcceptSub.
  ///
  /// In az, this message translates to:
  /// **'Dəyər {points} xal'**
  String cubeAcceptSub(int points);

  /// No description provided for @cubeBotTook.
  ///
  /// In az, this message translates to:
  /// **'Kompüter ikiqatı qəbul etdi · dəyər {points} xal'**
  String cubeBotTook(int points);

  /// Stored uppercase.
  ///
  /// In az, this message translates to:
  /// **'QƏLƏBƏ'**
  String get gameWonTitle;

  /// Stored uppercase.
  ///
  /// In az, this message translates to:
  /// **'MƏĞLUBİYYƏT'**
  String get gameLostTitle;

  /// Pass & play result; name as typed.
  ///
  /// In az, this message translates to:
  /// **'{name} QAZANDI'**
  String gameWinnerTitle(String name);

  /// No description provided for @resultSingle.
  ///
  /// In az, this message translates to:
  /// **'+{points} xal'**
  String resultSingle(int points);

  /// No description provided for @resultMars.
  ///
  /// In az, this message translates to:
  /// **'Mars · +{points} xal'**
  String resultMars(int points);

  /// No description provided for @resultKoks.
  ///
  /// In az, this message translates to:
  /// **'Koks · +{points} xal'**
  String resultKoks(int points);

  /// No description provided for @resultDropped.
  ///
  /// In az, this message translates to:
  /// **'İkiqat rədd edildi · +{points} xal'**
  String resultDropped(int points);

  /// No description provided for @resultResigned.
  ///
  /// In az, this message translates to:
  /// **'Təslim oldu · +{points} xal'**
  String resultResigned(int points);

  /// No description provided for @gameMatchProgress.
  ///
  /// In az, this message translates to:
  /// **'{target} xala qədər · matça {left} xal qaldı'**
  String gameMatchProgress(int target, int left);

  /// No description provided for @actionViewReplay.
  ///
  /// In az, this message translates to:
  /// **'Replay'**
  String get actionViewReplay;

  /// No description provided for @matchWonTitle.
  ///
  /// In az, this message translates to:
  /// **'Matç qələbəsi'**
  String get matchWonTitle;

  /// No description provided for @matchLostTitle.
  ///
  /// In az, this message translates to:
  /// **'Matç məğlubiyyəti'**
  String get matchLostTitle;

  /// No description provided for @matchWinnerTitle.
  ///
  /// In az, this message translates to:
  /// **'{name} matçı qazandı'**
  String matchWinnerTitle(String name);

  /// No description provided for @matchMeta.
  ///
  /// In az, this message translates to:
  /// **'{me} · {opp} · {points} xala qədər'**
  String matchMeta(String me, String opp, int points);

  /// No description provided for @matchMetaSingle.
  ///
  /// In az, this message translates to:
  /// **'{me} · {opp} · 1 oyun'**
  String matchMetaSingle(String me, String opp);

  /// No description provided for @matchRematch.
  ///
  /// In az, this message translates to:
  /// **'Revanş'**
  String get matchRematch;

  /// No description provided for @matchHome.
  ///
  /// In az, this message translates to:
  /// **'Ana səhifə'**
  String get matchHome;

  /// No description provided for @resignTitle.
  ///
  /// In az, this message translates to:
  /// **'Təslim ol'**
  String get resignTitle;

  /// No description provided for @resignBody.
  ///
  /// In az, this message translates to:
  /// **'Kubun dəyəri ×{cube}. Rəqibə verəcəyin xalı seç.'**
  String resignBody(int cube);

  /// No description provided for @resignSingle.
  ///
  /// In az, this message translates to:
  /// **'Tək oyun'**
  String get resignSingle;

  /// No description provided for @resignSingleDesc.
  ///
  /// In az, this message translates to:
  /// **'Adi məğlubiyyət'**
  String get resignSingleDesc;

  /// No description provided for @resignMars.
  ///
  /// In az, this message translates to:
  /// **'Mars'**
  String get resignMars;

  /// No description provided for @resignMarsDesc.
  ///
  /// In az, this message translates to:
  /// **'Heç daş çıxarılmayıb'**
  String get resignMarsDesc;

  /// No description provided for @resignKoks.
  ///
  /// In az, this message translates to:
  /// **'Koks'**
  String get resignKoks;

  /// No description provided for @resignKoksDesc.
  ///
  /// In az, this message translates to:
  /// **'Daş barda və ya rəqib evində'**
  String get resignKoksDesc;

  /// No description provided for @resignKoksDescLong.
  ///
  /// In az, this message translates to:
  /// **'Daş hələ rəqibin evindən keçməyib'**
  String get resignKoksDescLong;

  /// No description provided for @resignPoints.
  ///
  /// In az, this message translates to:
  /// **'−{points}'**
  String resignPoints(int points);

  /// No description provided for @resignConfirm.
  ///
  /// In az, this message translates to:
  /// **'Təslim ol · −{points}'**
  String resignConfirm(int points);

  /// No description provided for @menuResume.
  ///
  /// In az, this message translates to:
  /// **'Oyuna qayıt'**
  String get menuResume;

  /// No description provided for @menuSettings.
  ///
  /// In az, this message translates to:
  /// **'Ayarlar'**
  String get menuSettings;

  /// No description provided for @menuRules.
  ///
  /// In az, this message translates to:
  /// **'Qaydalar'**
  String get menuRules;

  /// No description provided for @menuSound.
  ///
  /// In az, this message translates to:
  /// **'Səs'**
  String get menuSound;

  /// No description provided for @menuResign.
  ///
  /// In az, this message translates to:
  /// **'Təslim ol'**
  String get menuResign;

  /// No description provided for @menuLeave.
  ///
  /// In az, this message translates to:
  /// **'Oyundan çıx'**
  String get menuLeave;

  /// No description provided for @leaveTitle.
  ///
  /// In az, this message translates to:
  /// **'Oyundan çıxırsan?'**
  String get leaveTitle;

  /// No description provided for @leaveBody.
  ///
  /// In az, this message translates to:
  /// **'Bu oyun yadda saxlanmayacaq.'**
  String get leaveBody;

  /// No description provided for @leaveConfirm.
  ///
  /// In az, this message translates to:
  /// **'Çıx'**
  String get leaveConfirm;

  /// No description provided for @ruleHeadTitle.
  ///
  /// In az, this message translates to:
  /// **'Başdan yalnız bir daş götürmək olar'**
  String get ruleHeadTitle;

  /// No description provided for @ruleHeadBody.
  ///
  /// In az, this message translates to:
  /// **'Bu növbədə başdan artıq bir daş oynadın. İstisna: ilk atışda 6-6, 4-4 və ya 3-3 düşəndə iki daş götürmək olar.'**
  String get ruleHeadBody;

  /// No description provided for @ruleSixBlockTitle.
  ///
  /// In az, this message translates to:
  /// **'Ardıcıl 6 xananı bağlamaq olmaz'**
  String get ruleSixBlockTitle;

  /// No description provided for @ruleSixBlockBody.
  ///
  /// In az, this message translates to:
  /// **'{from} → {to} gedişi 6 xanalıq sədd qurur, qabağında isə rəqibin heç bir daşı yoxdur. Başqa gediş seç.'**
  String ruleSixBlockBody(String from, String to);

  /// No description provided for @rulePointClosedTitle.
  ///
  /// In az, this message translates to:
  /// **'Bu xana bağlıdır'**
  String get rulePointClosedTitle;

  /// No description provided for @rulePointClosedShort.
  ///
  /// In az, this message translates to:
  /// **'Rəqibin iki və ya daha çox daşı olan xanaya getmək olmaz.'**
  String get rulePointClosedShort;

  /// No description provided for @rulePointClosedLong.
  ///
  /// In az, this message translates to:
  /// **'Uzun nərddə rəqibin daşı olan xanaya getmək olmaz.'**
  String get rulePointClosedLong;

  /// No description provided for @ruleBarTitle.
  ///
  /// In az, this message translates to:
  /// **'Əvvəl bardakı daşı daxil et'**
  String get ruleBarTitle;

  /// No description provided for @ruleBarBody.
  ///
  /// In az, this message translates to:
  /// **'Barda daşın olduqca başqa daşla oynamaq olmaz.'**
  String get ruleBarBody;

  /// No description provided for @ruleBothDiceTitle.
  ///
  /// In az, this message translates to:
  /// **'Hər iki zəri oynamaq lazımdır'**
  String get ruleBothDiceTitle;

  /// No description provided for @ruleBothDiceBody.
  ///
  /// In az, this message translates to:
  /// **'Bu gediş digər zəri oynamağa imkan vermir. Hər iki zəri işlədən gediş seç.'**
  String get ruleBothDiceBody;

  /// No description provided for @ruleLargerDieTitle.
  ///
  /// In az, this message translates to:
  /// **'Böyük zəri oyna'**
  String get ruleLargerDieTitle;

  /// No description provided for @ruleLargerDieBody.
  ///
  /// In az, this message translates to:
  /// **'Yalnız bir zər oynana bilirsə, böyük zəri oynamaq lazımdır.'**
  String get ruleLargerDieBody;

  /// No description provided for @ruleBearOffTitle.
  ///
  /// In az, this message translates to:
  /// **'Hələ daş çıxarmaq olmaz'**
  String get ruleBearOffTitle;

  /// No description provided for @ruleBearOffBody.
  ///
  /// In az, this message translates to:
  /// **'Daş çıxarmaq üçün bütün daşlar evdə (1–6) olmalıdır.'**
  String get ruleBearOffBody;

  /// No description provided for @ruleBearOffHigherTitle.
  ///
  /// In az, this message translates to:
  /// **'Əvvəl yuxarı xanadakı daşı oyna'**
  String get ruleBearOffHigherTitle;

  /// No description provided for @ruleBearOffHigherBody.
  ///
  /// In az, this message translates to:
  /// **'Böyük zərlə yalnız ən yuxarı xanadakı daşı çıxarmaq olar.'**
  String get ruleBearOffHigherBody;

  /// No description provided for @ruleNoDieTitle.
  ///
  /// In az, this message translates to:
  /// **'Bu məsafəyə zər yoxdur'**
  String get ruleNoDieTitle;

  /// No description provided for @ruleNoDieBody.
  ///
  /// In az, this message translates to:
  /// **'Daşı yalnız zərlərdəki xana sayı qədər aparmaq olar.'**
  String get ruleNoDieBody;

  /// No description provided for @ruleNoCheckerTitle.
  ///
  /// In az, this message translates to:
  /// **'Bu xanada sənin daşın yoxdur'**
  String get ruleNoCheckerTitle;

  /// No description provided for @ruleTurnCompleteTitle.
  ///
  /// In az, this message translates to:
  /// **'Bütün zərlər oynanıb'**
  String get ruleTurnCompleteTitle;

  /// No description provided for @ruleTurnCompleteBody.
  ///
  /// In az, this message translates to:
  /// **'Gedişi təsdiqlə və ya geri al.'**
  String get ruleTurnCompleteBody;

  /// No description provided for @replayListTitle.
  ///
  /// In az, this message translates to:
  /// **'Oyunlarım'**
  String get replayListTitle;

  /// No description provided for @replayEmptyTitle.
  ///
  /// In az, this message translates to:
  /// **'Hələ oyun yoxdur'**
  String get replayEmptyTitle;

  /// No description provided for @replayEmptyBody.
  ///
  /// In az, this message translates to:
  /// **'Bitirdiyin oyunlar burada görünəcək. Replay ilə hər gedişə yenidən baxa bilərsən.'**
  String get replayEmptyBody;

  /// No description provided for @replayTitle.
  ///
  /// In az, this message translates to:
  /// **'Replay · Oyun {n}'**
  String replayTitle(int n);

  /// No description provided for @replayPlayers.
  ///
  /// In az, this message translates to:
  /// **'{p1} – {p2}'**
  String replayPlayers(String p1, String p2);

  /// No description provided for @replayStart.
  ///
  /// In az, this message translates to:
  /// **'Başlanğıc'**
  String get replayStart;

  /// No description provided for @replayBack.
  ///
  /// In az, this message translates to:
  /// **'Geri'**
  String get replayBack;

  /// No description provided for @replayPlay.
  ///
  /// In az, this message translates to:
  /// **'Oynat'**
  String get replayPlay;

  /// No description provided for @replayPause.
  ///
  /// In az, this message translates to:
  /// **'Dayandır'**
  String get replayPause;

  /// No description provided for @replayForward.
  ///
  /// In az, this message translates to:
  /// **'İrəli'**
  String get replayForward;

  /// No description provided for @replayEnd.
  ///
  /// In az, this message translates to:
  /// **'Son'**
  String get replayEnd;

  /// No description provided for @replayOpening.
  ///
  /// In az, this message translates to:
  /// **'Açılış: {a} – {b}'**
  String replayOpening(int a, int b);

  /// No description provided for @replayNoMove.
  ///
  /// In az, this message translates to:
  /// **'gediş yoxdur'**
  String get replayNoMove;

  /// No description provided for @replayDouble.
  ///
  /// In az, this message translates to:
  /// **'ikiqat təklif'**
  String get replayDouble;

  /// No description provided for @replayTake.
  ///
  /// In az, this message translates to:
  /// **'qəbul'**
  String get replayTake;

  /// No description provided for @replayDrop.
  ///
  /// In az, this message translates to:
  /// **'rədd'**
  String get replayDrop;

  /// No description provided for @replayResign.
  ///
  /// In az, this message translates to:
  /// **'təslim'**
  String get replayResign;

  /// No description provided for @replayWon.
  ///
  /// In az, this message translates to:
  /// **'{name} qazandı · {points} xal'**
  String replayWon(String name, int points);

  /// No description provided for @replayLoadError.
  ///
  /// In az, this message translates to:
  /// **'Oyun açılmadı'**
  String get replayLoadError;

  /// No description provided for @settingsTitle.
  ///
  /// In az, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsGroupGame.
  ///
  /// In az, this message translates to:
  /// **'OYUN'**
  String get settingsGroupGame;

  /// No description provided for @settingsGroupAccessibility.
  ///
  /// In az, this message translates to:
  /// **'ƏLÇATANLIQ'**
  String get settingsGroupAccessibility;

  /// No description provided for @settingsGroupGeneral.
  ///
  /// In az, this message translates to:
  /// **'ÜMUMİ'**
  String get settingsGroupGeneral;

  /// No description provided for @settingsConfirmMove.
  ///
  /// In az, this message translates to:
  /// **'Gedişi təsdiqlə'**
  String get settingsConfirmMove;

  /// No description provided for @settingsAutoRoll.
  ///
  /// In az, this message translates to:
  /// **'Avtomatik zər at'**
  String get settingsAutoRoll;

  /// No description provided for @settingsShowLegalMoves.
  ///
  /// In az, this message translates to:
  /// **'Mümkün gedişləri göstər'**
  String get settingsShowLegalMoves;

  /// No description provided for @settingsPipCount.
  ///
  /// In az, this message translates to:
  /// **'Pip sayı'**
  String get settingsPipCount;

  /// No description provided for @settingsAnimationSpeed.
  ///
  /// In az, this message translates to:
  /// **'Animasiya sürəti'**
  String get settingsAnimationSpeed;

  /// No description provided for @animationSpeedSlow.
  ///
  /// In az, this message translates to:
  /// **'Yavaş'**
  String get animationSpeedSlow;

  /// No description provided for @animationSpeedNormal.
  ///
  /// In az, this message translates to:
  /// **'Normal'**
  String get animationSpeedNormal;

  /// No description provided for @animationSpeedFast.
  ///
  /// In az, this message translates to:
  /// **'Sürətli'**
  String get animationSpeedFast;

  /// No description provided for @settingsColorBlind.
  ///
  /// In az, this message translates to:
  /// **'Rəng korluğu rejimi'**
  String get settingsColorBlind;

  /// No description provided for @settingsLargePips.
  ///
  /// In az, this message translates to:
  /// **'Böyük zər xalları'**
  String get settingsLargePips;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In az, this message translates to:
  /// **'Hərəkəti azalt'**
  String get settingsReduceMotion;

  /// No description provided for @settingsSound.
  ///
  /// In az, this message translates to:
  /// **'Səs'**
  String get settingsSound;

  /// No description provided for @settingsHaptics.
  ///
  /// In az, this message translates to:
  /// **'Vibrasiya'**
  String get settingsHaptics;

  /// No description provided for @settingsLanguage.
  ///
  /// In az, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsReplays.
  ///
  /// In az, this message translates to:
  /// **'Oyunlarım'**
  String get settingsReplays;

  /// No description provided for @settingsLesson.
  ///
  /// In az, this message translates to:
  /// **'Dərsi təkrarla'**
  String get settingsLesson;

  /// No description provided for @settingsAbout.
  ///
  /// In az, this message translates to:
  /// **'Versiya {version}'**
  String settingsAbout(String version);

  /// No description provided for @errorTitle.
  ///
  /// In az, this message translates to:
  /// **'Nəsə alınmadı'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In az, this message translates to:
  /// **'Yenidən cəhd et. Problem davam edərsə, tətbiqi yenidən aç.'**
  String get errorBody;

  /// No description provided for @playVsComputer.
  ///
  /// In az, this message translates to:
  /// **'Kompüterə qarşı oyna'**
  String get playVsComputer;

  /// No description provided for @rulesShortBody.
  ///
  /// In az, this message translates to:
  /// **'Hər oyunçunun 15 daşı var. Daşlar zərə görə 24-dən 1-ə doğru hərəkət edir. Rəqibin tək daşına düşsən, onu bara göndərirsən; iki və daha çox daşı olan xana bağlıdır. Bütün daşlar evə (1–6) çatanda çıxarmağa başlayırsan. İlk 15 daşı çıxaran qalib gəlir. Rəqib heç daş çıxarmayıbsa — mars (×2), daşı barda və ya sənin evindədirsə — koks (×3).'**
  String get rulesShortBody;

  /// No description provided for @rulesLongBody.
  ///
  /// In az, this message translates to:
  /// **'Bütün 15 daş başda (24-cü xana) başlayır. Vurmaq yoxdur: rəqibin daşı olan xanaya getmək olmaz. Hər növbədə başdan yalnız bir daş götürmək olar (ilk atışda 6-6, 4-4, 3-3 istisnadır). Qabağında rəqib daşı olmayan ardıcıl 6 xananı bağlamaq olmaz. Bütün daşlar evə çatanda çıxarmağa başlayırsan. Rəqib heç daş çıxarmayıbsa — mars (×2), daşı hələ sənin evindən keçməyibsə — koks (×3).'**
  String get rulesLongBody;

  /// No description provided for @actionSave.
  ///
  /// In az, this message translates to:
  /// **'Yadda saxla'**
  String get actionSave;

  /// No description provided for @copied.
  ///
  /// In az, this message translates to:
  /// **'Kopyalandı'**
  String get copied;

  /// No description provided for @valueNone.
  ///
  /// In az, this message translates to:
  /// **'—'**
  String get valueNone;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In az, this message translates to:
  /// **'Xoş gəldin'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeBody.
  ///
  /// In az, this message translates to:
  /// **'Hesab yaratsan reytinqin və matç tarixçən bütün cihazlarda saxlanacaq.'**
  String get authWelcomeBody;

  /// No description provided for @authApple.
  ///
  /// In az, this message translates to:
  /// **'Apple ilə davam et'**
  String get authApple;

  /// No description provided for @authGoogle.
  ///
  /// In az, this message translates to:
  /// **'Google ilə davam et'**
  String get authGoogle;

  /// No description provided for @authEmail.
  ///
  /// In az, this message translates to:
  /// **'E-poçt ilə davam et'**
  String get authEmail;

  /// No description provided for @authGuest.
  ///
  /// In az, this message translates to:
  /// **'Qonaq kimi oyna'**
  String get authGuest;

  /// No description provided for @authLegal.
  ///
  /// In az, this message translates to:
  /// **'Davam etməklə {terms} və {privacy} ilə razılaşırsan.'**
  String authLegal(String terms, String privacy);

  /// No description provided for @authTerms.
  ///
  /// In az, this message translates to:
  /// **'İstifadə şərtləri'**
  String get authTerms;

  /// No description provided for @authPrivacy.
  ///
  /// In az, this message translates to:
  /// **'Məxfilik siyasəti'**
  String get authPrivacy;

  /// No description provided for @authProviderUnavailable.
  ///
  /// In az, this message translates to:
  /// **'Bu giriş üsulu hələ hazır deyil. E-poçt ilə və ya qonaq kimi davam et.'**
  String get authProviderUnavailable;

  /// No description provided for @authOffline.
  ///
  /// In az, this message translates to:
  /// **'Serverlə əlaqə yoxdur. İnterneti yoxla və yenidən cəhd et.'**
  String get authOffline;

  /// No description provided for @authTooManyTries.
  ///
  /// In az, this message translates to:
  /// **'Çox cəhd etdin. Bir az sonra yenidən yoxla.'**
  String get authTooManyTries;

  /// No description provided for @authSignIn.
  ///
  /// In az, this message translates to:
  /// **'Daxil ol'**
  String get authSignIn;

  /// No description provided for @emailTitle.
  ///
  /// In az, this message translates to:
  /// **'E-poçtunu yaz'**
  String get emailTitle;

  /// No description provided for @emailBody.
  ///
  /// In az, this message translates to:
  /// **'Şifrə lazım deyil. 6 rəqəmli giriş kodu göndərəcəyik.'**
  String get emailBody;

  /// No description provided for @emailLabel.
  ///
  /// In az, this message translates to:
  /// **'E-poçt'**
  String get emailLabel;

  /// No description provided for @emailSend.
  ///
  /// In az, this message translates to:
  /// **'Kodu göndər'**
  String get emailSend;

  /// No description provided for @emailInvalid.
  ///
  /// In az, this message translates to:
  /// **'E-poçt ünvanı düzgün deyil'**
  String get emailInvalid;

  /// No description provided for @codeTitle.
  ///
  /// In az, this message translates to:
  /// **'Kodu yaz'**
  String get codeTitle;

  /// No description provided for @codeBody.
  ///
  /// In az, this message translates to:
  /// **'{email} ünvanına göndərdik. Spam qovluğunu da yoxla.'**
  String codeBody(String email);

  /// No description provided for @codeLabel.
  ///
  /// In az, this message translates to:
  /// **'6 rəqəmli kod'**
  String get codeLabel;

  /// No description provided for @codeResendIn.
  ///
  /// In az, this message translates to:
  /// **'Kodu yenidən göndər · {time}'**
  String codeResendIn(String time);

  /// No description provided for @codeResend.
  ///
  /// In az, this message translates to:
  /// **'Kodu yenidən göndər'**
  String get codeResend;

  /// No description provided for @codeSent.
  ///
  /// In az, this message translates to:
  /// **'Yeni kod göndərildi'**
  String get codeSent;

  /// No description provided for @codeInvalid.
  ///
  /// In az, this message translates to:
  /// **'Kod yanlışdır. Yenidən yoxla.'**
  String get codeInvalid;

  /// No description provided for @codeExpired.
  ///
  /// In az, this message translates to:
  /// **'Kodun vaxtı bitib. Yeni kod istə.'**
  String get codeExpired;

  /// No description provided for @modeCasual.
  ///
  /// In az, this message translates to:
  /// **'Adi'**
  String get modeCasual;

  /// No description provided for @modeRanked.
  ///
  /// In az, this message translates to:
  /// **'Reytinqli'**
  String get modeRanked;

  /// No description provided for @searchTitle.
  ///
  /// In az, this message translates to:
  /// **'Rəqib axtarılır…'**
  String get searchTitle;

  /// No description provided for @searchElapsed.
  ///
  /// In az, this message translates to:
  /// **'Keçən vaxt {elapsed}'**
  String searchElapsed(String elapsed);

  /// No description provided for @searchTip.
  ///
  /// In az, this message translates to:
  /// **'Məsləhət: {tip}'**
  String searchTip(String tip);

  /// No description provided for @searchTipHeadRule.
  ///
  /// In az, this message translates to:
  /// **'Uzun nərddə başdan yalnız bir daş götürülür.'**
  String get searchTipHeadRule;

  /// No description provided for @searchTipPip.
  ///
  /// In az, this message translates to:
  /// **'Pip sayı yarışda kimin öndə olduğunu göstərir.'**
  String get searchTipPip;

  /// No description provided for @searchBotSoon.
  ///
  /// In az, this message translates to:
  /// **'30 saniyədə canlı rəqib tapılmasa, bot ilə oynayacaqsan.'**
  String get searchBotSoon;

  /// No description provided for @timeControlShort.
  ///
  /// In az, this message translates to:
  /// **'{minutes}+{delay}s'**
  String timeControlShort(int minutes, int delay);

  /// No description provided for @ratingRange.
  ///
  /// In az, this message translates to:
  /// **'{min}–{max}'**
  String ratingRange(int min, int max);

  /// No description provided for @vsMeta.
  ///
  /// In az, this message translates to:
  /// **'{rank} · {rating} · Qələbə {percent}%'**
  String vsMeta(String rank, int rating, int percent);

  /// No description provided for @vsMetaNoStats.
  ///
  /// In az, this message translates to:
  /// **'{rank} · {rating}'**
  String vsMetaNoStats(String rank, int rating);

  /// No description provided for @vsLabel.
  ///
  /// In az, this message translates to:
  /// **'vs'**
  String get vsLabel;

  /// No description provided for @pointsUpper.
  ///
  /// In az, this message translates to:
  /// **'{n} XAL'**
  String pointsUpper(int n);

  /// No description provided for @rankedUpper.
  ///
  /// In az, this message translates to:
  /// **'REYTİNQLİ'**
  String get rankedUpper;

  /// No description provided for @unrankedUpper.
  ///
  /// In az, this message translates to:
  /// **'REYTİNQSİZ'**
  String get unrankedUpper;

  /// No description provided for @vsStartsIn.
  ///
  /// In az, this message translates to:
  /// **'Oyun {seconds} saniyəyə başlayır'**
  String vsStartsIn(int seconds);

  /// No description provided for @botBadge.
  ///
  /// In az, this message translates to:
  /// **'BOT'**
  String get botBadge;

  /// No description provided for @botNoRating.
  ///
  /// In az, this message translates to:
  /// **'Reytinqə təsir etmir'**
  String get botNoRating;

  /// No description provided for @botFallbackNotice.
  ///
  /// In az, this message translates to:
  /// **'30 saniyədə canlı rəqib tapılmadı, ona görə bot ilə oynayırsan. Nəticə reytinqə təsir etmir.'**
  String get botFallbackNotice;

  /// No description provided for @gameModeCasual.
  ///
  /// In az, this message translates to:
  /// **'Adi · reytinqsiz'**
  String get gameModeCasual;

  /// No description provided for @playerBotMeta.
  ///
  /// In az, this message translates to:
  /// **'{noRating} · {pip}'**
  String playerBotMeta(String noRating, String pip);

  /// No description provided for @bannerLowTime.
  ///
  /// In az, this message translates to:
  /// **'Vaxt azalır'**
  String get bannerLowTime;

  /// No description provided for @bannerTimeLeft.
  ///
  /// In az, this message translates to:
  /// **'{time} qaldı'**
  String bannerTimeLeft(String time);

  /// No description provided for @bannerOpponentOffline.
  ///
  /// In az, this message translates to:
  /// **'Rəqibin bağlantısı kəsildi'**
  String get bannerOpponentOffline;

  /// No description provided for @bannerDisconnected.
  ///
  /// In az, this message translates to:
  /// **'Bağlantı kəsildi'**
  String get bannerDisconnected;

  /// No description provided for @playerOffline.
  ///
  /// In az, this message translates to:
  /// **'Oflayn'**
  String get playerOffline;

  /// No description provided for @reconnectTitle.
  ///
  /// In az, this message translates to:
  /// **'{name} yenidən qoşulur…'**
  String reconnectTitle(String name);

  /// No description provided for @reconnectBody.
  ///
  /// In az, this message translates to:
  /// **'{time} qaldı · vaxt bitsə, qələbə sənindir'**
  String reconnectBody(String time);

  /// No description provided for @selfReconnectTitle.
  ///
  /// In az, this message translates to:
  /// **'Bağlantı bərpa olunur…'**
  String get selfReconnectTitle;

  /// No description provided for @menuFairDice.
  ///
  /// In az, this message translates to:
  /// **'Ədalətli zər'**
  String get menuFairDice;

  /// No description provided for @menuFairDiceVerify.
  ///
  /// In az, this message translates to:
  /// **'Yoxla'**
  String get menuFairDiceVerify;

  /// No description provided for @matchRatingLabel.
  ///
  /// In az, this message translates to:
  /// **'REYTİNQ'**
  String get matchRatingLabel;

  /// No description provided for @matchRatingFrom.
  ///
  /// In az, this message translates to:
  /// **'{old} idi'**
  String matchRatingFrom(int old);

  /// No description provided for @matchRatingToNext.
  ///
  /// In az, this message translates to:
  /// **'{rank} üçün {points} xal qaldı'**
  String matchRatingToNext(String rank, int points);

  /// No description provided for @ratingDeltaUp.
  ///
  /// In az, this message translates to:
  /// **'+{n}'**
  String ratingDeltaUp(int n);

  /// No description provided for @ratingDeltaDown.
  ///
  /// In az, this message translates to:
  /// **'−{n}'**
  String ratingDeltaDown(int n);

  /// No description provided for @fairTitle.
  ///
  /// In az, this message translates to:
  /// **'Ədalətli zər'**
  String get fairTitle;

  /// No description provided for @fairIntro.
  ///
  /// In az, this message translates to:
  /// **'Hər zər atışı oyundan əvvəl kilidlənən server açarından, sənin açarından və atışın sırasından hesablanır. Oyundan sonra hər atışı özün yoxlaya bilərsən.'**
  String get fairIntro;

  /// No description provided for @fairCommitment.
  ///
  /// In az, this message translates to:
  /// **'Server açarının heşi (oyundan əvvəl)'**
  String get fairCommitment;

  /// No description provided for @fairCommitmentValue.
  ///
  /// In az, this message translates to:
  /// **'sha256: {hash}'**
  String fairCommitmentValue(String hash);

  /// No description provided for @fairServerSeed.
  ///
  /// In az, this message translates to:
  /// **'Server açarı (oyundan sonra açılır)'**
  String get fairServerSeed;

  /// No description provided for @fairYourSeed.
  ///
  /// In az, this message translates to:
  /// **'Sənin açarın'**
  String get fairYourSeed;

  /// No description provided for @fairOpponentSeed.
  ///
  /// In az, this message translates to:
  /// **'Rəqibin açarı'**
  String get fairOpponentSeed;

  /// No description provided for @fairRollNumber.
  ///
  /// In az, this message translates to:
  /// **'Atış nömrəsi'**
  String get fairRollNumber;

  /// No description provided for @fairRollValue.
  ///
  /// In az, this message translates to:
  /// **'#{n} · HMAC → {a}, {b}'**
  String fairRollValue(int n, int a, int b);

  /// No description provided for @fairMatch.
  ///
  /// In az, this message translates to:
  /// **'Uyğundur · {a} – {b}'**
  String fairMatch(int a, int b);

  /// No description provided for @fairMatchSub.
  ///
  /// In az, this message translates to:
  /// **'Atış #{n} hesablanmış nəticə ilə eynidir'**
  String fairMatchSub(int n);

  /// No description provided for @fairMismatch.
  ///
  /// In az, this message translates to:
  /// **'Uyğun deyil · {a} – {b}'**
  String fairMismatch(int a, int b);

  /// No description provided for @fairMismatchSub.
  ///
  /// In az, this message translates to:
  /// **'Atış #{n} hesablanmış nəticədən fərqlidir'**
  String fairMismatchSub(int n);

  /// No description provided for @fairCommitmentMismatch.
  ///
  /// In az, this message translates to:
  /// **'Server açarı heşə uyğun gəlmir'**
  String get fairCommitmentMismatch;

  /// No description provided for @fairPending.
  ///
  /// In az, this message translates to:
  /// **'Oyundan sonra açılacaq'**
  String get fairPending;

  /// No description provided for @fairPendingNote.
  ///
  /// In az, this message translates to:
  /// **'Server açarı oyun bitəndə açılacaq. Sonra hər atışı burada yoxlaya bilərsən.'**
  String get fairPendingNote;

  /// No description provided for @fairNoRolls.
  ///
  /// In az, this message translates to:
  /// **'Hələ atış yoxdur'**
  String get fairNoRolls;

  /// No description provided for @fairCopy.
  ///
  /// In az, this message translates to:
  /// **'Kodu kopyala'**
  String get fairCopy;

  /// No description provided for @fairCheckAnother.
  ///
  /// In az, this message translates to:
  /// **'Başqa atışı yoxla'**
  String get fairCheckAnother;

  /// No description provided for @fairPickTitle.
  ///
  /// In az, this message translates to:
  /// **'Atışı seç'**
  String get fairPickTitle;

  /// No description provided for @fairRollRow.
  ///
  /// In az, this message translates to:
  /// **'#{n} · {a} – {b}'**
  String fairRollRow(int n, int a, int b);

  /// No description provided for @fairOpeningTag.
  ///
  /// In az, this message translates to:
  /// **'açılış'**
  String get fairOpeningTag;

  /// No description provided for @tierBronze.
  ///
  /// In az, this message translates to:
  /// **'Bürünc'**
  String get tierBronze;

  /// No description provided for @tierSilver.
  ///
  /// In az, this message translates to:
  /// **'Gümüş'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In az, this message translates to:
  /// **'Qızıl'**
  String get tierGold;

  /// No description provided for @tierPlatinum.
  ///
  /// In az, this message translates to:
  /// **'Platin'**
  String get tierPlatinum;

  /// No description provided for @tierDiamond.
  ///
  /// In az, this message translates to:
  /// **'Almaz'**
  String get tierDiamond;

  /// No description provided for @tierMaster.
  ///
  /// In az, this message translates to:
  /// **'Master'**
  String get tierMaster;

  /// No description provided for @tierGrandmaster.
  ///
  /// In az, this message translates to:
  /// **'Qrossmeyster'**
  String get tierGrandmaster;

  /// No description provided for @rankWithSub.
  ///
  /// In az, this message translates to:
  /// **'{tier} {sub}'**
  String rankWithSub(String tier, String sub);

  /// No description provided for @profileMeta.
  ///
  /// In az, this message translates to:
  /// **'{rank} · {rating}'**
  String profileMeta(String rank, int rating);

  /// No description provided for @statRating.
  ///
  /// In az, this message translates to:
  /// **'Reytinq'**
  String get statRating;

  /// No description provided for @statWinRate.
  ///
  /// In az, this message translates to:
  /// **'Qələbə faizi'**
  String get statWinRate;

  /// No description provided for @statMatches.
  ///
  /// In az, this message translates to:
  /// **'Matçlar'**
  String get statMatches;

  /// No description provided for @statWins.
  ///
  /// In az, this message translates to:
  /// **'Qələbələr'**
  String get statWins;

  /// No description provided for @statPercent.
  ///
  /// In az, this message translates to:
  /// **'{n}%'**
  String statPercent(int n);

  /// No description provided for @profileHistory.
  ///
  /// In az, this message translates to:
  /// **'MATÇ TARİXÇƏSİ'**
  String get profileHistory;

  /// No description provided for @historyMeta.
  ///
  /// In az, this message translates to:
  /// **'{variant} · {format} · {date}'**
  String historyMeta(String variant, String format, String date);

  /// No description provided for @variantShortAbbr.
  ///
  /// In az, this message translates to:
  /// **'Qısa'**
  String get variantShortAbbr;

  /// No description provided for @variantLongAbbr.
  ///
  /// In az, this message translates to:
  /// **'Uzun'**
  String get variantLongAbbr;

  /// No description provided for @dateToday.
  ///
  /// In az, this message translates to:
  /// **'bu gün'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In az, this message translates to:
  /// **'dünən'**
  String get dateYesterday;

  /// No description provided for @historyScore.
  ///
  /// In az, this message translates to:
  /// **'{me}–{opp}'**
  String historyScore(int me, int opp);

  /// No description provided for @profileEdit.
  ///
  /// In az, this message translates to:
  /// **'Profili redaktə et'**
  String get profileEdit;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In az, this message translates to:
  /// **'Hələ onlayn matç yoxdur'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In az, this message translates to:
  /// **'Onlayn oynadığın matçlar burada görünəcək.'**
  String get historyEmptyBody;

  /// No description provided for @profileSignedOutTitle.
  ///
  /// In az, this message translates to:
  /// **'Hesabına daxil ol'**
  String get profileSignedOutTitle;

  /// No description provided for @profileSignedOutBody.
  ///
  /// In az, this message translates to:
  /// **'Reytinqin, statistikan və matç tarixçən burada olacaq.'**
  String get profileSignedOutBody;

  /// No description provided for @nameInvalid.
  ///
  /// In az, this message translates to:
  /// **'Ad 3–20 hərf, rəqəm və ya _ olmalıdır'**
  String get nameInvalid;

  /// No description provided for @offlineBanner.
  ///
  /// In az, this message translates to:
  /// **'İnternet yoxdur · oflayn rejim'**
  String get offlineBanner;

  /// No description provided for @onlineOfflineTitle.
  ///
  /// In az, this message translates to:
  /// **'Onlayn oyun əlçatan deyil'**
  String get onlineOfflineTitle;

  /// No description provided for @onlineOfflineBody.
  ///
  /// In az, this message translates to:
  /// **'Kompüterə qarşı və bir cihazda oyun işləyir. Bağlantı qayıdanda yenidən cəhd et.'**
  String get onlineOfflineBody;

  /// No description provided for @settingsAccountPrivacy.
  ///
  /// In az, this message translates to:
  /// **'Hesab və məxfilik'**
  String get settingsAccountPrivacy;

  /// No description provided for @accountGroupAccount.
  ///
  /// In az, this message translates to:
  /// **'HESAB'**
  String get accountGroupAccount;

  /// No description provided for @accountEmail.
  ///
  /// In az, this message translates to:
  /// **'E-poçt'**
  String get accountEmail;

  /// No description provided for @accountNickname.
  ///
  /// In az, this message translates to:
  /// **'Oyunçu adı'**
  String get accountNickname;

  /// No description provided for @accountEmailAdd.
  ///
  /// In az, this message translates to:
  /// **'Əlavə et'**
  String get accountEmailAdd;

  /// No description provided for @accountSignOut.
  ///
  /// In az, this message translates to:
  /// **'Hesabdan çıx'**
  String get accountSignOut;

  /// No description provided for @accountGroupData.
  ///
  /// In az, this message translates to:
  /// **'MƏLUMAT'**
  String get accountGroupData;

  /// No description provided for @accountExport.
  ///
  /// In az, this message translates to:
  /// **'Məlumatlarımı ixrac et'**
  String get accountExport;

  /// No description provided for @accountDelete.
  ///
  /// In az, this message translates to:
  /// **'Hesabı sil'**
  String get accountDelete;

  /// No description provided for @exportTitle.
  ///
  /// In az, this message translates to:
  /// **'Məlumatlarını ixrac et'**
  String get exportTitle;

  /// No description provided for @exportBody.
  ///
  /// In az, this message translates to:
  /// **'Bütün məlumatlarını ZIP faylı kimi 24 saat ərzində {email} ünvanına göndərəcəyik.'**
  String exportBody(String email);

  /// No description provided for @exportNeedsEmail.
  ///
  /// In az, this message translates to:
  /// **'Məlumatlarını almaq üçün əvvəlcə hesabına e-poçt bağla. İrəliləyişin olduğu kimi qalır.'**
  String get exportNeedsEmail;

  /// No description provided for @exportLinkEmail.
  ///
  /// In az, this message translates to:
  /// **'E-poçt bağla'**
  String get exportLinkEmail;

  /// No description provided for @exportProfile.
  ///
  /// In az, this message translates to:
  /// **'Profil və hesab'**
  String get exportProfile;

  /// No description provided for @exportGames.
  ///
  /// In az, this message translates to:
  /// **'Matç tarixçəsi'**
  String get exportGames;

  /// No description provided for @exportPurchases.
  ///
  /// In az, this message translates to:
  /// **'Alışlar və balans'**
  String get exportPurchases;

  /// No description provided for @exportSocial.
  ///
  /// In az, this message translates to:
  /// **'Dostlar və klan'**
  String get exportSocial;

  /// No description provided for @exportFormat.
  ///
  /// In az, this message translates to:
  /// **'Format'**
  String get exportFormat;

  /// No description provided for @exportFormatValue.
  ///
  /// In az, this message translates to:
  /// **'ZIP · JSON'**
  String get exportFormatValue;

  /// No description provided for @exportStart.
  ///
  /// In az, this message translates to:
  /// **'İxracı başlat'**
  String get exportStart;

  /// No description provided for @exportSent.
  ///
  /// In az, this message translates to:
  /// **'{email} ünvanına göndərildi'**
  String exportSent(String email);

  /// No description provided for @deleteTitle.
  ///
  /// In az, this message translates to:
  /// **'Hesab silinsin?'**
  String get deleteTitle;

  /// No description provided for @deleteItemRating.
  ///
  /// In az, this message translates to:
  /// **'Reytinq ({rating}), dərəcə və bütün matç tarixçəsi'**
  String deleteItemRating(int rating);

  /// No description provided for @deleteItemHistory.
  ///
  /// In az, this message translates to:
  /// **'Profil və bütün matç tarixçəsi'**
  String get deleteItemHistory;

  /// No description provided for @deleteIrreversible.
  ///
  /// In az, this message translates to:
  /// **'Hesab 30 gün sonra tamamilə silinir. Bu müddətdə daxil olsan, silinmə ləğv olunur.'**
  String get deleteIrreversible;

  /// No description provided for @deleteConfirmLabel.
  ///
  /// In az, this message translates to:
  /// **'Təsdiq üçün {word} yaz'**
  String deleteConfirmLabel(String word);

  /// No description provided for @deleteConfirmWord.
  ///
  /// In az, this message translates to:
  /// **'SİL'**
  String get deleteConfirmWord;

  /// No description provided for @setupOnlineTitle.
  ///
  /// In az, this message translates to:
  /// **'Onlayn oyun'**
  String get setupOnlineTitle;

  /// No description provided for @setupTimeLabel.
  ///
  /// In az, this message translates to:
  /// **'VAXT NƏZARƏTİ'**
  String get setupTimeLabel;

  /// No description provided for @timeBlitz.
  ///
  /// In az, this message translates to:
  /// **'Blits'**
  String get timeBlitz;

  /// No description provided for @timeRapid.
  ///
  /// In az, this message translates to:
  /// **'Sürətli'**
  String get timeRapid;

  /// No description provided for @timeClassic.
  ///
  /// In az, this message translates to:
  /// **'Klassik'**
  String get timeClassic;

  /// No description provided for @timeDaily.
  ///
  /// In az, this message translates to:
  /// **'Gündəlik'**
  String get timeDaily;

  /// Time control with its clock, e.g. "Blits 1+8s" (challenge rows, join screen).
  ///
  /// In az, this message translates to:
  /// **'{name} {clock}'**
  String timeControlWithClock(String name, String clock);

  /// No description provided for @timeValue.
  ///
  /// In az, this message translates to:
  /// **'{minutes} dəq + {delay}s'**
  String timeValue(int minutes, int delay);

  /// No description provided for @setupRated.
  ///
  /// In az, this message translates to:
  /// **'Reytinqli'**
  String get setupRated;

  /// No description provided for @setupRatedSub.
  ///
  /// In az, this message translates to:
  /// **'Reytinqin: {rating}'**
  String setupRatedSub(int rating);

  /// No description provided for @setupFindOpponent.
  ///
  /// In az, this message translates to:
  /// **'Rəqib axtar'**
  String get setupFindOpponent;

  /// No description provided for @tabStore.
  ///
  /// In az, this message translates to:
  /// **'Mağaza'**
  String get tabStore;

  /// No description provided for @lockerTitle.
  ///
  /// In az, this message translates to:
  /// **'Dolab'**
  String get lockerTitle;

  /// No description provided for @loadoutName.
  ///
  /// In az, this message translates to:
  /// **'Dəst {n}'**
  String loadoutName(int n);

  /// No description provided for @lockerSave.
  ///
  /// In az, this message translates to:
  /// **'Saxla'**
  String get lockerSave;

  /// No description provided for @lockerSaved.
  ///
  /// In az, this message translates to:
  /// **'Dəst yadda saxlanıldı'**
  String get lockerSaved;

  /// No description provided for @lockerAddLoadout.
  ///
  /// In az, this message translates to:
  /// **'Yeni dəst'**
  String get lockerAddLoadout;

  /// No description provided for @lockerRenameTitle.
  ///
  /// In az, this message translates to:
  /// **'Dəstin adı'**
  String get lockerRenameTitle;

  /// No description provided for @lockerRename.
  ///
  /// In az, this message translates to:
  /// **'Adını dəyiş'**
  String get lockerRename;

  /// No description provided for @lockerDelete.
  ///
  /// In az, this message translates to:
  /// **'Dəsti sil'**
  String get lockerDelete;

  /// No description provided for @lockerLoadoutLimit.
  ///
  /// In az, this message translates to:
  /// **'Ən çox {max} dəst ola bilər.'**
  String lockerLoadoutLimit(int max);

  /// No description provided for @lockerEmptyTitle.
  ///
  /// In az, this message translates to:
  /// **'Burada hələ heç nə yoxdur'**
  String get lockerEmptyTitle;

  /// No description provided for @lockerEmptyBody.
  ///
  /// In az, this message translates to:
  /// **'Bu bölməyə yeni əşyalar tezliklə gələcək.'**
  String get lockerEmptyBody;

  /// No description provided for @lockerShowOpponentCosmetics.
  ///
  /// In az, this message translates to:
  /// **'Rəqibin kosmetikasını göstər'**
  String get lockerShowOpponentCosmetics;

  /// No description provided for @categoryBoard.
  ///
  /// In az, this message translates to:
  /// **'Taxta'**
  String get categoryBoard;

  /// No description provided for @categoryCheckers.
  ///
  /// In az, this message translates to:
  /// **'Daşlar'**
  String get categoryCheckers;

  /// No description provided for @categoryDice.
  ///
  /// In az, this message translates to:
  /// **'Zər'**
  String get categoryDice;

  /// No description provided for @categoryDiceCup.
  ///
  /// In az, this message translates to:
  /// **'Zər qabı'**
  String get categoryDiceCup;

  /// No description provided for @categoryCube.
  ///
  /// In az, this message translates to:
  /// **'İkiqat kub'**
  String get categoryCube;

  /// No description provided for @categoryBackground.
  ///
  /// In az, this message translates to:
  /// **'Fon'**
  String get categoryBackground;

  /// No description provided for @categorySounds.
  ///
  /// In az, this message translates to:
  /// **'Səslər'**
  String get categorySounds;

  /// No description provided for @categoryEmote.
  ///
  /// In az, this message translates to:
  /// **'Emote'**
  String get categoryEmote;

  /// No description provided for @categoryAvatarFrame.
  ///
  /// In az, this message translates to:
  /// **'Avatar çərçivəsi'**
  String get categoryAvatarFrame;

  /// No description provided for @categoryTitle.
  ///
  /// In az, this message translates to:
  /// **'Titul'**
  String get categoryTitle;

  /// No description provided for @categoryWinEffect.
  ///
  /// In az, this message translates to:
  /// **'Qələbə effekti'**
  String get categoryWinEffect;

  /// No description provided for @categoryOther.
  ///
  /// In az, this message translates to:
  /// **'Digər'**
  String get categoryOther;

  /// No description provided for @itemEquipped.
  ///
  /// In az, this message translates to:
  /// **'Taxılıb'**
  String get itemEquipped;

  /// No description provided for @itemPreviewing.
  ///
  /// In az, this message translates to:
  /// **'Sınanır'**
  String get itemPreviewing;

  /// No description provided for @itemOwned.
  ///
  /// In az, this message translates to:
  /// **'Sahibsən'**
  String get itemOwned;

  /// No description provided for @itemSeason.
  ///
  /// In az, this message translates to:
  /// **'Sezon bileti'**
  String get itemSeason;

  /// No description provided for @itemTournamentReward.
  ///
  /// In az, this message translates to:
  /// **'Turnir mükafatı'**
  String get itemTournamentReward;

  /// No description provided for @itemAchievementReward.
  ///
  /// In az, this message translates to:
  /// **'Nailiyyət mükafatı'**
  String get itemAchievementReward;

  /// No description provided for @rarityCommon.
  ///
  /// In az, this message translates to:
  /// **'Adi'**
  String get rarityCommon;

  /// No description provided for @rarityRare.
  ///
  /// In az, this message translates to:
  /// **'Nadir'**
  String get rarityRare;

  /// No description provided for @rarityEpic.
  ///
  /// In az, this message translates to:
  /// **'Epik'**
  String get rarityEpic;

  /// No description provided for @rarityLegendary.
  ///
  /// In az, this message translates to:
  /// **'Əfsanəvi'**
  String get rarityLegendary;

  /// No description provided for @raritySeasonal.
  ///
  /// In az, this message translates to:
  /// **'Mövsümi'**
  String get raritySeasonal;

  /// No description provided for @rarityTournament.
  ///
  /// In az, this message translates to:
  /// **'Turnir'**
  String get rarityTournament;

  /// Uppercase overline; stored uppercased (no toUpperCase).
  ///
  /// In az, this message translates to:
  /// **'ADİ'**
  String get rarityCommonUpper;

  /// No description provided for @rarityRareUpper.
  ///
  /// In az, this message translates to:
  /// **'NADİR'**
  String get rarityRareUpper;

  /// No description provided for @rarityEpicUpper.
  ///
  /// In az, this message translates to:
  /// **'EPİK'**
  String get rarityEpicUpper;

  /// No description provided for @rarityLegendaryUpper.
  ///
  /// In az, this message translates to:
  /// **'ƏFSANƏVİ'**
  String get rarityLegendaryUpper;

  /// No description provided for @raritySeasonalUpper.
  ///
  /// In az, this message translates to:
  /// **'MÖVSÜMİ'**
  String get raritySeasonalUpper;

  /// No description provided for @rarityTournamentUpper.
  ///
  /// In az, this message translates to:
  /// **'TURNİR'**
  String get rarityTournamentUpper;

  /// No description provided for @itemObtainTitle.
  ///
  /// In az, this message translates to:
  /// **'NECƏ ƏLDƏ EDİLİR'**
  String get itemObtainTitle;

  /// No description provided for @obtainStore.
  ///
  /// In az, this message translates to:
  /// **'Mağaza'**
  String get obtainStore;

  /// No description provided for @obtainSeasonPremium.
  ///
  /// In az, this message translates to:
  /// **'Sezon bileti · Premium'**
  String get obtainSeasonPremium;

  /// No description provided for @obtainTournament.
  ///
  /// In az, this message translates to:
  /// **'Turnir'**
  String get obtainTournament;

  /// No description provided for @obtainAchievement.
  ///
  /// In az, this message translates to:
  /// **'Nailiyyət'**
  String get obtainAchievement;

  /// No description provided for @obtainDefault.
  ///
  /// In az, this message translates to:
  /// **'Standart dəst'**
  String get obtainDefault;

  /// No description provided for @obtainFree.
  ///
  /// In az, this message translates to:
  /// **'Pulsuz'**
  String get obtainFree;

  /// amount = count with thousands separators.
  ///
  /// In az, this message translates to:
  /// **'{count, plural, other{{amount} sikkə}}'**
  String priceCoins(int count, String amount);

  /// Paid currency (ADR-023): Yaqut / Rubies / Рубины / Yakut.
  ///
  /// In az, this message translates to:
  /// **'{count, plural, other{{amount} yaqut}}'**
  String priceGems(int count, String amount);

  /// No description provided for @itemTry.
  ///
  /// In az, this message translates to:
  /// **'Sına'**
  String get itemTry;

  /// No description provided for @itemBuy.
  ///
  /// In az, this message translates to:
  /// **'Al'**
  String get itemBuy;

  /// No description provided for @itemEquip.
  ///
  /// In az, this message translates to:
  /// **'Tax'**
  String get itemEquip;

  /// No description provided for @storeFeaturedOverline.
  ///
  /// In az, this message translates to:
  /// **'TÖVSİYƏ · {days} GÜN'**
  String storeFeaturedOverline(int days);

  /// No description provided for @storeDailyTitle.
  ///
  /// In az, this message translates to:
  /// **'GÜNLÜK SEÇİM'**
  String get storeDailyTitle;

  /// No description provided for @storeRefreshesIn.
  ///
  /// In az, this message translates to:
  /// **'Yenilənir {time}'**
  String storeRefreshesIn(String time);

  /// No description provided for @storeGemsTitle.
  ///
  /// In az, this message translates to:
  /// **'YAQUT'**
  String get storeGemsTitle;

  /// No description provided for @storePackUnavailable.
  ///
  /// In az, this message translates to:
  /// **'Yaqut almaq hələ mümkün deyil. Mağaza hesabları qoşulanda açılacaq.'**
  String get storePackUnavailable;

  /// No description provided for @storePackAdded.
  ///
  /// In az, this message translates to:
  /// **'+{amount} yaqut balansına əlavə olundu'**
  String storePackAdded(String amount);

  /// No description provided for @accountNeededTitle.
  ///
  /// In az, this message translates to:
  /// **'Hesabına daxil ol'**
  String get accountNeededTitle;

  /// No description provided for @accountNeededBody.
  ///
  /// In az, this message translates to:
  /// **'Sikkə qazanmaq, dəst almaq və tapşırıqları görmək üçün hesab lazımdır.'**
  String get accountNeededBody;

  /// No description provided for @purchasePrice.
  ///
  /// In az, this message translates to:
  /// **'Qiymət'**
  String get purchasePrice;

  /// No description provided for @purchaseBalanceAfter.
  ///
  /// In az, this message translates to:
  /// **'Balans sonra'**
  String get purchaseBalanceAfter;

  /// No description provided for @purchaseShortfall.
  ///
  /// In az, this message translates to:
  /// **'−{amount} çatmır'**
  String purchaseShortfall(String amount);

  /// No description provided for @purchaseNotEnoughGems.
  ///
  /// In az, this message translates to:
  /// **'Balansın kifayət etmir. {pack} yaqut paketini al və əşyanı birbaşa aç.'**
  String purchaseNotEnoughGems(String pack);

  /// No description provided for @purchaseNotEnoughCoins.
  ///
  /// In az, this message translates to:
  /// **'Sikkən kifayət etmir. Sikkə yalnız qazanılır: oyna və tapşırıqları bitir.'**
  String get purchaseNotEnoughCoins;

  /// No description provided for @purchaseBuyPack.
  ///
  /// In az, this message translates to:
  /// **'{amount} yaqut al'**
  String purchaseBuyPack(String amount);

  /// No description provided for @purchaseToMissions.
  ///
  /// In az, this message translates to:
  /// **'Tapşırıqlara bax'**
  String get purchaseToMissions;

  /// No description provided for @purchaseFailed.
  ///
  /// In az, this message translates to:
  /// **'Alış alınmadı. Yenidən cəhd et.'**
  String get purchaseFailed;

  /// No description provided for @purchaseAlreadyOwned.
  ///
  /// In az, this message translates to:
  /// **'Bu əşya artıq səndədir.'**
  String get purchaseAlreadyOwned;

  /// No description provided for @purchaseNotForSale.
  ///
  /// In az, this message translates to:
  /// **'Bu əşya satılmır.'**
  String get purchaseNotForSale;

  /// No description provided for @purchaseOwnedTitle.
  ///
  /// In az, this message translates to:
  /// **'{item} sənindir'**
  String purchaseOwnedTitle(String item);

  /// No description provided for @purchaseReceipt.
  ///
  /// In az, this message translates to:
  /// **'Qəbz'**
  String get purchaseReceipt;

  /// No description provided for @purchasePaid.
  ///
  /// In az, this message translates to:
  /// **'Ödəniş'**
  String get purchasePaid;

  /// No description provided for @purchaseClose.
  ///
  /// In az, this message translates to:
  /// **'Bağla'**
  String get purchaseClose;

  /// No description provided for @purchaseEquipNow.
  ///
  /// In az, this message translates to:
  /// **'İndi tax'**
  String get purchaseEquipNow;

  /// No description provided for @missionsTitle.
  ///
  /// In az, this message translates to:
  /// **'Tapşırıqlar'**
  String get missionsTitle;

  /// No description provided for @streakCardTitle.
  ///
  /// In az, this message translates to:
  /// **'Giriş seriyası · {days} gün'**
  String streakCardTitle(int days);

  /// No description provided for @streakTomorrow.
  ///
  /// In az, this message translates to:
  /// **'Sabah: +{coins}'**
  String streakTomorrow(int coins);

  /// No description provided for @missionsDaily.
  ///
  /// In az, this message translates to:
  /// **'Günlük'**
  String get missionsDaily;

  /// No description provided for @missionsWeekly.
  ///
  /// In az, this message translates to:
  /// **'Həftəlik'**
  String get missionsWeekly;

  /// No description provided for @missionsResetsIn.
  ///
  /// In az, this message translates to:
  /// **'Yenilənməyə {time}'**
  String missionsResetsIn(String time);

  /// No description provided for @missionProgress.
  ///
  /// In az, this message translates to:
  /// **'{done} / {target}'**
  String missionProgress(int done, int target);

  /// No description provided for @missionProgressCompact.
  ///
  /// In az, this message translates to:
  /// **'{done}/{target}'**
  String missionProgressCompact(int done, int target);

  /// No description provided for @missionReward.
  ///
  /// In az, this message translates to:
  /// **'+{n}'**
  String missionReward(int n);

  /// No description provided for @missionClaim.
  ///
  /// In az, this message translates to:
  /// **'Al'**
  String get missionClaim;

  /// No description provided for @missionClaimed.
  ///
  /// In az, this message translates to:
  /// **'Alındı'**
  String get missionClaimed;

  /// No description provided for @missionDoubles.
  ///
  /// In az, this message translates to:
  /// **'{n} dubl at'**
  String missionDoubles(int n);

  /// No description provided for @missionRankedWin.
  ///
  /// In az, this message translates to:
  /// **'{n, plural, =1{Reytinq oyunu qazan} other{{n} reytinq oyunu qazan}}'**
  String missionRankedWin(int n);

  /// No description provided for @missionCubeTakeWin.
  ///
  /// In az, this message translates to:
  /// **'Kubu qəbul et və qazan'**
  String get missionCubeTakeWin;

  /// No description provided for @missionPlayLong.
  ///
  /// In az, this message translates to:
  /// **'Uzun nərd oyna'**
  String get missionPlayLong;

  /// No description provided for @missionMars.
  ///
  /// In az, this message translates to:
  /// **'{n} oyunda mars et'**
  String missionMars(int n);

  /// No description provided for @missionPlay.
  ///
  /// In az, this message translates to:
  /// **'{n} oyun oyna'**
  String missionPlay(int n);

  /// No description provided for @missionWin.
  ///
  /// In az, this message translates to:
  /// **'{n} oyun qazan'**
  String missionWin(int n);

  /// No description provided for @missionGeneric.
  ///
  /// In az, this message translates to:
  /// **'Tapşırıq'**
  String get missionGeneric;

  /// No description provided for @dailyBonusTitle.
  ///
  /// In az, this message translates to:
  /// **'Günlük bonus · +{coins}'**
  String dailyBonusTitle(int coins);

  /// No description provided for @dailyBonusBody.
  ///
  /// In az, this message translates to:
  /// **'Bütün günlük tapşırıqları bitir · {done} / {total}'**
  String dailyBonusBody(int done, int total);

  /// No description provided for @streakOverline.
  ///
  /// In az, this message translates to:
  /// **'GİRİŞ SERİYASI'**
  String get streakOverline;

  /// No description provided for @streakDay1.
  ///
  /// In az, this message translates to:
  /// **'1-ci gün'**
  String get streakDay1;

  /// No description provided for @streakDay2.
  ///
  /// In az, this message translates to:
  /// **'2-ci gün'**
  String get streakDay2;

  /// No description provided for @streakDay3.
  ///
  /// In az, this message translates to:
  /// **'3-cü gün'**
  String get streakDay3;

  /// No description provided for @streakDay4.
  ///
  /// In az, this message translates to:
  /// **'4-cü gün'**
  String get streakDay4;

  /// No description provided for @streakDay5.
  ///
  /// In az, this message translates to:
  /// **'5-ci gün'**
  String get streakDay5;

  /// No description provided for @streakDay6.
  ///
  /// In az, this message translates to:
  /// **'6-cı gün'**
  String get streakDay6;

  /// No description provided for @streakDay7.
  ///
  /// In az, this message translates to:
  /// **'7-ci gün'**
  String get streakDay7;

  /// No description provided for @streakBody.
  ///
  /// In az, this message translates to:
  /// **'Hər gün daxil ol, 7-ci gün böyük bonusu al.'**
  String get streakBody;

  /// No description provided for @streakClaim.
  ///
  /// In az, this message translates to:
  /// **'+{coins} sikkəni al'**
  String streakClaim(int coins);

  /// No description provided for @streakResetNote.
  ///
  /// In az, this message translates to:
  /// **'Bir gün buraxsan, seriya 1-ci gündən başlayır.'**
  String get streakResetNote;

  /// No description provided for @levelUpOverline.
  ///
  /// In az, this message translates to:
  /// **'SƏVİYYƏ {from} → {to}'**
  String levelUpOverline(int from, int to);

  /// No description provided for @levelUpTitle.
  ///
  /// In az, this message translates to:
  /// **'Səviyyə yüksəldi'**
  String get levelUpTitle;

  /// No description provided for @xpProgress.
  ///
  /// In az, this message translates to:
  /// **'{xp} / {next} XP'**
  String xpProgress(String xp, String next);

  /// No description provided for @homeLevel.
  ///
  /// In az, this message translates to:
  /// **'Səv. {n}'**
  String homeLevel(int n);

  /// No description provided for @homeDailyMission.
  ///
  /// In az, this message translates to:
  /// **'GÜNLÜK MİSSİYA · {done}/{total}'**
  String homeDailyMission(int done, int total);

  /// No description provided for @homeMissionsDone.
  ///
  /// In az, this message translates to:
  /// **'Bu günün tapşırıqları bitdi'**
  String get homeMissionsDone;

  /// No description provided for @matchCoins.
  ///
  /// In az, this message translates to:
  /// **'sikkə'**
  String get matchCoins;

  /// No description provided for @matchXp.
  ///
  /// In az, this message translates to:
  /// **'təcrübə'**
  String get matchXp;

  /// No description provided for @xpBadge.
  ///
  /// In az, this message translates to:
  /// **'XP'**
  String get xpBadge;

  /// No description provided for @achievementsTitle.
  ///
  /// In az, this message translates to:
  /// **'Nailiyyətlər'**
  String get achievementsTitle;

  /// No description provided for @achievementsCount.
  ///
  /// In az, this message translates to:
  /// **'{done} / {total}'**
  String achievementsCount(int done, int total);

  /// No description provided for @titlesOverline.
  ///
  /// In az, this message translates to:
  /// **'TİTUL'**
  String get titlesOverline;

  /// No description provided for @titlesNone.
  ///
  /// In az, this message translates to:
  /// **'Titulsuz'**
  String get titlesNone;

  /// No description provided for @titlesLocked.
  ///
  /// In az, this message translates to:
  /// **'Nailiyyətlə açılır'**
  String get titlesLocked;

  /// No description provided for @achFirstWin.
  ///
  /// In az, this message translates to:
  /// **'İlk qələbə'**
  String get achFirstWin;

  /// No description provided for @achWins10.
  ///
  /// In az, this message translates to:
  /// **'10 qələbə'**
  String get achWins10;

  /// No description provided for @achWins100.
  ///
  /// In az, this message translates to:
  /// **'100 qələbə'**
  String get achWins100;

  /// No description provided for @achGames1000.
  ///
  /// In az, this message translates to:
  /// **'1000 oyun'**
  String get achGames1000;

  /// No description provided for @achMars10.
  ///
  /// In az, this message translates to:
  /// **'Mars ustası'**
  String get achMars10;

  /// No description provided for @achRankedWins25.
  ///
  /// In az, this message translates to:
  /// **'Reytinq döyüşçüsü'**
  String get achRankedWins25;

  /// No description provided for @achStreak10.
  ///
  /// In az, this message translates to:
  /// **'10 günlük seriya'**
  String get achStreak10;

  /// No description provided for @achGeneric.
  ///
  /// In az, this message translates to:
  /// **'Nailiyyət'**
  String get achGeneric;

  /// No description provided for @coinsSemantic.
  ///
  /// In az, this message translates to:
  /// **'Sikkə: {amount}'**
  String coinsSemantic(String amount);

  /// No description provided for @gemsSemantic.
  ///
  /// In az, this message translates to:
  /// **'Yaqut: {amount}'**
  String gemsSemantic(String amount);

  /// No description provided for @emoteWheelHint.
  ///
  /// In az, this message translates to:
  /// **'Sürüşdür\nvə burax'**
  String get emoteWheelHint;

  /// No description provided for @emoteButton.
  ///
  /// In az, this message translates to:
  /// **'Emosiya göndər'**
  String get emoteButton;

  /// No description provided for @gameChat.
  ///
  /// In az, this message translates to:
  /// **'Söhbət'**
  String get gameChat;

  /// No description provided for @emoteSmile.
  ///
  /// In az, this message translates to:
  /// **'Təbəssüm'**
  String get emoteSmile;

  /// No description provided for @emoteLaugh.
  ///
  /// In az, this message translates to:
  /// **'Gülüş'**
  String get emoteLaugh;

  /// No description provided for @emoteWow.
  ///
  /// In az, this message translates to:
  /// **'Heyrət'**
  String get emoteWow;

  /// No description provided for @emoteThink.
  ///
  /// In az, this message translates to:
  /// **'Düşünürəm'**
  String get emoteThink;

  /// No description provided for @emoteSad.
  ///
  /// In az, this message translates to:
  /// **'Kədər'**
  String get emoteSad;

  /// No description provided for @emoteAngry.
  ///
  /// In az, this message translates to:
  /// **'Hirs'**
  String get emoteAngry;

  /// No description provided for @emoteTea.
  ///
  /// In az, this message translates to:
  /// **'Çay'**
  String get emoteTea;

  /// No description provided for @emoteClap.
  ///
  /// In az, this message translates to:
  /// **'Əhsən'**
  String get emoteClap;

  /// No description provided for @phraseHello.
  ///
  /// In az, this message translates to:
  /// **'Salam!'**
  String get phraseHello;

  /// No description provided for @phraseGoodLuck.
  ///
  /// In az, this message translates to:
  /// **'Uğurlar'**
  String get phraseGoodLuck;

  /// No description provided for @phraseNiceMove.
  ///
  /// In az, this message translates to:
  /// **'Əla gediş'**
  String get phraseNiceMove;

  /// No description provided for @phraseDice.
  ///
  /// In az, this message translates to:
  /// **'Zərlər…'**
  String get phraseDice;

  /// No description provided for @phraseThanks.
  ///
  /// In az, this message translates to:
  /// **'Təşəkkürlər'**
  String get phraseThanks;

  /// No description provided for @phraseGoodGame.
  ///
  /// In az, this message translates to:
  /// **'Yaxşı oyun'**
  String get phraseGoodGame;

  /// No description provided for @phraseNiceRoll.
  ///
  /// In az, this message translates to:
  /// **'Gözəl zər'**
  String get phraseNiceRoll;

  /// No description provided for @phraseSorry.
  ///
  /// In az, this message translates to:
  /// **'Bağışla'**
  String get phraseSorry;

  /// No description provided for @tabClan.
  ///
  /// In az, this message translates to:
  /// **'Klan'**
  String get tabClan;

  /// No description provided for @modePrivateRoom.
  ///
  /// In az, this message translates to:
  /// **'Şəxsi otaq'**
  String get modePrivateRoom;

  /// No description provided for @modeFriends.
  ///
  /// In az, this message translates to:
  /// **'Dostlar'**
  String get modeFriends;

  /// No description provided for @socialAccountBody.
  ///
  /// In az, this message translates to:
  /// **'Dostlar, klanlar və şəxsi otaqlar üçün hesab lazımdır.'**
  String get socialAccountBody;

  /// No description provided for @send.
  ///
  /// In az, this message translates to:
  /// **'Göndər'**
  String get send;

  /// No description provided for @close.
  ///
  /// In az, this message translates to:
  /// **'Bağla'**
  String get close;

  /// No description provided for @friendsTitle.
  ///
  /// In az, this message translates to:
  /// **'Dostlar'**
  String get friendsTitle;

  /// No description provided for @friendsAdd.
  ///
  /// In az, this message translates to:
  /// **'Əlavə et'**
  String get friendsAdd;

  /// No description provided for @friendsSection.
  ///
  /// In az, this message translates to:
  /// **'DOSTLAR'**
  String get friendsSection;

  /// No description provided for @presenceOnline.
  ///
  /// In az, this message translates to:
  /// **'Onlayn'**
  String get presenceOnline;

  /// No description provided for @presenceInGame.
  ///
  /// In az, this message translates to:
  /// **'Oyunda'**
  String get presenceInGame;

  /// No description provided for @presenceOffline.
  ///
  /// In az, this message translates to:
  /// **'Oflayn'**
  String get presenceOffline;

  /// No description provided for @friendInvite.
  ///
  /// In az, this message translates to:
  /// **'Çağır'**
  String get friendInvite;

  /// No description provided for @friendWatch.
  ///
  /// In az, this message translates to:
  /// **'İzlə'**
  String get friendWatch;

  /// No description provided for @friendRequestsTitle.
  ///
  /// In az, this message translates to:
  /// **'SORĞULAR'**
  String get friendRequestsTitle;

  /// No description provided for @friendSentTitle.
  ///
  /// In az, this message translates to:
  /// **'GÖNDƏRİLƏNLƏR'**
  String get friendSentTitle;

  /// No description provided for @friendChallengesTitle.
  ///
  /// In az, this message translates to:
  /// **'ÇAĞIRIŞLAR'**
  String get friendChallengesTitle;

  /// No description provided for @friendAccept.
  ///
  /// In az, this message translates to:
  /// **'Qəbul et'**
  String get friendAccept;

  /// No description provided for @friendDismiss.
  ///
  /// In az, this message translates to:
  /// **'Rədd et'**
  String get friendDismiss;

  /// No description provided for @friendCancelRequest.
  ///
  /// In az, this message translates to:
  /// **'Sorğunu ləğv et'**
  String get friendCancelRequest;

  /// Friend challenge / private room summary, e.g. "Uzun nərd · 5 xal · Klassik 5+15s"; time = timeControlWithClock.
  ///
  /// In az, this message translates to:
  /// **'{variant} · {format} · {time}'**
  String challengeMeta(String variant, String format, String time);

  /// No description provided for @friendsEmptyTitle.
  ///
  /// In az, this message translates to:
  /// **'Hələ dostun yoxdur'**
  String get friendsEmptyTitle;

  /// No description provided for @friendsEmptyBody.
  ///
  /// In az, this message translates to:
  /// **'Adı ilə axtar və ya dost kodunu paylaş.'**
  String get friendsEmptyBody;

  /// No description provided for @friendInviteSent.
  ///
  /// In az, this message translates to:
  /// **'Dəvət göndərildi: {name}'**
  String friendInviteSent(String name);

  /// No description provided for @friendRemoved.
  ///
  /// In az, this message translates to:
  /// **'Dostluqdan çıxarıldı'**
  String get friendRemoved;

  /// No description provided for @metaWithClan.
  ///
  /// In az, this message translates to:
  /// **'{meta} · {clan}'**
  String metaWithClan(String meta, String clan);

  /// No description provided for @levelShort.
  ///
  /// In az, this message translates to:
  /// **'Səv. {n}'**
  String levelShort(int n);

  /// No description provided for @addFriendTitle.
  ///
  /// In az, this message translates to:
  /// **'Dost əlavə et'**
  String get addFriendTitle;

  /// No description provided for @addFriendSearchHint.
  ///
  /// In az, this message translates to:
  /// **'Ad ilə axtar'**
  String get addFriendSearchHint;

  /// No description provided for @addFriendSearchShort.
  ///
  /// In az, this message translates to:
  /// **'Ən azı 3 hərf yaz'**
  String get addFriendSearchShort;

  /// No description provided for @addFriendAction.
  ///
  /// In az, this message translates to:
  /// **'Əlavə et'**
  String get addFriendAction;

  /// No description provided for @addFriendOr.
  ///
  /// In az, this message translates to:
  /// **'və ya'**
  String get addFriendOr;

  /// No description provided for @addFriendCodeLabel.
  ///
  /// In az, this message translates to:
  /// **'DOST KODUN'**
  String get addFriendCodeLabel;

  /// No description provided for @addFriendCodeCaption.
  ///
  /// In az, this message translates to:
  /// **'Dostun bu kodu daxil etsin'**
  String get addFriendCodeCaption;

  /// No description provided for @addFriendCopyCode.
  ///
  /// In az, this message translates to:
  /// **'Kodu kopyala'**
  String get addFriendCopyCode;

  /// No description provided for @addFriendEnterCode.
  ///
  /// In az, this message translates to:
  /// **'KODLA ƏLAVƏ ET'**
  String get addFriendEnterCode;

  /// No description provided for @addFriendCodeHint.
  ///
  /// In az, this message translates to:
  /// **'8 simvollu kod'**
  String get addFriendCodeHint;

  /// No description provided for @friendRequested.
  ///
  /// In az, this message translates to:
  /// **'Göndərildi'**
  String get friendRequested;

  /// No description provided for @friendAccepted.
  ///
  /// In az, this message translates to:
  /// **'Dostsunuz'**
  String get friendAccepted;

  /// No description provided for @friendErrNotFound.
  ///
  /// In az, this message translates to:
  /// **'Oyunçu tapılmadı'**
  String get friendErrNotFound;

  /// No description provided for @friendErrBlocked.
  ///
  /// In az, this message translates to:
  /// **'Bu oyunçu ilə əlaqə mümkün deyil'**
  String get friendErrBlocked;

  /// No description provided for @friendErrAlready.
  ///
  /// In az, this message translates to:
  /// **'Artıq dostsunuz'**
  String get friendErrAlready;

  /// No description provided for @friendErrPending.
  ///
  /// In az, this message translates to:
  /// **'Sorğu artıq göndərilib'**
  String get friendErrPending;

  /// No description provided for @friendErrLimit.
  ///
  /// In az, this message translates to:
  /// **'Dost limiti dolub ({max})'**
  String friendErrLimit(int max);

  /// No description provided for @roomTitle.
  ///
  /// In az, this message translates to:
  /// **'Şəxsi otaq'**
  String get roomTitle;

  /// No description provided for @roomCodeLabel.
  ///
  /// In az, this message translates to:
  /// **'OTAQ KODU'**
  String get roomCodeLabel;

  /// No description provided for @roomCopy.
  ///
  /// In az, this message translates to:
  /// **'Kopyala'**
  String get roomCopy;

  /// No description provided for @roomShare.
  ///
  /// In az, this message translates to:
  /// **'Paylaş'**
  String get roomShare;

  /// No description provided for @roomShareText.
  ///
  /// In az, this message translates to:
  /// **'NardArena-da mənimlə oyna. Otaq kodu: {code}'**
  String roomShareText(String code);

  /// No description provided for @roomWaiting.
  ///
  /// In az, this message translates to:
  /// **'Dost gözlənilir…'**
  String get roomWaiting;

  /// No description provided for @roomExpiry.
  ///
  /// In az, this message translates to:
  /// **'Bitir: {time} · {left} qaldı'**
  String roomExpiry(String time, String left);

  /// No description provided for @roomInvited.
  ///
  /// In az, this message translates to:
  /// **'Dəvət: {name}'**
  String roomInvited(String name);

  /// No description provided for @roomSettingVariant.
  ///
  /// In az, this message translates to:
  /// **'Variant'**
  String get roomSettingVariant;

  /// No description provided for @roomSettingFormat.
  ///
  /// In az, this message translates to:
  /// **'Format'**
  String get roomSettingFormat;

  /// No description provided for @roomSettingTime.
  ///
  /// In az, this message translates to:
  /// **'Vaxt'**
  String get roomSettingTime;

  /// No description provided for @roomSettingRating.
  ///
  /// In az, this message translates to:
  /// **'Reytinq'**
  String get roomSettingRating;

  /// No description provided for @roomUnrated.
  ///
  /// In az, this message translates to:
  /// **'Təsir etmir'**
  String get roomUnrated;

  /// No description provided for @roomExpired.
  ///
  /// In az, this message translates to:
  /// **'Kodun vaxtı bitdi'**
  String get roomExpired;

  /// No description provided for @roomNewCode.
  ///
  /// In az, this message translates to:
  /// **'Yeni kod'**
  String get roomNewCode;

  /// No description provided for @roomCreate.
  ///
  /// In az, this message translates to:
  /// **'Otaq yarat'**
  String get roomCreate;

  /// No description provided for @roomCreateSub.
  ///
  /// In az, this message translates to:
  /// **'Kodu dosta göndər, o qoşulan kimi oyun başlayır'**
  String get roomCreateSub;

  /// No description provided for @roomJoinByCode.
  ///
  /// In az, this message translates to:
  /// **'Koda qoşul'**
  String get roomJoinByCode;

  /// No description provided for @roomJoinByCodeSub.
  ///
  /// In az, this message translates to:
  /// **'Dostunun otağına 6 simvollu kodla gir'**
  String get roomJoinByCodeSub;

  /// No description provided for @roomJoin.
  ///
  /// In az, this message translates to:
  /// **'Qoşul'**
  String get roomJoin;

  /// No description provided for @roomJoinTitle.
  ///
  /// In az, this message translates to:
  /// **'Otağa qoşul'**
  String get roomJoinTitle;

  /// No description provided for @roomJoinHint.
  ///
  /// In az, this message translates to:
  /// **'Dostunun göndərdiyi kodu yaz'**
  String get roomJoinHint;

  /// No description provided for @roomJoining.
  ///
  /// In az, this message translates to:
  /// **'Qoşulur…'**
  String get roomJoining;

  /// No description provided for @roomCreating.
  ///
  /// In az, this message translates to:
  /// **'Otaq yaradılır…'**
  String get roomCreating;

  /// No description provided for @roomNotFound.
  ///
  /// In az, this message translates to:
  /// **'Otaq tapılmadı və ya vaxtı bitib'**
  String get roomNotFound;

  /// No description provided for @roomInviteFriend.
  ///
  /// In az, this message translates to:
  /// **'Dostu çağır'**
  String get roomInviteFriend;

  /// No description provided for @roomPickFriend.
  ///
  /// In az, this message translates to:
  /// **'Kimi çağırırsan?'**
  String get roomPickFriend;

  /// No description provided for @roomCancelTitle.
  ///
  /// In az, this message translates to:
  /// **'Otaq bağlansın?'**
  String get roomCancelTitle;

  /// No description provided for @roomCancelBody.
  ///
  /// In az, this message translates to:
  /// **'Kod etibarsız olacaq.'**
  String get roomCancelBody;

  /// No description provided for @roomCancelConfirm.
  ///
  /// In az, this message translates to:
  /// **'Bağla'**
  String get roomCancelConfirm;

  /// No description provided for @spectatorLive.
  ///
  /// In az, this message translates to:
  /// **'İZLƏYİCİ'**
  String get spectatorLive;

  /// No description provided for @spectatorLeave.
  ///
  /// In az, this message translates to:
  /// **'Çıx'**
  String get spectatorLeave;

  /// No description provided for @spectatorNoChat.
  ///
  /// In az, this message translates to:
  /// **'Oyunçuların emosiyaları burada görünür'**
  String get spectatorNoChat;

  /// No description provided for @spectatorUnavailable.
  ///
  /// In az, this message translates to:
  /// **'Bu oyunu izləmək mümkün deyil'**
  String get spectatorUnavailable;

  /// No description provided for @spectatorGameOver.
  ///
  /// In az, this message translates to:
  /// **'Qalib: {name} · {score}'**
  String spectatorGameOver(String name, String score);

  /// No description provided for @spectatorWaiting.
  ///
  /// In az, this message translates to:
  /// **'Oyun yüklənir…'**
  String get spectatorWaiting;

  /// No description provided for @playerMenuAddFriend.
  ///
  /// In az, this message translates to:
  /// **'Dost əlavə et'**
  String get playerMenuAddFriend;

  /// No description provided for @playerMenuInvite.
  ///
  /// In az, this message translates to:
  /// **'Oyuna çağır'**
  String get playerMenuInvite;

  /// No description provided for @playerMenuMute.
  ///
  /// In az, this message translates to:
  /// **'Söhbəti səssizə al'**
  String get playerMenuMute;

  /// No description provided for @playerMenuUnmute.
  ///
  /// In az, this message translates to:
  /// **'Səsini aç'**
  String get playerMenuUnmute;

  /// No description provided for @playerMenuReport.
  ///
  /// In az, this message translates to:
  /// **'Şikayət et'**
  String get playerMenuReport;

  /// No description provided for @playerMenuBlock.
  ///
  /// In az, this message translates to:
  /// **'Blokla'**
  String get playerMenuBlock;

  /// No description provided for @playerMenuUnblock.
  ///
  /// In az, this message translates to:
  /// **'Bloku götür'**
  String get playerMenuUnblock;

  /// No description provided for @playerMenuUnfriend.
  ///
  /// In az, this message translates to:
  /// **'Dostluqdan çıxar'**
  String get playerMenuUnfriend;

  /// No description provided for @playerMenuInviteClan.
  ///
  /// In az, this message translates to:
  /// **'Klana dəvət et'**
  String get playerMenuInviteClan;

  /// No description provided for @reportTitle.
  ///
  /// In az, this message translates to:
  /// **'Şikayət: {name}'**
  String reportTitle(String name);

  /// No description provided for @reportReasonLabel.
  ///
  /// In az, this message translates to:
  /// **'SƏBƏB'**
  String get reportReasonLabel;

  /// No description provided for @reportReasonAbuse.
  ///
  /// In az, this message translates to:
  /// **'Təhqiramiz söhbət'**
  String get reportReasonAbuse;

  /// No description provided for @reportReasonName.
  ///
  /// In az, this message translates to:
  /// **'Qeyri-münasib ad və ya avatar'**
  String get reportReasonName;

  /// No description provided for @reportReasonCheating.
  ///
  /// In az, this message translates to:
  /// **'Kömək proqramı istifadəsi'**
  String get reportReasonCheating;

  /// No description provided for @reportReasonStalling.
  ///
  /// In az, this message translates to:
  /// **'Qəsdən vaxt uzatma'**
  String get reportReasonStalling;

  /// No description provided for @reportReasonLeaving.
  ///
  /// In az, this message translates to:
  /// **'Oyunu qəsdən tərk etmə'**
  String get reportReasonLeaving;

  /// No description provided for @reportReasonOther.
  ///
  /// In az, this message translates to:
  /// **'Digər'**
  String get reportReasonOther;

  /// No description provided for @reportNoteHint.
  ///
  /// In az, this message translates to:
  /// **'Əlavə qeyd (istəyə görə)'**
  String get reportNoteHint;

  /// No description provided for @reportAlsoBlock.
  ///
  /// In az, this message translates to:
  /// **'Bu oyunçunu da blokla'**
  String get reportAlsoBlock;

  /// No description provided for @reportDisclosure.
  ///
  /// In az, this message translates to:
  /// **'Son oyunun qeydi və söhbət şikayətə avtomatik əlavə olunur. {name} şikayətçinin kim olduğunu görməyəcək.'**
  String reportDisclosure(String name);

  /// No description provided for @reportSend.
  ///
  /// In az, this message translates to:
  /// **'Şikayəti göndər'**
  String get reportSend;

  /// No description provided for @reportLimit.
  ///
  /// In az, this message translates to:
  /// **'Bu gün çox şikayət göndərdin. Sabah yenidən yoxla.'**
  String get reportLimit;

  /// No description provided for @blockTitle.
  ///
  /// In az, this message translates to:
  /// **'{name} bloklansın?'**
  String blockTitle(String name);

  /// No description provided for @blockInfoMatchmaking.
  ///
  /// In az, this message translates to:
  /// **'Təsadüfi oyunlarda səninlə qarşılaşmayacaq.'**
  String get blockInfoMatchmaking;

  /// No description provided for @blockInfoContact.
  ///
  /// In az, this message translates to:
  /// **'Sənə mesaj, dostluq və oyun dəvəti göndərə bilməyəcək.'**
  String get blockInfoContact;

  /// No description provided for @blockInfoUndo.
  ///
  /// In az, this message translates to:
  /// **'Bloku {path} bölməsindən götürə bilərsən.'**
  String blockInfoUndo(String path);

  /// No description provided for @privacyBlocked.
  ///
  /// In az, this message translates to:
  /// **'Bloklananlar'**
  String get privacyBlocked;

  /// No description provided for @blockConfirm.
  ///
  /// In az, this message translates to:
  /// **'Blokla'**
  String get blockConfirm;

  /// No description provided for @blockDone.
  ///
  /// In az, this message translates to:
  /// **'{name} bloklandı.'**
  String blockDone(String name);

  /// No description provided for @unblockDone.
  ///
  /// In az, this message translates to:
  /// **'Blok götürüldü'**
  String get unblockDone;

  /// No description provided for @blockedEmpty.
  ///
  /// In az, this message translates to:
  /// **'Bloklanan oyunçu yoxdur'**
  String get blockedEmpty;

  /// No description provided for @reportSentTitle.
  ///
  /// In az, this message translates to:
  /// **'Şikayət göndərildi'**
  String get reportSentTitle;

  /// No description provided for @reportSentBody.
  ///
  /// In az, this message translates to:
  /// **'Moderator 24 saat ərzində baxacaq. Nəticə barədə bildiriş alacaqsan.'**
  String get reportSentBody;

  /// No description provided for @mutedNote.
  ///
  /// In az, this message translates to:
  /// **'Səssizə alındı'**
  String get mutedNote;

  /// No description provided for @unmutedNote.
  ///
  /// In az, this message translates to:
  /// **'Səsi açıldı'**
  String get unmutedNote;

  /// No description provided for @clansTitle.
  ///
  /// In az, this message translates to:
  /// **'Klanlar'**
  String get clansTitle;

  /// No description provided for @clanCreateShort.
  ///
  /// In az, this message translates to:
  /// **'Yarat'**
  String get clanCreateShort;

  /// No description provided for @clanSearchHint.
  ///
  /// In az, this message translates to:
  /// **'Ad və ya teq axtar'**
  String get clanSearchHint;

  /// No description provided for @clanFilterLanguage.
  ///
  /// In az, this message translates to:
  /// **'Dil: {code}'**
  String clanFilterLanguage(String code);

  /// No description provided for @clanFilterOpen.
  ///
  /// In az, this message translates to:
  /// **'Açıq'**
  String get clanFilterOpen;

  /// No description provided for @clanFilterMinRating.
  ///
  /// In az, this message translates to:
  /// **'Min. reytinq ≤ {rating}'**
  String clanFilterMinRating(int rating);

  /// No description provided for @clanTag.
  ///
  /// In az, this message translates to:
  /// **'[{tag}]'**
  String clanTag(String tag);

  /// No description provided for @clanListMeta.
  ///
  /// In az, this message translates to:
  /// **'Səv. {level} · {members}/{max} · {rating}'**
  String clanListMeta(int level, int members, int max, String rating);

  /// No description provided for @clanJoin.
  ///
  /// In az, this message translates to:
  /// **'Qoşul'**
  String get clanJoin;

  /// No description provided for @clanApply.
  ///
  /// In az, this message translates to:
  /// **'Müraciət'**
  String get clanApply;

  /// No description provided for @clanFull.
  ///
  /// In az, this message translates to:
  /// **'Dolu'**
  String get clanFull;

  /// No description provided for @clanInviteOnlyShort.
  ///
  /// In az, this message translates to:
  /// **'Dəvətlə'**
  String get clanInviteOnlyShort;

  /// No description provided for @clanPending.
  ///
  /// In az, this message translates to:
  /// **'Gözləyir'**
  String get clanPending;

  /// No description provided for @clanEmpty.
  ///
  /// In az, this message translates to:
  /// **'Klan tapılmadı'**
  String get clanEmpty;

  /// No description provided for @clanEmptyBody.
  ///
  /// In az, this message translates to:
  /// **'Başqa ad yoxla və ya öz klanını yarat.'**
  String get clanEmptyBody;

  /// No description provided for @clanInvitesTitle.
  ///
  /// In az, this message translates to:
  /// **'DƏVƏTLƏR'**
  String get clanInvitesTitle;

  /// No description provided for @clanInviteFrom.
  ///
  /// In az, this message translates to:
  /// **'Dəvət edən: {name}'**
  String clanInviteFrom(String name);

  /// No description provided for @clanStatLevel.
  ///
  /// In az, this message translates to:
  /// **'Səviyyə'**
  String get clanStatLevel;

  /// No description provided for @clanStatMembers.
  ///
  /// In az, this message translates to:
  /// **'Üzv'**
  String get clanStatMembers;

  /// No description provided for @clanStatRating.
  ///
  /// In az, this message translates to:
  /// **'Reytinq'**
  String get clanStatRating;

  /// No description provided for @clanStatLanguage.
  ///
  /// In az, this message translates to:
  /// **'Dil'**
  String get clanStatLanguage;

  /// No description provided for @clanMembersValue.
  ///
  /// In az, this message translates to:
  /// **'{members}/{max}'**
  String clanMembersValue(int members, int max);

  /// No description provided for @clanRequirements.
  ///
  /// In az, this message translates to:
  /// **'TƏLƏBLƏR'**
  String get clanRequirements;

  /// No description provided for @clanReqMinRating.
  ///
  /// In az, this message translates to:
  /// **'Min. reytinq'**
  String get clanReqMinRating;

  /// No description provided for @clanReqPolicy.
  ///
  /// In az, this message translates to:
  /// **'Qəbul'**
  String get clanReqPolicy;

  /// No description provided for @clanReqNone.
  ///
  /// In az, this message translates to:
  /// **'Yoxdur'**
  String get clanReqNone;

  /// No description provided for @clanTopMembers.
  ///
  /// In az, this message translates to:
  /// **'ƏN YAXŞI ÜZVLƏR'**
  String get clanTopMembers;

  /// No description provided for @clanMemberWithRole.
  ///
  /// In az, this message translates to:
  /// **'{name} · {role}'**
  String clanMemberWithRole(String name, String role);

  /// No description provided for @clanApplyCta.
  ///
  /// In az, this message translates to:
  /// **'Müraciət et'**
  String get clanApplyCta;

  /// No description provided for @clanJoinCta.
  ///
  /// In az, this message translates to:
  /// **'Qoşul'**
  String get clanJoinCta;

  /// No description provided for @clanAppliedCta.
  ///
  /// In az, this message translates to:
  /// **'Müraciət göndərildi'**
  String get clanAppliedCta;

  /// No description provided for @clanCancelApply.
  ///
  /// In az, this message translates to:
  /// **'Müraciəti geri götür'**
  String get clanCancelApply;

  /// No description provided for @clanInviteOnlyCta.
  ///
  /// In az, this message translates to:
  /// **'Yalnız dəvətlə'**
  String get clanInviteOnlyCta;

  /// No description provided for @clanFullCta.
  ///
  /// In az, this message translates to:
  /// **'Klan doludur'**
  String get clanFullCta;

  /// No description provided for @clanReqNotMet.
  ///
  /// In az, this message translates to:
  /// **'Tələblərə uyğun deyilsən'**
  String get clanReqNotMet;

  /// No description provided for @clanLeaveFirst.
  ///
  /// In az, this message translates to:
  /// **'Əvvəlcə hazırkı klandan çıx'**
  String get clanLeaveFirst;

  /// No description provided for @clanOpenMine.
  ///
  /// In az, this message translates to:
  /// **'Klana keç'**
  String get clanOpenMine;

  /// No description provided for @clanAcceptInvite.
  ///
  /// In az, this message translates to:
  /// **'Dəvəti qəbul et'**
  String get clanAcceptInvite;

  /// No description provided for @clanErrRatingLow.
  ///
  /// In az, this message translates to:
  /// **'Reytinqin bu klan üçün azdır'**
  String get clanErrRatingLow;

  /// No description provided for @clanErrInClan.
  ///
  /// In az, this message translates to:
  /// **'Artıq klandasan'**
  String get clanErrInClan;

  /// No description provided for @policyOpen.
  ///
  /// In az, this message translates to:
  /// **'Açıq'**
  String get policyOpen;

  /// No description provided for @policyOpenSub.
  ///
  /// In az, this message translates to:
  /// **'Reytinq şərtinə uyğun hər kəs dərhal qoşulur'**
  String get policyOpenSub;

  /// No description provided for @policyRequest.
  ///
  /// In az, this message translates to:
  /// **'Müraciət ilə'**
  String get policyRequest;

  /// No description provided for @policyRequestSub.
  ///
  /// In az, this message translates to:
  /// **'Lider, müavinlər və ağsaqqallar təsdiqləyir'**
  String get policyRequestSub;

  /// No description provided for @policyInvite.
  ///
  /// In az, this message translates to:
  /// **'Yalnız dəvət'**
  String get policyInvite;

  /// No description provided for @policyInviteSub.
  ///
  /// In az, this message translates to:
  /// **'Siyahıda görünür, amma qoşulmaq üçün dəvət lazımdır'**
  String get policyInviteSub;

  /// No description provided for @roleLeader.
  ///
  /// In az, this message translates to:
  /// **'Lider'**
  String get roleLeader;

  /// No description provided for @roleCoLeader.
  ///
  /// In az, this message translates to:
  /// **'Müavin'**
  String get roleCoLeader;

  /// No description provided for @roleElder.
  ///
  /// In az, this message translates to:
  /// **'Ağsaqqal'**
  String get roleElder;

  /// No description provided for @roleMember.
  ///
  /// In az, this message translates to:
  /// **'Üzv'**
  String get roleMember;

  /// No description provided for @emblemTitle.
  ///
  /// In az, this message translates to:
  /// **'Emblem'**
  String get emblemTitle;

  /// No description provided for @emblemSave.
  ///
  /// In az, this message translates to:
  /// **'Saxla'**
  String get emblemSave;

  /// No description provided for @emblemTabShape.
  ///
  /// In az, this message translates to:
  /// **'Forma'**
  String get emblemTabShape;

  /// No description provided for @emblemTabSymbol.
  ///
  /// In az, this message translates to:
  /// **'Simvol'**
  String get emblemTabSymbol;

  /// No description provided for @emblemTabColor.
  ///
  /// In az, this message translates to:
  /// **'Rəng'**
  String get emblemTabColor;

  /// No description provided for @emblemTabPattern.
  ///
  /// In az, this message translates to:
  /// **'Naxış'**
  String get emblemTabPattern;

  /// No description provided for @emblemPrimaryColor.
  ///
  /// In az, this message translates to:
  /// **'ƏSAS RƏNG'**
  String get emblemPrimaryColor;

  /// No description provided for @emblemShapeShield.
  ///
  /// In az, this message translates to:
  /// **'Qalxan'**
  String get emblemShapeShield;

  /// No description provided for @emblemShapeHexagon.
  ///
  /// In az, this message translates to:
  /// **'Altıbucaq'**
  String get emblemShapeHexagon;

  /// No description provided for @emblemShapeOctagon.
  ///
  /// In az, this message translates to:
  /// **'Səkkizbucaq'**
  String get emblemShapeOctagon;

  /// No description provided for @emblemShapeCircle.
  ///
  /// In az, this message translates to:
  /// **'Dairə'**
  String get emblemShapeCircle;

  /// No description provided for @emblemShapeDiamond.
  ///
  /// In az, this message translates to:
  /// **'Romb'**
  String get emblemShapeDiamond;

  /// No description provided for @emblemShapeBanner.
  ///
  /// In az, this message translates to:
  /// **'Bayraq'**
  String get emblemShapeBanner;

  /// No description provided for @emblemShapeStar.
  ///
  /// In az, this message translates to:
  /// **'Ulduz'**
  String get emblemShapeStar;

  /// No description provided for @emblemShapeArch.
  ///
  /// In az, this message translates to:
  /// **'Tağ'**
  String get emblemShapeArch;

  /// No description provided for @emblemSymbolDiamond.
  ///
  /// In az, this message translates to:
  /// **'Romb'**
  String get emblemSymbolDiamond;

  /// No description provided for @emblemSymbolDiamondDot.
  ///
  /// In az, this message translates to:
  /// **'Nöqtəli romb'**
  String get emblemSymbolDiamondDot;

  /// No description provided for @emblemSymbolCircle.
  ///
  /// In az, this message translates to:
  /// **'Halqa'**
  String get emblemSymbolCircle;

  /// No description provided for @emblemSymbolSquare.
  ///
  /// In az, this message translates to:
  /// **'Kvadrat'**
  String get emblemSymbolSquare;

  /// No description provided for @emblemSymbolInitials.
  ///
  /// In az, this message translates to:
  /// **'Hərflər'**
  String get emblemSymbolInitials;

  /// No description provided for @emblemPatternNone.
  ///
  /// In az, this message translates to:
  /// **'Yoxdur'**
  String get emblemPatternNone;

  /// No description provided for @emblemPatternLattice.
  ///
  /// In az, this message translates to:
  /// **'Şəbəkə'**
  String get emblemPatternLattice;

  /// No description provided for @emblemColorGarnet.
  ///
  /// In az, this message translates to:
  /// **'Nar'**
  String get emblemColorGarnet;

  /// No description provided for @emblemColorIndigo.
  ///
  /// In az, this message translates to:
  /// **'İndiqo'**
  String get emblemColorIndigo;

  /// No description provided for @emblemColorEmerald.
  ///
  /// In az, this message translates to:
  /// **'Zümrüd'**
  String get emblemColorEmerald;

  /// No description provided for @emblemColorBrass.
  ///
  /// In az, this message translates to:
  /// **'Tunc'**
  String get emblemColorBrass;

  /// No description provided for @emblemColorPurple.
  ///
  /// In az, this message translates to:
  /// **'Bənövşəyi'**
  String get emblemColorPurple;

  /// No description provided for @emblemColorSlate.
  ///
  /// In az, this message translates to:
  /// **'Şifer'**
  String get emblemColorSlate;

  /// No description provided for @emblemColorIvory.
  ///
  /// In az, this message translates to:
  /// **'Fil sümüyü'**
  String get emblemColorIvory;

  /// No description provided for @emblemColorBlue.
  ///
  /// In az, this message translates to:
  /// **'Mavi'**
  String get emblemColorBlue;

  /// No description provided for @emblemColorWalnut.
  ///
  /// In az, this message translates to:
  /// **'Qoz'**
  String get emblemColorWalnut;

  /// No description provided for @clanOnline.
  ///
  /// In az, this message translates to:
  /// **'{n} onlayn'**
  String clanOnline(int n);

  /// No description provided for @clanTabChat.
  ///
  /// In az, this message translates to:
  /// **'Söhbət'**
  String get clanTabChat;

  /// No description provided for @clanTabActivity.
  ///
  /// In az, this message translates to:
  /// **'Fəaliyyət'**
  String get clanTabActivity;

  /// No description provided for @clanTabWar.
  ///
  /// In az, this message translates to:
  /// **'Döyüş'**
  String get clanTabWar;

  /// No description provided for @clanTabChest.
  ///
  /// In az, this message translates to:
  /// **'Sandıq'**
  String get clanTabChest;

  /// No description provided for @clanChestTitle.
  ///
  /// In az, this message translates to:
  /// **'Həftəlik sandıq'**
  String get clanChestTitle;

  /// No description provided for @clanChestProgress.
  ///
  /// In az, this message translates to:
  /// **'{current} / {target}'**
  String clanChestProgress(String current, String target);

  /// No description provided for @clanChatHint.
  ///
  /// In az, this message translates to:
  /// **'Mesaj yaz…'**
  String get clanChatHint;

  /// No description provided for @clanChatEmpty.
  ///
  /// In az, this message translates to:
  /// **'Hələ mesaj yoxdur. İlk sən yaz.'**
  String get clanChatEmpty;

  /// No description provided for @clanActivityEmpty.
  ///
  /// In az, this message translates to:
  /// **'Hələ hadisə yoxdur'**
  String get clanActivityEmpty;

  /// No description provided for @clanChatTooFast.
  ///
  /// In az, this message translates to:
  /// **'Çox tez yazırsan. Bir az gözlə.'**
  String get clanChatTooFast;

  /// No description provided for @clanSysCreated.
  ///
  /// In az, this message translates to:
  /// **'Klan yaradıldı: {name}'**
  String clanSysCreated(String name);

  /// No description provided for @clanSysJoined.
  ///
  /// In az, this message translates to:
  /// **'{name} klana qoşuldu'**
  String clanSysJoined(String name);

  /// No description provided for @clanSysLeft.
  ///
  /// In az, this message translates to:
  /// **'{name} klandan çıxdı'**
  String clanSysLeft(String name);

  /// No description provided for @clanSysKicked.
  ///
  /// In az, this message translates to:
  /// **'{name} klandan çıxarıldı'**
  String clanSysKicked(String name);

  /// No description provided for @clanSysRole.
  ///
  /// In az, this message translates to:
  /// **'{name}: yeni rütbə · {role}'**
  String clanSysRole(String name, String role);

  /// No description provided for @clanSysLeader.
  ///
  /// In az, this message translates to:
  /// **'Yeni lider: {name}'**
  String clanSysLeader(String name);

  /// No description provided for @clanSysRenamed.
  ///
  /// In az, this message translates to:
  /// **'Klanın yeni adı: {name} [{tag}]'**
  String clanSysRenamed(String name, String tag);

  /// No description provided for @clanSysDonated.
  ///
  /// In az, this message translates to:
  /// **'{name} sandığa {amount} sikkə qoydu'**
  String clanSysDonated(String name, String amount);

  /// No description provided for @clanSysChestFull.
  ///
  /// In az, this message translates to:
  /// **'Həftəlik sandıq doldu'**
  String get clanSysChestFull;

  /// No description provided for @clanSysWarStarted.
  ///
  /// In az, this message translates to:
  /// **'Klan döyüşü başladı: {name} [{tag}]'**
  String clanSysWarStarted(String name, String tag);

  /// No description provided for @clanSysWarWin.
  ///
  /// In az, this message translates to:
  /// **'{name} klan döyüşündə qalib gəldi · +{points}'**
  String clanSysWarWin(String name, String points);

  /// No description provided for @clanSysWarEnded.
  ///
  /// In az, this message translates to:
  /// **'Klan döyüşü bitdi · {mine} : {theirs}'**
  String clanSysWarEnded(String mine, String theirs);

  /// No description provided for @clanMenuMembers.
  ///
  /// In az, this message translates to:
  /// **'Üzvlər'**
  String get clanMenuMembers;

  /// No description provided for @clanMenuLeaderboard.
  ///
  /// In az, this message translates to:
  /// **'Klan reytinqi'**
  String get clanMenuLeaderboard;

  /// No description provided for @clanMenuProfile.
  ///
  /// In az, this message translates to:
  /// **'Klan profili'**
  String get clanMenuProfile;

  /// No description provided for @clanMenuEmblem.
  ///
  /// In az, this message translates to:
  /// **'Emblemi dəyiş'**
  String get clanMenuEmblem;

  /// No description provided for @clanMenuRequests.
  ///
  /// In az, this message translates to:
  /// **'Müraciətlər'**
  String get clanMenuRequests;

  /// No description provided for @clanMenuInvite.
  ///
  /// In az, this message translates to:
  /// **'Dost dəvət et'**
  String get clanMenuInvite;

  /// No description provided for @clanMenuLeave.
  ///
  /// In az, this message translates to:
  /// **'Klandan çıx'**
  String get clanMenuLeave;

  /// No description provided for @clanLeaveTitle.
  ///
  /// In az, this message translates to:
  /// **'Klandan çıxırsan?'**
  String get clanLeaveTitle;

  /// No description provided for @clanLeaveBody.
  ///
  /// In az, this message translates to:
  /// **'Klan söhbəti və sandığa çıxışın bağlanacaq.'**
  String get clanLeaveBody;

  /// No description provided for @clanLeaveLastBody.
  ///
  /// In az, this message translates to:
  /// **'Sən sonuncu üzvsən: klan bağlanacaq.'**
  String get clanLeaveLastBody;

  /// No description provided for @clanTransferFirst.
  ///
  /// In az, this message translates to:
  /// **'Çıxmazdan əvvəl liderliyi başqa üzvə ver.'**
  String get clanTransferFirst;

  /// No description provided for @chatDelete.
  ///
  /// In az, this message translates to:
  /// **'Sil'**
  String get chatDelete;

  /// No description provided for @clanChestDonate.
  ///
  /// In az, this message translates to:
  /// **'Sandığa qoy'**
  String get clanChestDonate;

  /// No description provided for @clanChestMine.
  ///
  /// In az, this message translates to:
  /// **'Bu həftə sənin payın: {amount}'**
  String clanChestMine(String amount);

  /// No description provided for @clanChestReward.
  ///
  /// In az, this message translates to:
  /// **'Sandıq dolanda klan {xp} XP qazanır'**
  String clanChestReward(int xp);

  /// No description provided for @clanChestFullNote.
  ///
  /// In az, this message translates to:
  /// **'Bu həftə sandıq doldu'**
  String get clanChestFullNote;

  /// No description provided for @clanChestAmount.
  ///
  /// In az, this message translates to:
  /// **'MƏBLƏĞ'**
  String get clanChestAmount;

  /// No description provided for @clanDonated.
  ///
  /// In az, this message translates to:
  /// **'Sandığa {amount} sikkə qoydun'**
  String clanDonated(String amount);

  /// No description provided for @clanErrChestFull.
  ///
  /// In az, this message translates to:
  /// **'Sandıq artıq doludur'**
  String get clanErrChestFull;

  /// No description provided for @clanDonors.
  ///
  /// In az, this message translates to:
  /// **'BU HƏFTƏNİN PAYLARI'**
  String get clanDonors;

  /// No description provided for @membersTitle.
  ///
  /// In az, this message translates to:
  /// **'Üzvlər'**
  String get membersTitle;

  /// No description provided for @membersCount.
  ///
  /// In az, this message translates to:
  /// **'{members} / {max}'**
  String membersCount(int members, int max);

  /// No description provided for @memberMeta.
  ///
  /// In az, this message translates to:
  /// **'{presence} · {rating}'**
  String memberMeta(String presence, String rating);

  /// No description provided for @memberMe.
  ///
  /// In az, this message translates to:
  /// **'{name} (sən)'**
  String memberMe(String name);

  /// No description provided for @memberViewProfile.
  ///
  /// In az, this message translates to:
  /// **'Profilə bax'**
  String get memberViewProfile;

  /// No description provided for @memberInviteFriendly.
  ///
  /// In az, this message translates to:
  /// **'Dostluq matçına çağır'**
  String get memberInviteFriendly;

  /// No description provided for @memberPromoteCoLeader.
  ///
  /// In az, this message translates to:
  /// **'Müavin et'**
  String get memberPromoteCoLeader;

  /// No description provided for @memberPromoteElder.
  ///
  /// In az, this message translates to:
  /// **'Ağsaqqal et'**
  String get memberPromoteElder;

  /// No description provided for @memberDemote.
  ///
  /// In az, this message translates to:
  /// **'Üzv et'**
  String get memberDemote;

  /// No description provided for @memberTransferLead.
  ///
  /// In az, this message translates to:
  /// **'Liderliyi ver'**
  String get memberTransferLead;

  /// No description provided for @memberKick.
  ///
  /// In az, this message translates to:
  /// **'Klandan çıxar'**
  String get memberKick;

  /// No description provided for @memberKickConfirm.
  ///
  /// In az, this message translates to:
  /// **'{name} klandan çıxarılsın?'**
  String memberKickConfirm(String name);

  /// No description provided for @memberTransferConfirm.
  ///
  /// In az, this message translates to:
  /// **'Liderliyi ver: {name}?'**
  String memberTransferConfirm(String name);

  /// No description provided for @memberTransferBody.
  ///
  /// In az, this message translates to:
  /// **'Sən müavin olacaqsan.'**
  String get memberTransferBody;

  /// No description provided for @requestsEmpty.
  ///
  /// In az, this message translates to:
  /// **'Yeni müraciət yoxdur'**
  String get requestsEmpty;

  /// No description provided for @clanInvited.
  ///
  /// In az, this message translates to:
  /// **'Dəvət göndərildi'**
  String get clanInvited;

  /// No description provided for @warLive.
  ///
  /// In az, this message translates to:
  /// **'CANLI · BİTMƏSİNƏ {time}'**
  String warLive(String time);

  /// No description provided for @warCounted.
  ///
  /// In az, this message translates to:
  /// **'{n} / {max} matç sayıldı'**
  String warCounted(int n, int max);

  /// No description provided for @warMatches.
  ///
  /// In az, this message translates to:
  /// **'MATÇLAR'**
  String get warMatches;

  /// No description provided for @warFinished.
  ///
  /// In az, this message translates to:
  /// **'Bitdi {a}–{b}'**
  String warFinished(int a, int b);

  /// No description provided for @warWon.
  ///
  /// In az, this message translates to:
  /// **'BİTDİ · QƏLƏBƏ'**
  String get warWon;

  /// No description provided for @warLost.
  ///
  /// In az, this message translates to:
  /// **'BİTDİ · MƏĞLUBİYYƏT'**
  String get warLost;

  /// No description provided for @warDraw.
  ///
  /// In az, this message translates to:
  /// **'BİTDİ · HEÇ-HEÇƏ'**
  String get warDraw;

  /// No description provided for @warNoneTitle.
  ///
  /// In az, this message translates to:
  /// **'Bu həftə döyüş yoxdur'**
  String get warNoneTitle;

  /// No description provided for @warNoneBody.
  ///
  /// In az, this message translates to:
  /// **'Klanlar hər bazar ertəsi cütləşdirilir. Döyüş üçün ən azı 2 aktiv üzv lazımdır.'**
  String get warNoneBody;

  /// No description provided for @warNoOpponent.
  ///
  /// In az, this message translates to:
  /// **'Rəqib tapılmadı'**
  String get warNoOpponent;

  /// No description provided for @warHowTo.
  ///
  /// In az, this message translates to:
  /// **'Rəqib klanın üzvlərinə qarşı hər onlayn qələbə +{points} xal gətirir.'**
  String warHowTo(int points);

  /// No description provided for @warMatchesEmpty.
  ///
  /// In az, this message translates to:
  /// **'Hələ matç sayılmayıb'**
  String get warMatchesEmpty;

  /// No description provided for @clanLeaderboardTitle.
  ///
  /// In az, this message translates to:
  /// **'Klan reytinqi'**
  String get clanLeaderboardTitle;

  /// No description provided for @clanMyRank.
  ///
  /// In az, this message translates to:
  /// **'Sənin klanın · #{rank}'**
  String clanMyRank(int rank);

  /// No description provided for @createClanTitle.
  ///
  /// In az, this message translates to:
  /// **'Klan yarat'**
  String get createClanTitle;

  /// No description provided for @createStep.
  ///
  /// In az, this message translates to:
  /// **'{step} / {total}'**
  String createStep(int step, int total);

  /// No description provided for @createNameLabel.
  ///
  /// In az, this message translates to:
  /// **'Klanın adı'**
  String get createNameLabel;

  /// No description provided for @createNameCounter.
  ///
  /// In az, this message translates to:
  /// **'{n} / {max}'**
  String createNameCounter(int n, int max);

  /// No description provided for @createTagLabel.
  ///
  /// In az, this message translates to:
  /// **'Teq (3–5 hərf)'**
  String get createTagLabel;

  /// No description provided for @createTagFree.
  ///
  /// In az, this message translates to:
  /// **'Boşdur'**
  String get createTagFree;

  /// No description provided for @createTagTaken.
  ///
  /// In az, this message translates to:
  /// **'Tutulub'**
  String get createTagTaken;

  /// No description provided for @createTagInvalid.
  ///
  /// In az, this message translates to:
  /// **'Yalnız 3–5 latın hərfi'**
  String get createTagInvalid;

  /// No description provided for @createNameInvalid.
  ///
  /// In az, this message translates to:
  /// **'Ad 3–24 simvol olmalıdır'**
  String get createNameInvalid;

  /// No description provided for @createEmblemLabel.
  ///
  /// In az, this message translates to:
  /// **'EMBLEM'**
  String get createEmblemLabel;

  /// No description provided for @createEmblemMore.
  ///
  /// In az, this message translates to:
  /// **'Daha çox'**
  String get createEmblemMore;

  /// No description provided for @createColorLabel.
  ///
  /// In az, this message translates to:
  /// **'RƏNG'**
  String get createColorLabel;

  /// No description provided for @createPolicyLabel.
  ///
  /// In az, this message translates to:
  /// **'QOŞULMA'**
  String get createPolicyLabel;

  /// No description provided for @createMinRatingLabel.
  ///
  /// In az, this message translates to:
  /// **'MİNİMUM REYTİNQ'**
  String get createMinRatingLabel;

  /// No description provided for @createMinRatingAny.
  ///
  /// In az, this message translates to:
  /// **'Hamı'**
  String get createMinRatingAny;

  /// No description provided for @createMinRatingMax.
  ///
  /// In az, this message translates to:
  /// **'{n}+'**
  String createMinRatingMax(int n);

  /// No description provided for @createLanguageLabel.
  ///
  /// In az, this message translates to:
  /// **'DİL'**
  String get createLanguageLabel;

  /// No description provided for @createDescriptionLabel.
  ///
  /// In az, this message translates to:
  /// **'Təsvir (istəyə görə)'**
  String get createDescriptionLabel;

  /// No description provided for @createBalance.
  ///
  /// In az, this message translates to:
  /// **'Balans: {from} → {to}'**
  String createBalance(String from, String to);

  /// No description provided for @createRenameNote.
  ///
  /// In az, this message translates to:
  /// **'Ad sonra {price} sikkəyə dəyişir'**
  String createRenameNote(String price);

  /// No description provided for @createSubmit.
  ///
  /// In az, this message translates to:
  /// **'Klanı yarat'**
  String get createSubmit;

  /// No description provided for @createErrNameTaken.
  ///
  /// In az, this message translates to:
  /// **'Bu ad artıq tutulub'**
  String get createErrNameTaken;

  /// Tab bar label (4.1).
  ///
  /// In az, this message translates to:
  /// **'Turnirlər'**
  String get tabTournaments;

  /// No description provided for @tournamentsTitle.
  ///
  /// In az, this message translates to:
  /// **'Turnirlər'**
  String get tournamentsTitle;

  /// No description provided for @tourTabLive.
  ///
  /// In az, this message translates to:
  /// **'Canlı'**
  String get tourTabLive;

  /// No description provided for @tourTabUpcoming.
  ///
  /// In az, this message translates to:
  /// **'Gələcək'**
  String get tourTabUpcoming;

  /// No description provided for @tourTabMine.
  ///
  /// In az, this message translates to:
  /// **'Mənim'**
  String get tourTabMine;

  /// No description provided for @tourTabFinished.
  ///
  /// In az, this message translates to:
  /// **'Bitmiş'**
  String get tourTabFinished;

  /// No description provided for @tourFilterAll.
  ///
  /// In az, this message translates to:
  /// **'Hamısı'**
  String get tourFilterAll;

  /// No description provided for @tourFilterFree.
  ///
  /// In az, this message translates to:
  /// **'Pulsuz'**
  String get tourFilterFree;

  /// Overline; stored uppercased.
  ///
  /// In az, this message translates to:
  /// **'CANLI · RAUND {n}'**
  String tourStatusLive(int n);

  /// No description provided for @tourStatusOpen.
  ///
  /// In az, this message translates to:
  /// **'QEYDİYYAT AÇIQDIR'**
  String get tourStatusOpen;

  /// No description provided for @tourStatusUpcoming.
  ///
  /// In az, this message translates to:
  /// **'GƏLƏCƏK'**
  String get tourStatusUpcoming;

  /// No description provided for @tourStatusFinished.
  ///
  /// In az, this message translates to:
  /// **'BİTDİ'**
  String get tourStatusFinished;

  /// No description provided for @tourStatusCancelled.
  ///
  /// In az, this message translates to:
  /// **'LƏĞV EDİLDİ'**
  String get tourStatusCancelled;

  /// No description provided for @tourInMinutes.
  ///
  /// In az, this message translates to:
  /// **'{n} dəq'**
  String tourInMinutes(int n);

  /// No description provided for @tourTomorrowAt.
  ///
  /// In az, this message translates to:
  /// **'Sabah {time}'**
  String tourTomorrowAt(String time);

  /// No description provided for @tourFormatSwiss.
  ///
  /// In az, this message translates to:
  /// **'İsveç'**
  String get tourFormatSwiss;

  /// No description provided for @tourFormatKnockout.
  ///
  /// In az, this message translates to:
  /// **'Knockout'**
  String get tourFormatKnockout;

  /// No description provided for @tourFormatRoundRobin.
  ///
  /// In az, this message translates to:
  /// **'Dairəvi'**
  String get tourFormatRoundRobin;

  /// No description provided for @tourRounds.
  ///
  /// In az, this message translates to:
  /// **'{n} raund'**
  String tourRounds(int n);

  /// No description provided for @tourMeta.
  ///
  /// In az, this message translates to:
  /// **'{variant} · {points} xal'**
  String tourMeta(String variant, int points);

  /// No description provided for @tourEntrants.
  ///
  /// In az, this message translates to:
  /// **'{n}/{max}'**
  String tourEntrants(int n, int max);

  /// No description provided for @tourRegistered.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyatdasan'**
  String get tourRegistered;

  /// No description provided for @tourPlace.
  ///
  /// In az, this message translates to:
  /// **'Yer: {place}'**
  String tourPlace(String place);

  /// No description provided for @tourOut.
  ///
  /// In az, this message translates to:
  /// **'Çıxdın · {round}'**
  String tourOut(String round);

  /// No description provided for @tournamentsOfflineTitle.
  ///
  /// In az, this message translates to:
  /// **'Turnirlər oflayn görünmür'**
  String get tournamentsOfflineTitle;

  /// No description provided for @tournamentsOfflineBody.
  ///
  /// In az, this message translates to:
  /// **'Kompüterə qarşı və bir cihazda oyun işləyir. Bağlantı qayıdanda siyahı yenilənəcək.'**
  String get tournamentsOfflineBody;

  /// No description provided for @tournamentsEmptyTitle.
  ///
  /// In az, this message translates to:
  /// **'Hələ turnirin yoxdur'**
  String get tournamentsEmptyTitle;

  /// No description provided for @tournamentsEmptyBody.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyatdan keçdiyin turnirlər burada görünəcək.'**
  String get tournamentsEmptyBody;

  /// No description provided for @tournamentsEmptyCta.
  ///
  /// In az, this message translates to:
  /// **'Gələcək turnirlərə bax'**
  String get tournamentsEmptyCta;

  /// No description provided for @tournamentsNoneTitle.
  ///
  /// In az, this message translates to:
  /// **'Turnir yoxdur'**
  String get tournamentsNoneTitle;

  /// No description provided for @tournamentsNoneBody.
  ///
  /// In az, this message translates to:
  /// **'Bu siyahıda hələ turnir yoxdur. Bir az sonra yenidən bax.'**
  String get tournamentsNoneBody;

  /// No description provided for @listErrorTitle.
  ///
  /// In az, this message translates to:
  /// **'Siyahı yüklənmədi'**
  String get listErrorTitle;

  /// No description provided for @listErrorBody.
  ///
  /// In az, this message translates to:
  /// **'Serverlə əlaqə qurulmadı. Bir az sonra yenidən cəhd et.'**
  String get listErrorBody;

  /// No description provided for @sngCardMeta.
  ///
  /// In az, this message translates to:
  /// **'Dolan kimi başlayır'**
  String get sngCardMeta;

  /// No description provided for @sngJoin.
  ///
  /// In az, this message translates to:
  /// **'Qoşul'**
  String get sngJoin;

  /// No description provided for @privateTourCreateChoice.
  ///
  /// In az, this message translates to:
  /// **'Özəl turnir yarat'**
  String get privateTourCreateChoice;

  /// No description provided for @privateTourJoinByCode.
  ///
  /// In az, this message translates to:
  /// **'Kodla qoşul'**
  String get privateTourJoinByCode;

  /// No description provided for @leaderboardTitle.
  ///
  /// In az, this message translates to:
  /// **'Liderlər'**
  String get leaderboardTitle;

  /// No description provided for @tourHeroMeta.
  ///
  /// In az, this message translates to:
  /// **'{status} · {type} {size}'**
  String tourHeroMeta(String status, String type, int size);

  /// No description provided for @tourTypeKnockoutUpper.
  ///
  /// In az, this message translates to:
  /// **'KNOCKOUT'**
  String get tourTypeKnockoutUpper;

  /// No description provided for @tourTypeSwissUpper.
  ///
  /// In az, this message translates to:
  /// **'İSVEÇ'**
  String get tourTypeSwissUpper;

  /// No description provided for @tourTypeRoundRobinUpper.
  ///
  /// In az, this message translates to:
  /// **'DAİRƏVİ'**
  String get tourTypeRoundRobinUpper;

  /// No description provided for @tourTypeSngUpper.
  ///
  /// In az, this message translates to:
  /// **'SIT-AND-GO'**
  String get tourTypeSngUpper;

  /// No description provided for @tourStartsIn.
  ///
  /// In az, this message translates to:
  /// **'Başlanğıca'**
  String get tourStartsIn;

  /// No description provided for @tourLiveRound.
  ///
  /// In az, this message translates to:
  /// **'Raund {n} · {stage}'**
  String tourLiveRound(int n, String stage);

  /// No description provided for @tourNow.
  ///
  /// In az, this message translates to:
  /// **'Raund {n}'**
  String tourNow(int n);

  /// No description provided for @tourPrizeFund.
  ///
  /// In az, this message translates to:
  /// **'Mükafat fondu'**
  String get tourPrizeFund;

  /// No description provided for @tourParticipants.
  ///
  /// In az, this message translates to:
  /// **'İştirakçılar'**
  String get tourParticipants;

  /// No description provided for @tourParticipantsValue.
  ///
  /// In az, this message translates to:
  /// **'{n} / {max}'**
  String tourParticipantsValue(int n, int max);

  /// No description provided for @tourPlaceRange.
  ///
  /// In az, this message translates to:
  /// **'{from}–{to}'**
  String tourPlaceRange(String from, String to);

  /// No description provided for @tourRuleEntry.
  ///
  /// In az, this message translates to:
  /// **'Giriş'**
  String get tourRuleEntry;

  /// No description provided for @tourRuleFairDice.
  ///
  /// In az, this message translates to:
  /// **'Ədalətli zər'**
  String get tourRuleFairDice;

  /// No description provided for @tourRuleRating.
  ///
  /// In az, this message translates to:
  /// **'Reytinq'**
  String get tourRuleRating;

  /// No description provided for @tourRuleUnrated.
  ///
  /// In az, this message translates to:
  /// **'Dəyişmir'**
  String get tourRuleUnrated;

  /// No description provided for @tourFormatValue.
  ///
  /// In az, this message translates to:
  /// **'{type} · {points} xala qədər'**
  String tourFormatValue(String type, int points);

  /// No description provided for @tourEntryValue.
  ///
  /// In az, this message translates to:
  /// **'{price} · min. {rating}'**
  String tourEntryValue(String price, int rating);

  /// No description provided for @tourEntryInvite.
  ///
  /// In az, this message translates to:
  /// **'Dəvətlə'**
  String get tourEntryInvite;

  /// No description provided for @tourFairDiceValue.
  ///
  /// In az, this message translates to:
  /// **'Yoxlanıla bilər'**
  String get tourFairDiceValue;

  /// Primary CTA; the coin price is drawn after it.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyat'**
  String get tourRegister;

  /// No description provided for @tourRegisterFree.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyat · Pulsuz'**
  String get tourRegisterFree;

  /// No description provided for @tourUnregister.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyatı ləğv et'**
  String get tourUnregister;

  /// No description provided for @tourUnregisterTitle.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyat ləğv edilsin?'**
  String get tourUnregisterTitle;

  /// No description provided for @tourUnregisterBody.
  ///
  /// In az, this message translates to:
  /// **'Giriş haqqı balansına qaytarılacaq.'**
  String get tourUnregisterBody;

  /// No description provided for @tourUnregisterBodyFree.
  ///
  /// In az, this message translates to:
  /// **'Yerini başqa oyunçu tuta bilər.'**
  String get tourUnregisterBodyFree;

  /// No description provided for @tourRegisteredToast.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyatdan keçdin'**
  String get tourRegisteredToast;

  /// No description provided for @tourUnregisteredToast.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyat ləğv edildi'**
  String get tourUnregisteredToast;

  /// No description provided for @tourMinRating.
  ///
  /// In az, this message translates to:
  /// **'Minimum reytinq {n}'**
  String tourMinRating(int n);

  /// No description provided for @tourFull.
  ///
  /// In az, this message translates to:
  /// **'Yer qalmayıb'**
  String get tourFull;

  /// No description provided for @tourClosed.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyat bağlıdır'**
  String get tourClosed;

  /// No description provided for @tourInviteOnly.
  ///
  /// In az, this message translates to:
  /// **'Dəvət kodu ilə qoşul'**
  String get tourInviteOnly;

  /// No description provided for @tourOpenBracket.
  ///
  /// In az, this message translates to:
  /// **'Cədvələ bax'**
  String get tourOpenBracket;

  /// No description provided for @tourWatch.
  ///
  /// In az, this message translates to:
  /// **'İzlə'**
  String get tourWatch;

  /// No description provided for @tourTitlePrize.
  ///
  /// In az, this message translates to:
  /// **'Titul: {name}'**
  String tourTitlePrize(String name);

  /// No description provided for @tourRatingTooLow.
  ///
  /// In az, this message translates to:
  /// **'Bu turnir üçün reytinqin azdır.'**
  String get tourRatingTooLow;

  /// No description provided for @tourInviteRequired.
  ///
  /// In az, this message translates to:
  /// **'Bu turnirə yalnız dəvət kodu ilə qoşulmaq olar.'**
  String get tourInviteRequired;

  /// No description provided for @tourActionFailed.
  ///
  /// In az, this message translates to:
  /// **'Alınmadı. Bir az sonra yenidən cəhd et.'**
  String get tourActionFailed;

  /// No description provided for @tourLive.
  ///
  /// In az, this message translates to:
  /// **'CANLI'**
  String get tourLive;

  /// No description provided for @roundOf.
  ///
  /// In az, this message translates to:
  /// **'1/{n}'**
  String roundOf(int n);

  /// No description provided for @roundFinal.
  ///
  /// In az, this message translates to:
  /// **'Final'**
  String get roundFinal;

  /// No description provided for @tourNextMatch.
  ///
  /// In az, this message translates to:
  /// **'NÖVBƏTİ MATÇIN · {round}'**
  String tourNextMatch(String round);

  /// No description provided for @tourNextMetaOpen.
  ///
  /// In az, this message translates to:
  /// **'Raund açıqdır · {points} xala qədər'**
  String tourNextMetaOpen(int points);

  /// No description provided for @tourNextMetaPending.
  ///
  /// In az, this message translates to:
  /// **'Raund hələ açılmayıb · {points} xala qədər'**
  String tourNextMetaPending(int points);

  /// No description provided for @tourOpponentTbd.
  ///
  /// In az, this message translates to:
  /// **'Rəqib bəlli deyil'**
  String get tourOpponentTbd;

  /// No description provided for @tourReady.
  ///
  /// In az, this message translates to:
  /// **'Hazıram'**
  String get tourReady;

  /// No description provided for @tourReadyDone.
  ///
  /// In az, this message translates to:
  /// **'Hazırsan'**
  String get tourReadyDone;

  /// No description provided for @tourWaitingOpponent.
  ///
  /// In az, this message translates to:
  /// **'Rəqib gözlənilir'**
  String get tourWaitingOpponent;

  /// No description provided for @tourEliminated.
  ///
  /// In az, this message translates to:
  /// **'Turnirdən çıxdın · {round}'**
  String tourEliminated(String round);

  /// No description provided for @tourFinishedPanel.
  ///
  /// In az, this message translates to:
  /// **'Turnir bitdi · {place}'**
  String tourFinishedPanel(String place);

  /// No description provided for @zoomIn.
  ///
  /// In az, this message translates to:
  /// **'Böyüt'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In az, this message translates to:
  /// **'Kiçilt'**
  String get zoomOut;

  /// No description provided for @standingsTitle.
  ///
  /// In az, this message translates to:
  /// **'{name} · Cədvəl'**
  String standingsTitle(String name);

  /// No description provided for @standingsRound.
  ///
  /// In az, this message translates to:
  /// **'Raund'**
  String get standingsRound;

  /// No description provided for @standingsColRank.
  ///
  /// In az, this message translates to:
  /// **'#'**
  String get standingsColRank;

  /// No description provided for @standingsColPlayer.
  ///
  /// In az, this message translates to:
  /// **'OYUNÇU'**
  String get standingsColPlayer;

  /// No description provided for @standingsColWinLoss.
  ///
  /// In az, this message translates to:
  /// **'Q–M'**
  String get standingsColWinLoss;

  /// No description provided for @standingsColBuchholz.
  ///
  /// In az, this message translates to:
  /// **'BUCH'**
  String get standingsColBuchholz;

  /// No description provided for @standingsColPoints.
  ///
  /// In az, this message translates to:
  /// **'XAL'**
  String get standingsColPoints;

  /// No description provided for @standingsWinLoss.
  ///
  /// In az, this message translates to:
  /// **'{w}–{l}'**
  String standingsWinLoss(int w, int l);

  /// No description provided for @standingsFootnoteNoPlayoff.
  ///
  /// In az, this message translates to:
  /// **'Bərabərlikdə Buchholz, sonra reytinq'**
  String get standingsFootnoteNoPlayoff;

  /// No description provided for @standingsEmpty.
  ///
  /// In az, this message translates to:
  /// **'Cədvəl birinci raunddan sonra görünəcək.'**
  String get standingsEmpty;

  /// No description provided for @championTitle.
  ///
  /// In az, this message translates to:
  /// **'Çempion'**
  String get championTitle;

  /// No description provided for @championLine.
  ///
  /// In az, this message translates to:
  /// **'{name} · {tournament}'**
  String championLine(String name, String tournament);

  /// No description provided for @championFinal.
  ///
  /// In az, this message translates to:
  /// **'Final: {score} · {opponent}'**
  String championFinal(String score, String opponent);

  /// No description provided for @rewardCoins.
  ///
  /// In az, this message translates to:
  /// **'+{amount} sikkə'**
  String rewardCoins(String amount);

  /// No description provided for @championShare.
  ///
  /// In az, this message translates to:
  /// **'Paylaş'**
  String get championShare;

  /// No description provided for @championShareText.
  ///
  /// In az, this message translates to:
  /// **'{name} {tournament} turnirinin çempionu oldu. NardArena'**
  String championShareText(String name, String tournament);

  /// No description provided for @championShareCopied.
  ///
  /// In az, this message translates to:
  /// **'Mətn kopyalandı'**
  String get championShareCopied;

  /// No description provided for @sngTitle.
  ///
  /// In az, this message translates to:
  /// **'Sit-and-go · {size}'**
  String sngTitle(int size);

  /// No description provided for @sngSize.
  ///
  /// In az, this message translates to:
  /// **'{n} oyunçu'**
  String sngSize(int n);

  /// No description provided for @sngStartsWhenFull.
  ///
  /// In az, this message translates to:
  /// **'Dolan kimi başlayır'**
  String get sngStartsWhenFull;

  /// No description provided for @sngExpires.
  ///
  /// In az, this message translates to:
  /// **'{n} dəqiqəyə dolmasa, giriş haqqı qaytarılır'**
  String sngExpires(int n);

  /// No description provided for @sngFormatValue.
  ///
  /// In az, this message translates to:
  /// **'{variant} · {points} xal'**
  String sngFormatValue(String variant, int points);

  /// No description provided for @sngEntryFee.
  ///
  /// In az, this message translates to:
  /// **'Giriş haqqı'**
  String get sngEntryFee;

  /// No description provided for @sngTimeControl.
  ///
  /// In az, this message translates to:
  /// **'Vaxt nəzarəti'**
  String get sngTimeControl;

  /// No description provided for @sngNoShowRule.
  ///
  /// In az, this message translates to:
  /// **'Raund açılandan sonra {n} saniyə ərzində qoşulmayan oyunçu raundu texniki məğlubiyyətlə verir.'**
  String sngNoShowRule(int n);

  /// No description provided for @sngLeave.
  ///
  /// In az, this message translates to:
  /// **'Çıx · giriş haqqı qaytarılır'**
  String get sngLeave;

  /// No description provided for @noShowOverline.
  ///
  /// In az, this message translates to:
  /// **'RAUND {round} · MASA {table}'**
  String noShowOverline(int round, int table);

  /// No description provided for @noShowTitle.
  ///
  /// In az, this message translates to:
  /// **'Rəqib hələ qoşulmayıb'**
  String get noShowTitle;

  /// No description provided for @noShowBody.
  ///
  /// In az, this message translates to:
  /// **'{name} vaxt bitənə qədər gəlməsə, raund sənin xeyrinə texniki qələbə ilə bitəcək.'**
  String noShowBody(String name);

  /// No description provided for @tourBracket.
  ///
  /// In az, this message translates to:
  /// **'Turnir cədvəli'**
  String get tourBracket;

  /// No description provided for @walkoverTitle.
  ///
  /// In az, this message translates to:
  /// **'Növbəti raunda keçdin'**
  String get walkoverTitle;

  /// No description provided for @walkoverBody.
  ///
  /// In az, this message translates to:
  /// **'{name} vaxtında qoşulmadı. Raund texniki qələbə ilə sənə verildi. Reytinq dəyişmir.'**
  String walkoverBody(String name);

  /// No description provided for @walkoverNextRound.
  ///
  /// In az, this message translates to:
  /// **'Raund {n} başlayır'**
  String walkoverNextRound(int n);

  /// No description provided for @walkoverNextRoundWhen.
  ///
  /// In az, this message translates to:
  /// **'digər matçlar bitəndə'**
  String get walkoverNextRoundWhen;

  /// No description provided for @notFilledTitle.
  ///
  /// In az, this message translates to:
  /// **'Turnir başlamadı'**
  String get notFilledTitle;

  /// No description provided for @notFilledBody.
  ///
  /// In az, this message translates to:
  /// **'{minutes} dəqiqədə {size} oyunçudan yalnız {joined} nəfər qoşuldu. Giriş haqqı balansına qaytarıldı.'**
  String notFilledBody(int minutes, int size, int joined);

  /// No description provided for @notFilledBodyScheduled.
  ///
  /// In az, this message translates to:
  /// **'Kifayət qədər oyunçu yığılmadı. Giriş haqqı balansına qaytarıldı.'**
  String get notFilledBodyScheduled;

  /// No description provided for @refunded.
  ///
  /// In az, this message translates to:
  /// **'+{amount} qaytarıldı'**
  String refunded(String amount);

  /// No description provided for @notFilledJoinSmaller.
  ///
  /// In az, this message translates to:
  /// **'{n} nəfərlik masaya qoşul'**
  String notFilledJoinSmaller(int n);

  /// No description provided for @backToTournaments.
  ///
  /// In az, this message translates to:
  /// **'Turnirlərə qayıt'**
  String get backToTournaments;

  /// No description provided for @privateTourTitle.
  ///
  /// In az, this message translates to:
  /// **'Özəl turnir'**
  String get privateTourTitle;

  /// No description provided for @privateTourName.
  ///
  /// In az, this message translates to:
  /// **'Ad'**
  String get privateTourName;

  /// No description provided for @privateTourNameHint.
  ///
  /// In az, this message translates to:
  /// **'Turnirin adı'**
  String get privateTourNameHint;

  /// No description provided for @privateTourSize.
  ///
  /// In az, this message translates to:
  /// **'OYUNÇU SAYI'**
  String get privateTourSize;

  /// No description provided for @privateTourGame.
  ///
  /// In az, this message translates to:
  /// **'Oyun'**
  String get privateTourGame;

  /// No description provided for @privateTourLength.
  ///
  /// In az, this message translates to:
  /// **'Matç uzunluğu'**
  String get privateTourLength;

  /// No description provided for @privateTourStart.
  ///
  /// In az, this message translates to:
  /// **'Başlama vaxtı'**
  String get privateTourStart;

  /// No description provided for @privateTourStartManual.
  ///
  /// In az, this message translates to:
  /// **'Özün başladırsan'**
  String get privateTourStartManual;

  /// No description provided for @privateTourStartValue.
  ///
  /// In az, this message translates to:
  /// **'{weekday}, {time}'**
  String privateTourStartValue(String weekday, String time);

  /// No description provided for @privateTourEntry.
  ///
  /// In az, this message translates to:
  /// **'Giriş haqqı'**
  String get privateTourEntry;

  /// No description provided for @privateTourFree.
  ///
  /// In az, this message translates to:
  /// **'Pulsuz'**
  String get privateTourFree;

  /// No description provided for @privateTourNote.
  ///
  /// In az, this message translates to:
  /// **'Yaratmaq pulsuzdur. Özəl turnirlər reytinqə təsir etmir.'**
  String get privateTourNote;

  /// No description provided for @privateTourCreate.
  ///
  /// In az, this message translates to:
  /// **'Turniri yarat'**
  String get privateTourCreate;

  /// No description provided for @privateTourCodeLabel.
  ///
  /// In az, this message translates to:
  /// **'DƏVƏT KODU'**
  String get privateTourCodeLabel;

  /// No description provided for @privateTourMeta.
  ///
  /// In az, this message translates to:
  /// **'{when} · {variant}, {points} xal'**
  String privateTourMeta(String when, String variant, int points);

  /// No description provided for @privateTourCopyInvite.
  ///
  /// In az, this message translates to:
  /// **'Dəvəti kopyala'**
  String get privateTourCopyInvite;

  /// No description provided for @privateTourShareText.
  ///
  /// In az, this message translates to:
  /// **'NardArena-da \"{name}\" turnirinə qoşul. Dəvət kodu: {code}'**
  String privateTourShareText(String name, String code);

  /// No description provided for @privateTourRegistration.
  ///
  /// In az, this message translates to:
  /// **'QEYDİYYAT'**
  String get privateTourRegistration;

  /// No description provided for @privateTourOrganizer.
  ///
  /// In az, this message translates to:
  /// **'Təşkilatçı'**
  String get privateTourOrganizer;

  /// No description provided for @privateTourJoined.
  ///
  /// In az, this message translates to:
  /// **'Qoşuldu'**
  String get privateTourJoined;

  /// No description provided for @privateTourStartNowMin.
  ///
  /// In az, this message translates to:
  /// **'İndi başlat · ən az {n} oyunçu'**
  String privateTourStartNowMin(int n);

  /// No description provided for @privateTourStartNow.
  ///
  /// In az, this message translates to:
  /// **'İndi başlat'**
  String get privateTourStartNow;

  /// No description provided for @privateTourCancel.
  ///
  /// In az, this message translates to:
  /// **'Turniri ləğv et'**
  String get privateTourCancel;

  /// No description provided for @privateTourCancelTitle.
  ///
  /// In az, this message translates to:
  /// **'Turnir ləğv edilsin?'**
  String get privateTourCancelTitle;

  /// No description provided for @privateTourCancelBody.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyatdan keçən bütün oyunçular üçün turnir bağlanacaq.'**
  String get privateTourCancelBody;

  /// No description provided for @privateTourRemove.
  ///
  /// In az, this message translates to:
  /// **'Turnirdən çıxar'**
  String get privateTourRemove;

  /// No description provided for @privateTourCodeHint.
  ///
  /// In az, this message translates to:
  /// **'6 simvollu kod'**
  String get privateTourCodeHint;

  /// No description provided for @privateTourCodeNotFound.
  ///
  /// In az, this message translates to:
  /// **'Bu kodla turnir tapılmadı.'**
  String get privateTourCodeNotFound;

  /// No description provided for @privateTourTooMany.
  ///
  /// In az, this message translates to:
  /// **'Eyni anda ən çox 3 özəl turnir aça bilərsən.'**
  String get privateTourTooMany;

  /// No description provided for @privateTourNotEnough.
  ///
  /// In az, this message translates to:
  /// **'Başlamaq üçün ən az 2 oyunçu lazımdır.'**
  String get privateTourNotEnough;

  /// No description provided for @homeTourMeta.
  ///
  /// In az, this message translates to:
  /// **'Mükafat fondu · {prize}'**
  String homeTourMeta(String prize);

  /// No description provided for @homeTourStarts.
  ///
  /// In az, this message translates to:
  /// **'Başlanğıc {time} · {prize}'**
  String homeTourStarts(String time, String prize);

  /// No description provided for @homeSeason.
  ///
  /// In az, this message translates to:
  /// **'SEZON {n} · {days} GÜN'**
  String homeSeason(int n, int days);

  /// No description provided for @homeSeasonLevel.
  ///
  /// In az, this message translates to:
  /// **'Səviyyə {level} / {max}'**
  String homeSeasonLevel(int level, int max);

  /// No description provided for @homePuzzleOverline.
  ///
  /// In az, this message translates to:
  /// **'GÜNÜN TAPMACASI'**
  String get homePuzzleOverline;

  /// No description provided for @homeSeasonEnded.
  ///
  /// In az, this message translates to:
  /// **'SEZON {n} BAŞA ÇATDI'**
  String homeSeasonEnded(int n);

  /// No description provided for @homeSeasonSummaryCta.
  ///
  /// In az, this message translates to:
  /// **'Nəticələrinə bax'**
  String get homeSeasonSummaryCta;

  /// No description provided for @modePuzzles.
  ///
  /// In az, this message translates to:
  /// **'Tapmaca'**
  String get modePuzzles;

  /// No description provided for @seasonN.
  ///
  /// In az, this message translates to:
  /// **'Sezon {n}'**
  String seasonN(int n);

  /// No description provided for @lbScopeGlobal.
  ///
  /// In az, this message translates to:
  /// **'Qlobal'**
  String get lbScopeGlobal;

  /// No description provided for @lbScopeCountry.
  ///
  /// In az, this message translates to:
  /// **'Ölkə'**
  String get lbScopeCountry;

  /// No description provided for @lbScopeFriends.
  ///
  /// In az, this message translates to:
  /// **'Dostlar'**
  String get lbScopeFriends;

  /// No description provided for @lbScopeClan.
  ///
  /// In az, this message translates to:
  /// **'Klan'**
  String get lbScopeClan;

  /// No description provided for @lbRank.
  ///
  /// In az, this message translates to:
  /// **'#{n}'**
  String lbRank(int n);

  /// No description provided for @lbEmptyTitle.
  ///
  /// In az, this message translates to:
  /// **'Siyahı boşdur'**
  String get lbEmptyTitle;

  /// No description provided for @lbEmptyFriends.
  ///
  /// In az, this message translates to:
  /// **'Dostların hələ reytinq cədvəlində yoxdur.'**
  String get lbEmptyFriends;

  /// No description provided for @lbEmptyClan.
  ///
  /// In az, this message translates to:
  /// **'Klanın yoxdur və ya üzvlər hələ reytinqdə deyil.'**
  String get lbEmptyClan;

  /// No description provided for @lbEmptyCountry.
  ///
  /// In az, this message translates to:
  /// **'Profilində ölkə seçilməyib və ya bu ölkədən hələ oyunçu yoxdur.'**
  String get lbEmptyCountry;

  /// No description provided for @lbUnranked.
  ///
  /// In az, this message translates to:
  /// **'Reytinqə düşmək üçün bu sezon {n} reytinq oyunu oyna'**
  String lbUnranked(int n);

  /// No description provided for @lbSeasonPicker.
  ///
  /// In az, this message translates to:
  /// **'Sezon seç'**
  String get lbSeasonPicker;

  /// No description provided for @seasonPassTitle.
  ///
  /// In az, this message translates to:
  /// **'Sezon bileti'**
  String get seasonPassTitle;

  /// No description provided for @seasonOverline.
  ///
  /// In az, this message translates to:
  /// **'SEZON {n} · {days} GÜN {hours} SAAT'**
  String seasonOverline(int n, int days, int hours);

  /// No description provided for @seasonOverlineHours.
  ///
  /// In az, this message translates to:
  /// **'SEZON {n} · {hours} SAAT {minutes} DƏQ'**
  String seasonOverlineHours(int n, int hours, int minutes);

  /// No description provided for @seasonLevelNext.
  ///
  /// In az, this message translates to:
  /// **'Növbəti səviyyə: {n}'**
  String seasonLevelNext(int n);

  /// No description provided for @seasonLevelMax.
  ///
  /// In az, this message translates to:
  /// **'Son səviyyə'**
  String get seasonLevelMax;

  /// No description provided for @seasonTrackFree.
  ///
  /// In az, this message translates to:
  /// **'PULSUZ'**
  String get seasonTrackFree;

  /// No description provided for @seasonTrackPremium.
  ///
  /// In az, this message translates to:
  /// **'PREMİUM'**
  String get seasonTrackPremium;

  /// No description provided for @seasonRewardItem.
  ///
  /// In az, this message translates to:
  /// **'Əşya'**
  String get seasonRewardItem;

  /// No description provided for @seasonEndReward.
  ///
  /// In az, this message translates to:
  /// **'Sezon sonu mükafatı · {tier}'**
  String seasonEndReward(String tier);

  /// No description provided for @seasonEndRewardMeta.
  ///
  /// In az, this message translates to:
  /// **'{reward} · {points} xal qaldı'**
  String seasonEndRewardMeta(String reward, int points);

  /// No description provided for @seasonEndRewardReached.
  ///
  /// In az, this message translates to:
  /// **'{reward} · əldə edildi'**
  String seasonEndRewardReached(String reward);

  /// No description provided for @seasonRewardWithItem.
  ///
  /// In az, this message translates to:
  /// **'{item} + {coins}'**
  String seasonRewardWithItem(String item, String coins);

  /// No description provided for @seasonPremiumUnlock.
  ///
  /// In az, this message translates to:
  /// **'Premium aç'**
  String get seasonPremiumUnlock;

  /// No description provided for @seasonClaimAll.
  ///
  /// In az, this message translates to:
  /// **'Hamısını al · {n}'**
  String seasonClaimAll(int n);

  /// No description provided for @seasonPremiumOwned.
  ///
  /// In az, this message translates to:
  /// **'Premium aktivdir'**
  String get seasonPremiumOwned;

  /// No description provided for @seasonPremiumSheetTitle.
  ///
  /// In az, this message translates to:
  /// **'Sezon bileti · Premium'**
  String get seasonPremiumSheetTitle;

  /// No description provided for @seasonPremiumBody.
  ///
  /// In az, this message translates to:
  /// **'Premium yol bu sezonun premium mükafatlarını açır. Çatdığın səviyyələrin mükafatları dərhal alına bilər.'**
  String get seasonPremiumBody;

  /// No description provided for @seasonPremiumBought.
  ///
  /// In az, this message translates to:
  /// **'Premium açıldı'**
  String get seasonPremiumBought;

  /// No description provided for @seasonNeedsLevel.
  ///
  /// In az, this message translates to:
  /// **'Səviyyə {n} lazımdır'**
  String seasonNeedsLevel(int n);

  /// No description provided for @seasonNeedsPremium.
  ///
  /// In az, this message translates to:
  /// **'Bu mükafat premium yoldadır'**
  String get seasonNeedsPremium;

  /// No description provided for @seasonClaimedToast.
  ///
  /// In az, this message translates to:
  /// **'Mükafat alındı'**
  String get seasonClaimedToast;

  /// No description provided for @seasonUnavailable.
  ///
  /// In az, this message translates to:
  /// **'Sezon məlumatı yüklənmədi'**
  String get seasonUnavailable;

  /// No description provided for @seasonEnded.
  ///
  /// In az, this message translates to:
  /// **'SEZON {n} BAŞA ÇATDI'**
  String seasonEnded(int n);

  /// No description provided for @seasonStatGames.
  ///
  /// In az, this message translates to:
  /// **'Oyun'**
  String get seasonStatGames;

  /// No description provided for @seasonStatWinRate.
  ///
  /// In az, this message translates to:
  /// **'Qələbə'**
  String get seasonStatWinRate;

  /// No description provided for @seasonStatRank.
  ///
  /// In az, this message translates to:
  /// **'Dünyada yer'**
  String get seasonStatRank;

  /// No description provided for @seasonStatCountryRank.
  ///
  /// In az, this message translates to:
  /// **'Ölkədə yer'**
  String get seasonStatCountryRank;

  /// No description provided for @seasonStatRatingGain.
  ///
  /// In az, this message translates to:
  /// **'Reytinq dəyişimi'**
  String get seasonStatRatingGain;

  /// No description provided for @seasonStatRating.
  ///
  /// In az, this message translates to:
  /// **'Son reytinq'**
  String get seasonStatRating;

  /// No description provided for @seasonClaimRewards.
  ///
  /// In az, this message translates to:
  /// **'Mükafatları al'**
  String get seasonClaimRewards;

  /// No description provided for @seasonRewardLine.
  ///
  /// In az, this message translates to:
  /// **'Sezon mükafatı: {reward}'**
  String seasonRewardLine(String reward);

  /// No description provided for @seasonSoftReset.
  ///
  /// In az, this message translates to:
  /// **'Yeni sezonda reytinqin: {rating}'**
  String seasonSoftReset(int rating);

  /// No description provided for @seasonNoSummaryTitle.
  ///
  /// In az, this message translates to:
  /// **'Hələ bitmiş sezon yoxdur'**
  String get seasonNoSummaryTitle;

  /// No description provided for @seasonNoSummaryBody.
  ///
  /// In az, this message translates to:
  /// **'İlk sezon bitəndə nəticələrin burada görünəcək.'**
  String get seasonNoSummaryBody;

  /// 2.6 button.
  ///
  /// In az, this message translates to:
  /// **'Təhlil'**
  String get actionAnalysis;

  /// No description provided for @analysisTitle.
  ///
  /// In az, this message translates to:
  /// **'Təhlil · Oyun {n}'**
  String analysisTitle(int n);

  /// Label of the evaluation bar (heuristic, not equity; QUESTIONS #38).
  ///
  /// In az, this message translates to:
  /// **'Qiymət'**
  String get analysisEquity;

  /// No description provided for @analysisNote.
  ///
  /// In az, this message translates to:
  /// **'Qiymətləri sadə bot hesablayır, dəqiq qələbə şansı deyil. Neyron AI gələndə dəqiqləşəcək.'**
  String get analysisNote;

  /// No description provided for @analysisBest.
  ///
  /// In az, this message translates to:
  /// **'Ən yaxşı: {moves}'**
  String analysisBest(String moves);

  /// No description provided for @analysisYours.
  ///
  /// In az, this message translates to:
  /// **'Sənin: {moves} · {loss}'**
  String analysisYours(String moves, String loss);

  /// No description provided for @analysisBestPlayed.
  ///
  /// In az, this message translates to:
  /// **'Ən yaxşı gediş'**
  String get analysisBestPlayed;

  /// No description provided for @analysisRunning.
  ///
  /// In az, this message translates to:
  /// **'Təhlil edilir…'**
  String get analysisRunning;

  /// No description provided for @analysisMarkGood.
  ///
  /// In az, this message translates to:
  /// **'Yaxşı gediş'**
  String get analysisMarkGood;

  /// No description provided for @analysisMarkMistake.
  ///
  /// In az, this message translates to:
  /// **'Səhv'**
  String get analysisMarkMistake;

  /// No description provided for @analysisMarkBlunder.
  ///
  /// In az, this message translates to:
  /// **'Kobud səhv'**
  String get analysisMarkBlunder;

  /// No description provided for @analysisNotReady.
  ///
  /// In az, this message translates to:
  /// **'Matçın qeydi hələ hazır deyil. Bir az sonra yenidən cəhd et.'**
  String get analysisNotReady;

  /// No description provided for @analysisNoGames.
  ///
  /// In az, this message translates to:
  /// **'Bu matçda oynanmış oyun yoxdur.'**
  String get analysisNoGames;

  /// No description provided for @analysisGameChip.
  ///
  /// In az, this message translates to:
  /// **'Oyun {n}'**
  String analysisGameChip(int n);

  /// No description provided for @puzzleTitle.
  ///
  /// In az, this message translates to:
  /// **'Tapmaca {n} / {total}'**
  String puzzleTitle(int n, int total);

  /// No description provided for @puzzleDailyTitle.
  ///
  /// In az, this message translates to:
  /// **'Günün tapmacası'**
  String get puzzleDailyTitle;

  /// No description provided for @puzzleRating.
  ///
  /// In az, this message translates to:
  /// **'Reytinq {n}'**
  String puzzleRating(int n);

  /// No description provided for @puzzlePhaseOpening.
  ///
  /// In az, this message translates to:
  /// **'Açılış'**
  String get puzzlePhaseOpening;

  /// No description provided for @puzzlePhaseMiddle.
  ///
  /// In az, this message translates to:
  /// **'Ara oyun'**
  String get puzzlePhaseMiddle;

  /// No description provided for @puzzlePhaseBearOff.
  ///
  /// In az, this message translates to:
  /// **'Çıxarış'**
  String get puzzlePhaseBearOff;

  /// No description provided for @puzzleLevelEasy.
  ///
  /// In az, this message translates to:
  /// **'Asan'**
  String get puzzleLevelEasy;

  /// No description provided for @puzzleLevelMedium.
  ///
  /// In az, this message translates to:
  /// **'Orta'**
  String get puzzleLevelMedium;

  /// No description provided for @puzzleLevelHard.
  ///
  /// In az, this message translates to:
  /// **'Çətin'**
  String get puzzleLevelHard;

  /// No description provided for @puzzlePrompt.
  ///
  /// In az, this message translates to:
  /// **'Ən yaxşı gedişi tap'**
  String get puzzlePrompt;

  /// No description provided for @puzzleContext.
  ///
  /// In az, this message translates to:
  /// **'{side} oynayırsan. Zər: {d1} – {d2}.'**
  String puzzleContext(String side, int d1, int d2);

  /// No description provided for @puzzleSideWhite.
  ///
  /// In az, this message translates to:
  /// **'Ağ daşlarla'**
  String get puzzleSideWhite;

  /// No description provided for @puzzleSideBlack.
  ///
  /// In az, this message translates to:
  /// **'Qara daşlarla'**
  String get puzzleSideBlack;

  /// No description provided for @puzzleHint.
  ///
  /// In az, this message translates to:
  /// **'İpucu'**
  String get puzzleHint;

  /// No description provided for @puzzleConfirm.
  ///
  /// In az, this message translates to:
  /// **'Gedişi təsdiqlə'**
  String get puzzleConfirm;

  /// No description provided for @puzzleCorrect.
  ///
  /// In az, this message translates to:
  /// **'Doğru'**
  String get puzzleCorrect;

  /// No description provided for @puzzleCorrectFirstTry.
  ///
  /// In az, this message translates to:
  /// **'Ən yaxşı gediş · ilk cəhddə'**
  String get puzzleCorrectFirstTry;

  /// No description provided for @puzzleCorrectSecondTry.
  ///
  /// In az, this message translates to:
  /// **'Ən yaxşı gediş · ikinci cəhddə'**
  String get puzzleCorrectSecondTry;

  /// No description provided for @puzzleYours.
  ///
  /// In az, this message translates to:
  /// **'Sənin'**
  String get puzzleYours;

  /// No description provided for @puzzleSecondBest.
  ///
  /// In az, this message translates to:
  /// **'İkinci yaxşı'**
  String get puzzleSecondBest;

  /// No description provided for @puzzleBest.
  ///
  /// In az, this message translates to:
  /// **'Ən yaxşı'**
  String get puzzleBest;

  /// No description provided for @puzzleHidden.
  ///
  /// In az, this message translates to:
  /// **'gizli'**
  String get puzzleHidden;

  /// No description provided for @puzzleSeeAnalysis.
  ///
  /// In az, this message translates to:
  /// **'Təhlilə bax'**
  String get puzzleSeeAnalysis;

  /// No description provided for @puzzleNext.
  ///
  /// In az, this message translates to:
  /// **'Növbəti tapmaca'**
  String get puzzleNext;

  /// No description provided for @puzzleWrong.
  ///
  /// In az, this message translates to:
  /// **'Ən yaxşı gediş deyil'**
  String get puzzleWrong;

  /// No description provided for @puzzleAttemptsLeft.
  ///
  /// In az, this message translates to:
  /// **'Qalan cəhd: {n}'**
  String puzzleAttemptsLeft(int n);

  /// No description provided for @puzzleShowSolution.
  ///
  /// In az, this message translates to:
  /// **'Həllə bax'**
  String get puzzleShowSolution;

  /// No description provided for @puzzleOutOfTries.
  ///
  /// In az, this message translates to:
  /// **'Cəhdlər bitdi'**
  String get puzzleOutOfTries;

  /// No description provided for @puzzleAnswer.
  ///
  /// In az, this message translates to:
  /// **'Düzgün cavab: {move}'**
  String puzzleAnswer(String move);

  /// No description provided for @puzzleSetDoneTitle.
  ///
  /// In az, this message translates to:
  /// **'Bütün tapmacaları həll etdin'**
  String get puzzleSetDoneTitle;

  /// No description provided for @puzzleSetDoneBody.
  ///
  /// In az, this message translates to:
  /// **'Yeni tapmacalar tezliklə əlavə olunacaq.'**
  String get puzzleSetDoneBody;

  /// No description provided for @puzzleDailyDone.
  ///
  /// In az, this message translates to:
  /// **'Bugünkü tapmaca bitib. Növbəti tapmacalarla davam et.'**
  String get puzzleDailyDone;

  /// No description provided for @puzzleOffline.
  ///
  /// In az, this message translates to:
  /// **'Tapmacaları yoxlamaq üçün bağlantı lazımdır.'**
  String get puzzleOffline;

  /// Daily mission daily_puzzle_2.
  ///
  /// In az, this message translates to:
  /// **'{n} tapmaca həll et'**
  String missionPuzzle(int n);

  /// No description provided for @notifTitle.
  ///
  /// In az, this message translates to:
  /// **'Bildirişlər'**
  String get notifTitle;

  /// No description provided for @notifReadAll.
  ///
  /// In az, this message translates to:
  /// **'Hamısını oxu'**
  String get notifReadAll;

  /// No description provided for @notifTabAll.
  ///
  /// In az, this message translates to:
  /// **'Hamısı'**
  String get notifTabAll;

  /// No description provided for @notifTabGame.
  ///
  /// In az, this message translates to:
  /// **'Oyun'**
  String get notifTabGame;

  /// No description provided for @notifTabSocial.
  ///
  /// In az, this message translates to:
  /// **'Sosial'**
  String get notifTabSocial;

  /// No description provided for @notifTabTournament.
  ///
  /// In az, this message translates to:
  /// **'Turnir'**
  String get notifTabTournament;

  /// No description provided for @notifToday.
  ///
  /// In az, this message translates to:
  /// **'BU GÜN'**
  String get notifToday;

  /// No description provided for @notifYesterday.
  ///
  /// In az, this message translates to:
  /// **'DÜNƏN'**
  String get notifYesterday;

  /// No description provided for @notifEarlier.
  ///
  /// In az, this message translates to:
  /// **'ƏVVƏL'**
  String get notifEarlier;

  /// No description provided for @notifNow.
  ///
  /// In az, this message translates to:
  /// **'indi'**
  String get notifNow;

  /// No description provided for @notifMinutesAgo.
  ///
  /// In az, this message translates to:
  /// **'{n} dəq'**
  String notifMinutesAgo(int n);

  /// No description provided for @notifHoursAgo.
  ///
  /// In az, this message translates to:
  /// **'{n} saat'**
  String notifHoursAgo(int n);

  /// No description provided for @notifYesterdayAt.
  ///
  /// In az, this message translates to:
  /// **'Dünən {time}'**
  String notifYesterdayAt(String time);

  /// No description provided for @notifEmptyTitle.
  ///
  /// In az, this message translates to:
  /// **'Bildiriş yoxdur'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In az, this message translates to:
  /// **'Dostluq sorğuları, oyun dəvətləri və turnir xəbərləri burada görünəcək.'**
  String get notifEmptyBody;

  /// No description provided for @notifDelete.
  ///
  /// In az, this message translates to:
  /// **'Sil'**
  String get notifDelete;

  /// No description provided for @notifBellLabel.
  ///
  /// In az, this message translates to:
  /// **'Bildirişlər, {n} oxunmamış'**
  String notifBellLabel(int n);

  /// No description provided for @notifGone.
  ///
  /// In az, this message translates to:
  /// **'Bu dəvət artıq keçərli deyil'**
  String get notifGone;

  /// No description provided for @notifFriendRequest.
  ///
  /// In az, this message translates to:
  /// **'dostluq sorğusu göndərdi'**
  String get notifFriendRequest;

  /// No description provided for @notifFriendAccepted.
  ///
  /// In az, this message translates to:
  /// **'dostluq sorğunu qəbul etdi'**
  String get notifFriendAccepted;

  /// No description provided for @notifChallenge.
  ///
  /// In az, this message translates to:
  /// **'səni oyuna çağırır · {variant}, {points} xal, {time}'**
  String notifChallenge(String variant, int points, String time);

  /// No description provided for @notifClanInvite.
  ///
  /// In az, this message translates to:
  /// **'səni {clan} [{tag}] klanına dəvət edir'**
  String notifClanInvite(String clan, String tag);

  /// No description provided for @notifClanJoined.
  ///
  /// In az, this message translates to:
  /// **'klanına qəbul olundun'**
  String get notifClanJoined;

  /// No description provided for @notifClanWarWho.
  ///
  /// In az, this message translates to:
  /// **'Klan döyüşü:'**
  String get notifClanWarWho;

  /// No description provided for @notifClanWar.
  ///
  /// In az, this message translates to:
  /// **'rəqib {opponent} [{tag}]. Hər qələbə klana xal gətirir'**
  String notifClanWar(String opponent, String tag);

  /// No description provided for @notifTournamentReminder.
  ///
  /// In az, this message translates to:
  /// **'{n} dəqiqəyə başlayır'**
  String notifTournamentReminder(int n);

  /// No description provided for @notifTournamentStarted.
  ///
  /// In az, this message translates to:
  /// **'başladı. İlk oyunun hazırdır'**
  String get notifTournamentStarted;

  /// No description provided for @notifTournamentRound.
  ///
  /// In az, this message translates to:
  /// **'· Raund {round} hazırdır. Rəqib: {opponent}'**
  String notifTournamentRound(int round, String opponent);

  /// No description provided for @notifTournamentEliminated.
  ///
  /// In az, this message translates to:
  /// **'· Raund {round}: mübarizə bitdi'**
  String notifTournamentEliminated(int round);

  /// No description provided for @notifTournamentWon.
  ///
  /// In az, this message translates to:
  /// **'· Çempionsan! Mükafat hesabındadır'**
  String get notifTournamentWon;

  /// No description provided for @notifTournamentFinished.
  ///
  /// In az, this message translates to:
  /// **'bitdi · Yerin: {place}'**
  String notifTournamentFinished(int place);

  /// No description provided for @notifSeasonEndWho.
  ///
  /// In az, this message translates to:
  /// **'Sezon {n}'**
  String notifSeasonEndWho(int n);

  /// No description provided for @notifSeasonEnd.
  ///
  /// In az, this message translates to:
  /// **'bitdi · Dərəcən: {tier}. Nəticələrə bax'**
  String notifSeasonEnd(String tier);

  /// No description provided for @notifLevelUpWho.
  ///
  /// In az, this message translates to:
  /// **'Səviyyə {level}!'**
  String notifLevelUpWho(int level);

  /// No description provided for @notifLevelUp.
  ///
  /// In az, this message translates to:
  /// **'+{coins} sikkə qazandın'**
  String notifLevelUp(int coins);

  /// No description provided for @notifTournamentEliminatedPlace.
  ///
  /// In az, this message translates to:
  /// **'· Raund {round}: mübarizə bitdi. Yerin: {place}'**
  String notifTournamentEliminatedPlace(int round, int place);

  /// No description provided for @notifTournamentCancelled.
  ///
  /// In az, this message translates to:
  /// **'ləğv edildi'**
  String get notifTournamentCancelled;

  /// No description provided for @notifTournamentCancelledRefund.
  ///
  /// In az, this message translates to:
  /// **'ləğv edildi · {coins} sikkə geri qaytarıldı'**
  String notifTournamentCancelledRefund(int coins);

  /// No description provided for @notifSeasonEndRank.
  ///
  /// In az, this message translates to:
  /// **'bitdi · Dərəcən: {tier}, yerin: #{rank}. Mükafat: {coins} sikkə'**
  String notifSeasonEndRank(String tier, int rank, int coins);

  /// No description provided for @notifSeasonStarted.
  ///
  /// In az, this message translates to:
  /// **'başladı. Yeni sezon keçidi və mükafatlar səni gözləyir'**
  String get notifSeasonStarted;

  /// No description provided for @notifUnknown.
  ///
  /// In az, this message translates to:
  /// **'Yeni bildiriş'**
  String get notifUnknown;

  /// No description provided for @notifGroupGame.
  ///
  /// In az, this message translates to:
  /// **'OYUN'**
  String get notifGroupGame;

  /// No description provided for @notifGroupTournament.
  ///
  /// In az, this message translates to:
  /// **'TURNİR'**
  String get notifGroupTournament;

  /// No description provided for @notifGroupSocial.
  ///
  /// In az, this message translates to:
  /// **'SOSİAL'**
  String get notifGroupSocial;

  /// No description provided for @notifGroupRewards.
  ///
  /// In az, this message translates to:
  /// **'MÜKAFATLAR'**
  String get notifGroupRewards;

  /// No description provided for @notifPush.
  ///
  /// In az, this message translates to:
  /// **'Push bildirişləri'**
  String get notifPush;

  /// No description provided for @notifPushUnavailable.
  ///
  /// In az, this message translates to:
  /// **'Bu versiyada push hələ işləmir; hamısı qutuda görünür'**
  String get notifPushUnavailable;

  /// No description provided for @notifQuietHours.
  ///
  /// In az, this message translates to:
  /// **'Sakit saatlar'**
  String get notifQuietHours;

  /// No description provided for @notifQuietRange.
  ///
  /// In az, this message translates to:
  /// **'{start} – {end}'**
  String notifQuietRange(String start, String end);

  /// No description provided for @notifQuietOff.
  ///
  /// In az, this message translates to:
  /// **'Söndürülüb'**
  String get notifQuietOff;

  /// No description provided for @notifQuietBody.
  ///
  /// In az, this message translates to:
  /// **'Bu saatlarda push gəlmir, bildirişlər qutuda qalır.'**
  String get notifQuietBody;

  /// No description provided for @notifQuietFrom.
  ///
  /// In az, this message translates to:
  /// **'Başlanğıc'**
  String get notifQuietFrom;

  /// No description provided for @notifQuietTo.
  ///
  /// In az, this message translates to:
  /// **'Son'**
  String get notifQuietTo;

  /// No description provided for @notifQuietSave.
  ///
  /// In az, this message translates to:
  /// **'Yadda saxla'**
  String get notifQuietSave;

  /// No description provided for @notifEarlierHour.
  ///
  /// In az, this message translates to:
  /// **'Bir saat əvvəl'**
  String get notifEarlierHour;

  /// No description provided for @notifLaterHour.
  ///
  /// In az, this message translates to:
  /// **'Bir saat sonra'**
  String get notifLaterHour;

  /// No description provided for @notifGameInvites.
  ///
  /// In az, this message translates to:
  /// **'Oyun dəvətləri'**
  String get notifGameInvites;

  /// No description provided for @notifTournamentStart.
  ///
  /// In az, this message translates to:
  /// **'Turnir başlayır'**
  String get notifTournamentStart;

  /// No description provided for @notifTournamentStartSub.
  ///
  /// In az, this message translates to:
  /// **'{n} dəqiqə əvvəl'**
  String notifTournamentStartSub(int n);

  /// No description provided for @notifRoundReady.
  ///
  /// In az, this message translates to:
  /// **'Raund hazırdır'**
  String get notifRoundReady;

  /// No description provided for @notifRoundReadySub.
  ///
  /// In az, this message translates to:
  /// **'Və turnir nəticələri'**
  String get notifRoundReadySub;

  /// No description provided for @notifFriendRequests.
  ///
  /// In az, this message translates to:
  /// **'Dostluq sorğuları'**
  String get notifFriendRequests;

  /// No description provided for @notifClanInvites.
  ///
  /// In az, this message translates to:
  /// **'Klan dəvətləri'**
  String get notifClanInvites;

  /// No description provided for @notifClanWars.
  ///
  /// In az, this message translates to:
  /// **'Klan müharibəsi'**
  String get notifClanWars;

  /// No description provided for @notifSeasonResults.
  ///
  /// In az, this message translates to:
  /// **'Sezon nəticələri'**
  String get notifSeasonResults;

  /// No description provided for @notifPromptTitle.
  ///
  /// In az, this message translates to:
  /// **'Növbəni qaçırma'**
  String get notifPromptTitle;

  /// No description provided for @notifPromptBody.
  ///
  /// In az, this message translates to:
  /// **'Turnir başlayanda, raundun hazır olanda və dost dəvət göndərəndə xəbər verək. Hər kateqoriyanı ayarlardan söndürə bilərsən.'**
  String get notifPromptBody;

  /// No description provided for @notifPromptSample1.
  ///
  /// In az, this message translates to:
  /// **'Nigar səni oyuna çağırır · Qısa nərd, 5 xal'**
  String get notifPromptSample1;

  /// No description provided for @notifPromptSample2.
  ///
  /// In az, this message translates to:
  /// **'Bakı Cümə Kuboku 15 dəqiqəyə başlayır.'**
  String get notifPromptSample2;

  /// No description provided for @notifPromptAllow.
  ///
  /// In az, this message translates to:
  /// **'Bildirişləri aç'**
  String get notifPromptAllow;

  /// No description provided for @notifPromptLater.
  ///
  /// In az, this message translates to:
  /// **'İndi yox'**
  String get notifPromptLater;

  /// No description provided for @bannedTitle.
  ///
  /// In az, this message translates to:
  /// **'Hesab dayandırılıb'**
  String get bannedTitle;

  /// No description provided for @bannedBodyUntil.
  ///
  /// In az, this message translates to:
  /// **'Ədalətli oyun qaydalarının pozulmasına görə hesabın {date} tarixinədək dayandırılıb.'**
  String bannedBodyUntil(String date);

  /// No description provided for @bannedBodyPermanent.
  ///
  /// In az, this message translates to:
  /// **'Ədalətli oyun qaydalarının pozulmasına görə hesabın müddətsiz dayandırılıb.'**
  String get bannedBodyPermanent;

  /// No description provided for @bannedContact.
  ///
  /// In az, this message translates to:
  /// **'Bunun səhv olduğunu düşünürsənsə, {email} ünvanına yaz.'**
  String bannedContact(String email);

  /// No description provided for @bannedOffline.
  ///
  /// In az, this message translates to:
  /// **'Hesabdan çıxıb kompüterə qarşı və dostla oflayn oynamağa davam edə bilərsən.'**
  String get bannedOffline;

  /// No description provided for @bannedOverTitle.
  ///
  /// In az, this message translates to:
  /// **'Məhdudiyyət bitdi'**
  String get bannedOverTitle;

  /// No description provided for @bannedOverBody.
  ///
  /// In az, this message translates to:
  /// **'Hesabın yenidən aktivdir. Ədalətli oyun qaydalarına əməl etdiyin üçün təşəkkür edirik.'**
  String get bannedOverBody;

  /// No description provided for @bannedContinue.
  ///
  /// In az, this message translates to:
  /// **'Davam et'**
  String get bannedContinue;

  /// No description provided for @authBanned.
  ///
  /// In az, this message translates to:
  /// **'Bu hesab dayandırılıb'**
  String get authBanned;

  /// No description provided for @clanChatMuted.
  ///
  /// In az, this message translates to:
  /// **'Söhbətdə {time} tarixinədək yaza bilməzsən.'**
  String clanChatMuted(String time);

  /// No description provided for @clanChatMutedNoTime.
  ///
  /// In az, this message translates to:
  /// **'Hələlik söhbətdə yaza bilməzsən.'**
  String get clanChatMutedNoTime;

  /// No description provided for @queueCooldownTitle.
  ///
  /// In az, this message translates to:
  /// **'Axtarış müvəqqəti bağlıdır'**
  String get queueCooldownTitle;

  /// No description provided for @queueCooldownBody.
  ///
  /// In az, this message translates to:
  /// **'Bir neçə yarımçıq qalmış matça görə ümumi növbə {time} sonra açılacaq. Şəxsi otaqlar və turnirlər açıqdır.'**
  String queueCooldownBody(String time);

  /// No description provided for @queueCooldownOverBody.
  ///
  /// In az, this message translates to:
  /// **'Növbə yenidən açıqdır.'**
  String get queueCooldownOverBody;

  /// No description provided for @queueCooldownSearch.
  ///
  /// In az, this message translates to:
  /// **'Yenidən axtar'**
  String get queueCooldownSearch;

  /// No description provided for @notifModerationWarningWho.
  ///
  /// In az, this message translates to:
  /// **'Moderatorlardan xəbərdarlıq:'**
  String get notifModerationWarningWho;

  /// No description provided for @notifModerationWarning.
  ///
  /// In az, this message translates to:
  /// **'zəhmət olmasa ədalətli oyun qaydalarına əməl et. Səbəb: {reason}'**
  String notifModerationWarning(String reason);

  /// No description provided for @notifModerationWarningPlain.
  ///
  /// In az, this message translates to:
  /// **'zəhmət olmasa ədalətli oyun qaydalarına əməl et'**
  String get notifModerationWarningPlain;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['az', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'az': return AppLocalizationsAz();
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
