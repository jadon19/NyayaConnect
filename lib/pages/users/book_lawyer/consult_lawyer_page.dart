import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'lawyer_profile_page.dart';

class LawyerCardData {
  LawyerCardData({
    required this.id,
    required this.name,
    required this.speciality,
    required this.experienceYears,
    required this.languages,
    required this.rating,
    required this.reviewCount,
    required this.charges,
    required this.gender,
    required this.profilePic,
  });

  final String id;
  final String name;
  final String speciality;
  final int experienceYears;
  final List<String> languages;
  final double rating;
  final int reviewCount;
  final double charges;
  final String gender;
  final String? profilePic;
}

class ConsultLawyerPage extends StatefulWidget {
  const ConsultLawyerPage({super.key});

  @override
  State<ConsultLawyerPage> createState() => _ConsultLawyerPageState();
}

class _ConsultLawyerPageState extends State<ConsultLawyerPage> {
  String? selectedConcern;
  String? selectedLanguage;
  String? selectedGender;

  final List<String> concerns = [
    'Criminal Law',
    'Property Dispute',
    'Cyber Crime',
    'Family Law',
    'Employment Issue',
  ];
  final List<String> languages = ['English', 'Hindi', 'Kannada', 'Tamil'];
  final List<String> genders = ['Male', 'Female', 'No Preference'];
  bool preferencesCompleted = false;

  final List<LawyerCardData> _allLawyers = [];
  final List<LawyerCardData> _filteredLawyers = [];
  bool _loading = true;
  bool _firstDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _listenToLawyers();
  }

 void _listenToLawyers() {
  FirebaseFirestore.instance
      .collection('lawyers')
      .where('isVerified', isEqualTo: true)
      .snapshots()
      .listen((lawyersSnapshot) async {

    final list = <LawyerCardData>[];

    for (final doc in lawyersSnapshot.docs) {
      final id = doc.id;
      final base = doc.data();

      final details = (await FirebaseFirestore.instance
              .collection('lawyer_details')
              .doc(id)
              .get())
          .data() ?? {};

      final ratings = (await FirebaseFirestore.instance
              .collection('lawyer_ratings')
              .doc(id)
              .get())
          .data() ?? {};

      list.add(LawyerCardData(
        id: id,
        name: base['name'] ?? 'Unknown',
        gender: details['gender'] ?? 'Not specified',
        speciality: details['speciality'] ?? 'General Practice',
        experienceYears: details['experienceYears'] ?? 0,
        languages: List<String>.from(details['languages'] ?? []),
        charges: (details['chargesPerHour'] ?? 0).toDouble(),
        profilePic: details['profilePicUrl'],
        rating: (ratings['avgRating'] ?? 0).toDouble(),
        reviewCount: ratings['totalRatings'] ?? 0,
      ));
    }

    setState(() {
      _allLawyers
        ..clear()
        ..addAll(list);

      _applyFilters();
      _loading = false;
    });

    // SHOW MODAL ONLY AFTER FIRST LOAD
    if (!_firstDataLoaded) {
      _firstDataLoaded = true;

      Future.microtask(() {
        _showPreferenceModal();
      });
    }
  });
}



  void _applyFilters() {
    // If NO filter is selected → show ALL lawyers
    if (selectedConcern == null &&
        selectedLanguage == null &&
        selectedGender == null) {
      setState(() {
        _filteredLawyers
          ..clear()
          ..addAll(_allLawyers);
      });
      return;
    }

    // If ANY filter is selected → apply dynamically
    final filtered = _allLawyers.where((lawyer) {
      final concernMatch = selectedConcern == null
          ? true
          : lawyer.speciality.contains(selectedConcern!);

      final languageMatch = selectedLanguage == null
          ? true
          : lawyer.languages
                .map((e) => e.toLowerCase())
                .contains(selectedLanguage!.toLowerCase());

      final genderMatch =
          selectedGender == null || selectedGender == 'No Preference'
          ? true
          : lawyer.gender.toLowerCase() == selectedGender!.toLowerCase();

      return concernMatch && languageMatch && genderMatch;
    }).toList();

    setState(() {
      _filteredLawyers
        ..clear()
        ..addAll(filtered);
    });
  }

  void _showPreferenceModal() {
    int step = 0;
    final controller = PageController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            void nextStep() {
              if (step < 2) {
                modalSetState(() => step++);
                controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
                setState(() => preferencesCompleted = true);
                _applyFilters();
              }
            }

            return Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Let's help you find the right lawyer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: index <= step
                                ? const Color(0xFF42A5F5)
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 140,
                      child: PageView(
                        controller: controller,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildDropdown(
                            title: 'What is your concern area?',
                            value: selectedConcern,
                            items: concerns,
                            onChanged: (val) =>
                                modalSetState(() => selectedConcern = val),
                          ),
                          _buildDropdown(
                            title: 'Preferred Language',
                            value: selectedLanguage,
                            items: languages,
                            onChanged: (val) =>
                                modalSetState(() => selectedLanguage = val),
                          ),
                          _buildDropdown(
                            title: 'Lawyer Preference',
                            value: selectedGender,
                            items: genders,
                            onChanged: (val) =>
                                modalSetState(() => selectedGender = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42A5F5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: nextStep,
                      child: Text(
                        step < 2 ? 'Next' : 'Done',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown({
    required String title,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF42A5F5).withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Talk To Lawyer'),
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filteredLawyers.isEmpty
          ? Center(
              child: Text(
                selectedConcern == null ||
                        selectedLanguage == null ||
                        selectedGender == null
                    ? 'No lawyers available yet.'
                    : 'No lawyers match these preferences.',
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredLawyers.length,
              itemBuilder: (context, index) {
                final lawyer = _filteredLawyers[index];

                return Opacity(
                  opacity: 1.0,// fade until preferences done
                  child: GestureDetector(
                    onTap: () {
                      // disable tap before completion

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LawyerProfilePage(lawyerId: lawyer.id),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: lawyer.profilePic != null
                                ? NetworkImage(lawyer.profilePic!)
                                : null,
                            backgroundColor: const Color(0xFF42A5F5),
                            child: lawyer.profilePic == null
                                ? Text(
                                    lawyer.name.isNotEmpty
                                        ? lawyer.name[0].toUpperCase()
                                        : 'L',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lawyer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  lawyer.speciality,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 6),
                                Text('Exp: ${lawyer.experienceYears} years'),
                                Text(
                                  'Languages: ${lawyer.languages.join(', ')}',
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber.shade700,
                                      size: 18,
                                    ),
                                    Text(
                                      ' ${lawyer.rating.toStringAsFixed(1)}  ',
                                    ),
                                    Text(
                                      '₹${lawyer.charges.toStringAsFixed(0)}/hr',
                                      style: const TextStyle(
                                        color: Color(0xFF42A5F5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
