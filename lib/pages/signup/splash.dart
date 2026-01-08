import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding/onboarding_page_1.dart';
import 'login.dart';
import 'package:nyaya_connect/l10n/app_localizations.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  late final AnimationController _textController;
  late final Animation<double> _textAnimation;

  late double logoMaxSize;
  late double logoToTextSpacing;
  @override
void initState() {
  super.initState();

  // Initialize controllers only
  _logoController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  _textController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
}
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  // MediaQuery is safe to use here
  final screenHeight = MediaQuery.of(context).size.height;
  logoMaxSize = 150;
  logoToTextSpacing = screenHeight * 0.02;

  _logoAnimation = Tween<double>(
    begin: 0, // start from 0 (blank)
    end: logoMaxSize * 0.5,
  ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

  _textAnimation = Tween<double>(
    begin: 0, // fully transparent initially
    end: 1,
  ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

  // Start animation after first frame to ensure safe context usage
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _logoController.forward();
  });

  _logoController.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      _textController.forward();
    }
  });

  _textController.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(seconds: 3), _navigateNext);
    }
  });
}



  

  /// Check first launch and navigate accordingly
  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      _navigateWithFade(const OnboardingPage1());
    } else {
      _navigateWithFade(const AuthPage());
    }
  }

  void _navigateWithFade(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return SizedBox(
                  height: _logoAnimation.value,
                  width: _logoAnimation.value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/logo.png',
                width: logoMaxSize,
                height: logoMaxSize,
              ),
            ),
            SizedBox(height: logoToTextSpacing),
            FadeTransition(
              opacity: _textAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004AAD),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF38B6FF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
