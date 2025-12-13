import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaseQuiz extends StatefulWidget {
  final int caseNumber;

  const CaseQuiz({super.key, required this.caseNumber});

  @override
  State<CaseQuiz> createState() => _CaseQuizState();
}

class _CaseQuizState extends State<CaseQuiz> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _totalPoints = 0;
  String? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;

  List<Map<String, dynamic>> get _questions {
    switch (widget.caseNumber) {
      case 1:
        return [
          {
            'question': 'What was the original dispute in Kesavananda Bharati case?',
            'options': ['Right to property under Land Reforms Act', 'Freedom of speech violation', 'Right to education', 'Right to privacy'],
            'correct': 0,
            'explanation': 'The case began when Kesavananda Bharati challenged the government\'s attempts to acquire monastery property under the Land Reforms Act.',
            'points': 10,
          },
          {
            'question': 'How many judges heard the Kesavananda Bharati case?',
            'options': ['9 judges', '11 judges', '13 judges', '15 judges'],
            'correct': 2,
            'explanation': 'The case was heard by a historic 13-judge bench — the largest in Supreme Court history.',
            'points': 10,
          },
          {
            'question': 'What was the verdict ratio in Kesavananda Bharati case?',
            'options': ['6-7', '7-6', '8-5', '9-4'],
            'correct': 1,
            'explanation': 'The Supreme Court delivered a deeply divided 7–6 verdict.',
            'points': 10,
          },
          {
            'question': 'Which article was primarily under scrutiny in Kesavananda Bharati case?',
            'options': ['Article 14', 'Article 19', 'Article 21', 'Article 368'],
            'correct': 3,
            'explanation': 'Article 368 outlines the procedure and power of Parliament to amend the Constitution.',
            'points': 10,
          },
          {
            'question': 'What doctrine was established in Kesavananda Bharati case?',
            'options': ['Golden Triangle Doctrine', 'Basic Structure Doctrine', 'Due Process Doctrine', 'Strict Scrutiny Doctrine'],
            'correct': 1,
            'explanation': 'The Basic Structure Doctrine was established, holding that Parliament cannot alter or destroy the Basic Structure of the Constitution.',
            'points': 10,
          },
          {
            'question': 'Which earlier case had said Parliament could not amend Fundamental Rights?',
            'options': ['Shankari Prasad', 'Sajjan Singh', 'Golak Nath', 'Minerva Mills'],
            'correct': 2,
            'explanation': 'Golak Nath case had held that Parliament could not amend Fundamental Rights at all.',
            'points': 10,
          },
          {
            'question': 'Which Fundamental Rights were threatened by the amendments in Kesavananda case?',
            'options': ['Article 14, 19, and 21', 'Article 15, 16, and 17', 'Article 25, 26, and 27', 'Article 29, 30, and 31'],
            'correct': 0,
            'explanation': 'The Court was dealing with Fundamental Rights such as Article 14 (Equality), Article 19 (Freedom), and Article 21 (Right to Life).',
            'points': 10,
          },
          {
            'question': 'Which case later invoked the Basic Structure Doctrine?',
            'options': ['Maneka Gandhi', 'Vishaka', 'Minerva Mills', 'Kesavananda Bharati'],
            'correct': 2,
            'explanation': 'The Basic Structure Doctrine has been invoked in landmark judgments like Minerva Mills, S.R. Bommai, and the NJAC case.',
            'points': 10,
          },
          {
            'question': 'What does the Basic Structure Doctrine protect?',
            'options': ['All constitutional provisions', 'Core principles like democracy and secularism', 'Only Fundamental Rights', 'Only Directive Principles'],
            'correct': 1,
            'explanation': 'The Basic Structure Doctrine protects core principles like democracy, secularism, judicial independence, and rule of law.',
            'points': 10,
          },
          {
            'question': 'Can Parliament amend Fundamental Rights according to Kesavananda Bharati judgment?',
            'options': ['No, never', 'Yes, but only with 2/3 majority', 'Yes, but cannot alter Basic Structure', 'Yes, without any restrictions'],
            'correct': 2,
            'explanation': 'Parliament can amend any part of the Constitution, including Fundamental Rights, as long as it does not alter or destroy the Basic Structure.',
            'points': 10,
          },
        ];
      case 2:
        return [
          {
            'question': 'What was impounded in the Maneka Gandhi case?',
            'options': ['Her property', 'Her passport', 'Her bank account', 'Her vehicle'],
            'correct': 1,
            'explanation': 'In 1977, the Indian government abruptly impounded the passport of journalist Maneka Gandhi without offering any reasons.',
            'points': 10,
          },
          {
            'question': 'Which article was primarily interpreted in Maneka Gandhi case?',
            'options': ['Article 14', 'Article 19', 'Article 21', 'Article 32'],
            'correct': 2,
            'explanation': 'The main issue was the interpretation of Article 21, which deals with life and personal liberty.',
            'points': 10,
          },
          {
            'question': 'What doctrine was established linking Articles 14, 19, and 21?',
            'options': ['Basic Structure Doctrine', 'Golden Triangle Doctrine', 'Due Process Doctrine', 'Strict Scrutiny Doctrine'],
            'correct': 1,
            'explanation': 'The judgment linked Article 14, 19, and 21, forming the powerful doctrine of the "Golden Triangle."',
            'points': 10,
          },
          {
            'question': 'What standard did Maneka Gandhi case establish for procedures?',
            'options': ['Any procedure is valid', 'Procedure must be fair, just, and reasonable', 'Procedure must be written', 'Procedure must be approved by Parliament'],
            'correct': 1,
            'explanation': 'The Court held that any procedure restricting personal liberty must be fair, just, and reasonable, not arbitrary or oppressive.',
            'points': 10,
          },
          {
            'question': 'Which right was NOT derived from Article 21 after Maneka Gandhi?',
            'options': ['Right to Privacy', 'Right to Dignity', 'Right to Clean Environment', 'Right to Property'],
            'correct': 3,
            'explanation': 'The Maneka Gandhi ruling led to rights like Right to Privacy, Right to Dignity, Right to Clean Environment, but not Right to Property (which was removed as a fundamental right).',
            'points': 10,
          },
          {
            'question': 'What was the government\'s reason for impounding Maneka Gandhi\'s passport?',
            'options': ['National security', 'Public interest', 'Criminal investigation', 'No reason given'],
            'correct': 1,
            'explanation': 'When she requested an explanation, the government refused, citing "public interest."',
            'points': 10,
          },
          {
            'question': 'Which article guarantees freedom of movement?',
            'options': ['Article 19(1)(a)', 'Article 19(1)(b)', 'Article 19(1)(d)', 'Article 19(1)(g)'],
            'correct': 2,
            'explanation': 'Article 19(1)(d) guarantees freedom of movement throughout the territory of India.',
            'points': 10,
          },
          {
            'question': 'What did Maneka Gandhi case transform Article 21 into?',
            'options': ['A narrow procedural right', 'A broad fountain of human rights', 'A property right', 'A political right'],
            'correct': 1,
            'explanation': 'This transformed Article 21 from a narrow procedural right into a broad fountain of human rights.',
            'points': 10,
          },
          {
            'question': 'When was the Maneka Gandhi case decided?',
            'options': ['1975', '1976', '1977', '1978'],
            'correct': 3,
            'explanation': 'The Maneka Gandhi v. Union of India case was decided in 1978.',
            'points': 10,
          },
          {
            'question': 'What did the Maneka Gandhi case establish about Fundamental Rights?',
            'options': ['They are isolated silos', 'They are interconnected', 'They can be suspended easily', 'They only apply to citizens'],
            'correct': 1,
            'explanation': 'The Court made it clear that no Fundamental Right exists in isolation, establishing their interconnected nature.',
            'points': 10,
          },
        ];
      case 3:
        return [
          {
            'question': 'What triggered the Vishaka case?',
            'options': ['A property dispute', 'The gang-rape of Bhanwari Devi', 'A contract violation', 'A tax issue'],
            'correct': 1,
            'explanation': 'The Vishaka case was triggered by the brutal gang-rape of Bhanwari Devi, a social worker who attempted to stop a child marriage in Rajasthan.',
            'points': 10,
          },
          {
            'question': 'What was the main issue in Vishaka case?',
            'options': ['Property rights', 'Whether sexual harassment violates Fundamental Rights', 'Taxation', 'Contract law'],
            'correct': 1,
            'explanation': 'The core question was whether sexual harassment at workplace constitutes a violation of women\'s Fundamental Rights.',
            'points': 10,
          },
          {
            'question': 'What did the Supreme Court create in Vishaka case?',
            'options': ['A new law', 'Vishaka Guidelines', 'A commission', 'A committee'],
            'correct': 1,
            'explanation': 'The Supreme Court laid down the Vishaka Guidelines, making them binding law until Parliament enacted proper legislation.',
            'points': 10,
          },
          {
            'question': 'Which international convention was referenced in Vishaka case?',
            'options': ['UN Charter', 'CEDAW Convention', 'Geneva Convention', 'Vienna Convention'],
            'correct': 1,
            'explanation': 'The Court referenced the CEDAW Convention, an international treaty on eliminating discrimination against women.',
            'points': 10,
          },
          {
            'question': 'What did Vishaka Guidelines mandate?',
            'options': ['Internal Complaints Committees (ICC)', 'External committees only', 'No reporting mechanism', 'Only for government offices'],
            'correct': 0,
            'explanation': 'These guidelines mandated Internal Complaints Committees (ICC), employer responsibility, confidentiality, support for victims, and zero tolerance for harassment.',
            'points': 10,
          },
          {
            'question': 'When was the POSH Act passed?',
            'options': ['2010', '2011', '2012', '2013'],
            'correct': 3,
            'explanation': 'The Vishaka Guidelines functioned as law for nearly 16 years until the POSH Act was passed in 2013.',
            'points': 10,
          },
          {
            'question': 'Which article guarantees the right to practice any profession?',
            'options': ['Article 19(1)(a)', 'Article 19(1)(c)', 'Article 19(1)(g)', 'Article 19(1)(f)'],
            'correct': 2,
            'explanation': 'Article 19(1)(g) guarantees the right to practice any profession, trade, or business.',
            'points': 10,
          },
          {
            'question': 'What is the minimum number of employees required for an Internal Committee under POSH Act?',
            'options': ['5 employees', '10 employees', '15 employees', '20 employees'],
            'correct': 1,
            'explanation': 'Today, every company, school, NGO, or institution employing more than 10 people must have an Internal Committee under the POSH Act, 2013.',
            'points': 10,
          },
          {
            'question': 'Which article prohibits discrimination?',
            'options': ['Article 14', 'Article 15', 'Article 16', 'Article 17'],
            'correct': 1,
            'explanation': 'Article 15 prohibits discrimination on grounds of religion, race, caste, sex, or place of birth.',
            'points': 10,
          },
          {
            'question': 'What did Vishaka case establish about workplace safety?',
            'options': ['Only physical safety matters', 'Sexual harassment violates Fundamental Rights', 'No legal protection needed', 'Only for government employees'],
            'correct': 1,
            'explanation': 'The case established that sexual harassment at workplace constitutes a violation of women\'s Fundamental Rights, particularly Articles 14, 15, 19(1)(g), and 21.',
            'points': 10,
          },
        ];
      default:
        return [];
    }
  }

  Future<void> _updateUserPoints(int points) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'points': FieldValue.increment(points),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating points: $e');
    }
  }

  void _selectAnswer(int index) {
    if (_showFeedback) return;

    setState(() {
      _selectedAnswer = _questions[_currentQuestionIndex]['options'][index];
      _isCorrect = index == _questions[_currentQuestionIndex]['correct'];
      _showFeedback = true;

      if (_isCorrect) {
        _correctAnswers++;
        final points = _questions[_currentQuestionIndex]['points'] as int;
        _totalPoints += points;
        _updateUserPoints(points);
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showFeedback = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Text('🎉'),
            const SizedBox(width: 8),
            const Text(
              'Quiz Complete!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You scored $_totalPoints points!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Correct answers: $_correctAnswers/${_questions.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7785A0),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Great job! Keep learning to improve your legal knowledge.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Play Again',
              style: TextStyle(
                color: Color(0xFF9C27B0),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3CA2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF8BD3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BD3FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Legal Quest',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  '$_totalPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8BD3FF),
              Color(0xFF6BB5E8),
              Colors.white,
            ],
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_correctAnswers correct',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 30),
              // Question card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question block
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            question['question'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Answer options
                        Expanded(
                          child: ListView.builder(
                            itemCount: (question['options'] as List).length,
                            itemBuilder: (context, index) {
                              final option = question['options'][index] as String;
                              final isSelected = _selectedAnswer == option;
                              final isCorrectOption = index == question['correct'];
                              Color? optionColor;
                              Color? textColor = Colors.black87;

                              if (_showFeedback) {
                                if (isSelected) {
                                  optionColor = _isCorrect
                                      ? Colors.green.shade100
                                      : Colors.red.shade100;
                                  textColor = _isCorrect ? Colors.green : Colors.red;
                                } else if (isCorrectOption) {
                                  optionColor = Colors.green.shade50;
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _selectAnswer(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: optionColor ?? Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? (_isCorrect
                                                ? Colors.green
                                                : Colors.red)
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (_isCorrect
                                                    ? Colors.green
                                                    : Colors.red)
                                                : Colors.grey.shade300,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              String.fromCharCode(65 + index),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textColor,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Feedback section
                        if (_showFeedback) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _isCorrect
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCorrect ? Colors.green : Colors.red,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: _isCorrect ? Colors.green : Colors.red,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _isCorrect ? 'Correct!' : 'Incorrect',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isCorrect ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              question['explanation'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Next/Finish button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _showFeedback ? _nextQuestion : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3CA2FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isLastQuestion ? 'Finish Quiz' : 'Next Question',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

