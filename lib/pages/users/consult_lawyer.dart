import 'package:flutter/material.dart';

class ConsultLawyerPage extends StatelessWidget {
  const ConsultLawyerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consult Lawyer'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Text(
          'This is the Consult Lawyer page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
