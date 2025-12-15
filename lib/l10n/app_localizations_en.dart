// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NyayaConnect';

  @override
  String get tagline => 'Justice delivered digitally';

  @override
  String get helloWorld => 'Hello World';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String welcome(String userName) {
    return 'Welcome, $userName';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get consultLawyer => 'Consult Lawyer';

  @override
  String get documentReview => 'Document Review';

  @override
  String get meetingScheduled => 'Meeting Scheduled';

  @override
  String get documents => 'Documents';

  @override
  String get caseFiles => 'Case files';

  @override
  String get consultationSummaries => 'Consultation Summaries';

  @override
  String get courtOrders => 'Court Orders';

  @override
  String get legalTemplates => 'Legal Templates';

  @override
  String get eCourt => 'E-Court';

  @override
  String get eCourtDesc =>
      'Access virtual courtrooms and manage your cases digitally.';

  @override
  String get enterCourtroom => 'Enter a courtroom';

  @override
  String get aiDoubtForum => 'AI Doubt Forum';

  @override
  String get aiDoubtForumDesc =>
      'Get AI-powered assistance for legal queries and case research.';

  @override
  String get askAiAgent => 'Ask AI Agent';

  @override
  String get contactNgo => 'Contact NGO';

  @override
  String get contactNgoDesc =>
      'Reach out to registered NGOs for free legal assistance and support.';

  @override
  String get contactNow => 'Contact Now';

  @override
  String get findProbono => 'Find Probono Lawyer';

  @override
  String get findProbonoDesc =>
      'Because justice should never depend on your income—get the legal support you deserve at no cost.';

  @override
  String get myLearning => 'My Learning';

  @override
  String get myLearningDesc =>
      'Your Path to Legal Knowledge Starts Here. Master Legal Basics, Anytime, Anywhere.';

  @override
  String get startLearning => 'Start Learning';

  @override
  String get whatClientsSay => 'What Clients Say';

  @override
  String get emergencyHelp => 'Emergency Help';

  @override
  String get emergencyDialogTitle => 'Emergency Legal Help';

  @override
  String get emergencyDialogContent =>
      'Do you need immediate legal assistance? We can connect you with an emergency consultant right away.';

  @override
  String get cancel => 'Cancel';

  @override
  String get getHelpNow => 'Get Help Now';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';
}
