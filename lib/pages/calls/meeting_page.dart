import 'package:flutter/material.dart';
import '../../../../services/meeting_service.dart';
import '../../../../models/meeting_model.dart';
import '../../../../services/user_manager.dart';
import 'join_call_screen.dart';

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

          final now = DateTime.now();
          final meetingList = (snapshot.data ?? [])
              .where((m) => m.fullDateTime.isAfter(now))
              .toList();

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
    final dt = m.fullDateTime;
    final now = DateTime.now();

    //CHANGE THE CONDITION TO BELOW AFTER TESTING
    //final isJoinPossible = dt.difference(now).inMinutes <= 10 && dt.isAfter(now);
    final isJoinPossible = true; // TEMP: Always show Join Now

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
            Text("${m.date.toString().substring(0, 10)} at ${m.time}"),

            if (isJoinPossible) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity, // full width of card
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF004AAD),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Color(0xFF42A5F5),
                        width: 1.4,
                      ),
                    ),
                  ),
                  label: const Text(
                    "Join Meeting",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JoinCallScreen(meeting: m),
                      ),
                    );
                  },
                ),
              ),
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
