import 'package:flutter/material.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width; // optional, default full width
  final double height; // optional
  final Gradient? gradient; // optional gradient on tap

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 50,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) return 12;
            return 6;
          }),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            // show gradient as overlay only if gradient is provided
            if (states.contains(WidgetState.pressed) && gradient != null) {
              return Colors.transparent;
            }
            return Colors.white; // default button color
          }),
          shadowColor: WidgetStateProperty.all(Colors.black54),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                // overlay with semi-transparent primary color
                return gradient == null
                    ? Colors.blue.withOpacity(0.2)
                    : null;
              }
              return null;
            },
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient, // only visible on tap if provided
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
                color: Color(0xFF004AAD),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
