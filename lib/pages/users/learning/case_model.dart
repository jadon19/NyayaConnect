class CaseParty {
  final String name;
  final String role;
  final String description;

  CaseParty({
    required this.name,
    required this.role,
    required this.description,
  });
}

class CaseStep {
  final String title;
  final String detail;
  final String date;

  CaseStep({
    required this.title,
    required this.detail,
    required this.date,
  });
}

class CaseQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  CaseQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class CaseStudy {
  final String id;
  final String title;
  final String subtitle;
  final String overview;
  final String legalIssue;
  final List<CaseParty> parties;
  final List<String> storyHighlights;
  final List<CaseStep> timeline;
  final String verdict;
  final List<String> takeaways;
  final List<CaseQuizQuestion> quiz;
  final int coinReward;
  final String complexity;

  CaseStudy({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.overview,
    required this.legalIssue,
    required this.parties,
    required this.storyHighlights,
    required this.timeline,
    required this.verdict,
    required this.takeaways,
    required this.quiz,
    required this.coinReward,
    required this.complexity,
  });
}