import 'package:flutter/material.dart';

class SupportingDocumentsPage extends StatelessWidget {
  const SupportingDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence / Supporting Docs'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Text(
          'Photos, receipts, and other supporting documents will appear here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
