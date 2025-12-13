import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final String lawyerCustomId;
  final VoidCallback onTap;

  const NotificationBadgeIcon({
    super.key,
    required this.lawyerCustomId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('lawyerId', isEqualTo: lawyerCustomId)
          .where('status', isEqualTo: "pending")
          .snapshots(),

      builder: (context, snap) {
        int count = snap.hasData ? snap.data!.docs.length : 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: onTap,
            ),

            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.red,
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
