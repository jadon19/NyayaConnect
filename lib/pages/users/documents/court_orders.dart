import 'package:flutter/material.dart';

class CourtOrdersPage extends StatelessWidget {
  const CourtOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Court Orders'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Text(
          'Court notices, hearings, and judgments will appear here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
