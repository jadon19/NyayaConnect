import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'id': 'TXN001', 'amount': '₹500', 'bank': 'HDFC', 'time': '2025-10-10 12:30'},
      {'id': 'TXN002', 'amount': '₹1200', 'bank': 'SBI', 'time': '2025-10-12 14:50'},
    ];

    return Scaffold(
      appBar: AppBar(
  title: const Text('Transactions',style: TextStyle(color: Colors.white)),
  backgroundColor: const Color.fromARGB(255, 0, 183, 255), // make AppBar background transparent
  
  
),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (_, index) {
          final txn = transactions[index];
          return Card(
            elevation: 4,
            shadowColor: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text('Transaction: ${txn['id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ${txn['amount']}'),
                  Text('Bank: ${txn['bank']}'),
                  Text('Time: ${txn['time']}'),
                ],
              ),
              trailing: const Icon(Icons.receipt_long, color: Colors.blue),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
