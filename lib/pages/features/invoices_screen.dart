// lib/screens/features/invoices_screen.dart
import 'package:flutter/material.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final List<Map<String, dynamic>> _invoices = [
    {"id": "INV-001", "date": "2025-09-10", "amount": 1500, "status": "Paid"},
    {"id": "INV-002", "date": "2025-09-15", "amount": 2500, "status": "Pending"},
    {"id": "INV-003", "date": "2025-09-20", "amount": 1800, "status": "Paid"},
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case "Paid":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoices"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
                  (states) => Colors.blue.shade50),
          border: TableBorder.all(color: Colors.grey.shade300),
          columns: const [
            DataColumn(label: Text("ID")),
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Amount")),
            DataColumn(label: Text("Status")),
          ],
          rows: _invoices.map((invoice) {
            return DataRow(
              cells: [
                DataCell(Text(invoice["id"])),
                DataCell(Text(invoice["date"])),
                DataCell(Text("₹${invoice["amount"]}")),
                DataCell(
                  Row(
                    children: [
                      Icon(Icons.circle,
                          size: 12, color: _getStatusColor(invoice["status"])),
                      const SizedBox(width: 6),
                      Text(invoice["status"]),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add new invoice logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("New invoice feature coming soon!")),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Invoice"),
      ),
    );
  }
}