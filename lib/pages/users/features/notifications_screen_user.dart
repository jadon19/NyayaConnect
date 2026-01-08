import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/user_manager.dart';
import '../../../widgets/simple_gradient_header.dart';
import '../book_lawyer/consult_lawyer_page.dart'; // adjust path
import 'package:intl/intl.dart';

class UserNotificationsScreen extends StatelessWidget {
  UserNotificationsScreen({super.key});

  final String? myId = UserManager().userCustomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Modern cool grey background

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
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "No notifications yet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    final notif = docs[index].data();
                    final status = notif['status'] ?? "pending";
                    final Timestamp? apptTs = notif['appointmentDateTime'];

                    // choose icon & color theme
                    IconData iconData;
                    Color statusColor;
                    Color statusBgColor;

                    if (status == "accepted") {
                      iconData = Icons.check_circle_rounded;
                      statusColor = Colors.green.shade600;
                      statusBgColor = Colors.green.shade50;
                    } else if (status == "rejected") {
                      iconData = Icons.cancel_rounded;
                      statusColor = Colors.red.shade400;
                      statusBgColor = Colors.red.shade50;
                    } else {
                      iconData = Icons.hourglass_top_rounded;
                      statusColor = Colors.orange.shade700;
                      statusBgColor = Colors.orange.shade50;
                    }

                    // Modern Custom Card
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Leading Icon Badge
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.notifications_active_rounded,
                                    color: Colors.blue.shade600,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Main Content Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        status == "pending"
                                            ? "Request sent to ${notif['lawyerName'] ?? 'Lawyer'}"
                                            : status == "accepted"
                                            ? "${notif['lawyerName']} accepted your request"
                                            : "${notif['lawyerName']} rejected your request",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      if (apptTs != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_rounded,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                formatAppointment(apptTs),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      Text(
                                        "Sent • ${formatDateTime(notif['timestamp'])}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      if (status == "rejected") ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 32,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              side: BorderSide(
                                                color: Colors.blue.shade200,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          const ConsultLawyerPage(),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              "Look for a new lawyer",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Trailing Status Indicator
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: statusColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

String formatAppointment(Timestamp ts) {
  final dt = ts.toDate();
  return "${dt.day}/${dt.month}/${dt.year}  "
      "${DateFormat('hh:mm a').format(dt)}";
}

String formatDateTime(Timestamp? ts) {
  if (ts == null) return "";

  final dt = ts.toDate();
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour >= 12 ? "PM" : "AM";

  return "${dt.day}/${dt.month}/${dt.year}  "
      "$hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
}