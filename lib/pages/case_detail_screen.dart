import 'package:flutter/material.dart';

class CaseDetailScreen extends StatelessWidget {
  final String caseTitle;

  const CaseDetailScreen({super.key, required this.caseTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caseTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Case Details",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              "More details about $caseTitle.\n\n"
                  "For example:\n"
                  "- Parties involved\n"
                  "- Case status\n"
                  "- Hearing dates\n"
                  "- Notes",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Notes added")),
                );
              },
              icon: const Icon(Icons.note_add),
              label: const Text("Add Notes"),
            )
          ],
        ),
      ),
    );
  }
}