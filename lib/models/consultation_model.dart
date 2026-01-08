import 'package:cloud_firestore/cloud_firestore.dart';

class Consultation {
  final String id;
  final String lawyerId;
  final String lawyerName;
  final String clientId;
  final String clientName;
  final DateTime appointmentDateTime;
  final String status; // pending | accepted | rejected | completed
  final DateTime createdAt;
  final DateTime? updatedAt;

  Consultation({
    required this.id,
    required this.lawyerId,
    required this.lawyerName,
    required this.clientId,
    required this.clientName,
    required this.appointmentDateTime,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Firestore document → Consultation model
  factory Consultation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Consultation(
      id: doc.id,
      lawyerId: data['lawyerId'] ?? '',
      lawyerName: data['lawyerName'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      appointmentDateTime:
          (data['appointmentDateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert model → Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'clientId': clientId,
      'clientName': clientName,
      'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
