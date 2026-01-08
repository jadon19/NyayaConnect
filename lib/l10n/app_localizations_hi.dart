// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'न्याय कनेक्ट';

  @override
  String get tagline => 'डिजिटल रूप से न्याय प्रदान करना';

  @override
  String get helloWorld => 'नमस्ते दुनिया';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String welcome(String userName) {
    return 'स्वागत है, $userName';
  }

  @override
  String get quickActions => 'त्वरित कार्रवाई';

  @override
  String get consultLawyer => 'वकील से सलाह लें';

  @override
  String get documentReview => 'दस्तावेज़ समीक्षा';

  @override
  String get meetingScheduled => 'बैठक निर्धारित';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String get caseFiles => 'केस फ़ाइलें';

  @override
  String get consultationSummaries => 'परामर्श सारांश';

  @override
  String get courtOrders => 'अदालत के आदेश';

  @override
  String get legalTemplates => 'कानूनी टेम्पलेट्स';

  @override
  String get eCourt => 'ई-कोर्ट';

  @override
  String get eCourtDesc =>
      'वर्चुअल कोर्टरूम तक पहुंचें और अपने मामलों को डिजिटल रूप से प्रबंधित करें।';

  @override
  String get enterCourtroom => 'अदालत में प्रवेश करें';

  @override
  String get aiDoubtForum => 'एआई शंका मंच';

  @override
  String get aiDoubtForumDesc =>
      'कानूनी प्रश्नों और केस अनुसंधान के लिए एआई-संचालित सहायता प्राप्त करें।';

  @override
  String get askAiAgent => 'एआई एजेंट से पूछें';

  @override
  String get contactNgo => 'एनजीओ से संपर्क करें';

  @override
  String get contactNgoDesc =>
      'मुफ्त कानूनी सहायता और समर्थन के लिए पंजीकृत एनजीओ से संपर्क करें।';

  @override
  String get contactNow => 'अभी संपर्क करें';

  @override
  String get findProbono => 'प्रो-बोनो वकील खोजें';

  @override
  String get findProbonoDesc =>
      'क्योंकि न्याय कभी भी आपकी आय पर निर्भर नहीं होना चाहिए - बिना किसी लागत के कानूनी सहायता प्राप्त करें।';

  @override
  String get myLearning => 'मेरी शिक्षा';

  @override
  String get myLearningDesc =>
      'कानूनी ज्ञान की आपकी राह यहाँ से शुरू होती है। कहीं भी, कभी भी कानूनी मूल बातें सीखें।';

  @override
  String get startLearning => 'सीखना शुरू करें';

  @override
  String get whatClientsSay => 'ग्राहक क्या कहते हैं';

  @override
  String get emergencyHelp => 'आपातकालीन सहायता';

  @override
  String get emergencyDialogTitle => 'आपातकालीन कानूनी सहायता';

  @override
  String get emergencyDialogContent =>
      'क्या आपको तत्काल कानूनी सहायता की आवश्यकता है? हम आपको तुरंत एक आपातकालीन सलाहकार से जोड़ सकते हैं।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get getHelpNow => 'अभी मदद लें';

  @override
  String get goodMorning => 'सुप्रभात';

  @override
  String get goodAfternoon => 'नमस्कार';

  @override
  String get goodEvening => 'शुभ संध्या';
}
