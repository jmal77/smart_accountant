// lib/screens/accounts_view.dart
import 'package:flutter/material.dart';
import '../models.dart';

class AccountsView extends StatelessWidget {
  final AccountType type;
  final String title;

  const AccountsView({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('شاشة $title قيد التطوير'),
      ),
    );
  }
}
