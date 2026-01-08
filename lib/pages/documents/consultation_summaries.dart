import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../services/user_manager.dart';
import '../documents/view_summary.dart';

class ConsultationSummariesPage extends StatelessWidget {
  const ConsultationSummariesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- EXISTING LOGIC (UNCHANGED) ---
    final isLawyer = UserManager().isLawyer;
    final myId = isLawyer ? UserManager().lawyerId : UserManager().userCustomId;

    // Define theme colors
    const primaryBlue = Color(0xFF42A5F5);
    final bgGrey = Colors.grey[50];

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          "Consultation Summaries",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: isLawyer
            ? FirebaseFirestore.instance
                  .collection('meetings')
                  .where('lawyerId', isEqualTo: myId)
                  .where('summaryUploaded', isEqualTo: true)
                  .snapshots()
            : FirebaseFirestore.instance
                  .collection('meetings')
                  .where('clientId', isEqualTo: myId)
                  .where('summaryUploaded', isEqualTo: true)
                  .where('paymentStatus', isEqualTo: 'paid') // 🔒 FIX
                  .snapshots(),

        builder: (context, snapshot) {
          // 1. Better Loading State (Centered)
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // 2. Empty State Handling (UX Improvement)
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No summaries found",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 3. Enhanced List View
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Extract data using your logic
              final displayName = isLawyer
                  ? data['clientName']
                  : data['lawyerName'];
              // Parsing date safely to handle potential nulls
              final Timestamp? ts = data['appointmentDateTime'];

              final String dateString = ts != null
                  ? DateFormat('dd MMM yyyy').format(ts.toDate().toLocal())
                  : "Unknown Date";

              return _buildSummaryCard(
                context,
                displayName ?? "Unknown",
                dateString,
                doc,
                data,
              );
            },
          );
        },
      ),
    );
  }

  // Helper widget to build the "Pro" looking card
  Widget _buildSummaryCard(
    BuildContext context,
    String name,
    String date,
    DocumentSnapshot doc,
    Map<String, dynamic> data,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // --- NAVIGATION LOGIC (UNCHANGED) ---
          onTap: () {
            if (!UserManager().isLawyer && data['paymentStatus'] != 'paid') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please complete payment to view summary"),
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewSummaryPage(
                  meetingId: doc.id,
                  paymentStatus: data['paymentStatus'],
                ),
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                // Avatar / Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF42A5F5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
