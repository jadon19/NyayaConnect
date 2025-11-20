import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'case_model.dart';
import 'firebase_service.dart';

class CaseDetailPage extends StatefulWidget {
  final CaseStudy caseStudy;
  final FirebaseService firebaseService;

  const CaseDetailPage({
    super.key,
    required this.caseStudy,
    required this.firebaseService,
  });

  @override
  State<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends State<CaseDetailPage> {
  int answeredQuestions = 0;
  int correctAnswers = 0;
  bool rewardClaimed = false;
  final Map<int, int> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    final caseStudy = widget.caseStudy;

    return Scaffold(
      appBar: AppBar(
        title: Text(caseStudy.title),
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(caseStudy),
          const SizedBox(height: 20),
          _buildParties(caseStudy.parties),
          const SizedBox(height: 16),
          _buildStoryHighlights(caseStudy.storyHighlights),
          const SizedBox(height: 16),
          _buildLegalIssue(caseStudy.legalIssue),
          const SizedBox(height: 16),
          _buildTimeline(caseStudy.timeline),
          const SizedBox(height: 16),
          _buildVerdict(caseStudy.verdict, caseStudy.takeaways),
          const SizedBox(height: 16),
          _buildQuizSection(caseStudy.quiz),
          const SizedBox(height: 24),
          _buildRewardButton(caseStudy.coinReward),
        ],
      ),
    );
  }

  Widget _buildHeader(CaseStudy caseStudy) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF90CAF9)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Lottie.asset(
            'assets/scales.json',
            width: 90,
            height: 90,
            repeat: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caseStudy.subtitle,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  caseStudy.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        '${caseStudy.coinReward} coins',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.orange.shade400,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        caseStudy.complexity,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.white24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParties(List<CaseParty> parties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parties Involved',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...parties.map(
          (party) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Text(party.role[0]),
              ),
              title: Text(party.name),
              subtitle: Text('${party.role} • ${party.description}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryHighlights(List<String> highlights) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Case Highlights',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...highlights.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(point)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalIssue(String issue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.balance, color: Colors.deepPurple.shade400),
            const SizedBox(width: 12),
          Expanded(
            child: Text(
              issue,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<CaseStep> timeline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Legal Journey',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...timeline.map(
          (step) => ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  step.date.split(' ')[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(step.date.split(' ')[1]),
              ],
            ),
            title: Text(step.title),
            subtitle: Text(step.detail),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }

  Widget _buildVerdict(String verdict, List<String> takeaways) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verdict & Action',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            Text(verdict),
            const SizedBox(height: 12),
            const Text('Key Takeaways',
                style: TextStyle(fontWeight: FontWeight.w600)),
            ...takeaways.map(
              (tip) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                title: Text(tip),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection(List<CaseQuizQuestion> quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Case Quiz',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...quiz.asMap().entries.map(
          (entry) {
            final idx = entry.key;
            final question = entry.value;
            final selected = selectedAnswers[idx];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${idx + 1}. ${question.question}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...question.options.asMap().entries.map((opt) {
                      final optIndex = opt.key;
                      final optText = opt.value;
                      final isSelected = selected == optIndex;
                      final isCorrect = question.correctIndex == optIndex;

                      Color borderColor = Colors.grey.shade300;
                      Color fillColor = Colors.white;
                      IconData? icon;

                      if (selected != null) {
                        if (isCorrect) {
                          borderColor = Colors.green;
                          fillColor = Colors.green.shade50;
                          icon = Icons.check_circle;
                        } else if (isSelected && !isCorrect) {
                          borderColor = Colors.red;
                          fillColor = Colors.red.shade50;
                          icon = Icons.cancel;
                        }
                      } else if (isSelected) {
                        borderColor = Colors.blue;
                        fillColor = Colors.blue.shade50;
                      }

                      return InkWell(
                        onTap: selected == null
                            ? () => _onAnswerSelected(idx, optIndex, isCorrect)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 14),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 1.3),
                            color: fillColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(optText)),
                              if (icon != null)
                                Icon(icon, color: borderColor),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (selected != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          question.explanation,
                          style: TextStyle(
                              color: selected == question.correctIndex
                                  ? Colors.green.shade700
                                  : Colors.red.shade700),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRewardButton(int coins) {
    final quizCount = widget.caseStudy.quiz.length;

    final allAnswered = answeredQuestions == quizCount;
    final allCorrect = correctAnswers == quizCount;

    String buttonText;
    Color buttonColor;

    if (!allAnswered) {
      buttonText = 'Answer all questions to earn $coins coins';
      buttonColor = Colors.grey;
    } else if (rewardClaimed) {
      buttonText = 'Reward claimed!';
      buttonColor = Colors.green.shade400;
    } else if (allCorrect) {
      buttonText = 'Claim $coins coins';
      buttonColor = Colors.orange;
    } else {
      buttonText = 'Score full marks to claim coins';
      buttonColor = Colors.grey;
    }

    return ElevatedButton(
      onPressed: allCorrect && !rewardClaimed ? _claimReward : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _onAnswerSelected(int questionIndex, int selectedIndex, bool isCorrect) {
    setState(() {
      selectedAnswers[questionIndex] = selectedIndex;
      answeredQuestions += 1;
      if (isCorrect) correctAnswers += 1;
    });
  }

  Future<void> _claimReward() async {
    await widget.firebaseService.updateUserScore(
      widget.caseStudy.coinReward,
    );
    setState(() => rewardClaimed = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('You earned ${widget.caseStudy.coinReward} coins! Great job!'),
        ),
      );
    }
  }
}