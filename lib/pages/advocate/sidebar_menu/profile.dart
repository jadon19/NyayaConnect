import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String? _selectedGender;
  String? _profilePicUrl;
  File? _pickedImage;

  // read-only
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
      _bioController.text = data['bio'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _selectedGender = data['gender'];
      _addressController.text = data['address'] ?? '';
      _stateController.text = data['state'] ?? '';
      _pincodeController.text = data['pincode'] ?? '';
      _profilePicUrl = data['profilePic'];
      _loading = false;
    });
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_pickedImage == null) return null;
    try {
      final ref =
          FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
      await ref.putFile(_pickedImage!);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      final profileUrl = await _uploadProfileImage(user.uid);
      final payload = {
        'bio': _bioController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _selectedGender ?? '',
        'address': _addressController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
      };
      if (profileUrl != null) {
        payload['profilePic'] = profileUrl;
        _profilePicUrl = profileUrl;
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
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(hint),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            hintText: hint,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF42A5F5), width: 1.5),
            ),
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: _genderOptions.map((g) {
              final selected = _selectedGender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          selected ? const Color(0xFF42A5F5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF42A5F5)
                            : Colors.transparent,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF42A5F5).withOpacity(0.25),
                                blurRadius: 8,
                              )
                            ]
                          : null,
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
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Pincode must be exactly 6 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  Container(
                    height: 260,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF64B5F6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                  ),
                  Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: const Text('Your Profile'),
                        actions: const [
                          Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.settings_outlined),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            children: [
                              _buildHeaderCard(),
                              const SizedBox(height: 16),
                              _buildFormCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          6,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _saving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final imageProvider = _pickedImage != null
        ? FileImage(_pickedImage!)
        : (_profilePicUrl != null && _profilePicUrl!.isNotEmpty
            ? NetworkImage(_profilePicUrl!)
            : null);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: imageProvider as ImageProvider?,
                  backgroundColor: Colors.white,
                  child: imageProvider == null
                      ? const Icon(Icons.person,
                          size: 42, color: Color(0xFF42A5F5))
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
                          color: Colors.black12,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.edit,
                        size: 18, color: Color(0xFF0288D1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _name.isEmpty ? 'User' : _name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Nyaya Connect Member',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            _infoField('Email', _email),
            _infoField('Phone', _phone),
          ],
        ),
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _textField(
                controller: _bioController,
                hint: 'Bio',
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a short bio';
                  }
                  if (v.trim().length < 10) {
                    return 'Bio should be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _textField(
                controller: _ageController,
                hint: 'Age',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter age';
                  if (!RegExp(r'^\d+$').hasMatch(v.trim())) {
                    return 'Invalid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _genderSelector(),
              const SizedBox(height: 14),
              _textField(
                controller: _addressController,
                hint: 'Address',
                keyboardType: TextInputType.streetAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: _stateController,
                      hint: 'State',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
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
    );
  }
}