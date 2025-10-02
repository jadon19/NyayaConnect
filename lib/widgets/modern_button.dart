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
          elevation: MaterialStateProperty.resolveWith<double>((states) {
            if (states.contains(MaterialState.pressed)) return 12;
            return 6;
          }),
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            // show gradient as overlay only if gradient is provided
            if (states.contains(MaterialState.pressed) && gradient != null) {
              return Colors.transparent;
            }
            return Colors.white; // default button color
          }),
          shadowColor: MaterialStateProperty.all(Colors.black54),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(MaterialState.pressed)) {
                // overlay with semi-transparent primary color
                return gradient == null
                    ? Colors.blue.withOpacity(0.2)
                    : null;
              }
              return null;
            },
          ),
          padding: MaterialStateProperty.all(
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
