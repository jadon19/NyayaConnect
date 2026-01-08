import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/user_manager.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- EXISTING LOGIC & VARIABLES ---
    final user = UserManager();
    final bool isLawyer = user.isLawyer;

    final String? myId = isLawyer ? user.lawyerId : user.userCustomId;

    if (myId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Theme Colors
    const primaryBlue = Color(0xFF42A5F5);
    const moneyGreen = Color(0xFF2E7D32);
    const bgGrey = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where(isLawyer ? 'lawyerId' : 'clientId', isEqualTo: myId)
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // --- LOGIC: FILTER MY TRANSACTIONS (UNCHANGED) ---
          final myTxns = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return isLawyer
                ? data['lawyerId'] == myId
                : data['clientId'] == myId;
          }).toList();

          // --- UI: EMPTY STATE ---
          if (myTxns.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No transactions yet",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // --- UI: TRANSACTION LIST ---
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: myTxns.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final data = myTxns[index].data() as Map<String, dynamic>;

              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

              final String otherName = isLawyer
                  ? (data['clientName'] as String? ?? "Client")
                  : (data['lawyerName'] as String? ?? "Lawyer");

              final bool isSuccess = data['status'] == 'success';

              final String gateway = data['paymentGateway'] ?? "N/A";
              final int amount = data['amount'] ?? 0;
              final bool isIncoming = isLawyer;
              final String directionLabel = isIncoming ? "Received" : "Paid";
              final Color directionColor = isIncoming ? moneyGreen : Colors.red;
              final IconData directionIcon = isIncoming
                  ? Icons.arrow_downward
                  : Icons.arrow_upward;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // 1. Icon Container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? moneyGreen.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSuccess ? Icons.check : Icons.priority_high,
                          color: isSuccess ? moneyGreen : Colors.red,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 2. Main Details (Name & Date)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              otherName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (createdAt != null)
                              Text(
                                "${_monthName(createdAt.month)} ${createdAt.day}, ${createdAt.year} • ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              "Gateway: $gateway",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. Amount & Status Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                directionIcon,
                                size: 16,
                                color: directionColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "₹$amount",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: directionColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: directionColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              directionLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: directionColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Small helper to make dates look better (Optional)
  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
