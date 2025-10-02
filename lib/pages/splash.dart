import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding/onboarding_page_1.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  late final AnimationController _textController;
  late final Animation<double> _textAnimation;

  late double logoMaxSize;
  late double logoToTextSpacing;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;

      logoMaxSize = 150;
      logoToTextSpacing = screenHeight * 0.05;

      _logoAnimation = Tween<double>(begin: 0, end: logoMaxSize * 0.5)
          .animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

      _textAnimation = Tween<double>(begin: 0, end: 1)
          .animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

      _logoController.forward();

      _logoController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _textController.forward();
        }
      });

      // Wait 3 seconds after animations complete
      _textController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 700),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const OnboardingPage1(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  final curved =
                      CurvedAnimation(parent: animation, curve: Curves.easeOut);
                  return FadeTransition(opacity: curved, child: child);
                },
              ),
            );
          });
        }
      });
    });
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
                children: const [
                  Text(
                    'NyayaConnect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004AAD),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Justice delivered digitally',
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