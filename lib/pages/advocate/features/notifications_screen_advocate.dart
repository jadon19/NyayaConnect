import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/consultation_service.dart';
import '../../../models/consultation_model.dart';
import '../../../widgets/simple_gradient_header.dart';
import '../../../services/user_manager.dart';
import 'file_case.dart';

class LawyerNotificationsScreen extends StatefulWidget {
  const LawyerNotificationsScreen({super.key});

  @override
  State<LawyerNotificationsScreen> createState() =>
      _LawyerNotificationsScreenState();
}

class _LawyerNotificationsScreenState extends State<LawyerNotificationsScreen> {
  final ConsultationService _consultationService = ConsultationService();

  // ---------------------------------------------------------------------------
  // LOGIC SECTION - KEPT EXACTLY AS ORIGINAL
  // ---------------------------------------------------------------------------

  Future<void> _acceptConsultation(Consultation consultation) async {
    final lawyerId = UserManager().lawyerId;
    if (lawyerId == null) return;

    try {
      await _consultationService.acceptConsultation(consultation.id, lawyerId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation accepted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectConsultation(Consultation consultation) async {
    try {
      await _consultationService.rejectConsultation(consultation.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<List<QueryDocumentSnapshot>> _fetchCaseConsentNotifications() async {
    final lawyerId = UserManager().lawyerId;
    if (lawyerId == null) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: lawyerId)
        .where('type', isEqualTo: 'case_consent')
        .where('status', whereIn: ['new', 'in_progress'])
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    return snapshot.docs;
  }

  // ---------------------------------------------------------------------------
  // UI SECTION - MODERNIZED
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = UserManager();

    if (!user.isLawyer || user.lawyerId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Modern cool grey background
      body: Column(
        children: [
          const SimpleGradientHeader(title: 'Notifications'),
          Expanded(
            child: StreamBuilder<List<Consultation>>(
              stream: _consultationService.getPendingConsultationsForLawyer(
                user.lawyerId!,
              ),
              builder: (context, consultationSnap) {
                if (consultationSnap.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final consultations = consultationSnap.data ?? [];

                return FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _fetchCaseConsentNotifications(),
                  builder: (context, caseSnap) {
                    if (caseSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final caseNotifications = caseSnap.data ?? [];

                    if (consultations.isEmpty && caseNotifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount:
                          consultations.length + caseNotifications.length,
                      separatorBuilder: (ctx, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index < consultations.length) {
                          return _buildConsultationCard(consultations[index]);
                        }
                        final doc =
                            caseNotifications[index - consultations.length];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildCaseConsentCard(data, doc.id);
                      },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.blueGrey[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: TextStyle(
              color: Colors.blueGrey[800],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no new notifications.',
            style: TextStyle(color: Colors.blueGrey[400], fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(Consultation consultation) {
    final dt = consultation.appointmentDateTime;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // Softer shadow
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Row: Avatar + Name + Status Chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade100, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    radius: 22,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.clientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'New Consultation Request',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade100),
                  ),
                  child: Text(
                    "Pending",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info Container (Date & Time)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.blueGrey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(dt),
                          style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 20, color: Colors.grey.shade300),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Colors.blueGrey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('hh:mm a').format(dt),
                          style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectConsultation(consultation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red.shade100),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptConsultation(consultation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseConsentCard(
    Map<String, dynamic> data,
    String notificationId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Decorative top bar instead of side gradient
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.folder_shared_rounded,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['clientName'] ?? 'Client Request',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Consent Received",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (data['message'] != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data['message'],
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // 1️⃣ Handle notification immediately (consent consumed)
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(notificationId)
                            .update({
                              'status': 'in_progress',
                              'openedAt': FieldValue.serverTimestamp(),
                            });

                        if (!mounted) return;

                        // 2️⃣ Open CreateCasePage DIRECTLY
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateCasePage(
                              meetingId: data['meetingId'],
                              clientId: data['clientId'],
                              clientName: data['clientName'],
                              notificationId: notificationId,
                            ),
                          ),
                        );
                      },

                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text(
                        'Create Case File',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.blue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
