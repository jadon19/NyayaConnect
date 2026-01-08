import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'case_info_tab.dart';
import 'case_document_tab.dart';
import 'case_activity_tab.dart';

class CaseDetailPage extends StatelessWidget {
  final String requestId;

  const CaseDetailPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF42A5F5);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('case_requests')
          .doc(requestId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: themeColor),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final caseTitle = data['caseTitle'] ?? "Case Details";

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: themeColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                caseTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              bottom: TabBar(
                // Enhanced Tab Styling
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.info_outline, size: 20),
                    text: "Info",
                  ),
                  Tab(
                    icon: Icon(Icons.description_outlined, size: 20),
                    text: "Documents",
                  ),
                  Tab(
                    icon: Icon(Icons.history_outlined, size: 20),
                    text: "Activity",
                  ),
                ],
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: TabBarView(
                children: [
                  CaseInfoTab(caseData: data),
                  CaseDocumentTab(requestId: requestId),
                  CaseActivityTab(requestId: requestId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}