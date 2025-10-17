import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nyaya_connect/pages/ai_doubt_forum.dart';

import 'pages/splash.dart';
import 'pages/advocate/homescreen.dart';
import 'pages/users/homescreen.dart';
import 'pages/judge/homescreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Firebase and load .env *in parallel*
    await Future.wait([
      Firebase.initializeApp(),
      dotenv.load(fileName: ".env"),
    ]);

    debugPrint('✅ Firebase initialized and .env loaded successfully');
    debugPrint("✅ OpenAI Key: ${dotenv.env['OPENAI_API_KEY']}");
    debugPrint("✅ Indian Kanoon Key: ${dotenv.env['INDIAN_KANOON_API_KEY']}");
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nyaya Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RootPage(),
      routes: {
        '/aiDoubt': (context) => const AIDoubtForumPage(),
      },
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  /// ✅ Fetch user details (isLawyer + userName) from Firestore
  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    try {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Firestore read error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ✅ If user not logged in → Splash/Login
    if (user == null) {
      return const ExitOnBackPage(child: SplashPage());
    }

    // ✅ If logged in → load role + username
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data')),
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

        return ExitOnBackPage(
          child: judgeId != null
              ? HomeScreenJudge(userName: userName)
              : lawyerId != null
              ? HomeScreenLawyer(userName: userName)
              : HomeScreenUser(userName: userName),
        );
      },
    );
  }
}

/// ✅ Common wrapper to show exit confirmation popup
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
