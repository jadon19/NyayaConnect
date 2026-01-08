import 'package:flutter/material.dart';
import '../../../../services/meeting_service.dart';
import '../../../../models/meeting_model.dart';
import '../../../../services/user_manager.dart';
import 'join_call_screen.dart';
import '../../services/payment_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../documents/view_summary.dart';
import '../advocate/features/upload_summary.dart';
import '../users/features/rate_lawyer.dart';
import 'package:intl/intl.dart';

class MeetingsScreen extends StatelessWidget {
  MeetingsScreen({super.key});

  final _userManager = UserManager();

  @override
  Widget build(BuildContext context) {
    final bool isLawyer = _userManager.isLawyer;
    final String id = isLawyer
        ? (_userManager.lawyerId ?? '')
        : (_userManager.userCustomId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLawyer ? "Scheduled Meetings" : "Your Meetings",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: StreamBuilder<List<Meeting>>(
        stream: isLawyer
            ? MeetingService().getLawyerMeetings(id)
            : MeetingService().getUserMeetings(id),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final meetingList = (snapshot.data ?? []);

          if (meetingList.isEmpty) {
            return _buildEmptyUI(isLawyer);
          }

          return ListView.builder(
            itemCount: meetingList.length,
            itemBuilder: (_, i) {
              final m = meetingList[i];
              return _buildMeetingTile(context, m, isLawyer);
            },
          );
        },
      ),
    );
  }

  // REUSABLE UI
  Widget _buildMeetingTile(BuildContext context, Meeting m, bool isLawyer) {
    //CHANGE THE CONDITION TO BELOW AFTER TESTING
    //final canJoin = dt.difference(now).inMinutes <= 10 && dt.isAfter(now);
    final bool canJoin = !m.callCompleted;
    // TEMP: Always show Join Now

    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: const Icon(Icons.video_call, color: Color(0xFF42A5F5)),
        title: Text(
          isLawyer
              ? "Meeting with ${m.clientName}"
              : "Meeting with ${m.lawyerName}",
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(m.appointmentDateTime.toLocal()),
            ),

            if (canJoin) ...[
              _joinMeetingButton(context, m),
            ] else ...[
              _postCallActions(context, m, isLawyer),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyUI(bool isLawyer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),

          Text(
            "No meetings yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isLawyer
                ? "Accept a consultation to schedule a meeting."
                : "Consult a Lawyer to book a meeting!",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Widget _joinMeetingButton(BuildContext context, Meeting m) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: const Icon(Icons.video_call),
      label: const Text("Join Meeting"),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoCallScreen(meeting: m)),
        );
      },
    ),
  );
}

Widget _postCallActions(BuildContext context, Meeting m, bool isLawyer) {
  if (isLawyer) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text(
          m.summaryUploaded == true ? "Update Summary" : "Upload Summary",
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UploadSummaryPage(meeting: m)),
          );
        },
      ),
    );
  }

  // CLIENT UI
  return StatefulBuilder(
    builder: (context, setState) {
      bool paying = false;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Consultation Fee: ₹${m.amount}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
              fontSize: 16,
            ),
          ),
          if (m.paymentStatus == 'blocked') ...[
            const Text(
              "Payment will be enabled after the lawyer uploads the consultation summary.",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      (m.summaryUploaded == true &&
                          m.paymentStatus == 'pending' &&
                          m.razorpayOrderId != null)
                      ? () async {
                          if (paying) return;
                          setState(() => paying = true);

                          try {
                            final paymentService = PaymentService.instance;

                            paymentService.init(
                              onSuccess: (response) async {
                                await FirebaseFirestore.instance
                                    .collection('meetings')
                                    .doc(m.id)
                                    .update({'paymentStatus': 'paid'});

                                await FirebaseFirestore.instance
                                    .collection('transactions')
                                    .add({
                                      'meetingId': m.id,
                                      'clientId': UserManager().userCustomId,
                                      'clientName': m.clientName,
                                      'lawyerId': m.lawyerId,
                                      'lawyerName': m.lawyerName,
                                      'amount': m.amount,
                                      'paymentGateway': 'Razorpay',
                                      'razorpayOrderId': response.orderId,
                                      'razorpayPaymentId': response.paymentId,
                                      'status': 'success',
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () {
                                    PaymentService.instance.dispose();
                                  },
                                );
                                setState(() => paying = false);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Payment successful"),
                                  ),
                                );
                              },
                              onError: (error) {
                                paymentService.dispose();
                                setState(() => paying = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Payment failed"),
                                  ),
                                );
                              },
                            );

                            paymentService.openCheckout(
                              orderId: m.razorpayOrderId!,
                              amount: m.amount,
                              name: "NyayaConnect",
                              description: "Legal Consultation",
                            );
                          } catch (e) {
                            setState(() => paying = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Payment error")),
                            );
                          }
                        }
                      : null,

                  child: paying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Pay Now"),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: ElevatedButton(
                  onPressed: m.paymentStatus == 'paid'
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewSummaryPage(
                                meetingId: m.id,
                                paymentStatus: m.paymentStatus,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text("View Summary"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RateLawyerPage(
                    lawyerId: m.lawyerId,
                    lawyerName: m.lawyerName,
                  ),
                ),
              );
            },
            child: const Text("Rate Lawyer"),
          ),
        ],
      );
    },
  );
}
