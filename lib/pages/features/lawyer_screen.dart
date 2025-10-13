// lib/screens/features/lawyer_screen.dart
import 'package:flutter/material.dart';

class LawyerScreen extends StatefulWidget {
  const LawyerScreen({super.key});

  @override
  State<LawyerScreen> createState() => _LawyerScreenState();
}

class _LawyerScreenState extends State<LawyerScreen> {
  final List<Map<String, String>> _lawyers = [
    {
      "name": "Adv. Anjali Sharma",
      "specialty": "Family & Divorce",
      "location": "Delhi",
      "rating": "4.8"
    },
    {
      "name": "Adv. Rohit Verma",
      "specialty": "Criminal Law",
      "location": "Mumbai",
      "rating": "4.6"
    },
    {
      "name": "Adv. Priya Das",
      "specialty": "Property & Real Estate",
      "location": "Bengaluru",
      "rating": "4.7"
    },
  ];

  String _query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = _lawyers
        .where((lawyer) =>
    lawyer["name"]!.toLowerCase().contains(_query.toLowerCase()) ||
        lawyer["specialty"]!
            .toLowerCase()
            .contains(_query.toLowerCase()) ||
        lawyer["location"]!
            .toLowerCase()
            .contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find a Lawyer"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔎 Search Bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by name, specialty, or location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),

            // 👨‍⚖️ Lawyers List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("No lawyers found"))
                  : ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final lawyer = filtered[i];
                  return _LawyerCard(
                    name: lawyer["name"]!,
                    specialty: lawyer["specialty"]!,
                    location: lawyer["location"]!,
                    rating: lawyer["rating"]!,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Opening ${lawyer["name"]}'s profile..."),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LawyerCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String location;
  final String rating;
  final VoidCallback onTap;

  const _LawyerCard({
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  name[0],
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(specialty,
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(rating),
                        const Spacer(),
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(location,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}