import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  Future<int> getUserScore() async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('learningScore')) {
      return doc['learningScore'] ?? 0;
    }
    return 0;
  }

  Future<void> updateUserScore(int score) async {
    await _firestore.collection('users').doc(userId).set(
      {'learningScore': score},
      SetOptions(merge: true), // merge avoids overwriting other fields
    );
  }
}
