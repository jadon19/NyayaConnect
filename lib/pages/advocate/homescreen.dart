import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyaya_connect/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rive/rive.dart' as rive;
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/testimonial_card.dart';
import '../notification_screen.dart';
import 'verify_advocate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreenLawyer extends StatefulWidget {
  final String userName;

  const HomeScreenLawyer({super.key, required this.userName});

  @override
  State<HomeScreenLawyer> createState() => _HomeAdvocateScreenState();
}

class _HomeAdvocateScreenState extends State<HomeScreenLawyer>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late AnimationController _cardController;
  late Animation<double> _fabAnimation;
  late Animation<double> _cardAnimation;

  // Sidebar state + controller (controls both sidebar and content shift)
  bool _isSidebarOpen = false;
  late AnimationController _sidebarController;
  late Animation<Offset> _sidebarOffset;

  // Verification state
  String _verificationStatus = "not_submitted"; 
// can be "not_submitted", "pending", "approved"
 // This would come from backend/SharedPreferences

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();

    // Sidebar controller (drives both the sidebar slide and content transform)
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _sidebarOffset = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // off-screen left
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sidebarController, curve: Curves.easeInOut));

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

  // Check verification status from SharedPreferences
  Future<void> _checkVerificationStatus() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!doc.exists) return;

  final status = doc['verificationStatus'] ?? 'not_submitted';

  // Cache locally if needed
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('verification_status', status);

  setState(() {
    _verificationStatus = status;
  });
}


  // ✅ logout function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
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

  // Navigate to verification screen
  void _navigateToVerification() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const VerifyLawyerScreen()),
  ).then((value) {
    // Refresh verification status when returning from VerifyAdvocate
    _checkVerificationStatus();
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
          SlideTransition(
            position: _sidebarOffset,
            child: _buildSidebar(),
          ),

          // 2) Dim overlay (only visible when sidebar is open)
          //    Clicking the overlay closes the sidebar.
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(
                color: Colors.black38,
              ),
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
                  absorbing: _isSidebarOpen, // prevent interactions when sidebar open
                  child: child,
                ),
              );
            },
            // child is the existing main content container you already had — preserved
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
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
                        // Welcome banner with verification status
                        _buildWelcomeBanner(),
                        const SizedBox(height: 20),
                        _buildSectionHeader("Quick Actions"),
                        _buildQuickActions(),
                        const SizedBox(height: 30),
                        _buildLegendCard(
                          title: "E-Court",
                          description:
                              "Access virtual courtrooms and manage your cases digitally.",
                          buttonText: "Enter a courtroom",
                          onTap: () => Navigator.pushNamed(context, '/eCourt'),
                        ),
                        _buildLegendCard(
                          title: "AI Doubt Forum",
                          description:
                              "Get AI-powered assistance for legal queries and case research.",
                          buttonText: "Ask AI Agent",
                          onTap: () => Navigator.pushNamed(context, '/aiDoubt'),
                        ),
                        const SizedBox(height: 30),
                        _buildSectionHeader("Recent Activity"),
                        _buildRecentActivity(),
                        const SizedBox(height: 30),
                        _buildSectionHeader("My Reviews"),
                        _buildReviews(),
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
          gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: Colors.white70)),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(buttonText, style: const TextStyle(color: Colors.white)),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
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
              child: rive.RiveAnimation.asset(
                'assets/profile_icon.riv', // replace with your Rive file
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Text aligned horizontally with icon center
            Expanded(
              child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Row(
      children: [
        Text(
          "Good ${_getGreeting()}, ${widget.userName}",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        if (_verificationStatus == "approved") ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ],
    ),
    const SizedBox(height: 4),
    if (_verificationStatus == "not_submitted")
      GestureDetector(
        onTap: _navigateToVerification,
        child: const Text(
          "Get verified now",
          style: TextStyle(
            fontSize: 14, 
            color: Color(0xFF42A5F5),
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
    else if (_verificationStatus == "pending")
      const Text(
        "Verification Pending",
        style: TextStyle(fontSize: 14, color: Colors.orange),
      )
    else if (_verificationStatus == "approved")
      const Text(
        "You are verified ✓",
        style: TextStyle(fontSize: 14, color: Colors.green),
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
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Meetings', 'route': '/meetings', 'icon': Icons.calendar_today},
      {'title': 'My Cases', 'route': '/myCases', 'icon': Icons.folder_open},
      {'title': 'Clients', 'route': '/clients', 'icon': Icons.people},
      {'title': 'Earnings', 'route': '/earnings', 'icon': Icons.attach_money},
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
                    color: const Color(0xFF42A5F5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.3)),
                  ),
                  child: Icon(
                    a['icon'] as IconData,
                    color: const Color(0xFF42A5F5),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(a['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'icon': Icons.calendar_today, 'title': 'Meeting with Client - Rajesh', 'subtitle': 'Today at 2PM', 'color': Colors.blue},
      {'icon': Icons.gavel, 'title': 'Case hearing scheduled', 'subtitle': 'Tomorrow at 10AM', 'color': Colors.orange},
      {'icon': Icons.description, 'title': 'Document review completed', 'subtitle': '2 hours ago', 'color': Colors.green},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: activities.map((a) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: (a['color'] as Color).withOpacity(0.1),
                child: Icon(a['icon'] as IconData, color: a['color'] as Color),
              ),
              title: Text(a['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
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
          TestimonialCard(name: 'Rajesh Kumar', text: 'Excellent legal advice! Very professional.'),
          SizedBox(width: 16),
          TestimonialCard(name: 'Priya Sharma', text: 'Quick response and great courtroom presence.'),
          SizedBox(width: 16),
          TestimonialCard(name: 'Amit Singh', text: 'Helped me win my case. Highly recommended!'),
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
        content: const Text('Do you need immediate legal assistance? We can connect you with an emergency consultant right away.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // TODO: implement emergency help flow
            },
            child: const Text('Get Help Now', style: TextStyle(color: Colors.white)),
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
      "Feedback"
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
                  backgroundImage: AssetImage('assets/blank_profile.png'), // placeholder
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(widget.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white54, thickness: 1),
              ...menuItems.map((item) {
                return ListTile(
                  title: Text(item, style: const TextStyle(color: Colors.white)),
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
