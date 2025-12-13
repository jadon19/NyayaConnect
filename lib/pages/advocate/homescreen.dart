import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyaya_connect/pages/signup/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/testimonial_card.dart';
import 'features/notifications_screen_advocate.dart';
import 'verify_advocate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import '../sidebar_menu/track_case.dart';
import '../sidebar_menu/transactions.dart';
import '../sidebar_menu/call_logs.dart';
import '../sidebar_menu/feedback.dart';
import 'package:share_plus/share_plus.dart';
import '../documents/case_files.dart';
import '../documents/consultation_summaries.dart';
import '../documents/court_orders.dart';
import '../documents/legal_templates.dart';
import '../community/community.dart';
import '../ai_doubt_forum.dart';
import '../../services/user_manager.dart';
class HomeScreenLawyer extends StatefulWidget {
  final String userName;

  const HomeScreenLawyer({super.key, required this.userName});

  @override
  State<HomeScreenLawyer> createState() => _HomeAdvocateScreenState();
}

class _HomeAdvocateScreenState extends State<HomeScreenLawyer>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSidebarOpen = false;

  late AnimationController _sidebarController;
  late AnimationController _menuItemsController;
  late Animation<Offset> _sidebarOffset;

  late AnimationController _fabController;
  late AnimationController _cardController;
  late Animation<double> _fabAnimation;
  late Animation<double> _cardAnimation;

  String _verificationStatus = "not_submitted";
  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();

    _sidebarController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _sidebarOffset = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sidebarController, curve: Curves.easeInOut));

    _menuItemsController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _fabController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _cardController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fabAnimation = CurvedAnimation(parent: _fabController, curve: Curves.elasticOut);
    _cardAnimation = CurvedAnimation(parent: _cardController, curve: Curves.easeInOut);

    _fabController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _menuItemsController.dispose();
    _fabController.dispose();
    _cardController.dispose();
    super.dispose();
  }
