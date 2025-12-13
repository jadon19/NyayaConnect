import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ManagerPage(),
  ));
}

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  // --- Color Palette ---
  final Color kDarkBlue = const Color(0xFF0F2C59);
  final Color kTeal = const Color(0xFF14B8A6);
  final Color kGreyText = const Color(0xFF6B7280);
  final Color kLightBlueBg = const Color(0xFFEBF1F9);

  // --- Chart State ---
  // Tracks which bar is currently selected. Default is 5 (June).
  int _selectedChartIndex = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Light off-white background
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Summary Card
              _buildTopCard(),

              const SizedBox(height: 24),

              // 2. Circular Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildCircularStat(
                      percentage: 0.68,
                      label: "Active Cases",
                      count: 575,
                      color: kTeal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCircularStat(
                      percentage: 0.32,
                      label: "Closed Cases",
                      count: 270,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Pro Bono Card
              _buildProBonoCard(),

              const SizedBox(height: 24),

              // 4. Interactive Monthly Earnings Chart
              _buildEarningsChart(),

              const SizedBox(height: 16),

              // 5. Case Wise Earnings Button (Bottom)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Add navigation logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "View Case Wise Earnings",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "845",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: kDarkBlue,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Total Clients Represented",
            style: TextStyle(
              fontSize: 14,
              color: kGreyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kDarkBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "View All Clients",
                style: TextStyle(
                  color: kDarkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularStat({
    required double percentage,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              "${(percentage * 100).toInt()}%",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "$label ($count)",
          style: TextStyle(
            fontSize: 13,
            color: kGreyText,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProBonoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kLightBlueBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Pro Bono Work",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDarkBlue,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "42",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: kDarkBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Active: 28 | Closed: 14",
            style: TextStyle(
              fontSize: 14,
              color: kGreyText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kDarkBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(
                "View Pro Bono Clients",
                style: TextStyle(
                  color: kDarkBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart() {
    // Chart Data
    final List<Map<String, dynamic>> chartData = [
      {'label': 'Jan', 'value': 0.35, 'amount': '\$18.5k'},
      {'label': 'Feb', 'value': 0.45, 'amount': '\$24.2k'},
      {'label': 'Mar', 'value': 0.80, 'amount': '\$42.0k'},
      {'label': 'Apr', 'value': 0.60, 'amount': '\$31.5k'},
      {'label': 'May', 'value': 0.75, 'amount': '\$39.8k'},
      {'label': 'Jun', 'value': 1.0, 'amount': '\$52.4k'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monthly Earnings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkBlue,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("\$50k",
                        style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                    Text("\$30k",
                        style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                    Text("\$10k",
                        style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 20), // Spacer for X-axis alignment
                  ],
                ),
                const SizedBox(width: 10),
                
                // Bars Area
                Expanded(
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(chartData.length, (index) {
        final data = chartData[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildInteractiveBar(
            index: index,
            label: data['label'],
            pct: data['value'],
            amount: data['amount'],
            isSelected: _selectedChartIndex == index,
          ),
        );
      }),
    ),
  ),
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveBar({
    required int index,
    required String label,
    required double pct,
    required String amount,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartIndex = index;
        });
      },
      child: Container(
        // Transparent container extends touch area slightly
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // The Floating "Tag"
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  amount,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            // The Bar Visual
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: 24,
              height: 120 * pct, // Scale height
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isSelected
                      // Darker/Solid when selected
                      ? [const Color(0xFF0F2C59), const Color(0xFF0F2C59)]
                      // Gradient/Lighter when not selected
                      : [
                          kDarkBlue.withOpacity(0.7),
                          const Color(0xFF4B89DC).withOpacity(0.7)
                        ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // X-Axis Label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kDarkBlue : kGreyText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}