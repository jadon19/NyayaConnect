import 'dart:io'; // For File operations
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage

class VerifyLawyerScreen extends StatefulWidget {
  const VerifyLawyerScreen({super.key});

  @override
  State<VerifyLawyerScreen> createState() => _VerifyLawyerScreenState();
}

class _VerifyLawyerScreenState extends State<VerifyLawyerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _enrollmentController = TextEditingController();
  
  String? _aadharFilePath;
  String? _enrollmentFilePath;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  // Error states for validation
  bool _enrollmentError = false;
  bool _aadharError = false;
  bool _enrollmentFileError = false;

  @override
  void dispose() {
    _enrollmentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          if (type == 'aadhar') {
            _aadharFilePath = result.files.single.path;
            _aadharError = false;
          } else if (type == 'enrollment') {
            _enrollmentFilePath = result.files.single.path;
            _enrollmentFileError = false;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  void _validateForm() {
    setState(() {
      _enrollmentError = _enrollmentController.text.trim().isEmpty;
      _aadharError = _aadharFilePath == null;
      _enrollmentFileError = _enrollmentFilePath == null;
    });
  }
Future<void> _submitVerification() async {
  _validateForm();

  // Check for validation errors
  if (_enrollmentError || _aadharError || _enrollmentFileError) {
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Optional: Upload files to Firebase Storage
    String? aadharUrl;
    String? enrollmentUrl;
    final storageRef = FirebaseStorage.instance.ref().child('lawyers/${user.uid}');

    if (_aadharFilePath != null) {
      final aadharFile = File(_aadharFilePath!);
      final aadharTask = await storageRef.child('aadhar.${_aadharFilePath!.split('.').last}').putFile(aadharFile);
      aadharUrl = await aadharTask.ref.getDownloadURL();
    }

    if (_enrollmentFilePath != null) {
      final enrollmentFile = File(_enrollmentFilePath!);
      final enrollmentTask = await storageRef.child('enrollment.${_enrollmentFilePath!.split('.').last}').putFile(enrollmentFile);
      enrollmentUrl = await enrollmentTask.ref.getDownloadURL();
    }

    // Update Firestore with verification details
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'verificationStatus': 'pending',
      'enrollmentNumber': _enrollmentController.text.trim(),
      'aadharFile': aadharUrl ?? _aadharFilePath,
      'enrollmentFile': enrollmentUrl ?? _enrollmentFilePath,
      'verificationSubmittedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });

    // Auto return to home screen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context, true); // triggers HomeScreen refresh
      }
    });

  } catch (e) {
    setState(() {
      _isSubmitting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit verification: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Lawyer'),
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF42A5F5), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lawyer Verification',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF42A5F5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please provide the following documents to verify your lawyer credentials.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bar Council Enrollment Number
                  _buildTextField(
                    controller: _enrollmentController,
                    label: 'Bar Council Enrollment Number',
                    hint: 'Enter your enrollment number',
                    error: _enrollmentError,
                    errorText: 'Required',
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: 20),

                  // Aadhar Card Upload
                  _buildFileUpload(
                    label: 'Aadhar Card',
                    filePath: _aadharFilePath,
                    onTap: () => _pickFile('aadhar'),
                    error: _aadharError,
                    errorText: 'Required',
                  ),

                  const SizedBox(height: 20),

                  // Enrollment Certificate Upload
                  _buildFileUpload(
                    label: 'Enrollment Certificate',
                    filePath: _enrollmentFilePath,
                    onTap: () => _pickFile('enrollment'),
                    error: _enrollmentFileError,
                    errorText: 'Required',
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || _isSubmitted ? null : _submitVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSubmitted ? Colors.white : Colors.green,
                        foregroundColor: _isSubmitted ? Colors.green : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isSubmitted ? 'Sent for verification' : 'Verify',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  if (_isSubmitted) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your verification request has been submitted successfully. You will be redirected to the home screen shortly.',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool error,
    required String errorText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red : Colors.grey[300]!,
                width: error ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red : Colors.grey[300]!,
                width: error ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red : const Color(0xFF42A5F5),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        if (error) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFileUpload({
    required String label,
    required String? filePath,
    required VoidCallback onTap,
    required bool error,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error ? Colors.red : Colors.grey[300]!,
                width: error ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: error ? Colors.red : const Color(0xFF42A5F5),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filePath != null ? 'File selected' : 'Tap to upload file',
                        style: TextStyle(
                          color: filePath != null ? Colors.green[700] : Colors.grey[600],
                          fontWeight: filePath != null ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (filePath != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          filePath.split('/').last,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: error ? Colors.red : Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (error) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
