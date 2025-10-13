// lib/screens/features/meeting_screen.dart
import 'package:flutter/material.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final List<Map<String, String>> _meetings = [];

  Future<void> _scheduleMeeting() async {
    DateTime now = DateTime.now();

    // Pick a date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null) return;

    // Pick a time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _meetings.add({
        "title": "Meeting with Client",
        "datetime": finalDateTime.toString(),
      });
    });
  }

  String _formatDateTime(String dt) {
    final date = DateTime.parse(dt);
    return "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meetings"),
        centerTitle: true,
      ),
      body: _meetings.isEmpty
          ? const Center(child: Text("No meetings scheduled yet."))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _meetings.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(meeting["title"]!),
              subtitle: Text(_formatDateTime(meeting["datetime"]!)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _meetings.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scheduleMeeting,
        icon: const Icon(Icons.add),
        label: const Text("Schedule"),
      ),
    );
  }
}