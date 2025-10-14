import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'learning/questions_model.dart';
import 'learning/questions.dart';
import 'learning/firebase_service.dart';

class MyLearningPage extends StatefulWidget {
  const MyLearningPage({super.key});

  @override
  State<MyLearningPage> createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _cardController;
  late AnimationController _pointsController;

  late Animation<double> _progressAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _pointsBounceAnimation;

  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _totalPoints = 0;
  int _correctAnswers = 0;
  bool _isAnswered = false;
  int? _selectedAnswer;
  bool _showResult = false;

  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pointsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));

    _pointsBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pointsController,
      curve: Curves.elasticOut,
    ));

    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    int score = await _firebaseService.getUserScore();
    _totalPoints = score;

    // Load questions and shuffle
    _questions = List.from(defaultQuestions)..shuffle();

    setState(() {
      _isLoading = false;
    });

    _cardController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) async {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answerIndex;
      _isAnswered = true;
    });

    HapticFeedback.lightImpact();

    bool isCorrect = answerIndex == _questions[_currentQuestionIndex].correctAnswer;

    if (isCorrect) {
      setState(() {
        _totalPoints += 10;
        _correctAnswers++;
      });

      // update Firebase score immediately
      await _firebaseService.updateUserScore(_totalPoints);

      _pointsController.forward().then((_) {
        _pointsController.reverse();
      });
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showResult = true;
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
        _showResult = false;
      });
      _cardController.reset();
      _cardController.forward();
    } else {
      _showQuizComplete();
    }
  }

  void _showQuizComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎉 Quiz Complete!", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You scored $_totalPoints points!", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text("Correct answers: $_correctAnswers/${_questions.length}", style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Text("Great job! Keep learning to improve your legal knowledge.", textAlign: TextAlign.center),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            child: const Text("Play Again"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _isAnswered = false;
      _selectedAnswer = null;
      _showResult = false;
    });

    _questions.shuffle();
    _cardController.reset();
    _cardController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Legal Quest"),
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                AnimatedBuilder(
                  animation: _pointsBounceAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pointsBounceAnimation.value,
                    child: Text("$_totalPoints", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF42A5F5), Color(0xFFE3F2FD)], stops: [0.0, 0.3]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Question ${_currentQuestionIndex + 1} of ${_questions.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        Text("$_correctAnswers correct", style: TextStyle(color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) => LinearProgressIndicator(
                        value: _progressAnimation.value * ((_currentQuestionIndex + 1) / _questions.length),
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // Quiz Card
              Expanded(
                child: SlideTransition(
                  position: _cardSlideAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFF42A5F5).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(_questions[_currentQuestionIndex].question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4)),
                            ),

                            const SizedBox(height: 24),

                            // Options
                            Expanded(
                              child: ListView.builder(
                                itemCount: _questions[_currentQuestionIndex].options.length,
                                itemBuilder: (context, index) => _buildOptionButton(index),
                              ),
                            ),

                            // Result Section
                            if (_showResult) ...[
                              const SizedBox(height: 16),
                              _buildResultSection(),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _nextQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF42A5F5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(_currentQuestionIndex < _questions.length - 1 ? "Next Question" : "Finish Quiz",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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

  Widget _buildOptionButton(int index) {
    bool isSelected = _selectedAnswer == index;
    bool isCorrect = index == _questions[_currentQuestionIndex].correctAnswer;
    bool showResult = _showResult;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[700]!;
        borderColor = Colors.red;
      } else {
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[600]!;
        borderColor = Colors.grey[300]!;
      }
    } else {
      backgroundColor = isSelected ? const Color(0xFF42A5F5).withOpacity(0.1) : Colors.grey.withOpacity(0.05);
      textColor = isSelected ? const Color(0xFF42A5F5) : Colors.black87;
      borderColor = isSelected ? const Color(0xFF42A5F5) : Colors.grey[300]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 2)),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: showResult && isCorrect
                        ? Colors.green
                        : showResult && isSelected && !isCorrect
                            ? Colors.red
                            : isSelected
                                ? const Color(0xFF42A5F5)
                                : Colors.grey[300],
                  ),
                  child: Center(
                    child: showResult && isCorrect
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : showResult && isSelected && !isCorrect
                            ? const Icon(Icons.close, color: Colors.white, size: 16)
                            : Text(String.fromCharCode(65 + index), // A,B,C,D
                                style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(_questions[_currentQuestionIndex].options[index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    bool isCorrect = _selectedAnswer == _questions[_currentQuestionIndex].correctAnswer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCorrect ? Colors.green : Colors.red, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(isCorrect ? "Correct!" : "Incorrect", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green[700] : Colors.red[700])),
              if (isCorrect) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                  child: const Text("+10 points", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(_questions[_currentQuestionIndex].explanation, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4)),
        ],
      ),
    );
  }
}
