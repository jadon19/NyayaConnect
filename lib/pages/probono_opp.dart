import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/simple_gradient_header.dart';
import '../services/user_manager.dart';

class ProbonoPage extends StatelessWidget {
  const ProbonoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = UserManager(); // <-- instantiate singleton
    final role = userManager.role;

    final bool isClient = role == "client";

    // -------------------------
    // DEFAULT PRO BONO LAWYERS
    // -------------------------
    final proBonoLawyers = [
      {
        'name': 'Adv. Meera Desai',
        'speciality': 'Family Law, Domestic Violence, Legal Aid',
        'phone': '+91 99223 11445',
        'email': 'meera.desai@legalhelp.org',
        'experience': '12 years experience',
      },
      {
        'name': 'Adv. Arjun Khanna',
        'speciality': 'Criminal Defense, Undertrial Support',
        'phone': '+91 98155 66778',
        'email': 'arjun.khanna@justicepro.org',
        'experience': '15 years experience',
      },
      {
        'name': 'Adv. Shalini Rao',
        'speciality': 'Women Rights, Cyber Crime, Free Legal Aid',
        'phone': '+91 98760 33441',
        'email': 'shalini.rao@probono.in',
        'experience': '10 years experience',
      },
    ];

    // -------------------------
    // CLIENT CASES SEEKING HELP
    // -------------------------
    final clientRequests = [
      {
        'title': 'Domestic Violence – Need urgent advice',
        'category': 'Family Law',
        'client': 'Anonymous Client',
        'description':
            'Client is seeking urgent guidance regarding domestic violence and protection orders.',
      },
      {
        'title': 'Wrongful Arrest – Need representation',
        'category': 'Criminal Law',
        'client': 'Anonymous Client',
        'description':
            'Undertrial prisoner requires pro bono litigation support for bail.',
      },
      {
        'title': 'Land Dispute – Rural family help',
        'category': 'Civil / Land Rights',
        'client': 'Anonymous Client',
        'description':
            'Family in rural area needs support for land ownership verification.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SimpleGradientHeader(title: "Pro Bono Assistance"),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              // Client sees PROBONO LAWYERS
              // Lawyer sees CLIENT REQUESTS
              itemCount: isClient ? proBonoLawyers.length : clientRequests.length,
              itemBuilder: (context, index) {
                return isClient
                    ? _ProBonoLawyerCard(lawyer: proBonoLawyers[index])
                    : _ClientRequestCard(request: clientRequests[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProBonoLawyerCard extends StatelessWidget {
  final Map<String, String> lawyer;

  const _ProBonoLawyerCard({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      color: Colors.white,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lawyer['name']!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(lawyer['speciality']!, style: const TextStyle(color: Colors.black54)),
            Text(lawyer['experience']!, style: const TextStyle(color: Colors.black87, fontSize: 13)),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.phone,
              label: lawyer['phone']!,
              onTap: () => launchUrl(Uri.parse('tel:${lawyer['phone']}')),
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              label: lawyer['email']!,
              onTap: () => launchUrl(Uri.parse('mailto:${lawyer['email']}')),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                minimumSize: const Size.fromHeight(44),
              ),
              icon: const Icon(Icons.chat),
              label: const Text("Request Pro Bono Help", style: TextStyle(color: Colors.white)),
              onPressed: () => _showRequestSheet(context, lawyer['name']!),
            )
          ],
        ),
      ),
    );
  }

  void _showRequestSheet(BuildContext context, String lawyerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 45, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Send Pro Bono Request to $lawyerName', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Describe your legal issue', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42A5F5), minimumSize: const Size.fromHeight(46)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted. Lawyer will contact you soon.')));
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientRequestCard extends StatelessWidget {
  final Map<String, String> request;
  const _ClientRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      color: Colors.white,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(request['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(request['category']!, style: const TextStyle(color: Colors.black54)),
          const Divider(height: 22),
          Text(request['description']!, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD), minimumSize: const Size.fromHeight(42)),
            icon: const Icon(Icons.volunteer_activism, color: Colors.white),
            label: const Text("Volunteer to Help", style: TextStyle(color: Colors.white)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Client will be notified of your interest.')));
            },
          ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _InfoRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }
}
