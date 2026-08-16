// lib/screens/dashboard_view.dart
import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  final Widget Function(BuildContext) buildDrawer;
  final bool isArabic;
  final String shopName;
  final String shopPhone;

  const DashboardView({
    super.key,
    required this.buildDrawer,
    required this.isArabic,
    required this.shopName,
    required this.shopPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الرئيسية' : 'Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard, size: 80),
            const SizedBox(height: 20),
            Text(shopName, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text(shopPhone),
          ],
        ),
      ),
    );
  }
}
