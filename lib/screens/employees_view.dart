// lib/screens/employees_view.dart
import 'package:flutter/material.dart';

class EmployeesView extends StatelessWidget {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الموظفين')),
      body: const Center(
        child: Text('شاشة الموظفين قيد التطوير'),
      ),
    );
  }
}
