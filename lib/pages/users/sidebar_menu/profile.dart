import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String? _selectedGender;
  File? _pickedImage;

  // Non-editable
  String _name = '';
  String _email = '';
  String _phone = '';

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      setState(() => _loading = false);
      return;
    }

    final data = doc.data()!;
    setState(() {
      _name = data['name'] ?? '';
      _email = data['email'] ?? '';
      _phone = data['phone'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _selectedGender = data['gender'];
      _addressController.text = data['address'] ?? '';
      _stateController.text = data['state'] ?? '';
      _pincodeController.text = data['pincode'] ?? '';
      _loading = false;
    });
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  // Upload image to Firebase Storage and return download URL (or null)
  Future<String?> _uploadProfileImage(String uid) async {
    if (_pickedImage == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
      final uploadTask = await ref.putFile(_pickedImage!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      // handle error upstream
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      String? profileUrl = await _uploadProfileImage(user.uid);

      // Prepare data exactly as "users" module expects (merge: true)
      final payload = {
        'age': _ageController.text.trim(),
        'gender': _selectedGender ?? '',
        'address': _addressController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
      };

      if (profileUrl != null) {
        payload['profilePic'] = profileUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(payload, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // Modern label + field builder
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );

  Widget _modernTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(hint),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0288D1), width: 1.5),
            ),
            counterText: '', // hide length counter
          ),
        ),
      ],
    );
  }

  Widget _genderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Gender'),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _genderOptions.map((g) {
              final selected = _selectedGender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF0288D1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? const Color(0xFF0288D1) : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      g,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String? _pincodeValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter Pincode';
    final p = value.trim();
    final valid = RegExp(r'^\d{6}$').hasMatch(p);
    if (!valid) return 'Pincode must be exactly 6 digits';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Profile'),
  backgroundColor: Colors.transparent, // make AppBar background transparent
  elevation: 0,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D47A1), // Dark Blue (top)
          Color(0xFF64B5F6), // Light Blue (bottom)
        ],
      ),
    ),
  ),
),

      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top card: avatar + readonly info
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 14.0),
                              child: Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 38,
                                        backgroundImage:
                                            _pickedImage != null ? FileImage(_pickedImage!) : null,
                                        backgroundColor: Colors.blue.shade100,
                                        child: _pickedImage == null
                                            ? const Icon(Icons.person, size: 36, color: Colors.white)
                                            : null,
                                      ),
                                      GestureDetector(
                                        onTap: _pickProfileImage,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.12),
                                                blurRadius: 6,
                                              )
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Color(0xFF0288D1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _name.isEmpty ? 'No name' : _name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _email.isEmpty ? 'No email' : _email,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _phone.isEmpty ? 'No phone' : _phone,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Form card
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Personal info',
                                      style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 12),

                                    // Age
                                    _modernTextField(
                                      controller: _ageController,
                                      hint: 'Age',
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Please enter Age';
                                        }
                                        // optional: ensure numeric
                                        if (!RegExp(r'^\d+$').hasMatch(v.trim())) {
                                          return 'Invalid age';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Gender selector
                                    _genderSelector(),
                                    const SizedBox(height: 12),

                                    // Address
                                    _modernTextField(
                                      controller: _addressController,
                                      hint: 'Address',
                                      keyboardType: TextInputType.streetAddress,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Please enter Address';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _modernTextField(
                                            controller: _stateController,
                                            hint: 'State',
                                            keyboardType: TextInputType.text,
                                            validator: (v) {
                                              if (v == null || v.trim().isEmpty) {
                                                return 'Please enter State';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _modernTextField(
                                            controller: _pincodeController,
                                            hint: 'Pincode',
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            validator: _pincodeValidator,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                  ),

                  // Save button anchored to bottom
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Profile',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
