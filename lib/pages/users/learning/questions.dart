import 'questions_model.dart';


final List<QuizQuestion> defaultQuestions = [
  QuizQuestion(
    question: "Which article of the Indian Constitution deals with the Right to Equality?",
    options: ["Article 14", "Article 19", "Article 21", "Article 32"],
    correctAnswer: 0,
    explanation:
        "Article 14 guarantees equality before law and equal protection of laws to all persons within the territory of India.",
  ),
  QuizQuestion(
    question: "What is the maximum punishment for contempt of court in India?",
    options: ["6 months imprisonment", "1 year imprisonment", "2 years imprisonment", "3 years imprisonment"],
    correctAnswer: 0,
    explanation: "The Contempt of Courts Act, 1971 provides for a maximum punishment of 6 months imprisonment or fine up to ₹2000.",
  ),
  QuizQuestion(
    question: "Which amendment introduced the Right to Education as a fundamental right?",
    options: ["86th Amendment", "87th Amendment", "88th Amendment", "89th Amendment"],
    correctAnswer: 0,
    explanation: "The 86th Constitutional Amendment Act, 2002 made the Right to Education a fundamental right under Article 21A.",
  ),
  // add more questions here as needed
];
