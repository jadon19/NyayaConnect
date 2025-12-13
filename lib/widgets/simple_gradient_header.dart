import 'package:flutter/material.dart';

class SimpleGradientHeader extends StatelessWidget {
  final String title;

  const SimpleGradientHeader({
    super.key,
    required this.title,
  });

  

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF90CAF9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),

      child: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.only(top:30,bottom: 16),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
