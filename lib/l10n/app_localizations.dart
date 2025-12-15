import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NyayaConnect'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Justice delivered digitally'**
  String get tagline;

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World'**
  String get helloWorld;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}'**
  String welcome(String userName);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @consultLawyer.
  ///
  /// In en, this message translates to:
  /// **'Consult Lawyer'**
  String get consultLawyer;

  /// No description provided for @documentReview.
  ///
  /// In en, this message translates to:
  /// **'Document Review'**
  String get documentReview;

  /// No description provided for @meetingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Meeting Scheduled'**
  String get meetingScheduled;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @caseFiles.
  ///
  /// In en, this message translates to:
  /// **'Case files'**
  String get caseFiles;

  /// No description provided for @consultationSummaries.
  ///
  /// In en, this message translates to:
  /// **'Consultation Summaries'**
  String get consultationSummaries;

  /// No description provided for @courtOrders.
  ///
  /// In en, this message translates to:
  /// **'Court Orders'**
  String get courtOrders;

  /// No description provided for @legalTemplates.
  ///
  /// In en, this message translates to:
  /// **'Legal Templates'**
  String get legalTemplates;

  /// No description provided for @eCourt.
  ///
  /// In en, this message translates to:
  /// **'E-Court'**
  String get eCourt;

  /// No description provided for @eCourtDesc.
  ///
  /// In en, this message translates to:
  /// **'Access virtual courtrooms and manage your cases digitally.'**
  String get eCourtDesc;

  /// No description provided for @enterCourtroom.
  ///
  /// In en, this message translates to:
  /// **'Enter a courtroom'**
  String get enterCourtroom;

  /// No description provided for @aiDoubtForum.
  ///
  /// In en, this message translates to:
  /// **'AI Doubt Forum'**
  String get aiDoubtForum;

  /// No description provided for @aiDoubtForumDesc.
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered assistance for legal queries and case research.'**
  String get aiDoubtForumDesc;

  /// No description provided for @askAiAgent.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Agent'**
  String get askAiAgent;

  /// No description provided for @contactNgo.
  ///
  /// In en, this message translates to:
  /// **'Contact NGO'**
  String get contactNgo;

  /// No description provided for @contactNgoDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach out to registered NGOs for free legal assistance and support.'**
  String get contactNgoDesc;

  /// No description provided for @contactNow.
  ///
  /// In en, this message translates to:
  /// **'Contact Now'**
  String get contactNow;

  /// No description provided for @findProbono.
  ///
  /// In en, this message translates to:
  /// **'Find Probono Lawyer'**
  String get findProbono;

  /// No description provided for @findProbonoDesc.
  ///
  /// In en, this message translates to:
  /// **'Because justice should never depend on your income—get the legal support you deserve at no cost.'**
  String get findProbonoDesc;

  /// No description provided for @myLearning.
  ///
  /// In en, this message translates to:
  /// **'My Learning'**
  String get myLearning;

  /// No description provided for @myLearningDesc.
  ///
  /// In en, this message translates to:
  /// **'Your Path to Legal Knowledge Starts Here. Master Legal Basics, Anytime, Anywhere.'**
  String get myLearningDesc;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get startLearning;

  /// No description provided for @whatClientsSay.
  ///
  /// In en, this message translates to:
  /// **'What Clients Say'**
  String get whatClientsSay;

  /// No description provided for @emergencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Emergency Help'**
  String get emergencyHelp;

  /// No description provided for @emergencyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Legal Help'**
  String get emergencyDialogTitle;

  /// No description provided for @emergencyDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you need immediate legal assistance? We can connect you with an emergency consultant right away.'**
  String get emergencyDialogContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @getHelpNow.
  ///
  /// In en, this message translates to:
  /// **'Get Help Now'**
  String get getHelpNow;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
