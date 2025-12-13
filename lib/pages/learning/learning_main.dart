import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'flashcard_viewer.dart';

class LearningMainPage extends StatefulWidget {
  const LearningMainPage({super.key});

  @override
  State<LearningMainPage> createState() => _LearningMainPageState();
}

class _LearningMainPageState extends State<LearningMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BD3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BD3FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Legal Quest',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          FutureBuilder<int>(
            future: _getUserPoints(),
            builder: (context, snapshot) {
              final points = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 4),
                    Text(
                      '$points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8BD3FF),
              Color(0xFF6BB5E8),
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Select a Case Study',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildCaseCard(
                  caseNumber: 1,
                  title: 'Kesavananda Bharati v. State of Kerala (1973)',
                  description: 'Constitutional Amendments & Basic Structure Doctrine',
                  onTap: () => _navigateToCase(1),
                ),
                const SizedBox(height: 20),
                _buildCaseCard(
                  caseNumber: 2,
                  title: 'Maneka Gandhi v. Union of India (1978)',
                  description: 'Expansion of Article 21 – Fair, Just & Reasonable Procedure',
                  onTap: () => _navigateToCase(2),
                ),
                const SizedBox(height: 20),
                _buildCaseCard(
                  caseNumber: 3,
                  title: 'Vishaka v. State of Rajasthan (1997)',
                  description: 'Sexual Harassment at Workplace – Foundation of the POSH Act',
                  onTap: () => _navigateToCase(3),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int> _getUserPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['points'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildCaseCard({
    required int caseNumber,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Case $caseNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004AAD),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7785A0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF3CA2FF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCase(int caseNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardViewer(caseNumber: caseNumber),
      ),
    );
  }
}

