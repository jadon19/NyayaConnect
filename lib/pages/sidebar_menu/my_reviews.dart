import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LawyerReviewsScreen extends StatefulWidget {
  final String lawyerId;

  const LawyerReviewsScreen({super.key, required this.lawyerId});

  @override
  State<LawyerReviewsScreen> createState() => _LawyerReviewsScreenState();
}

class _LawyerReviewsScreenState extends State<LawyerReviewsScreen> {
  String _sortBy = "recent"; // recent, highest, lowest
  Map<String, dynamic>? ratingData;

  @override
  void initState() {
    super.initState();
    loadRatingData();
  }

  Future<void> loadRatingData() async {
  final docRef = FirebaseFirestore.instance
      .collection("lawyer_ratings")
      .doc(widget.lawyerId);

  final ratingDoc = await docRef.get();

  if (!ratingDoc.exists) {
    // Create default rating structure
    await docRef.set({
      "avgRating": 0.0,
      "totalRatings": 0,
      "reviews": [],
      "lawyerName": "",  // optional
    });
  }

  // Load again after ensuring doc is created
  final freshDoc = await docRef.get();

  setState(() {
    ratingData = freshDoc.data();
  });
}


  // ⭐ Star Widget
  Widget buildStars(double rating) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating.round() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // const themeColor = Color(0xFF42A5F5);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Client Reviews",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: ratingData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),

                // SORT BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.sort),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black54),
                      ),
                      label: DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                              value: "recent", child: Text("Recent")),
                          DropdownMenuItem(
                              value: "highest", child: Text("Highest Rated")),
                          DropdownMenuItem(
                              value: "lowest", child: Text("Lowest Rated")),
                        ],
                        onChanged: (v) {
                          setState(() => _sortBy = v!);
                        },
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // LIST OF REVIEWS
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("lawyer_ratings")
                        .doc(widget.lawyerId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.data() == null) {
                        return const Center(child: Text("No reviews yet"));
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
final List reviews = (data["reviews"] ?? []) as List;


                      if (reviews.isEmpty) {
                        return const Center(child: Text("No reviews yet"));
                      }

                      // SORTING
                      if (_sortBy == "recent") {
                        reviews.sort((a, b) =>
                            (b["timestamp"] as Timestamp)
                                .compareTo(a["timestamp"]));
                      } else if (_sortBy == "highest") {
                        reviews.sort((a, b) =>
                            b["rating"].compareTo(a["rating"]));
                      } else if (_sortBy == "lowest") {
                        reviews.sort((a, b) =>
                            a["rating"].compareTo(b["rating"]));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final r = reviews[index];
                          final clientName = r["clientName"] ?? "Anonymous";
                          final reviewText = r["reviewText"] ?? "";
                          final rating = r["rating"]?.toDouble() ?? 0.0;
                          final profilePic = r["profilePic"];

                          return _buildReviewCard(
                            name: clientName,
                            profilePic: profilePic,
                            review: reviewText,
                            rating: rating,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------- HEADER SECTION ----------------
  Widget _buildHeaderSection() {
    final avg = (ratingData?["avgRating"] ?? 0).toDouble();
    final total = ratingData?["totalRatings"] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Attorney ${ratingData?["lawyerName"] ?? ""}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(width: 6),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < avg.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            "Based on $total total reviews",
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 16),
          const Text(
            "Client Feedback",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ---------------- REVIEW CARD UI ----------------
  Widget _buildReviewCard({
    required String name,
    String? profilePic,
    required String review,
    required double rating,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Pic
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage:
                      profilePic != null ? NetworkImage(profilePic) : null,
                  child: profilePic == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 10),

                // Name + rating stars
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          "(${rating.toStringAsFixed(1)})",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),

            // REVIEW TEXT
            if (review.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                review.length > 120
                    ? "${review.substring(0, 120)}..."
                    : review,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),

              if (review.length > 120)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Read More"),
                  ),
                )
            ],
          ],
        ),
      ),
    );
  }
}
