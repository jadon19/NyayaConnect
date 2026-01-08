import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml for date formatting

class CaseDocumentTab extends StatelessWidget {
  final String requestId;

  const CaseDocumentTab({super.key, required this.requestId});

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
          return const Center(child: CircularProgressIndicator(color: themeColor));
        }

        final caseData = snapshot.data!.data() as Map<String, dynamic>;
        final bool isEditable = caseData['status'] == 'pending';

        return Column(
          children: [
            // Upload Section
            if (isEditable)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Storage upload logic
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                    label: const Text(
                      "Upload New Document",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
              ),

            // Document List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('case_requests')
                    .doc(requestId)
                    .collection('documents')
                    .orderBy('uploadedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: themeColor));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_copy_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            "No documents uploaded yet",
                            style: TextStyle(color: Colors.grey[500], fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      // Handle Timestamp safely
                      final DateTime? uploadedAt = (data['uploadedAt'] as Timestamp?)?.toDate();
                      final String dateStr = uploadedAt != null 
                          ? DateFormat('MMM dd, yyyy • hh:mm a').format(uploadedAt)
                          : 'Date unknown';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50], // PDF-style red tint
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                        ),
                        title: Text(
                          data['fileName'] ?? 'Document.pdf',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("By: ${data['uploadedBy'] ?? 'Unknown User'}"),
                            Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new, color: themeColor),
                          onPressed: () {
                            // TODO: Open/Download logic
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}