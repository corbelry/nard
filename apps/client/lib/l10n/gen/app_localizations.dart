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
