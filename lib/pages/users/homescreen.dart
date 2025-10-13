import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyaya_connect/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ added


import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/category_card.dart';
import '../../widgets/testimonial_card.dart';
import '../notification_screen.dart';

class HomeScreenUser extends StatefulWidget {
  final String userName;

  const HomeScreenUser({super.key, required this.userName});

  @override
  State<HomeScreenUser> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeScreenUser>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late AnimationController _cardController;
  late Animation<double> _fabAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Added AppBar with Logout
      appBar: AppBar(
        title: Text('Welcome, ${widget.userName}'),
        backgroundColor: const Color(0xFF004AAD),
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
                  _buildWelcomeBanner(),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Quick Actions"),
                  _buildQuickActions(),
                  const SizedBox(height: 30),
                  _buildServices(),
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

      /// 🔹 Emergency Help FAB
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

  /// 🔹 Widgets

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
            child: Text(
              widget.userName.isNotEmpty
                  ? widget.userName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E88E5),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Good ${_getGreeting()}, ${widget.userName}!\nHow can we assist you today?',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.search, 'label': 'Find Lawyer', 'route': '/lawyers'},
      {'icon': Icons.chat, 'label': 'Quick Chat', 'route': '/chat'},
      {'icon': Icons.schedule, 'label': 'Book Meeting', 'route': '/meeting'},
      {'icon': Icons.article, 'label': 'Legal Docs', 'route': '/documents'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, a['route'] as String),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(a['label'] as String,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServices() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          CategoryCard(icon: Icons.business, label: 'Corporate', onTap: () {}),
          CategoryCard(icon: Icons.family_restroom, label: 'Family', onTap: () {}),
          CategoryCard(icon: Icons.gavel, label: 'Criminal', onTap: () {}),
          CategoryCard(icon: Icons.home, label: 'Property', onTap: () {}),
          CategoryCard(icon: Icons.work, label: 'Employment', onTap: () {}),
          CategoryCard(icon: Icons.more_horiz, label: 'More', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'icon': Icons.person, 'title': 'Consultation with Adv. Sharma', 'subtitle': 'Completed • 2h ago', 'color': Colors.green},
      {'icon': Icons.schedule, 'title': 'Meeting scheduled', 'subtitle': 'Tomorrow at 3PM', 'color': Colors.orange},
      {'icon': Icons.description, 'title': 'Document review pending', 'subtitle': 'Awaiting response', 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
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

  Widget _buildTestimonials() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: const [
          TestimonialCard(
              name: 'Rajesh Kumar',
              text: 'Excellent service! Found the perfect lawyer.'),
          SizedBox(width: 16),
          TestimonialCard(
              name: 'Priya Sharma',
              text: 'Quick response and professional guidance.'),
          SizedBox(width: 16),
          TestimonialCard(
              name: 'Amit Singh',
              text: 'The consultation was very helpful and affordable.'),
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
              onPressed: () {
                Navigator.pop(context);
                // TODO: implement emergency help flow
              },
              child: const Text('Get Help Now', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}