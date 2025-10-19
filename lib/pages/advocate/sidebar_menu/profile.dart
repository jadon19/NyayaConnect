import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _chargesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String? _selectedGender;
  String? _selectedSpecialization;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _profilePicUrl = '';

  double? _rating;
  int? _reviewCount;

  bool _loading = true;
  File? _pickedImage;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _specializationOptions = [
    'Criminal Law',
    'Civil Law',
    'Corporate Law',
    'Family Law',
    'Property Law',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _name = data['name'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';
      }

      final lawyerDoc = await FirebaseFirestore.instance
          .collection('lawyers')
          .doc(user.uid)
          .get();
      if (lawyerDoc.exists) {
        final data = lawyerDoc.data()!;
        _ageController.text = data['age']?.toString() ?? '';
        _selectedGender = data['gender'];
        _bioController.text = data['bio'] ?? '';
        _experienceController.text = data['experience'] ?? '';
        _languagesController.text = data['languages'] ?? '';
        _chargesController.text = data['charges']?.toString() ?? '';
        _profilePicUrl = data['profilePic'] ?? '';
        _addressController.text = data['address'] ?? '';
        _stateController.text = data['state'] ?? '';
        _pincodeController.text = data['pincode'] ?? '';
      }

      setState(() => _loading = false);
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('lawyers').doc(user.uid).set({
      'age': _ageController.text.trim(),
      'gender': _selectedGender ?? '',
      'bio': _bioController.text.trim(),
      'specialization': _selectedSpecialization ?? '',
      'experience': _experienceController.text.trim(),
      'languages': _languagesController.text.trim(),
      'charges': double.tryParse(_chargesController.text.trim()) ?? 0,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _languagesController.dispose();
    _chargesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF0288D1),
        elevation: 2,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      top: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile header
                            Card(
                              color: Colors.white, // make background white
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _pickProfileImage,
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          CircleAvatar(
                                            radius: 40,
                                            backgroundImage:
                                                _pickedImage != null
                                                ? FileImage(_pickedImage!)
                                                : _profilePicUrl.isNotEmpty
                                                ? NetworkImage(_profilePicUrl)
                                                      as ImageProvider
                                                : null,
                                            backgroundColor:
                                                Colors.blue.shade100,
                                            child:
                                                (_pickedImage == null &&
                                                    _profilePicUrl.isEmpty)
                                                ? const Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Color(0xFF0288D1),
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            _email,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            _phone,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Stats cards
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _legendCard(
                                  Icons.star,
                                  'Rating',
                                  _rating != null ? '$_rating ⭐' : 'No rating',
                                ),
                                _legendCard(
                                  Icons.reviews,
                                  'Reviews',
                                  _reviewCount != null ? '$_reviewCount' : '0',
                                ),
                                _legendCard(
                                  Icons.monetization_on,
                                  'Charges',
                                  _chargesController.text.isNotEmpty
                                      ? '₹${_chargesController.text}/hr'
                                      : '-',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Editable form
                            Card(
                              color:Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      _buildTextField(
                                        'Age',
                                        _ageController,
                                        TextInputType.number,
                                      ),
                                      _buildDropdown(
                                        'Gender',
                                        _selectedGender,
                                        _genderOptions,
                                        (val) {
                                          setState(() => _selectedGender = val);
                                        },
                                      ),
                                      _buildTextField(
                                        'Bio',
                                        _bioController,
                                        TextInputType.multiline,
                                        maxLines: 3,
                                      ),
                                      _buildDropdown(
                                        'Specialization',
                                        _selectedSpecialization,
                                        _specializationOptions,
                                        (val) {
                                          setState(
                                            () => _selectedSpecialization = val,
                                          );
                                        },
                                      ),
                                      _buildTextField(
                                        'Experience',
                                        _experienceController,
                                        TextInputType.text,
                                      ),
                                      _buildTextField(
                                        'Languages',
                                        _languagesController,
                                        TextInputType.text,
                                      ),
                                      _buildTextField(
                                        'Charges per hour',
                                        _chargesController,
                                        TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),

                            // Save button
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 10,
                              ),
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0288D1),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 40,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black26,
                                ),
                                child: const Text(
                                  'Save Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTextField(
  String label,
  TextEditingController controller,
  TextInputType type, {
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0288D1),
                width: 1.5,
              ),
            ),
          ),
          validator: (value) {
            if ((value ?? '').isEmpty) return 'Please enter $label';
            return null;
          },
        ),
      ],
    ),
  );
}

  Widget _buildDropdown(
  String label,
  String? currentValue,
  List<String> options,
  ValueChanged<String?> onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: DropdownButtonFormField<String>(
      initialValue: currentValue,
      decoration: InputDecoration(
        labelText: label,
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
      ),
      hint: Text('Select $label'),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select $label';
        return null;
      },
    ),
  );
}



  Widget _legendCard(IconData icon, String title, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0288D1), size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
