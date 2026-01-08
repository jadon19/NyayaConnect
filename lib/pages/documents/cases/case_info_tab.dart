import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CaseInfoTab extends StatelessWidget {
  final Map<String, dynamic> caseData;

  const CaseInfoTab({super.key, required this.caseData});

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF42A5F5);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Section with Status
        _buildHeader(themeColor),
        const SizedBox(height: 20),

        // Case Details Card
        _buildSectionCard(
          "Core Details",
          [
            _infoRow(Icons.person_outline, "Lawyer", caseData['lawyerName']),
            _infoRow(Icons.account_circle_outlined, "Client", caseData['clientName']),
            if (caseData['submittedAt'] != null)
              _infoRow(
                Icons.calendar_today_outlined,
                "Submitted On",
                DateFormat('MMMM dd, yyyy')
                    .format((caseData['submittedAt'] as Timestamp).toDate()),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Court Information Card (Only shows if data exists)
        if (caseData['courtCaseNumber'] != null || caseData['courtId'] != null)
          _buildSectionCard(
            "Legal Reference",
            [
              if (caseData['courtCaseNumber'] != null)
                _infoRow(Icons.gavel_outlined, "Court Case No.", caseData['courtCaseNumber']),
              if (caseData['courtId'] != null)
                _infoRow(Icons.account_balance_outlined, "Court", caseData['courtId']),
            ],
          ),
      ],
    );
  }

  Widget _buildHeader(Color themeColor) {
    final status = (caseData['status'] ?? 'pending').toString().toUpperCase();
    Color statusColor;
    
    switch (status.toLowerCase()) {
      case 'active': statusColor = Colors.green; break;
      case 'pending': statusColor = Colors.orange; break;
      case 'closed': statusColor = Colors.grey; break;
      default: statusColor = themeColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caseData['caseTitle'] ?? 'Untitled Case',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.5)),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.1),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF42A5F5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                Text(
                  value ?? '—',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}