import 'package:flutter/material.dart';

class LegalLiteracyScreen extends StatelessWidget {
  const LegalLiteracyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      {"title": "Fundamental Rights", "desc": "Know your constitutional rights."},
      {"title": "Consumer Protection", "desc": "Understand your rights as a consumer."},
      {"title": "Property Law", "desc": "Basics of buying/selling property."},
      {"title": "Family Law", "desc": "Marriage, divorce, inheritance laws."},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Legal Literacy")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: Text(topics[index]["title"]!),
              subtitle: Text(topics[index]["desc"]!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to detailed article
              },
            ),
          );
        },
      ),
    );
  }
}