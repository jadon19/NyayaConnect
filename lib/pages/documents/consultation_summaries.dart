import 'package:flutter/material.dart';

class ConsultationSummariesPage extends StatelessWidget {
  const ConsultationSummariesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Summaries'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Text(
          'Past consultation notes and summaries will appear here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
