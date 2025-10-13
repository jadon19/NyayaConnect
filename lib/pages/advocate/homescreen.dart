import 'package:flutter/material.dart';
import 'package:nyaya_connect/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ added
import '../legal_literacy.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/category_card.dart';
import '../../widgets/testimonial_card.dart';

/// Home screen for advocates
class HomeScreenLawyer extends StatefulWidget {
  final String userName;

  const HomeScreenLawyer({super.key, required this.userName});

  @override
  State<HomeScreenLawyer> createState() => _HomeAdvocateScreenState();
}

class _HomeAdvocateScreenState extends State<HomeScreenLawyer> {
  int _currentIndex = 0;

  // ✅ Logout function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.userName}'),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E88E5),
                        Color(0xFF42A5F5),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 35, color: Color(0xFF1E88E5)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// 🔹 Categories Section
                _buildSectionHeader("Categories", onTap: () {
                  // TODO: Navigate to categories list
                }),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CategoryCard(
                        icon: Icons.calendar_today,
                        label: 'Calendar',
                        onTap: () {
                          Navigator.pushNamed(context, '/calendar');
                        },
                      ),
                      CategoryCard(
                        icon: Icons.task_alt,
                        label: 'Tasks',
                        onTap: () {
                          Navigator.pushNamed(context, '/tasks');
                        },
                      ),
                      CategoryCard(
                        icon: Icons.receipt_long,
                        label: 'Invoice',
                        onTap: () {
                          Navigator.pushNamed(context, '/invoices');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// 🔹 E-Court Section
                _buildSectionHeader("E-Court"),
                const SizedBox(height: 12),
                _buildInfoCard(
                  title: "E-Court",
                  description:
                  "An e-Courtroom is a digital platform that enables remote legal proceedings, "
                      "allowing judges, lawyers, and clients to communicate through video conferencing.",
                ),

                const SizedBox(height: 24),

                /// 🔹 Personal Section
                _buildSectionHeader("Personal Section"),
                const SizedBox(height: 12),
                _buildPersonalSection(),

                const SizedBox(height: 24),

                /// 🔹 Reviews & Testimonials
                _buildSectionHeader("Reviews & Testimonials"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: const [
                      TestimonialCard(
                        name: 'Sudarsh Ranjan',
                        text:
                        'Great work by legal support analysts. It provides instant help for my legal problems.',
                      ),
                      SizedBox(width: 16),
                      TestimonialCard(
                        name: 'Rohan Singh',
                        text:
                        'Very satisfied with the gap between clients and legal knowledge being reduced.',
                      ),
                      SizedBox(width: 16),
                      TestimonialCard(
                        name: 'Vatsal Raina',
                        text:
                        'Instant help for my legal problems and better understanding of cases.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      /// 🔹 Bottom Navigation
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalLiteracyScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  /// 🔹 Helper Widgets

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              )),
          if (onTap != null)
            TextButton(
              onPressed: onTap,
              child: const Text(
                "Show All",
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    )),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new,
                    size: 18, color: Color(0xFF1E88E5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(description,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[700], height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF64B5F6),
              Color(0xFF42A5F5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _PersonalSectionItem(
              icon: Icons.description,
              label: 'Documents',
              onTap: () => Navigator.pushNamed(context, '/documents'),
            ),
            _PersonalSectionItem(
              icon: Icons.folder_open,
              label: 'Cases',
              onTap: () => Navigator.pushNamed(context, '/casesAdvocate'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalSectionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PersonalSectionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 35, color: const Color(0xFF1E88E5)),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }
}