import 'package:flutter/material.dart';
import 'package:nyaya_connect/pages/login.dart';
import '../../widgets/modern_button.dart';

class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({super.key});

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _fadeAnimation;

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
          // Circle from right
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: CirclePainter(
                  alignment: Alignment.centerRight,
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 50),

                    // Title wrapped inside circle (split in 2 lines)
                    const Text(
                      'Sign Up\nto Get Started',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 30), // margin before image

                    // Image (inside circle, minimal margins)
                    SizedBox(
                      width: screenWidth * 0.7, // slightly smaller than circle radius
                      height: screenWidth * 0.7 * (1544 / 1920), // maintain aspect ratio
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/onboarding3.jpg',
                          key: UniqueKey(), // prevent caching
                          fit: BoxFit.cover, // zoom/stretch to fill
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), // spacing between image and paragraph

                    // Paragraph
                    const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n'
                      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n'
                      'Ut enim ad minim veniam.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const Spacer(),

                    // Button + concentric page indicator
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
  width: screenWidth * 0.5,
  child: ModernButton(
    text: "Sign Up",
    onPressed: () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthPage(),
          transitionsBuilder: (_, a, __, c) {
            final curved = CurvedAnimation(parent: a, curve: Curves.easeInOut);
            return FadeTransition(opacity: curved, child: c);
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    },
  ),
),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            ConcentricDot(active: false),
                            ConcentricDot(active: false),
                            ConcentricDot(active: true),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Alignment alignment;
  final double radius;
  CirclePainter({required this.alignment, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF004AAD);
    Offset center = Offset(size.width, size.height / 2);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      oldDelegate.radius != radius;
}

class ConcentricDot extends StatelessWidget {
  final bool active;
  const ConcentricDot({this.active = false, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
