import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/simple_gradient_header.dart';

class ContactNgoPage extends StatelessWidget {
  const ContactNgoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ngos = [
      {
        'name': 'Nyaya Seva Foundation',
        'focus': 'Free legal aid for women & seniors',
        'phone': '+91 98765 43210',
        'email': 'help@nyayaseva.org',
        'website': 'https://nyayaseva.org',
        'address': 'C-102, Defence Colony, New Delhi',
      },
      {
        'name': 'Justice For All Trust',
        'focus': 'Litigation support for undertrial prisoners',
        'phone': '+91 90123 45678',
        'email': 'support@justiceforall.in',
        'website': 'https://justiceforall.in',
        'address': '14/2, Meera Marg, Mumbai',
      },
      {
        'name': 'Sahyog Legal Aid',
        'focus': 'Rural land rights and legal education',
        'phone': '+91 98111 22334',
        'email': 'contact@sahyog.org',
        'website': 'https://sahyog.org',
        'address': 'Plot 7, Sector 62, Noida',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔵 Gradient header
          const SimpleGradientHeader(title: "Contact NGOs"),

          // 🔵 NGO List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ngos.length,
              itemBuilder: (context, index) {
                final ngo = ngos[index];
                return _NgoCard(ngo: ngo);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NgoCard extends StatelessWidget {
  final Map<String, String> ngo;
  const _NgoCard({required this.ngo});

  @override
  Widget build(BuildContext context) {
    return Card(
  margin: const EdgeInsets.only(bottom: 16),
  elevation: 6, // stronger shadow
  color: Colors.white, // ensure white background
  shadowColor: Colors.black26,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ngo['name']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(ngo['focus']!, style: const TextStyle(color: Colors.black54)),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.phone,
              label: ngo['phone']!,
              onTap: () => launchUrl(Uri.parse('tel:${ngo['phone']}')),
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              label: ngo['email']!,
              onTap: () => launchUrl(Uri.parse('mailto:${ngo['email']}')),
            ),
            _InfoRow(
              icon: Icons.public,
              label: ngo['website']!,
              onTap: () => launchUrl(Uri.parse(ngo['website']!)),
            ),
            _InfoRow(icon: Icons.location_on_outlined, label: ngo['address']!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(
                  0xFF004AAD,
                ), // text + icon color (dark blue)
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF42A5F5), width: 1.4),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text(
                'Request Assistance',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () => _showRequestSheet(context, ngo),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestSheet(BuildContext context, Map<String, String> ngo) {
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
            Container(
              width: 45,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Request support from ${ngo['name']}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 18),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Describe your legal issue',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Request submitted. NGO will contact you soon.',
                    ),
                  ),
                );
              },
              child: const Text('Submit',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
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
