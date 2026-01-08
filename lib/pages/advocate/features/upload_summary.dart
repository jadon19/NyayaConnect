import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/meeting_model.dart';

class UploadSummaryPage extends StatefulWidget {
  final Meeting meeting;
  const UploadSummaryPage({super.key, required this.meeting});

  @override
  State<UploadSummaryPage> createState() => _UploadSummaryPageState();
}

class _UploadSummaryPageState extends State<UploadSummaryPage> {
  // --- EXISTING LOGIC & CONTROLLERS (UNCHANGED) ---
  final _summaryCtrl = TextEditingController();
  final _recommendCtrl = TextEditingController();
  final _nextStepsCtrl = TextEditingController();
  bool _caseRequired = false;

  Future<void> _saveSummary() async {
    if (_summaryCtrl.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meeting.id)
          .update({
            'summary': {
              'summaryText': _summaryCtrl.text.trim(),
              'recommendations': _recommendCtrl.text.trim(),
              'nextSteps': _nextStepsCtrl.text.trim(),
              'uploadedAt': FieldValue.serverTimestamp(),
              'uploadedBy': widget.meeting.lawyerId,
            },
            'summaryUploaded': true,
            'caseRequired': _caseRequired,
            "paymentStatus": "pending", // IMPORTANT
          });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save summary')));
    }
  }

  // --- NEW UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // Define the primary blue color locally for easy styling
    const primaryBlue = Color(0xFF42A5F5);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. INFO CARD (Replaces the basic readOnlyFields)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.gavel,
                    "Lawyer",
                    widget.meeting.lawyerName,
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildInfoRow(
                    Icons.person_outline,
                    "Client",
                    widget.meeting.clientName,
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildInfoRow(
                    Icons.calendar_today,
                    "Date",
                    widget.meeting.date.toString().substring(0, 10),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. INPUT SECTIONS
            _buildSectionHeader("Summary", Icons.description, isRequired: true),
            _buildStyledInput(
              _summaryCtrl,
              "Enter the key points of the discussion...",
              minLines: 5,
            ),

            const SizedBox(height: 20),

            _buildSectionHeader("Recommendations", Icons.lightbulb_outline),
            _buildStyledInput(
              _recommendCtrl,
              "Enter legal advice provided...",
              minLines: 3,
            ),

            const SizedBox(height: 20),

            _buildSectionHeader("Next Steps", Icons.flag_outlined),
            _buildStyledInput(
              _nextStepsCtrl,
              "Action items and deadlines...",
              minLines: 3,
            ),

            const SizedBox(height: 32),
            CheckboxListTile(
              title: const Text(
                "Request client to file a legal case",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                "Client will be notified after payment to review and accept",
              ),
              value: _caseRequired,
              onChanged: (val) {
                setState(() => _caseRequired = val ?? false);
              },
            ),
            const SizedBox(height: 24),

            // 3. ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "SAVE SUMMARY",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS FOR CLEANER CODE ---

  // Helper for the top info card rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF42A5F5), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper for Section Headers (e.g., "Summary", "Recommendations")
  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              text: title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the white text input boxes
  Widget _buildStyledInput(
    TextEditingController controller,
    String hint, {
    int minLines = 3,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: null, // Allows the box to grow as they type
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
