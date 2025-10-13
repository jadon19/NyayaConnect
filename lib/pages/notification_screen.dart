import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {"title": "New Case Update", "time": "2h ago"},
      {"title": "Meeting Scheduled", "time": "Yesterday"},
      {"title": "Document Approved", "time": "2 days ago"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: Text(notifications[index]["title"]!),
            subtitle: Text(notifications[index]["time"]!),
            trailing: IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () {
                // TODO: mark as read
              },
            ),
          );
        },
      ),
    );
  }
}