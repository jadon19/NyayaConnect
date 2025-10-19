import 'package:flutter/material.dart';

class CallLogsScreen extends StatelessWidget {
  const CallLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = [
      {'name': 'Milind Awasthi', 'time': 'Today, 10:30 AM'},
      {'name': 'Priya Sharma', 'time': 'Yesterday, 4:15 PM'},
      {'name': 'Lawyer Helpdesk', 'time': '2025-10-14, 2:00 PM'},
    ];

    return Scaffold(
      appBar: AppBar(
  title: const Text('Call Logs'),
  backgroundColor: Colors.transparent, // make AppBar background transparent
  elevation: 0,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D47A1), // Dark Blue (top)
          Color(0xFF64B5F6), // Light Blue (bottom)
        ],
      ),
    ),
  ),
),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: calls.length,
        itemBuilder: (_, index) {
          final call = calls[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.lightBlueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(call['name']!),
            subtitle: Text(call['time']!),
            trailing: const Icon(Icons.call, color: Colors.green),
            onTap: () {},
          );
        },
      ),
    );
  }
}
