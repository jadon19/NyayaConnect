import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../sidebar_menu/my_reviews.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/user_manager.dart';

class LawyerProfileScreen extends StatefulWidget {
  const LawyerProfileScreen({super.key});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  static const Color themeColor = Color(0xFF42A5F5);

  final _bioController = TextEditingController();
  final _dobController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _pincodeController = TextEditingController();
  final _chargesController = TextEditingController();

  String? _selectedGender;
  String? _selectedState;
  String? _selectedSpeciality;
  int? _selectedExperience;
  List<String> _selectedLanguages = [];

  String? _lawyerId;
  String? _lawyerName;
  String? _lawyerEmail;
  String? _lawyerPhone;

  double _avgRating = 0;
  int _totalRatings = 0;

  File? _localImage;
  String? _profileImageUrl;

  bool _isSaving = false;
  bool _loading = true;
  Map<String, dynamic>? _details;
  Map<String, dynamic>? _ratings;

  final List<String> _states = [
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

  final List<String> _specialityOptions = [
    'Criminal Law',
    'Civil Law',
    'Corporate Law',
    'Family Law',
    'Property Law',
    'Tax Law',
    'Constitutional Law',
    'Labour Law',
    'Intellectual Property Law',
    'Environmental Law',
    'Cyber Law',
    'Immigration Law',
    'General Practice',
  ];

  final List<String> _languageOptions = [
    'English',
    'Hindi',
    'Marathi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Punjabi',
    'Bengali',
    'Gujarati',
  ];

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    final result = await _loadLawyerBaseInfo();

    _details = result["details"];
    _ratings = result["ratings"];

    // fill controllers here ONCE
    _bioController.text = _details!["bio"] ?? "";
    _dobController.text = _details!["dob"] ?? "";
    _selectedGender = _details!["gender"].toString().isEmpty
        ? null
        : _details!["gender"];
    _address1Controller.text = _details!["addressLine1"] ?? "";
    _address2Controller.text = _details!["addressLine2"] ?? "";
    _selectedState = _details!["state"].toString().isEmpty
        ? null
        : _details!["state"];
    _pincodeController.text = _details!["pincode"] ?? "";
    _selectedSpeciality = _details!["speciality"].toString().isEmpty
        ? null
        : _details!["speciality"];
    _selectedExperience = _details!["experienceYears"];
    _selectedLanguages = List<String>.from(_details!["languages"] ?? []);
    _chargesController.text = "${_details!["chargesPerHour"] ?? 0}";
    _profileImageUrl = _details!["profilePicUrl"];

    _avgRating = (_ratings!["avgRating"] ?? 0.0).toDouble();
    _totalRatings = _ratings!["totalRatings"] ?? 0;

    setState(() => _loading = false);
  }

