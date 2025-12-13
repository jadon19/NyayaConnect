import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/consultation_service.dart';
import '../../../models/consultation_model.dart';
import '../../../widgets/simple_gradient_header.dart';
class LawyerNotificationsScreen extends StatefulWidget {
  const LawyerNotificationsScreen({super.key});

  @override
  State<LawyerNotificationsScreen> createState() =>
      _LawyerNotificationsScreenState();
}

class _LawyerNotificationsScreenState extends State<LawyerNotificationsScreen> {
  final ConsultationService _consultationService = ConsultationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _lawyerId;

  @override
  void initState() {
    super.initState();
    _loadLawyerId();
  }

  Future<void> _loadLawyerId() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final lawyerId = userDoc.data()?['lawyerId'];
          if (lawyerId != null) {
            setState(() => _lawyerId = lawyerId);
            return;
          }
        }

        // fallback: find lawyer by userId
        final lawyerQuery = await _firestore
            .collection('lawyers')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (lawyerQuery.docs.isNotEmpty) {
          setState(() => _lawyerId = lawyerQuery.docs.first.id);
        }
      }
    } catch (e) {
      debugPrint("Error loading lawyer ID: $e");
    }
  }

  Future<void> _acceptConsultation(String consultationId) async {
    if (_lawyerId == null) return;

    try {
      await _consultationService.acceptConsultation(
          consultationId, _lawyerId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation accepted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectConsultation(String consultationId) async {
    try {
      await _consultationService.rejectConsultation(consultationId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        const SimpleGradientHeader(title: 'Notifications'),

        Expanded(
          child: StreamBuilder<List<Consultation>>(
            stream: _lawyerId == null
                ? const Stream.empty()
                : _consultationService.getPendingConsultationsForLawyer(_lawyerId!),

            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final consultations = snapshot.data ?? [];

              if (consultations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "No new consultation requests",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      )
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: consultations.length,
                itemBuilder: (context, index) {
                  final c = consultations[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Color(0xFF42A5F5)),
                              SizedBox(width: 8),
                              Text(
                                c.clientName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey),
                              SizedBox(width: 6),
                              Text(
                                _formatDate(c.consultationDate),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),

                          SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey),
                              SizedBox(width: 6),
                              Text(
                                c.consultationTime,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _rejectConsultation(c.id),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red),
                                  ),
                                  child: Text(
                                    "Reject",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _acceptConsultation(c.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF42A5F5),
                                  ),
                                  child: Text(
                                    "Accept",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    ),
  );
}

}