Future<void> _checkVerificationStatus() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // STEP 1 — Read lawyerId (from UserManager or Firestore)
  String? lawyerId = UserManager().lawyerId;

  if (lawyerId == null || lawyerId.trim().isEmpty) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    lawyerId = userDoc.data()?['lawyerId'];
  }

  // No lawyerId: not submitted
  if (lawyerId == null || lawyerId.trim().isEmpty) {
    setState(() => _verificationStatus = "not_submitted");
    return;
  }

  // STEP 2 — Fetch correct lawyer document using lawyerId
  final lawyerDoc = await FirebaseFirestore.instance
      .collection('lawyers')
      .doc(lawyerId)
      .get();

  if (!lawyerDoc.exists) {
    setState(() => _verificationStatus = "not_submitted");
    return;
  }

  final status = lawyerDoc.data()?['verificationStatus'] ?? "not_submitted";

  // Save locally
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('verification_status', status);

  // Update UI
  setState(() => _verificationStatus = status);
}


  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  void _toggleSidebar() {
    setState(() {
      if (_isSidebarOpen) {
        _sidebarController.reverse();
        _menuItemsController.reverse();
      } else {
        _sidebarController.forward();
        _menuItemsController.forward();
      }
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _onNavBarTap(int index) {
  setState(() => _currentIndex = index);
}

  

  void _navigateToVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerifyLawyerScreen()),
    ).then((_) => _checkVerificationStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.userName}',style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF42A5F5),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),

      // ✅ FIXED STACK ORDER
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildMainContent(), // Home page stays same
              LawyerNotificationsScreen(), // Alerts page
              const CommunityScreen(), // Community
              const AIDoubtForumPage(), // Learn
            ],
          ),

          // Dim overlay
          if (_isSidebarOpen)
            AnimatedOpacity(
              opacity: _isSidebarOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _toggleSidebar,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black26),
              ),
            ),

          // Sidebar on top
          SlideTransition(
            position: _sidebarOffset,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildSidebar(),
            ),
          ),
        ],
      ),

      floatingActionButton:  _currentIndex == 2
    ? null
    :ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFE53E3E),
          icon: const Icon(Icons.support_agent, color: Colors.white),
          label: const Text("Emergency Help"),
          onPressed: _showEmergencyDialog,
        ),
      ),
      bottomNavigationBar:
      CustomBottomNavBar(currentIndex: _currentIndex, onTap: _onNavBarTap),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _cardAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeBanner(),
                const SizedBox(height: 20),
                _buildSectionHeader("Quick Actions"),
                _buildQuickActions(),
                const SizedBox(height: 25),
                _buildDocuments(),
                const SizedBox(height: 25),
                _buildSectionHeader("Services"),
                const SizedBox(height: 12),
                _buildServiceCard(
                  title: "E-Court",
                  subtitle:
                  "Access virtual courtrooms and manage your cases digitally.",
                  icon: Icons.account_balance_outlined,
                  primaryText: "Enter a courtroom",
                  onPrimary: () => Navigator.pushNamed(context, '/eCourt'),
                ),
                const SizedBox(height: 16),
                _buildServiceCard(
                  title: "AI Doubt Forum",
                  subtitle:
                  "Get AI-powered assistance for legal queries and case research.",
                  icon: Icons.smart_toy_outlined,
                  primaryText: "Ask AI Agent",
                  onPrimary: () => Navigator.pushNamed(context, '/aiDoubt'),
                ),
                const SizedBox(height: 16),
                  _buildServiceCard(
                    title: "Join NGO",
                    subtitle:
                        "Reach out to registered NGOs for Collaboration. Explore and get Hands-on-experience.",
                    primaryText: "Contact Now",
                    onPrimary: () => Navigator.pushNamed(context, '/contactNgo'),
                    icon: Icons.handshake_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    title: "Probono Opportunities",
                    subtitle:
                        "Use your legal expertise to uplift lives, empower communities, and deliver justice where it is needed most.",
                    primaryText: "Search Now",
                    onPrimary: () => Navigator.pushNamed(context, '/probono'),
                    icon: Icons.contact_page_outlined,
                  ),
                  const SizedBox(height: 16),
                  // 🔹 My Learning Section
                  _buildServiceCard(
                    title: "My learning",
                    subtitle:
                        "Your Path to Legal Knowledge Starts Here.Master Legal Basics, Anytime, Anywhere.",
                    primaryText: "Start Learning",
                    onPrimary: () => Navigator.pushNamed(context, '/mylearning'),
                    icon: Icons.lightbulb_outline,
                  ),
                const SizedBox(height: 20),
                _buildSectionHeader("Recent Activity"),
                _buildRecentActivity(),
                const SizedBox(height: 25),
                _buildSectionHeader("My Reviews"),
                _buildReviews(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5),  Color(0xFF90CAF9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleSidebar,
            child: const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF42A5F5), size: 28),
          ),
            
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Good ${_getGreeting()}, ${widget.userName}",
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                if (_verificationStatus == "not_submitted")
                  GestureDetector(
                    onTap: _navigateToVerification,
                    child: const Text(
                      "Get verified now!",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0D47A1),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                else if (_verificationStatus == "pending")
                  const Text("Verification Pending",
                      style: TextStyle(color: Colors.orange))
                else
                  const Text("You are verified ✓",
                      style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      {'icon': Icons.person, 'label': 'Profile', 'page': LawyerProfileScreen()},
      {'icon': Icons.call, 'label': 'Call Logs', 'page': CallLogsScreen()},
      {'icon': Icons.payment, 'label': 'Transactions', 'page': TransactionsScreen()},
      {'icon': Icons.location_on, 'label': 'Track Case', 'page': TrackCaseScreen()},
        {
        'icon': Icons.share,
        'label': 'Share',
        'action': () async {
          // Example using share_plus package
          await Share.share(
            'Check out this amazing app: https://play.google.com/store/apps/details?id=com.example.app',
          );
        },
      },{'icon': Icons.feedback, 'label': 'Feedback', 'page': FeedbackScreen()},
    ];

    return Container(
      width: 270,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // pure white top
            Color(0xFFE0F7FA), // very light cyan bottom
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFB3E5FC),
                  child: Icon(Icons.person, color: Colors.blueAccent, size: 30),
                ),
                SizedBox(width: 12),
                Text(
                  "Advocate Profile",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.black26),
          Expanded(
            child: AnimatedBuilder(
              animation: _menuItemsController,
              builder: (context, _) {
                return ListView.builder(
                  itemCount: menuItems.length,
                  padding: const EdgeInsets.only(top: 8),
                  itemBuilder: (context, index) {
                    final animValue =
                    (_menuItemsController.value - (index * 0.05)).clamp(0.0, 1.0);
                    final opacity = animValue;
                    final offsetX = -30 * (1 - animValue);

                    return Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(offsetX, 0),
                        child: ListTile(
                          leading: Icon(menuItems[index]['icon'] as IconData,
                              color: Colors.blue.shade700),
                          title: Text(menuItems[index]['label'] as String,
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 15)),
                          onTap: () {
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                menuItems[index]['page']
                                    as Widget, // navigate to page
                          ),
                        );
                            _toggleSidebar();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  // Other builder helpers (unchanged)
  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
  );

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Meetings', 'route': '/meetings', 'icon': Icons.calendar_today},
      {'title': 'Clients', 'route': '/clients', 'icon': Icons.people},
      {'title': 'Earnings', 'route': '/manager', 'icon': Icons.manage_accounts_sharp},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, a['route'] as String),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 8)
                    ],
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: Colors.blue.shade800, size: 30),
                ),
                const SizedBox(height: 8),
                Text(a['title'] as String,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  Widget _buildDocuments() {
    final List<Map<String, dynamic>> docs = [
      {
        'title': 'Case files',
        'page': const CaseFilesPage(),
        'icon': Icons.folder_shared,
      },
      {
        'title': 'Consultation Summaries',
        'page': const ConsultationSummariesPage(),
        'icon': Icons.article,
      },
      {
        'title': 'Court Orders',
        'page': const CourtOrdersPage(),
        'icon': Icons.gavel,
      },
      {
        'title': 'Legal Templates',
        'page': const LegalTemplatesPage(),
        'icon': Icons.description,
      },
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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    d['icon'] as IconData,
                    color: Colors.blue.shade700,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d['title']?.toString() ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String primaryText,
    required VoidCallback onPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue.shade800, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                      const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onPrimary,
                    child: Text(primaryText,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'icon': Icons.calendar_today,
        'title': 'Meeting with Client - Rajesh',
        'subtitle': 'Today at 2PM',
        'color': Colors.blue
      },
      {
        'icon': Icons.gavel,
        'title': 'Case hearing scheduled',
        'subtitle': 'Tomorrow at 10AM',
        'color': Colors.orange
      },
      {
        'icon': Icons.description,
        'title': 'Document review completed',
        'subtitle': '2 hours ago',
        'color': Colors.green
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: Column(
          children: activities.map((a) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: (a['color'] as Color).withOpacity(0.1),
                child: Icon(a['icon'] as IconData, color: a['color'] as Color),
              ),
              title: Text(a['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(a['subtitle'] as String),
              trailing: const Icon(Icons.chevron_right),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: const [
          TestimonialCard(
              name: 'Rajesh Kumar',
              text: 'Excellent legal advice! Very professional.'),
          SizedBox(width: 16),
          TestimonialCard(
              name: 'Priya Sharma',
              text: 'Quick response and great courtroom presence.'),
          SizedBox(width: 16),
          TestimonialCard(
              name: 'Amit Singh', text: 'Helped me win my case. Highly recommended!'),
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
            'Do you need immediate legal assistance? We can connect you with an emergency consultant right away.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text('Get Help Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
