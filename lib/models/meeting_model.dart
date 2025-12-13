import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String id;
  final String consultationId;
  final String lawyerId;
  final String lawyerName;
  final String clientId;
  final String clientName;
  final DateTime date;
  final String time;
  final String status; // scheduled, completed, cancelled
  final DateTime createdAt;

  Meeting({
    required this.id,
    required this.consultationId,
    required this.lawyerId,
    required this.lawyerName,
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.time,
    required this.status,
    required this.createdAt,
  });
  DateTime get fullDateTime {
  final parts = time.split(" "); // Example: "03:40 PM"
  final hm = parts[0].split(":");

  int hour = int.parse(hm[0]);
  int minute = int.parse(hm[1]);
  final ampm = parts[1];

  if (ampm == "PM" && hour != 12) hour += 12;
  if (ampm == "AM" && hour == 12) hour = 0;

  return DateTime(date.year, date.month, date.day, hour, minute);
}


factory Meeting.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  
  final ts = data['createdAt'];
  DateTime created =
      ts is Timestamp ? ts.toDate() : DateTime.now();  // SAFE FALLBACK

  return Meeting(
    id: doc.id,
    consultationId: data['consultationId'] ?? '',
    lawyerId: data['lawyerId'] ?? '',
    lawyerName: data['lawyerName'] ?? '',
    clientId: data['clientId'] ?? '',
    clientName: data['clientName'] ?? '',
    date: (data['date'] as Timestamp).toDate(),
    time: data['time'] ?? '',
    status: data['status'] ?? 'scheduled',
    createdAt: created,
  );
}


}
