import 'package:flutter/material.dart';
import '../../../models/meeting_model.dart';

class JoinCallScreen extends StatelessWidget {
  final Meeting meeting;

  const JoinCallScreen({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Call")),
      body: Center(
        child: Text(
          "Call UI will be implemented here.\n\nMeeting ID: ${meeting.id}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
