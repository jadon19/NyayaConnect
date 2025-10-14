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
  State<HomeScreenUser> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeScreenUser>
    with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;

  int _currentIndex = 0;
  late AnimationController _fabController;
  late AnimationController _cardController;
  late Animation<double> _fabAnimation;
  late Animation<double> _cardAnimation;

  // Sidebar state + controller (controls both sidebar and content shift)
  bool _isSidebarOpen = false;
  late AnimationController _sidebarController;
  late Animation<Offset> _sidebarOffset;

  @override
  void initState() {
    super.initState();

    // Sidebar controller (drives both the sidebar slide and content transform)
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _sidebarOffset =
        Tween<Offset>(
          begin: const Offset(-1.0, 0.0), // off-screen left
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _sidebarController, curve: Curves.easeInOut),
        );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    );

    _fabController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _cardController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  // ✅ logout function
  Future<void> _logout() async {
  try {
    // ✅ Sign out from FirebaseAuth
    await FirebaseAuth.instance.signOut();

    // ✅ Clear locally stored data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // ✅ Safety check for widget mount
    if (!mounted) return;

    // ✅ Restart the app flow (go to Splash/Login)
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

  // Toggle sidebar open/close (used by welcome banner onTap)
  void _toggleSidebar() {
    setState(() {
      if (_isSidebarOpen) {
        _sidebarController.reverse();
      } else {
        _sidebarController.forward();
      }
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // amount to shift main content to the right when sidebar opens (60% of width)
    final double contentShift = screenWidth * 0.60;

    return Scaffold(
      // keep same appBar as before (static)
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

      // Body is now a Stack: sidebar + main content (which will translate/scale)
      body: Stack(
        children: [
          // 1) Sidebar (slides in from left)
          SlideTransition(position: _sidebarOffset, child: _buildSidebar()),

          // 2) Dim overlay (only visible when sidebar is open)
          //    Clicking the overlay closes the sidebar.
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(color: Colors.black38),
            ),

          // 3) Main content — AnimatedBuilder reads _sidebarController and translates + scales
          AnimatedBuilder(
            animation: _sidebarController,
            builder: (context, child) {
              // value 0.0 -> closed, 1.0 -> open
              final v = _sidebarController.value;
              // Translate main content to the right proportional to v
              final translateX = contentShift * v;
              // Slight scale down for a depth effect
              final scale = 1.0 - (0.06 * v);

              return Transform(
                transform: Matrix4.identity()
                  ..translate(translateX)
                  ..scale(scale, scale),
                alignment: Alignment.centerLeft,
                child: AbsorbPointer(
                  absorbing:
                      _isSidebarOpen, // prevent interactions when sidebar open
                  child: child,
                ),
              );
            },
            // child is the existing main content container you already had — preserved
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF42A5F5), Colors.white],
                  stops: [0.0, 0.4],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _cardAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome banner (already toggles the sidebar onTap)
                        _buildWelcomeBanner(),
                        const SizedBox(height: 20),
                        _buildSectionHeader("Quick Actions"),
                        _buildQuickActions(),
                        const SizedBox(height: 30),
                        // 🔹 New: Pro Bono Section
                        _buildSectionHeader("Pro Bono Opportunities"),
                        _buildProBonoSection(),
                        const SizedBox(height: 30),
                        _buildDocuments(),
                        _buildLegendCard(
                          title: "E-Court",
                          description:
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                          buttonText: "Enter a courtroom",
                          onTap: () => Navigator.pushNamed(context, '/eCourt'),
                        ),
                        _buildLegendCard(
                          title: "AI Doubt Forum",
                          description:
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                          buttonText: "Ask AI Agent",
                          onTap: () => Navigator.pushNamed(context, '/aiDoubt'),
                        ),
                        const SizedBox(height: 30),
                        _buildMyLearningSection(),
                        const SizedBox(height: 30),
                        _buildSectionHeader("Recent Activity"),
                        _buildRecentActivity(),
                        const SizedBox(height: 30),
                        _buildSectionHeader("What Clients Say"),
                        _buildTestimonials(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      /// 🔹 Emergency Help FAB (unchanged)
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFE53E3E),
          onPressed: _showEmergencyDialog,
          icon: const Icon(Icons.support_agent, color: Colors.white),
          label: const Text(
            'Emergency Help',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  /// 🔹 Widgets (original functions preserved) — no changes to these except that
  /// the sidebar toggle now uses _toggleSidebar() which drives the new animation.

  Widget _buildLegendCard({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return GestureDetector(
      onTap: () {
        // Toggle sidebar animation (uses the new _toggleSidebar)
        _toggleSidebar();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Colors.white],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Row(
          children: [
            // Rive animated profile icon (placeholder Rive file path)
            SizedBox(
              width: 60,
              height: 60,
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 32, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            // Text aligned horizontally with icon center
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Good ${_getGreeting()},",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "How can we help you today?",
                    style: TextStyle(fontSize: 14, color: Color(0xFF42A5F5)),
                  ),
                ],
              ),
            ),
            // Optional: small arrow to indicate clickable
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    // Each action has a title, optional image/icon, and a target page widget
    final actions = [
      {
        'title': 'Consult Lawyer',
        'page': ConsultLawyerPage(), // replace with your actual .dart page
      },
      {'title': 'Document Review', 'page': DocumentReviewPage()},
      {'title': 'Meeting Scheduled', 'page': MeetingScheduledPage()},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => a['page'] as Widget),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300], // placeholder for icon/image
                ),
                const SizedBox(height: 8),
                Text(
                  a['title'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProBonoSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('pro_bono_opportunities')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final proBonoList = snapshot.data!.docs;
        return Column(
          children: proBonoList.map((doc) {
            final data = doc.data();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'Pro Bono Opportunity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['description'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // optionally navigate to a details page using doc.id
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "View",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDocuments() {
    // Each doc has a title, local asset image, and target page
    final List<Map<String, dynamic>> docs = [
      {
        'title': 'Case files',
        'asset': 'assets/doc1.png',
        'page': CaseFilesPage(), // replace with your actual .dart page
      },
      {
        'title': 'Consultation Summaries',
        'asset': 'assets/doc2.png',
        'page': ConsultationSummariesPage(),
      },
      {
        'title': 'Court Orders',
        'asset': 'assets/doc3.png',
        'page': CourtOrdersPage(),
      },
      {
        'title': 'Legal Templates',
        'asset': 'assets/doc4.png',
        'page': LegalTemplatesPage(),
      },
      {
        'title': 'Supporting Documents',
        'asset': 'assets/doc5.png',
        'page': SupportingDocumentsPage(),
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: docs.map((doc) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => doc['page'] as Widget),
                    );
                  },
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(doc['asset']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  doc['title']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('activity')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final activities = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: activities.map((doc) {
                final a = doc.data();
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    child: const Icon(Icons.person, color: Colors.black87),
                  ),
                  title: Text(
                    a['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(a['subtitle'] ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/learning_placeholder.png',
                  ), // placeholder
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: implement emergency help flow
            },
            child: const Text(
              'Get Help Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      "Profile",
      "My Documents",
      "Call Logs",
      "Transactions",
      "My Cases",
      "Track Case",
      "Support",
      "Share",
      "Feedback",
    ];

    return Material(
      color: Colors.blue.shade700, // aesthetic gradient can be added here
      child: SafeArea(
        child: SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: AssetImage(
                    'assets/blank_profile.png',
                  ), // placeholder
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white54, thickness: 1),
              ...menuItems.map((item) {
                return ListTile(
                  title: Text(
                    item,
                    style: const TextStyle(color: Colors.white),
                  ),
                  leading: const Icon(Icons.chevron_right, color: Colors.white),
                  onTap: () {
                    // TODO: Add navigation for each menu item
                    // Example:
                    // if (item == 'Profile') Navigator.pushNamed(context, '/profile');
                    // Close sidebar after tapping:
                    setState(() {
                      _sidebarController.reverse();
                      _isSidebarOpen = false;
                    });
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
