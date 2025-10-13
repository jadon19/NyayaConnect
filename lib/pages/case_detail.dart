import 'package:flutter/material.dart';
import 'case_detail_screen.dart';

class CasesScreen extends StatelessWidget {
  final String role; // "Client" or "Advocate"

  const CasesScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final List<String> dummyCases = [
      "Case #101 - Property Dispute",
      "Case #102 - Family Court",
      "Case #103 - Employment Issue",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("$role Cases"),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyCases.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.gavel, color: Colors.blue),
            title: Text(dummyCases[index]),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CaseDetailScreen(
                    caseTitle: dummyCases[index], // ✅ passes correct title
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}