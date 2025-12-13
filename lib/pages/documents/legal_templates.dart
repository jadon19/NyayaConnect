import 'package:flutter/material.dart';

class LegalTemplatesPage extends StatelessWidget {
  const LegalTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Templates / Forms'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Text(
          'Templates like Notice to Tenant, Affidavit, Power of Attorney will appear here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
