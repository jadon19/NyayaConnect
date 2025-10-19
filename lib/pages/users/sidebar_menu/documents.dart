import 'package:flutter/material.dart';

class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = ['FIR', 'Challan', 'ID Proof', 'Address Proof'];
    return Scaffold(
      appBar:AppBar(
  title: const Text('My Documents'),
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
        itemCount: documents.length,
        itemBuilder: (_, index) {
          return Card(
            elevation: 4,
            shadowColor: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text(documents[index]),
              trailing: const Icon(Icons.download, color: Colors.blue),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
