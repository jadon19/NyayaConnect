// profile_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Gender and state
  String? _gender;
  String? _state;

  // profile image
  File? _localImage;
  String? _profileImageUrl;

  // A copy of userId (read from users collection)
  String? _userId;

  bool _isLoading = false;

  // Indian states list (short list; add full list if you want)
  final List<String> _indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserBaseInfo();
  }

  Future<void> _loadUserBaseInfo() async {
  final firebaseUser = _auth.currentUser;

  if (firebaseUser == null) {
    debugPrint("User not logged in");
    return;
  }

  final uid = firebaseUser.uid;

  try {
    // 1️⃣ Load users/{uid}
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? firebaseUser.email ?? '';
        _phoneController.text = data['phone']?.toString() ?? '';

        _userId = data['userId'] ?? uid;
      });

      print("AUTH UID = $uid");
      print("MANUAL USER ID (from users collection) = $_userId");
    } else {
      setState(() {
        _emailController.text = firebaseUser.email ?? '';
        _userId = uid;
      });

      print("USERS DOC NOT FOUND — Using UID as userId = $_userId");
    }

    print("Attempting to read Firestore: user_details/$_userId");

    // 2️⃣ Load extended user profile
    final detailsDoc =
        await _firestore.collection('user_details').doc(_userId).get();

    if (detailsDoc.exists) {
      final d = detailsDoc.data() as Map<String, dynamic>;

      setState(() {
        _profileImageUrl = d['profilePicUrl'];
        _bioController.text = d['bio'] ?? '';
        _dobController.text = d['dob'] ?? '';
        _gender = d['gender'];
        _address1Controller.text = d['addressLine1'] ?? '';
        _address2Controller.text = d['addressLine2'] ?? '';
        _state = d['state'];
        _pincodeController.text = d['pincode'] ?? '';
      });

      print("SUCCESS: Loaded user_details/$_userId");
    } else {
      print("user_details/$_userId DOES NOT EXIST");
    }
  } catch (e) {
    debugPrint("Error loading user info: $e");
  }
}


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _localImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
  final firebaseUid = _auth.currentUser?.uid;

  if (firebaseUid == null) {
    print("No auth UID found");
    return null;
  }

  if (_localImage == null) {
    print("No new image selected, keep old");
    return _profileImageUrl;
  }

  final ref = _storage.ref().child('profile_photos/$firebaseUid.jpg');

  try {
    await ref.putFile(_localImage!);
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    print("Profile photo upload error: $e");
    return null;
  }
}


  int _calculateAgeFromDob(String dobText) {
    // expecting dobText to be in yyyy-MM-dd format
    try {
      final dob = DateFormat('yyyy-MM-dd').parse(dobText);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final uid = _userId ?? _auth.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      setState(() => _isLoading = false);
      return;
    }
    

    try {
      // 1) Upload image if new
      final uploadedUrl = await _uploadProfileImage();

      // 2) Compute age
      final dobText = _dobController.text.trim();
      final age = _calculateAgeFromDob(dobText);

      // 3) Build payload
      final payload = {
        'userId': uid,
        'profilePicUrl': uploadedUrl ?? _profileImageUrl ?? '',
        'bio': _bioController.text.trim(),
        'dob': dobText,
        'age': age,
        'gender': _gender ?? '',
        'addressLine1': _address1Controller.text.trim(),
        'addressLine2': _address2Controller.text.trim(),
        'state': _state ?? '',
        'pincode': _pincodeController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 4) Save to user_details collection. Use userId as doc id so we can create/update easily.
      await _firestore
          .collection('user_details')
          .doc(_userId)
          .set(payload, SetOptions(merge: true));

      if (uploadedUrl != null) {
      setState(() {
        _profileImageUrl = uploadedUrl;
        _localImage = null;
      });
    }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    } catch (e) {
      debugPrint('Error saving profile: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
    


  }

  Future<void> _pickDob() async {
    final initialDate = DateTime(1995, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: (_dobController.text.isNotEmpty)
          ? DateTime.tryParse(_dobController.text) ?? initialDate
          : initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
      builder: (context, child) {
        // mimic Instagram-style full-screen or themed picker by providing theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF42A5F5), // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF42A5F5),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
        title: const Text(
          "Your Profile",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            
          ),
        ),
        leading: const BackButton(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 6),

              // ------------------ PROFILE IMAGE ------------------
              GestureDetector(
  onTap: _pickImage,
  child: Stack(
    alignment: Alignment.bottomRight,
    children: [
      // ⭐ Outer container for blue border
      Container(
        padding: const EdgeInsets.all(3), // thickness of border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF42A5F5).withOpacity(0.8),
            width: 3,
          ),
        ),
        child: CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white,
          child: _localImage != null
              ? ClipOval(
                  child: Image.file(
                    _localImage!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                )
              : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                  ? ClipOval(
                      child: Image.network(
                        _profileImageUrl!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Color(0xFF42A5F5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
        ),
      ),

      // ⭐ Camera icon stays ABOVE, no overlap with border
      CircleAvatar(
        radius: 15,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.camera_alt,
          size: 18,
          color: const Color(0xFF42A5F5),
        ),
      ),
    ],
  ),
),


              const SizedBox(height: 12),

              // NAME
              Text(
                _nameController.text.isEmpty
                    ? "User Name"
                    : _nameController.text,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF42A5F5),
                ),
              ),

              const SizedBox(height: 4),

              // PHONE
              Text(
                "+91 ${_phoneController.text}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 20),

              // ------------------ EMAIL ------------------
              _buildInputField(
                icon: Icons.email_outlined,
                child: TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "email@example.com",
                  ),
                ),
              ),

              // ------------------ BIO ------------------
              _buildInputField(
                icon: Icons.info_outline,
                child: TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Bio (like Instagram bio)",
                  ),
                ),
              ),

              // ------------------ DOB + GENDER ------------------
              _buildInputField(
                icon: Icons.cake_outlined,
                child: InkWell(
                  onTap: _pickDob,
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Date of Birth",
                      ),
                    ),
                  ),
                ),
              ),

              _buildInputField(
                icon: Icons.person_outline,
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(border: InputBorder.none),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                      DropdownMenuItem(
                        value: "Prefer not to say",
                        child: Text("Prefer not to say"),
                      ),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                ),
              ),

              // ------------------ ADDRESS ------------------
              _buildInputField(
                icon: Icons.home_outlined,
                child: TextFormField(
                  controller: _address1Controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Address line 1",
                  ),
                ),
              ),

              _buildInputField(
                icon: Icons.location_on_outlined,
                child: TextFormField(
                  controller: _address2Controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Address line 2",
                  ),
                ),
              ),

              // ------------------ STATE + PIN ------------------
              _buildInputField(
                icon: Icons.map_outlined,
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _state,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(border: InputBorder.none),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _indianStates
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _state = v),
                  ),
                ),
              ),

              _buildInputField(
                icon: Icons.pin_drop_outlined,
                child: TextFormField(
                  controller: _pincodeController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: "Pincode",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ------------------ SAVE BUTTON ------------------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Profile",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required IconData icon, required Widget child}) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _pincodeController.dispose();
    super.dispose();
  }
}
