import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/user_manager.dart';

class ViewSummaryPage extends StatelessWidget {
  final String meetingId;
  final String paymentStatus;

  const ViewSummaryPage({
    super.key,
    required this.meetingId,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isLawyer = UserManager().isLawyer;
    const primaryBlue = Color(0xFF42A5F5);

    // --- 1. LOCKED STATE (PAYMENT REQUIRED) ---
    if (!isLawyer && paymentStatus != 'paid') {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Consultation Summary"),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 64,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Access Restricted",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Please complete the payment to view the detailed consultation summary and lawyer recommendations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- 2. VIEW SUMMARY STATE ---
    return Scaffold(
      backgroundColor: Colors.grey[50], // Consistent light grey background
      appBar: AppBar(
        title: const Text(
          "Consultation Summary",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meetings')
            .doc(meetingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final summary = data['summary'] ?? {};

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Intro Banner (Optional visual touch)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: primaryBlue),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Here is the official record of your consultation.",
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _section("Summary", summary['summaryText'], Icons.subject),
              _section(
                "Recommendations",
                summary['recommendations'],
                Icons.lightbulb_outline,
              ),
              _section("Next Steps", summary['nextSteps'], Icons.flag_outlined),
              const SizedBox(height: 20),

              if (data['caseRequired'] == true &&
                  data['caseCreated'] != true &&
                  !UserManager().isLawyer)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // 1. Record client consent
                        await FirebaseFirestore.instance
                            .collection('meetings')
                            .doc(meetingId)
                            .update({'clientConsentForCase': true});

                        // 2. Notify lawyer (USING lawyerId – consistent with ConsultationService)
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .add({
                              'userId': data['lawyerId'], // ✅ SAME PATTERN
                              'userType': 'lawyer',
                              'type': 'case_consent',
                              'status': 'new',
                              'title': 'Client Approved Case Filing',
                              'message':
                                  '${data['clientName']} approved proceeding with the case.',
                              'meetingId': meetingId,
                              'clientId': data['clientId'],
                              'clientName': data['clientName'],
                              'isRead': false,
                              'timestamp': Timestamp.now(),
                            });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Consent sent to lawyer'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },

                    child: const Text("PROCEED WITH CASE"),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- ENHANCED SECTION WIDGET ---
  Widget _section(String title, String text, IconData icon) {
    // If text is empty, you might want to hide it or show "N/A".
    // Here we show it to remain consistent with your original logic.
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text.isEmpty ? "No details provided." : text,
              style: TextStyle(
                fontSize: 15,
                height: 1.6, // Better readability for long text
                color: text.isEmpty ? Colors.grey[400] : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
