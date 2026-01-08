import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/user_manager.dart';

class CallLogsScreen extends StatelessWidget {
  const CallLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserManager();
    final bool isLawyer = user.isLawyer;
    final String myId = isLawyer ? user.lawyerId! : user.userCustomId!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Logs', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 183, 255),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("calls")
            .where(isLawyer ? "lawyerId" : "clientId", isEqualTo: myId)
            .orderBy("startedAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load call logs"));
          }


          // Filter calls that involve this user (lawyer or client)
          final myCalls = snapshot.data!.docs;

          if (myCalls.isEmpty) {
            return Center(
              child: Text(
                "No call logs available",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myCalls.length,
            itemBuilder: (_, index) {
              final data = myCalls[index].data() as Map<String, dynamic>;

              final DateTime? started = (data["startedAt"] as Timestamp?)
                  ?.toDate();
              final int duration = data["durationSeconds"] ?? 0;

              final String otherPersonName = isLawyer
                  ? (data["clientName"] ?? "Client")
                  : (data["lawyerName"] ?? "Lawyer");

              String timeText = started != null
                  ? "${started.day}-${started.month}-${started.year}, ${started.hour}:${started.minute.toString().padLeft(2, '0')}"
                  : "Unknown time";

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.lightBlueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(otherPersonName),
                subtitle: Text("$timeText  •  ${duration}s"),
                trailing: const Icon(Icons.call, color: Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}
