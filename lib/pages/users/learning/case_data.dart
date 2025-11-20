import 'case_model.dart';

final List<CaseStudy> caseStudies = [
  CaseStudy(
    id: 'case1',
    title: 'The Voice of Riya',
    subtitle: 'Cyber Harassment & Right to Privacy',
    overview:
        'A young journalist receives anonymous threats after exposing municipal corruption. She files a complaint under IT Act and IPC sections.',
    legalIssue: 'Cyber harassment, extortion, breach of privacy',
    parties: [
      CaseParty(
        name: 'Riya Sharma',
        role: 'Complainant',
        description: 'Investigative journalist who exposed corruption.',
      ),
      CaseParty(
        name: 'Anil Khanna',
        role: 'Accused',
        description: 'Municipal contractor accused of corruption.',
      ),
    ],
    storyHighlights: [
      'Riya exposes forged bills in road construction.',
      'She receives doctored photos & threats on WhatsApp.',
      'Police initially dismiss it as “personal matter”.',
      'Riya approaches Cyber Crime Cell with all evidence.',
    ],
    timeline: [
      CaseStep(
        title: 'Complaint Filed',
        detail:
            'Riya files FIR citing Sections 354D, 507 IPC & IT Act 66E, 72.',
        date: '12 Jan 2025',
      ),
      CaseStep(
        title: 'Digital Forensics',
        detail:
            'Cyber lab links threatening number to contractor’s office network.',
        date: '28 Jan 2025',
      ),
      CaseStep(
        title: 'Charge Sheet',
        detail: 'Police file charge sheet within 60 days.',
        date: '05 Mar 2025',
      ),
    ],
    verdict:
        'Court granted restraining order, seized devices, and initiated proceedings under IT Act & IPC. Riya received police protection.',
    takeaways: [
      'Collect digital evidence: screenshots, headers, call logs.',
      'Use dedicated cyber cell portals for faster action.',
      'Sections 354D, 507 IPC + IT Act Sections 66E, 72 offer strong relief.',
    ],
    quiz: [
      CaseQuizQuestion(
        question: 'Which section protects privacy breach through electronic mode?',
        options: ['IT Act 66A', 'IT Act 66E', 'IPC 354A', 'IPC 500'],
        correctIndex: 1,
        explanation:
            'Section 66E of IT Act penalizes intentional violation of privacy through electronic transmission.',
      ),
      CaseQuizQuestion(
        question:
            'What is an essential first step when receiving online threats?',
        options: [
          'Ignore them if anonymous',
          'Approach cyber police with evidence',
          'Post screenshots online',
          'Change your phone number'
        ],
        correctIndex: 1,
        explanation:
            'Collect and submit evidence to cyber police/CERT-In for legal validation.',
      ),
    ],
    coinReward: 75,
    complexity: 'Medium',
  ),
  CaseStudy(
    id: 'case2',
    title: 'Farmer vs Seed Giant',
    subtitle: 'Consumer Protection & Contract Law',
    overview:
        'A cooperative of 120 farmers sues a seed company for selling defective rice seeds that caused massive yield loss.',
    legalIssue: 'Defective goods, collective consumer action',
    parties: [
      CaseParty(
        name: 'Kaveri Farmers Cooperative',
        role: 'Complainant',
        description: '120 farmers from Mandya district.',
      ),
      CaseParty(
        name: 'AgroMax Seeds Pvt Ltd',
        role: 'Respondent',
        description: 'Seed manufacturer claiming high-yield variety.',
      ),
    ],
    storyHighlights: [
      'Farmers bought seeds with written yield guarantees.',
      'Crop failed with 60% loss across members.',
      'Company blamed monsoon despite IMD normal report.',
      'Cooperative files joint complaint in State Consumer Commission.',
    ],
    timeline: [
      CaseStep(
        title: 'Notice Served',
        detail:
            'Farmers served legal notice requesting compensation within 15 days.',
        date: '03 Aug 2024',
      ),
      CaseStep(
        title: 'Expert Committee',
        detail:
            'Agriculture university confirms seed defect via germination tests.',
        date: '18 Sep 2024',
      ),
      CaseStep(
        title: 'Commission Order',
        detail:
            'State Commission orders refund, compensation, and blacklisting.',
        date: '12 Jan 2025',
      ),
    ],
    verdict:
        'Commission awarded ₹2.8 crore as compensation, refund, and directed Agriculture Dept to blacklist AgroMax for 3 years.',
    takeaways: [
      'Collective complaints have higher weight in State Commission.',
      'Expert agriculture reports are key for proof.',
      'Maintain invoices, lot numbers, and advertisement copies.',
    ],
    quiz: [
      CaseQuizQuestion(
        question:
            'Which forum handles claims above ₹1 crore (post 2019 Consumer Act)?',
        options: [
          'District Commission',
          'State Commission',
          'National Commission',
          'Lok Adalat'
        ],
        correctIndex: 1,
        explanation:
            'State Consumer Commission handles claims above ₹50 lakh (post 2019 amendment).',
      ),
      CaseQuizQuestion(
        question: 'Why are seed lot numbers important?',
        options: [
          'They indicate price discount',
          'They link product to manufacturing batch',
          'They show fertilizer mix',
          'They are irrelevant'
        ],
        correctIndex: 1,
        explanation:
            'Lot/batch numbers help trace manufacturing defects and recall orders.',
      ),
    ],
    coinReward: 90,
    complexity: 'High',
  ),
  CaseStudy(
    id: 'case3',
    title: 'Tenant’s Digital Trail',
    subtitle: 'Rental Disputes & Digital Evidence',
    overview:
        'A tenant proves illegal eviction attempt by presenting CCTV clips, WhatsApp chats, and rent payment UPI screenshots.',
    legalIssue: 'Illegal eviction, tenant rights, digital admissibility',
    parties: [
      CaseParty(
        name: 'Saurav Mehta',
        role: 'Tenant',
        description: 'Tech employee residing for 4 years with rent agreement.',
      ),
      CaseParty(
        name: 'Unity Estates LLP',
        role: 'Landlord',
        description: 'Commercial landlord wanting higher rent.',
      ),
    ],
    storyHighlights: [
      'Landlord disconnects utilities to force eviction.',
      'Locks are changed while tenant is at work.',
      'Tenant uses society CCTV, WhatsApp chats, and payment proofs.',
      'Approaches Rent Authority & local police.',
    ],
    timeline: [
      CaseStep(
        title: 'Emergency Order',
        detail:
            'Rent Authority orders immediate restoration of possession and utilities.',
        date: '22 Nov 2024',
      ),
      CaseStep(
        title: 'Penalty Proceedings',
        detail:
            'Rent Authority imposes penalty for violating Model Tenancy Act.',
        date: '15 Jan 2025',
      ),
    ],
    verdict:
        'Tenant restored with police assistance. Landlord fined ₹1 lakh and directed to renew agreement at original terms.',
    takeaways: [
      'Model Tenancy Act prohibits forceful eviction without due process.',
      'Digital evidence (CCTV, chats, UPI) must be accompanied with 65B certificates.',
      'Emergency injunctions help restore possession quickly.',
    ],
    quiz: [
      CaseQuizQuestion(
        question:
            'Under Model Tenancy Act, what must landlords obtain before eviction?',
        options: [
          'Police approval',
          'Rent Authority order',
          'Society NOC',
          'Nothing is required'
        ],
        correctIndex: 1,
        explanation:
            'Landlords need Rent Authority order and due process; self-help eviction is illegal.',
      ),
    ],
    coinReward: 60,
    complexity: 'Medium',
  ),
];