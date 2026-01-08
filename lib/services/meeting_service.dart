import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting_model.dart';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create meeting after consultation acceptance
  Future<String> createMeeting({
  required String consultationId,
  required String lawyerId,
  required String lawyerName,
  required String clientId,
  required String clientName,
  required DateTime appointmentDateTime,
}) async {
  final ref = await _firestore.collection('meetings').add({
    'consultationId': consultationId,
    'lawyerId': lawyerId,
    'lawyerName': lawyerName,
    'clientId': clientId,
    'clientName': clientName,

    // 🔑 single field
    'appointmentDateTime':
        Timestamp.fromDate(appointmentDateTime),

    'status': 'scheduled',
    'createdAt': FieldValue.serverTimestamp(),
  });

  return ref.id;
}

  // Get upcoming meetings for user
  Stream<List<Meeting>> getUserMeetings(String userId) {
    return _firestore
        .collection('meetings')
        .where('clientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList());
  }

  // Get upcoming meetings for lawyer
  Stream<List<Meeting>> getLawyerMeetings(String lawyerId) {
    return _firestore
        .collection('meetings')
        .where('lawyerId', isEqualTo: lawyerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList());
  }
}
