import 'package:flutter/material.dart';
import 'case_quiz.dart';

class FlashcardViewer extends StatefulWidget {
  final int caseNumber;

  const FlashcardViewer({super.key, required this.caseNumber});

  @override
  State<FlashcardViewer> createState() => _FlashcardViewerState();
}

class _FlashcardViewerState extends State<FlashcardViewer> {
  int _currentIndex = 0;

  List<Map<String, String>> get _flashcards {
    switch (widget.caseNumber) {
      case 1:
        return [
          {
            'title': 'Case Background',
            'content':
                'This case began when Kesavananda Bharati, the head of a Hindu mutt in Kerala, challenged the government\'s attempts to acquire monastery property under the Land Reforms Act. While the original dispute was about land rights, it quickly transformed into a larger constitutional battle involving the limits of parliamentary power. The case attracted national attention due to rising concerns about government overreach during that era.\n\nOver time, the focus shifted from property rights to the broader question of whether Parliament had unlimited power to amend the Constitution. The case was heard by a historic 13-judge bench — the largest in Supreme Court history — showing the gravity of the issue. It marked a turning point in India\'s constitutional philosophy.',
          },
          {
            'title': 'Core Issue',
            'content':
                'The central issue was whether Parliament could amend any part of the Constitution, including Fundamental Rights, under Article 368. This question arose because earlier cases like Shankari Prasad and Sajjan Singh had upheld broad amendment powers, while Golak Nath had said Parliament could not amend Fundamental Rights at all.\n\nThis conflict created confusion about the true scope of Article 368. The Kesavananda case sought to resolve this once and for all, leading to a constitutional confrontation between Parliament\'s power and the Supreme Court\'s role in protecting rights.',
          },
          {
            'title': 'Articles Involved',
            'content':
                'The major provision under scrutiny was Article 368, which outlines the procedure and power of Parliament to amend the Constitution. The Court was also indirectly dealing with Fundamental Rights such as Article 14 (Equality), Article 19 (Freedom of Speech and Movement), and Article 21 (Right to Life and Liberty), which were threatened by the amendments being challenged.\n\nAdditionally, the dispute involved the then-existing Article 31, which governed the right to property, making it relevant to the petitioner\'s original concern. Together, these articles created a complex legal framework balancing state power, individual rights, and constitutional stability.',
          },
          {
            'title': 'Judgement',
            'content':
                'The Supreme Court delivered a deeply divided 7–6 verdict. It held that Parliament could amend any part of the Constitution, including Fundamental Rights, as long as it did not alter or destroy the Basic Structure. This was the first time the term "Basic Structure" formally appeared in Indian constitutional law.\n\nThis ruling preserved democratic values by limiting Parliament\'s authority while still allowing necessary constitutional evolution. It became one of the most influential judgments in the world on constitutional supremacy and judicial review.',
          },
          {
            'title': 'Why It Still Matters',
            'content':
                'The Basic Structure Doctrine acts as a safeguard against authoritarianism. It ensures that no ruling party, no matter how powerful, can tamper with core principles like democracy, secularism, judicial independence, or rule of law. Even if Parliament has a majority, it cannot rewrite the Constitution\'s soul.\n\nThe doctrine continues to protect India\'s democracy today. It has been invoked in landmark judgments like Minerva Mills, S.R. Bommai, and the NJAC case, proving its long-term relevance in keeping constitutional power balanced.',
          },
        ];
      case 2:
        return [
          {
            'title': 'Case Background',
            'content':
                'In 1977, the Indian government abruptly impounded the passport of journalist Maneka Gandhi without offering any reasons. When she requested an explanation, the government refused, citing "public interest." This arbitrary action triggered national debate about the abuse of state power during the post-Emergency era.\n\nFeeling her rights were violated, Maneka Gandhi approached the Supreme Court. This case quickly grew beyond her personal issue and evolved into a historic challenge to the meaning of personal liberty in India.',
          },
          {
            'title': 'Core Issue',
            'content':
                'The main issue was the interpretation of Article 21, which states that no person shall be deprived of life or personal liberty except according to "procedure established by law." The question was: Can the government impose any procedure, even if it is unfair and unreasonable, or must the procedure meet certain standards?\n\nThe case also raised questions about whether Fundamental Rights are isolated silos or interconnected. The Court was required to decide if Articles 14 (Equality) and 19 (Freedoms) influence how Article 21 must be interpreted.',
          },
          {
            'title': 'Articles Involved',
            'content':
                'The judgment linked Article 14, 19, and 21, forming the powerful doctrine of the "Golden Triangle." This meant that any law violating personal liberty must also satisfy equality and freedom principles. The Court made it clear that no Fundamental Right exists in isolation.\n\nThe case also indirectly addressed rights like freedom of movement (under Article 19) and administrative fairness (under Article 14), making it foundational in modern constitutional jurisprudence.',
          },
          {
            'title': 'Judgement',
            'content':
                'The Supreme Court held that any procedure restricting personal liberty must be fair, just, and reasonable, not arbitrary or oppressive. This transformed Article 21 from a narrow procedural right into a broad fountain of human rights.\n\nThis judgment made the government more accountable by requiring fairness in all actions affecting life and liberty. It paved the way for judicial activism in expanding human rights protections.',
          },
          {
            'title': 'Why It Still Matters',
            'content':
                'The Maneka Gandhi ruling led to the birth of numerous rights under Article 21, including the Right to Privacy, Right to Dignity, Right to Clean Environment, Right against Illegal Detention, and many more. It practically reshaped India\'s human rights landscape.\n\nToday, it is one of the most frequently cited cases in courts, governance, policing, and administrative decisions. Almost every rights-based judgment in India builds on its foundation.',
          },
        ];
      case 3:
        return [
          {
            'title': 'Case Background',
            'content':
                'The Vishaka case was triggered by the brutal gang-rape of Bhanwari Devi, a social worker who attempted to stop a child marriage in Rajasthan. At the time, there was no dedicated law addressing workplace sexual harassment, leaving women vulnerable and without proper remedies.\n\nWomen\'s rights groups, including Vishaka (an NGO), filed a PIL demanding legal protection for women at workplaces. The case exposed massive gaps in India\'s legal system and brought national attention to the safety of working women.',
          },
          {
            'title': 'Core Issue',
            'content':
                'The core question was whether sexual harassment at workplace constitutes a violation of women\'s Fundamental Rights. Since no specific legislation existed, the Court had to determine whether it could frame binding guidelines in the absence of a law.\n\nThe issue challenged the state\'s constitutional responsibility to ensure safe working environments and tested whether the judiciary could step in to protect rights when the legislature failed to act.',
          },
          {
            'title': 'Articles Involved',
            'content':
                'The case referred to several rights:\n\nArticle 14 – Equality before law\nArticle 15 – Prohibition of discrimination\nArticle 19(1)(g) – Right to practice any profession\nArticle 21 – Right to life, dignity, and safe workplace\n\nThe Court also referenced the CEDAW Convention, an international treaty on eliminating discrimination against women, showing India\'s global human rights obligations.',
          },
          {
            'title': 'Judgement',
            'content':
                'The Supreme Court laid down the Vishaka Guidelines, making them binding law until Parliament enacted proper legislation. These guidelines mandated Internal Complaints Committees (ICC), employer responsibility, confidentiality, support for victims, and zero tolerance for harassment.\n\nThis judgment created India\'s first legally recognized framework for workplace sexual harassment, functioning as law for nearly 16 years until the POSH Act was passed in 2013.',
          },
          {
            'title': 'Why It Still Matters',
            'content':
                'The Vishaka judgment revolutionized workplace rights for women in India. It helped create safer work environments and forced organizations to adopt structured mechanisms for reporting and addressing harassment.\n\nToday, every company, school, NGO, or institution employing more than 10 people must have an Internal Committee under the POSH Act, 2013, which is built entirely on the Vishaka framework. It remains one of India\'s most socially impactful judgments.',
          },
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Case Study ${widget.caseNumber}'),
        ),
        body: const Center(child: Text('No flashcards available')),
      );
    }

    final isLastCard = _currentIndex == _flashcards.length - 1;
    final flashcard = _flashcards[_currentIndex];

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
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card ${_currentIndex + 1} of ${_flashcards.length}',
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
                  value: (_currentIndex + 1) / _flashcards.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 30),
              // Flashcard content
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
                        const SizedBox(height: 20),
                        Text(
                          flashcard['title']!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              flashcard['content']!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Next button or completion options
                        if (isLastCard)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CaseQuiz(
                                          caseNumber: widget.caseNumber,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3CA2FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Test Your Knowledge',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.popUntil(
                                      context,
                                      (route) => route.isFirst,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF3CA2FF),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Thanks for Learning',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3CA2FF),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentIndex++;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3CA2FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
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

