import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_accountant_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. جدول الحسابات (عملاء، موردين، موظفين، والصندوق)
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        type INTEGER NOT NULL, -- 0: عميل, 1: مورد, 2: موظف, 3: صندوق
        balance REAL DEFAULT 0.0
      )
    ''');

    // 2. جدول القيود والسندات (سند قبض، سند صرف، قيد بسيط)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER,
        amount REAL NOT NULL,
        is_debit INTEGER NOT NULL, -- 1: له (قبض/دائن), 0: عليه (صرف/مدين)
        note TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // 3. جدول المخازن والأصناف (شامل الخدمي والمخزني والوحدات المتفرعة)
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL, -- 'product' (مخزني), 'service' (خدمي)
        major_unit TEXT, -- كرتون/درزن
        minor_unit TEXT, -- حبة/علبة
        conversion_rate INTEGER DEFAULT 1, -- كم حبة في الكرتون
        buy_price REAL DEFAULT 0.0,
        sell_price REAL DEFAULT 0.0,
        quantity INTEGER DEFAULT 0 -- تسجل بالوحدة الصغرى دائما لسهولة الجرد
      )
    ''');

    // 4. جدول حركات المخزون (توريد / صرف مخزني)
    await db.execute('''
      CREATE TABLE inventory_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER,
        qty_change INTEGER NOT NULL, -- موجب (توريد), سالب (صرف)
        note TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // إعداد حساب الصندوق الافتراضي عند أول تشغيل للتطبيق
    await db.rawInsert("INSERT INTO accounts (name, phone, type, balance) VALUES ('الصندوق الرئيسي (الكاش)', '', 3, 0.0)");
  }

  // --- دوال إغلاق قاعدة البيانات ---
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
