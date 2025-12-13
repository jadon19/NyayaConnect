import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/user_manager.dart';
import '../../../widgets/simple_gradient_header.dart';
import '../book_lawyer/consult_lawyer_page.dart'; // adjust path

class UserNotificationsScreen extends StatelessWidget {
  UserNotificationsScreen({super.key});

  final String? myId = UserManager().userCustomId;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🔵 Gradient Header
          const SimpleGradientHeader(title: "Notifications"),

          // 🔽 Remaining Body Content
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: myId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                // loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // empty
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 70,
                          color: Colors.grey[400], // cannot be const
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No notifications yet",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 12),
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final notif = docs[index].data();
                    final status = notif['status'] ?? "pending";

                    // choose icon
                    Icon trailingIcon;
                    if (status == "accepted") {
                      trailingIcon = const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      );
                    } else if (status == "rejected") {
                      trailingIcon = const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                      );
                    } else {
                      trailingIcon = const Icon(
                        Icons.hourglass_top,
                        color: Colors.orange,
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications_active,
                          color: Color(0xFF42A5F5),
                        ),

                        title: Text(
                          notif['status'] == "pending"
                              ? "Request sent to ${notif['lawyerName'] ?? 'Lawyer'}"
                              : notif['status'] == "accepted"
                              ? "${notif['lawyerName']} accepted your request"
                              : "${notif['lawyerName']} rejected your request",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDateTime(notif['timestamp']),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),

                            if (status == "rejected") ...[
                              const SizedBox(height: 6),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 20),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ConsultLawyerPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Look for a new lawyer",
                                  style: TextStyle(
                                    color: Color(0xFF42A5F5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        trailing: trailingIcon,

                        onTap: () {
                          if (status == "rejected") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SearchNewLawyerPage(),
                              ),
                            );
                          }
                        },
                      ),
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
}

class SearchNewLawyerPage extends StatelessWidget {
  const SearchNewLawyerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find a New Lawyer")),
      body: const Center(child: Text("Implement lawyer search screen here")),
    );
  }
}

String formatDateTime(Timestamp? ts) {
  if (ts == null) return "";

  final dt = ts.toDate();
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour >= 12 ? "PM" : "AM";

  return "${dt.day}/${dt.month}/${dt.year}  "
      "$hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
}
