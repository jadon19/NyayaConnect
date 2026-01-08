import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/user_manager.dart';

class RateLawyerPage extends StatefulWidget {
  final String lawyerId;
  final String lawyerName;

  const RateLawyerPage({
    super.key,
    required this.lawyerId,
    required this.lawyerName,
  });

  @override
  State<RateLawyerPage> createState() => _RateLawyerPageState();
}

class _RateLawyerPageState extends State<RateLawyerPage> {
  int _rating = 0;
  final _reviewCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submitRating() async {
    if (_rating == 0) return;

    setState(() => _loading = true);

    final user = UserManager();
    final ref = FirebaseFirestore.instance
        .collection('lawyer_ratings')
        .doc(widget.lawyerId);

    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(ref);

      double avg = 0;
      int count = 0;
      List reviews = [];

      if (snap.exists) {
        avg = (snap['avgRating'] ?? 0).toDouble();
        count = snap['totalRatings'] ?? 0;
        reviews = List.from(snap['reviews'] ?? []);
      }

      final newAvg = ((avg * count) + _rating) / (count + 1);

      reviews.add({
        'userId': user.userCustomId,
        'userName': user.userName,
        'rating': _rating,
        'review': _reviewCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      txn.set(ref, {
        'avgRating': newAvg,
        'totalRatings': count + 1,
        'reviews': reviews,
      }, SetOptions(merge: true));
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rate ${widget.lawyerName}"),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Rating",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = i + 1),
                );
              }),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _reviewCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Write a review (optional)",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitRating,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Rating"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
