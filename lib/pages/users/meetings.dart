import 'package:flutter/material.dart';

class MeetingScheduledPage extends StatefulWidget {
  const MeetingScheduledPage({super.key});

  @override
  State<MeetingScheduledPage> createState() => _MeetingScheduledPageState();
}

class _MeetingScheduledPageState extends State<MeetingScheduledPage> {
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
        'title': 'Meeting on ${pickedDate.day}/${pickedDate.month}/${pickedDate.year}',
        'time': '${pickedTime.format(context)}',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meeting scheduled successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: _meetings.isEmpty
          ? const Center(
        child: Text(
          'No meetings scheduled yet.\nTap + to schedule one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _meetings.length,
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text(meeting['title'] ?? ''),
              subtitle: Text('Time: ${meeting['time']}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scheduleMeeting,
        backgroundColor: const Color(0xFF42A5F5),
        child: const Icon(Icons.add),
      ),
    );
  }
}
