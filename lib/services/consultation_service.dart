import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/consultation_model.dart';
import '../services/meeting_service.dart';

class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create consultation request (client -> lawyer)
  Future<String> createConsultation({
    required String lawyerId,
    required String lawyerName,
    required String clientId,
    required String clientName,
    required DateTime date,
    required String time,
  }) async {
    try {
      final consultationRef = await _firestore.collection('consultations').add({
        'lawyerId': lawyerId,
        'lawyerName': lawyerName,
        'clientId': clientId,
        'clientName': clientName,
        'consultationDate': Timestamp.fromDate(date),
        'consultationTime': time,
        'status': 'pending', // pending | accepted | rejected | completed
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // notify lawyer
      await _firestore.collection('notifications').add({
        'userId': lawyerId,
        'userType': 'lawyer',
        'type': 'consultation_request',
        'title': 'New Consultation Request',
        'message':
            '$clientName requested a consultation on ${_formatDate(date)} at $time',
        'consultationId': consultationRef.id,
        'clientId': clientId,
        'clientName': clientName,
        'consultationDate': Timestamp.fromDate(date),
        'consultationTime': time,
        'status': 'pending',
        'isRead': false,
        'timestamp': Timestamp.now(),

      });
      // Notify the USER also
await _firestore.collection('notifications').add({
  'userId': clientId,                // <-- THIS IS THE USER'S ID
  'userType': 'client',
  'title': 'Request sent to $lawyerName',   // FIXED
  'lawyerName': lawyerName,
  'message': 'Your consultation request to $lawyerName is pending.',
  'consultationId': consultationRef.id,
  'status': 'pending',
  'isRead': false,
  'timestamp': Timestamp.now(),

});


      return consultationRef.id;
    } catch (e) {
      throw Exception("Failed to create consultation: $e");
    }
  }

  /// Get all consultations for a lawyer (past + upcoming)
  Stream<List<Consultation>> getLawyerConsultations(String lawyerId) {
    return _firestore
        .collection('consultations')
        .where('lawyerId', isEqualTo: lawyerId)
        .orderBy('consultationDate', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Consultation.fromFirestore(d)).toList(),
        );
  }

  /// Get all consultations for a client (history)
  Stream<List<Consultation>> getClientConsultations(String clientId) {
    return _firestore
        .collection('consultations')
        .where('clientId', isEqualTo: clientId)
        .orderBy('consultationDate', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Consultation.fromFirestore(d)).toList(),
        );
  }

  /// NEW: Get pending consultations for lawyer (for alerts)
  Stream<List<Consultation>> getPendingConsultationsForLawyer(String lawyerId) {
    return _firestore
        .collection('consultations')
        .where('lawyerId', isEqualTo: lawyerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Consultation.fromFirestore(d)).toList(),
        );
  }

  /// Lawyer accepts consultation
  Future<void> acceptConsultation(
    String consultationId,
    String lawyerId,
  ) async {
    try {
      // 1. Update consultation status
      await _firestore.collection('consultations').doc(consultationId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Fetch consultation details
      final doc = await _firestore
          .collection('consultations')
          .doc(consultationId)
          .get();
      final data = doc.data()!;

      final clientId = data['clientId'];
      final clientName = data['clientName'];
      final lawyerName = data['lawyerName'];
      final date = (data['consultationDate'] as Timestamp).toDate();
      final time = data['consultationTime'];

      // 3. Create meeting
      await MeetingService().createMeeting(
        consultationId: consultationId,
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        clientId: clientId,
        clientName: clientName,
        date: date,
        time: time,
      );

      // 4. Send notification to the user
      await _firestore.collection('notifications').add({
        'userId': clientId,
        'lawyerName': lawyerName,
        'title': 'Consultation Accepted',
        'message': 'Your meeting with $lawyerName is scheduled.',
        'timestamp': Timestamp.now(),

        'type': 'consultation_accepted',
        'status': 'accepted',
      });
    } catch (e) {
      throw Exception("Error accepting consultation: $e");
    }
  }

  /// Lawyer rejects consultation
  Future<void> rejectConsultation(String consultationId) async {
    try {
      await _firestore.collection('consultations').doc(consultationId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // fetch details to notify client
      final doc = await _firestore
          .collection('consultations')
          .doc(consultationId)
          .get();
      final data = doc.data()!;
      final clientId = data['clientId'];
      final lawyerName = data['lawyerName'];
      final date = (data['consultationDate'] as Timestamp).toDate();
      final time = data['consultationTime'];

      await _firestore.collection('notifications').add({
        'userId': clientId,
        'userType': 'client',
        'type': 'consultation_rejected',
        'title': 'Consultation Rejected',
        'message':
            'Your consultation with $lawyerName scheduled for ${_formatDate(date)} at $time was rejected.',
        'consultationId': consultationId,
        'lawyerName': lawyerName,
        'consultationDate': Timestamp.fromDate(date),
        'consultationTime': time,
        'status': 'rejected',
        'isRead': false,
        'timestamp': Timestamp.now(),

      });
    } catch (e) {
      throw Exception("Failed to reject consultation: $e");
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
