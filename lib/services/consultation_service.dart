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
    required DateTime appointmentDateTime, // UTC
  }) async {
    try {
      final consultationRef =
          await _firestore.collection('consultations').add({
        'lawyerId': lawyerId,
        'lawyerName': lawyerName,
        'clientId': clientId,
        'clientName': clientName,

        // 🔑 SINGLE SOURCE OF TRUTH
        'appointmentDateTime':
            Timestamp.fromDate(appointmentDateTime),

        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 🔔 Notify lawyer
      await _firestore.collection('notifications').add({
        'userId': lawyerId,
        'userType': 'lawyer',
        'type': 'consultation_request',
        'consultationId': consultationRef.id,

        'clientId': clientId,
        'clientName': clientName,
        'lawyerName': lawyerName,

        // 🔑 same datetime
        'appointmentDateTime':
            Timestamp.fromDate(appointmentDateTime),

        'status': 'pending',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 🔔 Notify client
      await _firestore.collection('notifications').add({
        'userId': clientId,
        'userType': 'client',
        'type': 'consultation',

        'consultationId': consultationRef.id,
        'lawyerName': lawyerName,

        'appointmentDateTime':
            Timestamp.fromDate(appointmentDateTime),

        'status': 'pending',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return consultationRef.id;
    } catch (e) {
      throw Exception("Failed to create consultation: $e");
    }
  }

  /// Get consultations for lawyer
  Stream<List<Consultation>> getLawyerConsultations(String lawyerId) {
    return _firestore
        .collection('consultations')
        .where('lawyerId', isEqualTo: lawyerId)
        .orderBy('appointmentDateTime')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Consultation.fromFirestore(d)).toList());
  }

  /// Get consultations for client
  Stream<List<Consultation>> getClientConsultations(String clientId) {
    return _firestore
        .collection('consultations')
        .where('clientId', isEqualTo: clientId)
        .orderBy('appointmentDateTime')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Consultation.fromFirestore(d)).toList());
  }

  /// Pending consultations for lawyer
  Stream<List<Consultation>> getPendingConsultationsForLawyer(String lawyerId) {
    return _firestore
        .collection('consultations')
        .where('lawyerId', isEqualTo: lawyerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Consultation.fromFirestore(d)).toList());
  }

  /// Lawyer accepts consultation
  Future<void> acceptConsultation(
      String consultationId, String lawyerId) async {
    try {
      await _firestore
          .collection('consultations')
          .doc(consultationId)
          .update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _firestore
          .collection('consultations')
          .doc(consultationId)
          .get();
      final data = doc.data()!;

      final DateTime appointmentDateTime =
          (data['appointmentDateTime'] as Timestamp).toDate();

      // Create meeting
      await MeetingService().createMeeting(
        consultationId: consultationId,
        lawyerId: lawyerId,
        lawyerName: data['lawyerName'],
        clientId: data['clientId'],
        clientName: data['clientName'],
        appointmentDateTime: appointmentDateTime,
      );

      // Notify client
      await _firestore.collection('notifications').add({
        'userId': data['clientId'],
        'type': 'consultation',
        'status': 'accepted',
        'lawyerName': data['lawyerName'],
        'appointmentDateTime':
            data['appointmentDateTime'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error accepting consultation: $e");
    }
  }

  /// Lawyer rejects consultation
  Future<void> rejectConsultation(String consultationId) async {
    try {
      await _firestore
          .collection('consultations')
          .doc(consultationId)
          .update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _firestore
          .collection('consultations')
          .doc(consultationId)
          .get();
      final data = doc.data()!;

      await _firestore.collection('notifications').add({
        'userId': data['clientId'],
        'type': 'consultation',
        'status': 'rejected',
        'lawyerName': data['lawyerName'],
        'appointmentDateTime':
            data['appointmentDateTime'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to reject consultation: $e");
    }
  }
}
