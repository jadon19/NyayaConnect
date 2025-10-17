import 'package:flutter/material.dart';
import 'onboarding_page_2.dart';
import '../login.dart';
import '../../widgets/modern_button.dart';


class OnboardingPage1 extends StatefulWidget {
  const OnboardingPage1({super.key});

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _skipFadeAnimation;

  @override
  void initState() {
    super.initState();
    final screenWidth =
        MediaQueryData.fromView(WidgetsBinding.instance.window).size.width;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _radiusAnimation = Tween<double>(begin: 0, end: screenWidth).animate(
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Circle from left
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: CirclePainter(
                  alignment: Alignment.centerLeft,
                  radius: _radiusAnimation.value,
                ),
              );
            },
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // Title
                    const Text(
                      'Welcome to NyayaConnect',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Image
                    SizedBox(
                      width: screenWidth * 0.7,
                      height: screenWidth * 0.7 * (1544 / 1920),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/onboarding1.jpg',
                          key: UniqueKey(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Paragraph
                    const Text(
                      'Empowering citizens and lawyers through one digital platform.\n'
                          'Connect, consult, and manage legal matters securely — all in one place.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const Spacer(),

                    // ModernButton + Page Indicators
                    ModernButton(
                      text: 'Get Started',
                      width: screenWidth * 0.5,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const OnboardingPage2(),
                            transitionsBuilder: (_, a, __, c) {
                              final curved =
                                  CurvedAnimation(parent: a, curve: Curves.easeInOut);
                              return FadeTransition(opacity: curved, child: c);
                            },
                            transitionDuration: const Duration(milliseconds: 700),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ConcentricDot(active: true),
                        ConcentricDot(active: false),
                        ConcentricDot(active: false),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Skip button
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
                    color: Color(0xFF004AAD),
                    fontSize: 16,
                    fontFamily: 'Roboto',
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

// Custom painter for circle
class CirclePainter extends CustomPainter {
  final Alignment alignment;
  final double radius;
  CirclePainter({required this.alignment, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF004AAD);
    Offset center = Offset(0, size.height / 2);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      oldDelegate.radius != radius;
}

// Concentric page indicator
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
