// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arabic_wallpaper/main.dart';

void main() {
  testWidgets('تطبيق المحاسب المالي يعمل بشكل صحيح', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartAccountantApp());
    expect(find.text('المحاسب المالي'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
