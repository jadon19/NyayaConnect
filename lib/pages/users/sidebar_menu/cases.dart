import 'package:flutter/material.dart';

class MyCasesScreen extends StatelessWidget {
  const MyCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cases = [
      {
        'caseNo': 'C1234',
        'court': 'District Court',
        'nextHearing': '2025-11-05',
        'lawyer': 'Adv. Milind'
      },
      {
        'caseNo': 'C5678',
        'court': 'City Court',
        'nextHearing': '2025-12-01',
        'lawyer': 'Adv. Priya'
      },
    ];

    return Scaffold(
      appBar: AppBar(
  title: const Text('Cases'),
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

      body: cases.isEmpty
          ? const Center(child: Text('No Pending Cases'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cases.length,
              itemBuilder: (_, index) {
                final c = cases[index];
                return Card(
                  elevation: 4,
                  shadowColor: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('Case No: ${c['caseNo']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Court: ${c['court']}'),
                        Text('Next Hearing: ${c['nextHearing']}'),
                        Text('Lawyer: ${c['lawyer']}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward, color: Colors.blue),
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
