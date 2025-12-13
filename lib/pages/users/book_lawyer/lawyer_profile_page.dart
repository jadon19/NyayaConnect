import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'book_appointment_screen.dart';

class LawyerProfilePage extends StatefulWidget {
  final String lawyerId;

  const LawyerProfilePage({
    Key? key,
    required this.lawyerId,
  }) : super(key: key);

  @override
  State<LawyerProfilePage> createState() => _LawyerProfilePageState();
}

class _LawyerProfilePageState extends State<LawyerProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  Map<String, dynamic>? _lawyerData;
  double _rating = 0.0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLawyerData();
  }

  Future<void> _fetchLawyerData() async {
  try {
    // 1. Fetch base lawyer data
    final lawyerDoc = await _firestore
        .collection('lawyers')
        .doc(widget.lawyerId)
        .get();
    if (!lawyerDoc.exists) {
      // Still necessary to prevent crashes
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lawyer not found')),
        );
        Navigator.pop(context);
      }
      return;
    }
    final lawyerData = lawyerDoc.data()!;
    // 2. Fetch lawyer_details/{id} in parallel
    final detailsFuture = _firestore
        .collection('lawyer_details')
        .doc(widget.lawyerId)
        .get();

    // 3. Fetch lawyer_ratings/{id} in parallel
    final ratingFuture = _firestore
        .collection('lawyer_ratings')
        .doc(widget.lawyerId)
        .get();

    final detailsDoc = await detailsFuture;
    final ratingDoc = await ratingFuture;

    final details = detailsDoc.data() ?? {};
    final ratings = ratingDoc.data() ?? {};

    // 4. Combine data into a single map
    final combinedData = {
      ...lawyerData,   // name, phone, email, etc.
      ...details,      // speciality, experienceYears, gender, languages, etc.
    };

    setState(() {
      _lawyerData = combinedData;

      _rating = (ratings['avgRating'] is int)
          ? (ratings['avgRating'] as int).toDouble()
          : (ratings['avgRating'] ?? 0.0).toDouble();

      _reviewCount = ratings['totalRatings'] ?? 0;

      _loading = false;
    });
  } catch (e) {
    debugPrint('Error fetching lawyer data: $e');
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text('Lawyer Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_lawyerData == null) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text('Lawyer Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: Text('Lawyer not found')),
      );
    }

    final name = _lawyerData!['name'] ?? 'Lawyer';
    final speciality = _lawyerData!['speciality'] ?? 'General Practice';
    final experienceYears = _lawyerData!['experienceYears'] ?? 0;
    final languages = List<String>.from(_lawyerData!['languages'] ?? []);
    final charges = _lawyerData!['chargesPerHour'] ?? _lawyerData!['charges'] ?? 0;
    final profilePic = _lawyerData!['profilePicUrl'];
    final bio = _lawyerData!['bio'] ?? 'An experienced legal professional with a strong background in law practice and a reputation for resolving complex cases effectively.';

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Lawyer Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
              backgroundColor: const Color(0xFF42A5F5),
              child: profilePic == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'L',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              speciality,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber.shade700),
                const SizedBox(width: 4),
                Text('$_rating ($_reviewCount reviews)'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(Icons.person, 'Exp', '$experienceYears years'),
                _buildStat(Icons.language, 'Languages', languages.join(', ')),
                _buildStat(
                  Icons.currency_rupee,
                  'Charges',
                  '₹$charges/hr',
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Lawyer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bio,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookAppointmentScreen(
                      lawyerId: widget.lawyerId,
                      lawyerName: name,
                    ),
                  ),
                );
              },
              child: const Text(
                'Book Appointment',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF42A5F5)),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
      ],
    );
  }
}

