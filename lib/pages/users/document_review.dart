import 'package:flutter/material.dart';

class DocumentReviewPage extends StatelessWidget {
  const DocumentReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Review'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Text(
          'This is the Document Review page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
