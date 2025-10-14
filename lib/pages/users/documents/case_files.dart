import 'package:flutter/material.dart';

class CaseFilesPage extends StatelessWidget {
  const CaseFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Files'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Text(
          'List of Case Files (FIRs, Petitions, Agreements) will appear here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
