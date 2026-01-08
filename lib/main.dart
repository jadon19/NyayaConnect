import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'pages/signup/splash.dart';
import 'pages/advocate/homescreen.dart';
import 'pages/users/homescreen.dart';
import 'pages/judge/homescreen.dart';
import 'pages/ai_doubt_forum.dart';
import 'pages/contact_ngo_page.dart';
import 'pages/learning/learning_main.dart';
import 'services/user_manager.dart';
import 'pages/probono_opp.dart';
import 'pages/calls/meeting_page.dart';
import 'pages/documents/consultation_summaries.dart';
import 'pages/advocate/features/manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/documents/cases/case_files.dart';
import 'package:nyaya_connect/l10n/app_localizations.dart';
import 'services/language_manager.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Background Message Received: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  await dotenv.load(fileName: ".env");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

Future<void> setupFCM(String uid) async {
  final messaging = FirebaseMessaging.instance;

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Get token
  final token = await messaging.getToken();
  debugPrint("📨 FCM Token: $token");

  if (token != null) {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      "fcmToken": token,
    }, SetOptions(merge: true));
  }

  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("Foreground Notification: ${message.notification?.title}");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageManager(),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nyaya Connect',
          theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
          locale: LanguageManager().locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootPage(),
          routes: {
            '/contactNgo': (_) => const ContactNgoPage(),
            '/mylearning': (_) => const LearningMainPage(),
            '/aiDoubt': (_) => const AIDoubtForumPage(),
            '/probono': (_) => const ProbonoPage(),
            '/meetings': (_) => MeetingsScreen(),
            '/clients': (_) => ConsultationSummariesPage(),
            '/manager' :(_) => ManagerPage(),
            '/FileCase':(_)=> CaseFilesPage(),
          },
        );
      },
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) return doc.data();
    } catch (e) {
      debugPrint('Firestore read error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const ExitOnBackPage(child: SplashPage());
    }

    Future.microtask(() => setupFCM(user.uid));

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;

        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('User data not found.')),
          );
        }

         final lawyerId = data['lawyerId'];
    final judgeId = data['judgeId'];
    final userName = data['name'] ?? 'User';

    UserManager().userName = userName;
    UserManager().userCustomId = data['userId'];
    UserManager().lawyerId = lawyerId;
    UserManager().judgeCustomId = judgeId;

    final isLawyer = lawyerId != null && lawyerId.toString().trim().isNotEmpty;
    final isJudge  = judgeId != null && judgeId.toString().trim().isNotEmpty;

    return ExitOnBackPage(
      child: isJudge
          ? HomeScreenJudge(userName: userName)
          : isLawyer
              ? HomeScreenLawyer(userName: userName)
              : HomeScreenUser(userName: userName),
    );
      },
    );
  }
}

class ExitOnBackPage extends StatelessWidget {
  final Widget child;
  const ExitOnBackPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Do you really want to exit Nyaya Connect?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: child,
    );
  }
}
