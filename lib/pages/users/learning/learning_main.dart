import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'firebase_service.dart';
import 'case_data.dart';
import 'case_detail_page.dart';

class LearningMainPage extends StatefulWidget {
  const LearningMainPage({super.key});

  @override
  State<LearningMainPage> createState() => _LearningMainPageState();
}

class _LearningMainPageState extends State<LearningMainPage> {
  final FirebaseService firebaseService = FirebaseService();
  int userCoins = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final score = await firebaseService.getUserScore();
    if (mounted) {
      setState(() {
        userCoins = score;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Quest – Case Library'),
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        actions: [
          Chip(
            avatar: const Icon(Icons.stars, color: Colors.amber),
            label: Text(
              '$userCoins coins',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD0EFFF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadCoins,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.indigo.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Lottie.asset(
                    'assets/courtroom.json',
                    width: 60,
                    height: 60,
                    repeat: true,
                  ),
                  title: const Text(
                    'Pick a case, follow the story, ace the quiz!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Earn coins for each case you master. Unlock advanced content soon!',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...caseStudies.map(
                (caseStudy) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaseDetailPage(
                            caseStudy: caseStudy,
                            firebaseService: firebaseService,
                          ),
                        ),
                      );
                      _loadCoins();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.menu_book,
                                color: Color(0xFF42A5F5), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(caseStudy.subtitle,
                                    style:
                                        const TextStyle(color: Colors.black54)),
                                Text(
                                  caseStudy.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  caseStudy.overview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text('${caseStudy.coinReward} coins'),
                                      avatar: const Icon(Icons.stars,
                                          color: Colors.amber, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(caseStudy.complexity),
                                      avatar: const Icon(Icons.scale_outlined,
                                          size: 18),
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
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}