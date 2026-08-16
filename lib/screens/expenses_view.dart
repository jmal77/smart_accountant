// lib/screens/expenses_view.dart
import 'package:flutter/material.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المصاريف')),
      body: const Center(
        child: Text('شاشة المصاريف قيد التطوير'),
      ),
    );
  }
}
