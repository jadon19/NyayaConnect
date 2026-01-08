import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../services/user_manager.dart';
import '../../documents/cases/case_files.dart';

class CreateCasePage extends StatefulWidget {
  final String meetingId;
  final String clientId;
  final String clientName;
  final String notificationId;

  const CreateCasePage({
    super.key,
    required this.meetingId,
    required this.clientId,
    required this.clientName,
    required this.notificationId,
  });

  @override
  State<CreateCasePage> createState() => _CreateCasePageState();
}

class _CreateCasePageState extends State<CreateCasePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _submitCaseRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = UserManager();
    if (!user.isLawyer || user.lawyerId == null) return;

    setState(() => _loading = true);

    try {
      // 1️⃣ Create CASE REGISTRATION REQUEST (NOT official case)
      await FirebaseFirestore.instance.collection('case_requests').add({
        'meetingId': widget.meetingId,

        'lawyerId': user.lawyerId,
        'lawyerName': user.userName,

        'clientId': widget.clientId,
        'clientName': widget.clientName,

        'caseTitle': _titleCtrl.text.trim(),
        'caseSummary': _summaryCtrl.text.trim(),

        // Court-related fields (future use)
        'status': 'pending', // pending | accepted | rejected
        'courtId': null,
        'courtCaseNumber': null,

        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2️⃣ Mark meeting as case-requested
      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meetingId)
          .update({'caseRequestSubmitted': true});
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.notificationId)
          .update({
            'status': 'consumed',
            'consumedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      // Clear stack and go to CaseFilesPage
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CaseFilesPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Case request submitted. Awaiting court approval.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting case request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Modern Light Grey
      appBar: AppBar(
        title: const Text(
          "Draft Case for Court",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Context Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Client Name",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Case Information",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Title Input
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'Case Title',
                  hintText: 'e.g., Property Dispute vs State',
                  prefixIcon: const Icon(
                    Icons.gavel_rounded,
                    color: Colors.blue,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              // Summary Input
              TextFormField(
                controller: _summaryCtrl,
                maxLines: 6,
                style: const TextStyle(height: 1.5),
                decoration: InputDecoration(
                  labelText: 'Case Summary',
                  alignLabelWithHint: true,
                  hintText:
                      'Describe the key facts and grounds for the case...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Icon(Icons.description_rounded, color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 32),

              // Modern Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submitCaseRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.blue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _loading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded),
                  label: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Submit to Court",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
