import 'package:flutter/material.dart';

class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = ['FIR', 'Challan', 'ID Proof', 'Address Proof'];
    return Scaffold(
      appBar:AppBar(
  title: const Text('My Documents',style: TextStyle(color: Colors.white)),
  backgroundColor: const Color.fromARGB(255, 0, 183, 255), // make AppBar background transparent
  
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
