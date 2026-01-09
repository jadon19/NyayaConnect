import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyaya_connect/main.dart' show RootPage;
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/testimonial_card.dart';
import 'features/notifications_screen_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_lawyer/consult_lawyer_page.dart';
import 'features/document_review.dart';
import '../calls/meeting_page.dart';
import '../documents/cases/case_files.dart';
import '../documents/consultation_summaries.dart';
import '../documents/court_orders.dart';
import '../documents/legal_templates.dart';
import '../sidebar_menu/call_logs.dart';
import '../sidebar_menu/transactions.dart';
import '../ai_doubt_forum.dart';
import 'profile.dart';
import '../sidebar_menu/feedback.dart';
import 'package:share_plus/share_plus.dart';
import '../community/community.dart';
import '../../services/language_manager.dart';
import 'package:nyaya_connect/l10n/app_localizations.dart';
import '../sidebar_menu/details.dart';
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

      // 🔥 Preserve onboarding status
      bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? false;

      await prefs.clear();

      // 🔥 Restore onboarding flag
      prefs.setBool('isFirstLaunch', isFirstLaunch);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RootPage()),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.welcome(widget.userName)),
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
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildMainContent(), // Home page stays same
              UserNotificationsScreen(), // Alerts page
              const CommunityScreen(), // Community
              const AIDoubtForumPage(), // Learn
            ],
          ),

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
      floatingActionButton: _currentIndex == 2
          ? null // Hide FAB on this tab
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFFE53E3E),
              onPressed: _showEmergencyDialog,
              icon: const Icon(Icons.support_agent, color: Colors.white),
              label: Text(AppLocalizations.of(context)!.emergencyHelp),
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
      {'icon': Icons.person, 'label': 'Profile', 'page': ProfileScreen()},

      {'icon': Icons.call, 'label': 'Call Logs', 'page': CallLogsScreen()},
      {
        'icon': Icons.payment,
        'label': 'Transactions',
        'page': TransactionsScreen(),
      },

      {
        'icon': Icons.share,
        'label': 'Share',
        'action': () async {
          // Example using share_plus package
          await Share.share(
            'Check out this amazing app: https://play.google.com/store/apps/details?id=com.example.app',
          );
        },
      },
      {'icon': Icons.feedback, 'label': 'Feedback', 'page': FeedbackScreen()},
      {
        'icon': Icons.language,
        'label': 'Language',
        'action': _showLanguageDialog,
      },
      {'icon': Icons.card_membership_outlined, 'label': 'Project Owners','page':ProjectInfoCard()},
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
                    leading: Icon(
                      menuItems[i]['icon'] as IconData,
                      color: Colors.blue.shade700,
                    ),
                    title: Text(
                      menuItems[i]['label'] as String,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    onTap: () {
                      _closeSidebar();
                      if (menuItems[i]['action'] != null) {
                        (menuItems[i]['action'] as Function?)?.call();
                      } else if (menuItems[i]['page'] != null) {
                        // close sidebar first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                menuItems[i]['page']
                                    as Widget, // navigate to page
                          ),
                        );
                      }
                    },
                  ),
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
      {
        'title': AppLocalizations.of(context)!.consultLawyer,
        'icon': Icons.gavel,
        'page': const ConsultLawyerPage(),
      },
      {
        'title': AppLocalizations.of(context)!.documentReview,
        'icon': Icons.description,
        'page': const DocumentReviewPage(),
      },
      {
        'title': AppLocalizations.of(context)!.meetingScheduled,
        'icon': Icons.calendar_today,
        'page': MeetingsScreen(),
      },
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
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    a['icon'] as IconData,
                    color: Colors.blue.shade700,
                    size: 30,
                  ),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onTap,
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
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
            child: Icon(Icons.person, color: Color(0xFF42A5F5), size: 28),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_getGreeting(context)},",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // Restored Documents horizontal list (Case files, Consultation Summaries, Court Orders, Legal Templates, Supporting Documents)
  Widget _buildDocuments() {
    final List<Map<String, dynamic>> docs = [
      {
        'title': AppLocalizations.of(context)!.caseFiles,
        'page': const CaseFilesPage(),
        'icon': Icons.folder_shared,
      },
      {
        'title': AppLocalizations.of(context)!.consultationSummaries,
        'page': const ConsultationSummariesPage(),
        'icon': Icons.article,
      },
      {
        'title': AppLocalizations.of(context)!.courtOrders,
        'page': const CourtOrdersPage(),
        'icon': Icons.gavel,
      },
      {
        'title': AppLocalizations.of(context)!.legalTemplates,
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

  // Restored My Learning section that links to Learning screen

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
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
                  _buildSectionHeader(AppLocalizations.of(context)!.quickActions),
                  _buildQuickActions(),
                  const SizedBox(height: 25),

                  // 🔹 Documents Section
                  _buildSectionHeader(AppLocalizations.of(context)!.documents),
                  const SizedBox(height: 8),
                  _buildDocuments(),
                  const SizedBox(height: 16),

                  // 🔹 E-Court
                  _buildLegendCard(
                    title: AppLocalizations.of(context)!.eCourt,
                    description:
                        AppLocalizations.of(context)!.eCourtDesc,
                    buttonText: AppLocalizations.of(context)!.enterCourtroom,
                    onTap: () => Navigator.pushNamed(context, '/eCourt'),
                    icon: Icons.account_balance_outlined,
                  ),

                  // 🔹 AI Doubt Forum
                  _buildLegendCard(
                    title: AppLocalizations.of(context)!.aiDoubtForum,
                    description:
                        AppLocalizations.of(context)!.aiDoubtForumDesc,
                    buttonText: AppLocalizations.of(context)!.askAiAgent,
                    onTap: () => Navigator.pushNamed(context, '/aiDoubt'),
                    icon: Icons.smart_toy_outlined,
                  ),

                  const SizedBox(height: 20),
                  _buildLegendCard(
                    title: AppLocalizations.of(context)!.contactNgo,
                    description:
                        AppLocalizations.of(context)!.contactNgoDesc,
                    buttonText: AppLocalizations.of(context)!.contactNow,
                    onTap: () => Navigator.pushNamed(context, '/contactNgo'),
                    icon: Icons.handshake_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildLegendCard(
                    title: AppLocalizations.of(context)!.findProbono,
                    description:
                        AppLocalizations.of(context)!.findProbonoDesc,
                    buttonText: AppLocalizations.of(context)!.contactNow,
                    onTap: () => Navigator.pushNamed(context, '/probono'),
                    icon: Icons.contact_page_outlined,
                  ),
                  const SizedBox(height: 25),
                  // 🔹 My Learning Section
                  _buildLegendCard(
                    title: AppLocalizations.of(context)!.myLearning,
                    description:
                        AppLocalizations.of(context)!.myLearningDesc,
                    buttonText: AppLocalizations.of(context)!.startLearning,
                    onTap: () => Navigator.pushNamed(context, '/mylearning'),
                    icon: Icons.lightbulb_outline,
                  ),

                  const SizedBox(height: 25),

                  // 🔹 Testimonials
                  _buildSectionHeader(AppLocalizations.of(context)!.whatClientsSay),
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
        title: Text(AppLocalizations.of(context)!.emergencyDialogTitle),
        content: Text(
          AppLocalizations.of(context)!.emergencyDialogContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.getHelpNow,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppLocalizations.of(context)!.goodMorning;
    if (hour < 17) return AppLocalizations.of(context)!.goodAfternoon;
    return AppLocalizations.of(context)!.goodEvening;
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  LanguageManager().changeLanguage(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('हिंदी (Hindi)'),
                onTap: () {
                  LanguageManager().changeLanguage(const Locale('hi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('ಕನ್ನಡ (Kannada)'),
                onTap: () {
                  LanguageManager().changeLanguage(const Locale('kn'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
