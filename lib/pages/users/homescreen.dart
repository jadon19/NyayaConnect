import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyaya_connect/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/testimonial_card.dart';
import '../notification_screen.dart';
import 'learning_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'consult_lawyer.dart';
import 'document_review.dart';
import 'meetings.dart';
import 'documents/case_files.dart';
import 'documents/consultation_summaries.dart';
import 'documents/court_orders.dart';
import 'documents/legal_templates.dart';
import 'documents/supporting_documents.dart';

class HomeScreenUser extends StatefulWidget {
  final String userName;

  const HomeScreenUser({super.key, required this.userName});

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _sidebarAnimation;
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
            (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error logging out. Please try again.')),
        );
      }
    }
  }

  void _toggleSidebar() {
    HapticFeedback.mediumImpact();
    setState(() => _isSidebarOpen = !_isSidebarOpen);
    _isSidebarOpen ? _controller.forward() : _controller.reverse();
  }

  void _closeSidebar() {
    if (_isSidebarOpen) {
      _controller.reverse();
      setState(() => _isSidebarOpen = false);
    }
  }

  void _onNavBarTap(int index) {
    setState(() => _currentIndex = index);
    HapticFeedback.lightImpact();
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.userName}'),
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMainContent(),

          /// Blur overlay
          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              final opacity = _sidebarAnimation.value * 0.25;
              return IgnorePointer(
                ignoring: !_isSidebarOpen,
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 250),
                  child: GestureDetector(
                    onTap: _closeSidebar,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 6 * _sidebarAnimation.value,
                        sigmaY: 6 * _sidebarAnimation.value,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(opacity * 0.6),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          /// Sidebar overlay
          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              final slide = (1 - _sidebarAnimation.value) * -260;
              return Transform.translate(
                offset: Offset(slide, 0),
                child: child,
              );
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildSidebar(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE53E3E),
        onPressed: _showEmergencyDialog,
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: const Text('Emergency Help'),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  // ✅ Redesigned Sidebar (light)
  Widget _buildSidebar() {
    final menuItems = [
      {'icon': Icons.person, 'label': 'Profile'},
      {'icon': Icons.folder, 'label': 'My Documents'},
      {'icon': Icons.call, 'label': 'Call Logs'},
      {'icon': Icons.payment, 'label': 'Transactions'},
      {'icon': Icons.work, 'label': 'My Cases'},
      {'icon': Icons.location_on, 'label': 'Track Case'},
      {'icon': Icons.support_agent, 'label': 'Support'},
      {'icon': Icons.share, 'label': 'Share'},
      {'icon': Icons.feedback, 'label': 'Feedback'},
    ];

    return Material(
      elevation: 12,
      color: Colors.transparent,
      child: Container(
        width: 260,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFFB3E5FC),
                  child: Icon(Icons.person, color: Colors.blue, size: 36),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(color: Colors.black26),
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: Icon(menuItems[i]['icon'] as IconData,
                        color: Colors.blue.shade700),
                    title: Text(menuItems[i]['label'] as String,
                        style: const TextStyle(color: Colors.black87)),
                    onTap: _closeSidebar,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Actions with icons
  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Consult Lawyer', 'icon': Icons.gavel, 'page': const ConsultLawyerPage()},
      {'title': 'Document Review', 'icon': Icons.description, 'page': const DocumentReviewPage()},
      {'title': 'Meeting Scheduled', 'icon': Icons.calendar_today, 'page': const MeetingScheduledPage()},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => a['page'] as Widget),
            ),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: Colors.blue.shade700, size: 30),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 85,
                  child: Text(
                    a['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Pro Bono cards with icons
  Widget _buildProBonoSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('pro_bono_opportunities')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!.docs;
        return Column(
          children: data.map((doc) {
            final d = doc.data();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.volunteer_activism,
                      color: Colors.green, size: 30),
                  title: Text(d['title'] ?? 'Pro Bono Opportunity',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(d['description'] ?? '',
                      style: const TextStyle(color: Colors.black87)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Reuse Legend Card for E-Court and AI Forum
  Widget _buildLegendCard({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onTap,
                      child: Text(buttonText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWelcomeBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF90CAF9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: _toggleSidebar,
          child: const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child:
            Icon(Icons.person, color: Color(0xFF42A5F5), size: 28),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Good ${_getGreeting()},",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              Text(widget.userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    ),
  );

  // Restored Documents horizontal list (Case files, Consultation Summaries, Court Orders, Legal Templates, Supporting Documents)
  Widget _buildDocuments() {
    final List<Map<String, dynamic>> docs = [
      {'title': 'Case files', 'page': const CaseFilesPage(), 'icon': Icons.folder_shared},
      {'title': 'Consultation Summaries', 'page': const ConsultationSummariesPage(), 'icon': Icons.article},
      {'title': 'Court Orders', 'page': const CourtOrdersPage(), 'icon': Icons.gavel},
      {'title': 'Legal Templates', 'page': const LegalTemplatesPage(), 'icon': Icons.description},
      {'title': 'Supporting Documents', 'page': const SupportingDocumentsPage(), 'icon': Icons.attach_file},
    ];

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: docs.map((d) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => d['page'] as Widget),
            ),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(d['icon'] as IconData, color: Colors.blue.shade700, size: 30),
                  const SizedBox(height: 8),
                  Text(d['title']?.toString() ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Restored My Learning section that links to Learning screen
  Widget _buildMyLearningSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("My Learning"),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyLearningPage()),
              );
            },
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/learning_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Text(
                  "Learning Points",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Text(title,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87)),
  );

  // Main body content (placed documents and learning back into content)
  Widget _buildMainContent() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 12 && !_isSidebarOpen) _toggleSidebar();
        if (details.delta.dx < -12 && _isSidebarOpen) _closeSidebar();
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF90CAF9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeBanner(),
                  const SizedBox(height: 20),

                  // 🔹 Quick Actions
                  _buildSectionHeader("Quick Actions"),
                  _buildQuickActions(),
                  const SizedBox(height: 25),

                  // 🔹 Documents Section
                  _buildSectionHeader("Documents"),
                  const SizedBox(height: 8),
                  _buildDocuments(),
                  const SizedBox(height: 16),

                  // 🔹 E-Court
                  _buildLegendCard(
                    title: "E-Court",
                    description:
                    "Access virtual courtrooms and manage your cases digitally.",
                    buttonText: "Enter a courtroom",
                    onTap: () => Navigator.pushNamed(context, '/eCourt'),
                    icon: Icons.account_balance_outlined,
                  ),

                  // 🔹 AI Doubt Forum
                  _buildLegendCard(
                    title: "AI Doubt Forum",
                    description:
                    "Get AI-powered assistance for legal queries and case research.",
                    buttonText: "Ask AI Agent",
                    onTap: () => Navigator.pushNamed(context, '/aiDoubt'),
                    icon: Icons.smart_toy_outlined,
                  ),

                  const SizedBox(height: 12),

                  // 🔹 My Learning Section
                  _buildMyLearningSection(),

                  const SizedBox(height: 25),

                  // 🔹 Testimonials
                  _buildSectionHeader("What Clients Say"),
                  _buildTestimonials(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTestimonials() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: const [
          TestimonialCard(
            name: 'Rajesh Kumar',
            text: 'Excellent service! Found the perfect lawyer.',
          ),
          SizedBox(width: 16),
          TestimonialCard(
            name: 'Priya Sharma',
            text: 'Quick response and professional guidance.',
          ),
          SizedBox(width: 16),
          TestimonialCard(
            name: 'Amit Singh',
            text: 'The consultation was very helpful and affordable.',
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emergency Legal Help'),
        content: const Text(
          'Do you need immediate legal assistance? We can connect you with an emergency consultant right away.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text('Get Help Now',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
