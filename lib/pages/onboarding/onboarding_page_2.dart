import 'package:flutter/material.dart';
import 'package:nyaya_connect/pages/login.dart';
import 'onboarding_page_3.dart';
import '../../widgets/modern_button.dart';


class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _skipFadeAnimation;

  @override
  void initState() {
    super.initState();
    final screenHeight =
        MediaQueryData.fromView(WidgetsBinding.instance.window).size.height;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _radiusAnimation = Tween<double>(begin: 0, end: screenHeight * 0.6)
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _skipFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Circle from top
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(screenWidth, screenHeight),
                painter: CirclePainter(
                  alignment: Alignment.topCenter,
                  radius: _radiusAnimation.value,
                ),
              );
            },
          ),

          // Fade-in Skip button
          Positioned(
            top: 40,
            right: 24,
            child: FadeTransition(
              opacity: _skipFadeAnimation,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ),

          // Content inside the circle
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: SizedBox(
                height: screenHeight * 0.6, // height of the circle area
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      const Text(
                        'Discover Legal Aid Effortlessly',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Paragraph
                      const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n'
                        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Next Button
                      SizedBox(
  width: screenWidth * 0.5,
  child: ModernButton(
    text: "Next",   // <-- use label here
    onPressed: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingPage3(),
          transitionsBuilder: (_, a, __, c) {
            return FadeTransition(opacity: a, child: c);
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    },
  ),
),


                      const SizedBox(height: 16),

                      // Page indicators
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConcentricDot(active: false),
                          ConcentricDot(active: true),
                          ConcentricDot(active: false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Image in remaining white area (outside circle)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: SizedBox(
                width: screenWidth * 0.7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/onboarding2.jpg',
                    key: UniqueKey(),
                    fit: BoxFit.contain, // fully visible, not cropped
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Circle painter
class CirclePainter extends CustomPainter {
  final Alignment alignment;
  final double radius;
  CirclePainter({required this.alignment, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF004AAD);
    Offset center = alignment == Alignment.topCenter
        ? Offset(size.width / 2, 0)
        : size.center(Offset.zero);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.alignment != alignment;
}

// Page indicator dot
class ConcentricDot extends StatelessWidget {
  final bool active;
  const ConcentricDot({this.active = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(active ? 1.0 : 0.4),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(active ? 1.0 : 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
