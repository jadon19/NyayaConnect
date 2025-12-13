import 'package:flutter/material.dart';

class TrackCaseScreen extends StatelessWidget {
  const TrackCaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController caseController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
  title: const Text('Track Case',style: TextStyle(color: Colors.white)),
  backgroundColor: const Color.fromARGB(255, 0, 183, 255),  // make AppBar background transparent
  
),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: caseController,
              decoration: const InputDecoration(
                labelText: 'Enter Case Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.white; // background turns white when pressed
      }
      return Colors.blue.shade700; // default background
    }),
    foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.lightBlue; // text turns light blue when pressed
      }
      return Colors.white; // default text color
    }),
    minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  onPressed: () {
    // Your submit logic
  },
  child: const Text(
    'Track',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
),

          ],
        ),
      ),
    );
  }
}