  Future<Map<String, dynamic>> _loadLawyerBaseInfo() async {
    final manager = UserManager();
    final lawyerId = manager.lawyerId;
    _lawyerId = lawyerId;
    if (lawyerId == null) return {};

    final lawyerRef = FirebaseFirestore.instance
        .collection("lawyers")
        .doc(lawyerId);

    final detailsRef = FirebaseFirestore.instance
        .collection("lawyer_details")
        .doc(lawyerId);

    final ratingsRef = FirebaseFirestore.instance
        .collection("lawyer_ratings")
        .doc(lawyerId);

    final lawyerSnap = await lawyerRef.get();
    final detailsSnap = await detailsRef.get();
    final ratingsSnap = await ratingsRef.get();

    // ---------- BASIC INFO ----------
    final lawyerData = lawyerSnap.data() ?? {};
    _lawyerName = lawyerData["name"];
    _lawyerEmail = lawyerData["email"];
    _lawyerPhone = lawyerData["phone"];

    // ---------- CREATE DEFAULT DETAILS ----------
    if (!detailsSnap.exists) {
      await detailsRef.set({
        "bio": "",
        "dob": "",
        "gender": "",
        "addressLine1": "",
        "addressLine2": "",
        "state": "",
        "pincode": "",
        "speciality": "",
        "experienceYears": 0,
        "languages": [],
        "chargesPerHour": 0,
        "profilePicUrl": "",
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    // ---------- CREATE DEFAULT RATINGS ----------
    if (!ratingsSnap.exists) {
      await ratingsRef.set({"avgRating": 0.0, "totalRatings": 0});
    }

    // Now return the new values
    final newDetails = (await detailsRef.get()).data();
    final newRatings = (await ratingsRef.get()).data();

    return {"details": newDetails, "ratings": newRatings};
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _localImage = File(picked.path));
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dobController.text = DateFormat("yyyy-MM-dd").format(picked);
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      if (_lawyerId == null) throw "Missing Lawyer ID";

      int charges = int.tryParse(_chargesController.text.trim()) ?? 0;
      String? downloadUrl;

      if (_localImage != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final storageRef = FirebaseStorage.instance.ref().child(
          "profile_photos/$uid.jpg",
        );

        print("UPLOAD PATH: profile_photos/$uid.jpg");

        await storageRef.putFile(_localImage!);
        downloadUrl = await storageRef.getDownloadURL();
      }

      final data = {
        "bio": _bioController.text.trim(),
        "dob": _dobController.text.trim(),
        "gender": _selectedGender ?? "",
        "addressLine1": _address1Controller.text.trim(),
        "addressLine2": _address2Controller.text.trim(),
        "state": _selectedState ?? "",
        "pincode": _pincodeController.text.trim(),
        "speciality": _selectedSpeciality ?? "",
        "experienceYears": _selectedExperience ?? 0,
        "chargesPerHour": charges,
        "languages": _selectedLanguages,
        "updatedAt": FieldValue.serverTimestamp(),
        if (downloadUrl != null) "profilePicUrl": downloadUrl,
      };

      await FirebaseFirestore.instance
          .collection("lawyer_details")
          .doc(_lawyerId)
          .set(data, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile Saved")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // =======================================================================
  //                              FINAL UI (CLEAN & CORRECT)
  // =======================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Your Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileUI(),
    );
  }

  // ====================================================================
  // Helper Widgets
  // ====================================================================
  Widget _buildProfileUI() {
    // Now build your scrollable UI
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 6),

            // ---------------- PROFILE IMAGE ----------------
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeColor.withOpacity(0.8),
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
                          : (_profileImageUrl != null &&
                                _profileImageUrl!.isNotEmpty)
                          ? ClipOval(
                              child: Image.network(
                                _profileImageUrl!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              (_lawyerName != null && _lawyerName!.isNotEmpty)
                                  ? _lawyerName![0].toUpperCase()
                                  : "L",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, size: 18, color: themeColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Lawyer Name
            Text(
              _lawyerName ?? "Lawyer",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: themeColor,
              ),
            ),

            const SizedBox(height: 4),

            if (_lawyerPhone != null)
              Text(
                "+91 $_lawyerPhone",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

            const SizedBox(height: 10),

            // Ratings
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < _avgRating.round()
                        ? Icons.star
                        : Icons.star_border_outlined,
                    color: Colors.amber,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "($_totalRatings reviews)",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---------------- ALL FIELDS ----------------
            _field(icon: Icons.email, child: _readonly(_lawyerEmail ?? "")),

            _field(
              icon: Icons.info_outline,
              child: TextFormField(
                controller: _bioController,
                decoration: _dec("Short professional bio"),
              ),
            ),

            _field(
              icon: Icons.cake_outlined,
              child: InkWell(
                onTap: _pickDob,
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _dobController,
                    decoration: _dec("Date of Birth"),
                  ),
                ),
              ),
            ),

            _field(
              icon: Icons.person_outline,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(
                      value: "Prefer not to say",
                      child: Text("Prefer not to say"),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
              ),
            ),

            _field(
              icon: Icons.home_outlined,
              child: TextFormField(
                controller: _address1Controller,
                decoration: _dec("Address line 1"),
              ),
            ),

            _field(
              icon: Icons.location_city_outlined,
              child: TextFormField(
                controller: _address2Controller,
                decoration: _dec("Address line 2"),
              ),
            ),

            _field(
              icon: Icons.map_outlined,
              child: DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: const InputDecoration(border: InputBorder.none),
                items: _states
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedState = v),
              ),
            ),

            _field(
              icon: Icons.pin_drop_outlined,
              child: TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: _dec("Pincode"),
              ),
            ),

            _field(
              icon: Icons.balance,
              child: DropdownButtonFormField(
                value: _selectedSpeciality,
                decoration: const InputDecoration(border: InputBorder.none),
                items: _specialityOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSpeciality = v),
              ),
            ),

            _field(
              icon: Icons.exposure_outlined,
              child: DropdownButtonFormField(
                value: _selectedExperience,
                decoration: const InputDecoration(border: InputBorder.none),
                items: List.generate(
                  40,
                  (i) => DropdownMenuItem(value: i, child: Text("$i yr")),
                ),
                onChanged: (v) => setState(() => _selectedExperience = v),
              ),
            ),

            _field(
              icon: Icons.currency_rupee,
              child: TextFormField(
                controller: _chargesController,
                keyboardType: TextInputType.number,
                decoration: _dec("Charges per hour"),
              ),
            ),

            // ---------------- Languages ----------------
            _field(
              icon: Icons.language,
              child: DropdownButtonFormField<String>(
                value: null,
                decoration: const InputDecoration(border: InputBorder.none),
                items: _languageOptions
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) {
                  if (!_selectedLanguages.contains(v) &&
                      _selectedLanguages.length < 3) {
                    setState(() => _selectedLanguages.add(v!));
                  }
                },
              ),
            ),

            Wrap(
              spacing: 6,
              children: _selectedLanguages
                  .map(
                    (l) => Chip(
                      label: Text(l),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () =>
                          setState(() => _selectedLanguages.remove(l)),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _lawyerId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LawyerReviewsScreen(lawyerId: _lawyerId!),
                          ),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: themeColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "View My Reviews",
                  style: TextStyle(color: themeColor),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
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
    );
  }

  Widget _field({required IconData icon, required Widget child}) {
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
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  InputDecoration _dec(String? hint) {
    return InputDecoration(border: InputBorder.none, hintText: hint);
  }

  Widget _readonly(String value) {
    return Text(value, style: const TextStyle(color: Colors.black87));
  }
}
