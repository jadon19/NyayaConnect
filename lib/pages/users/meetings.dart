import 'package:flutter/material.dart';

class MeetingScheduledPage extends StatelessWidget {
  const MeetingScheduledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Scheduled'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Text(
          'This is the Meeting Scheduled page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
