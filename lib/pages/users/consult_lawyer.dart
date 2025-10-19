import 'package:flutter/material.dart';
import 'book_lawyer/lawyer_profile.dart';

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
    "Criminal Law",
    "Property Dispute",
    "Cyber Crime",
    "Family Law",
    "Employment Issue",
  ];
  final List<String> languages = ["English", "Hindi", "Kannada", "Tamil"];
  final List<String> genders = ["Male", "Female", "No Preference"];

  final List<Map<String, dynamic>> lawyers = [
    {
      'name': 'Karan Jeet Rai Sharma',
      'specialization': 'Cyber Crime & Criminal Law',
      'experience': '15 years',
      'languages': 'Tamil, Hindi, Kannada',
      'rating': 4.8,
      'reviews': 1524,
      'charges': 31,
      'gender': 'Male',
    },
    {
      'name': 'Radhika N Chari',
      'specialization': 'Property & Family Dispute',
      'experience': '12 years',
      'languages': 'English, Hindi',
      'rating': 4.9,
      'reviews': 320,
      'charges': 42,
      'gender': 'Female',
    },
    {
      'name': 'Milind Awasthi',
      'specialization': 'Criminal & Civil Cases',
      'experience': '10 years',
      'languages': 'English, Hindi',
      'rating': 4.7,
      'reviews': 606,
      'charges': 35,
      'gender': 'Male',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), _showPreferenceModal);
  }

  void _showPreferenceModal() {
    int step = 0;
    PageController pageController = PageController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void nextStep() {
              if (step < 2) {
                setModalState(() => step++);
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
              }
            }

            Widget stepIndicator() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: index <= step
                          ? Colors.blue.shade700
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    40, // ⬅️ added space
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      "Let's help you find the right lawyer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  stepIndicator(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDropdown(
                          title: "What is your concern area?",
                          value: selectedConcern,
                          items: concerns,
                          onChanged: (val) =>
                              setModalState(() => selectedConcern = val),
                        ),
                        _buildDropdown(
                          title: "Preferred Language",
                          value: selectedLanguage,
                          items: languages,
                          onChanged: (val) =>
                              setModalState(() => selectedLanguage = val),
                        ),
                        _buildDropdown(
                          title: "Lawyer Preference",
                          value: selectedGender,
                          items: genders,
                          onChanged: (val) =>
                              setModalState(() => selectedGender = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: nextStep,
                    child: Text(
                      step < 2 ? "Next" : "Done",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
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
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blue.shade50,
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
        title: const Text("Talk To Lawyer"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: lawyers.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final lawyer = lawyers[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LawyerProfilePage(lawyer: lawyer),
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
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(
                      'assets/images/lawyer_placeholder.png',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lawyer['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          lawyer['specialization'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 6),
                        Text("Exp: ${lawyer['experience']}"),
                        Text("Languages: ${lawyer['languages']}"),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                            Text("${lawyer['rating']}  "),
                            Text(
                              "₹${lawyer['charges']}/hr",
                              style: TextStyle(
                                color: Colors.blue.shade700,
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
          );
        },
      ),
    );
  }
}
