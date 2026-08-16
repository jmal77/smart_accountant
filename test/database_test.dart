// test/database_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:arabic_wallpaper/database_helper.dart';
import 'package:arabic_wallpaper/models.dart';

void main() {
  group('اختبارات قاعدة البيانات', () {
    late DatabaseHelper db;

    setUp(() async {
      db = DatabaseHelper();
    });

    test('إضافة وحذف حساب', () async {
      final account = Account(
        name: 'عميل اختبار',
        phone: '123456789',
        type: 'customer',
        balance: 1000,
      );
      
      final id = await db.insertAccount(account);
      expect(id, greaterThan(0));
      
      final accounts = await db.getAccounts(type: 'customer');
      expect(accounts.isNotEmpty, true);
      
      final deleted = await db.deleteAccount(id);
      expect(deleted, 1);
    });
  });
}
