import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String id;
  final String consultationId;
  final String lawyerId;
  final String lawyerName;
  final String clientId;
  final String clientName;

  /// 🔑 Single source of truth (UTC)
  final DateTime appointmentDateTime;

  final String status;
  final DateTime createdAt;

  final bool callCompleted;
  final String paymentStatus;
  final bool summaryUploaded;
  final bool caseCreated;

  final int amount;
  final String? razorpayOrderId;

  final bool caseRequired;
  final bool clientConsentForCase;

  Meeting({
    required this.id,
    required this.consultationId,
    required this.lawyerId,
    required this.lawyerName,
    required this.clientId,
    required this.clientName,
    required this.appointmentDateTime,
    required this.status,
    required this.createdAt,
    required this.callCompleted,
    required this.paymentStatus,
    required this.summaryUploaded,
    required this.caseCreated,
    required this.amount,
    required this.razorpayOrderId,
    required this.caseRequired,
    required this.clientConsentForCase,
  });

  /// Agora channel name = meeting.id
  String get channelId => id;

  /// ✅ Directly usable DateTime
  DateTime get fullDateTime => appointmentDateTime.toLocal();

  /// UI helpers (optional but convenient)
  DateTime get date => appointmentDateTime.toLocal();

  String get time {
  final local = appointmentDateTime.toLocal();
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final ampm = local.hour >= 12 ? 'PM' : 'AM';

  return "${_twoDigits(hour12)}:${_twoDigits(local.minute)} $ampm";
}

  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Meeting(
      id: doc.id,
      consultationId: data['consultationId'] ?? '',
      lawyerId: data['lawyerId'] ?? '',
      lawyerName: data['lawyerName'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',

      appointmentDateTime:
          (data['appointmentDateTime'] as Timestamp).toDate(),

      status: data['status'] ?? 'scheduled',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),

      callCompleted: data['callCompleted'] ?? false,
      paymentStatus: data['paymentStatus'] ?? 'pending',
      summaryUploaded: data['summaryUploaded'] ?? false,
      caseCreated: data['caseCreated'] ?? false,

      amount: data['amount'] ?? 0,
      razorpayOrderId: data['razorpayOrderId'],

      caseRequired: data['caseRequired'] ?? false,
      clientConsentForCase: data['clientConsentForCase'] ?? false,
    );
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
