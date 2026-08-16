// lib/database_helper.dart
import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_accountant.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        type TEXT NOT NULL,
        balance REAL DEFAULT 0,
        created_at INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        position TEXT,
        salary REAL DEFAULT 0,
        hire_date INTEGER,
        is_active INTEGER DEFAULT 1
      )
    ''');
    
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT,
        date INTEGER NOT NULL,
        note TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity REAL DEFAULT 0,
        unit TEXT,
        price REAL DEFAULT 0,
        category TEXT,
        supplier_id INTEGER,
        min_quantity REAL DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL,
        type TEXT NOT NULL,
        customer_id INTEGER,
        supplier_id INTEGER,
        date INTEGER NOT NULL,
        total REAL DEFAULT 0,
        paid REAL DEFAULT 0,
        status TEXT DEFAULT 'pending',
        note TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER,
        item_name TEXT NOT NULL,
        quantity REAL DEFAULT 1,
        unit_price REAL DEFAULT 0,
        total REAL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // ============ دوال الإعدادات ============
  Future<String?> getSetting(String key) async {
    try {
      final db = await database;
      final result = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: [key],
      );
      if (result.isNotEmpty) {
        return result.first['value'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> setSetting(String key, String value) async {
    try {
      final db = await database;
      await db.insert(
        'settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error setting setting: $e');
    }
  }

  // ============ دوال الحسابات ============
  Future<List<Account>> getAccounts({String? type}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps;
      if (type != null) {
        maps = await db.query(
          'accounts',
          where: 'type = ?',
          whereArgs: [type],
          orderBy: 'name ASC',
        );
      } else {
        maps = await db.query('accounts', orderBy: 'name ASC');
      }
      return maps.map((map) => Account.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ دوال الموظفين ============
  Future<List<Employee>> getEmployees({bool? isActive}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps;
      if (isActive != null) {
        maps = await db.query(
          'employees',
          where: 'is_active = ?',
          whereArgs: [isActive ? 1 : 0],
          orderBy: 'name ASC',
        );
      } else {
        maps = await db.query('employees', orderBy: 'name ASC');
      }
      return maps.map((map) => Employee.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return await db.insert('employees', employee.toMap());
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    final db = await database;
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ دوال المصاريف ============
  Future<List<Expense>> getExpenses({DateTime? startDate, DateTime? endDate}) async {
    try {
      final db = await database;
      String where = '';
      List<Object?> whereArgs = [];
      
      if (startDate != null && endDate != null) {
        where = 'date BETWEEN ? AND ?';
        whereArgs = [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch];
      } else if (startDate != null) {
        where = 'date >= ?';
        whereArgs = [startDate.millisecondsSinceEpoch];
      } else if (endDate != null) {
        where = 'date <= ?';
        whereArgs = [endDate.millisecondsSinceEpoch];
      }
      
      final maps = await db.query(
        'expenses',
        where: where.isNotEmpty ? where : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date DESC',
      );
      return maps.map((map) => Expense.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ دوال المخزون ============
  Future<List<InventoryItem>> getInventoryItems({String? category}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps;
      if (category != null) {
        maps = await db.query(
          'inventory',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'name ASC',
        );
      } else {
        maps = await db.query('inventory', orderBy: 'name ASC');
      }
      return maps.map((map) => InventoryItem.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    return await db.insert('inventory', item.toMap());
  }

  Future<int> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    return await db.update(
      'inventory',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteInventoryItem(int id) async {
    final db = await database;
    return await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ دوال الفواتير ============
  Future<List<Invoice>> getInvoices({String? type, String? status}) async {
    try {
      final db = await database;
      String where = '';
      List<Object?> whereArgs = [];
      
      if (type != null && status != null) {
        where = 'type = ? AND status = ?';
        whereArgs = [type, status];
      } else if (type != null) {
        where = 'type = ?';
        whereArgs = [type];
      } else if (status != null) {
        where = 'status = ?';
        whereArgs = [status];
      }
      
      final maps = await db.query(
        'invoices',
        where: where.isNotEmpty ? where : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date DESC',
      );
      return maps.map((map) => Invoice.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertInvoice(Invoice invoice) async {
    final db = await database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<int> updateInvoice(Invoice invoice) async {
    final db = await database;
    return await db.update(
      'invoices',
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    await db.delete(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ دوال عناصر الفاتورة ============
  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );
      return maps.map((map) => InvoiceItem.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> insertInvoiceItems(List<InvoiceItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert('invoice_items', item.toMap());
    }
    await batch.commit();
  }

  Future<void> deleteInvoiceItems(int invoiceId) async {
    final db = await database;
    await db.delete(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
  }

  // ============ دوال الإحصائيات ============
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    try {
      final expenses = await getExpenses(startDate: startDate, endDate: endDate);
      double total = 0;
      for (var expense in expenses) {
        total += expense.amount;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getTotalSales({DateTime? startDate, DateTime? endDate}) async {
    try {
      final db = await database;
      String where = '';
      List<Object?> whereArgs = [];
      
      if (startDate != null && endDate != null) {
        where = 'type = "sale" AND date BETWEEN ? AND ?';
        whereArgs = [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch];
      } else if (startDate != null) {
        where = 'type = "sale" AND date >= ?';
        whereArgs = [startDate.millisecondsSinceEpoch];
      } else if (endDate != null) {
        where = 'type = "sale" AND date <= ?';
        whereArgs = [endDate.millisecondsSinceEpoch];
      } else {
        where = 'type = "sale"';
      }
      
      final result = await db.rawQuery(
        'SELECT SUM(total) as total FROM invoices WHERE $where',
        whereArgs,
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ============ دوال النسخ الاحتياطي ============
  Future<String> exportToJson() async {
    try {
      final db = await database;
      final data = {
        'version': 2,
        'export_date': DateTime.now().toIso8601String(),
        'settings': await db.query('settings'),
        'accounts': await db.query('accounts'),
        'employees': await db.query('employees'),
        'expenses': await db.query('expenses'),
        'inventory': await db.query('inventory'),
        'invoices': await db.query('invoices'),
        'invoice_items': await db.query('invoice_items'),
      };
      return json.encode(data);
    } catch (e) {
      return '{}';
    }
  }

  Future<void> importFromJson(Map<String, dynamic> data) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('invoice_items');
        await txn.delete('invoices');
        await txn.delete('inventory');
        await txn.delete('expenses');
        await txn.delete('employees');
        await txn.delete('accounts');
        await txn.delete('settings');
        
        const tables = [
          'settings', 'accounts', 'employees', 
          'expenses', 'inventory', 'invoices', 'invoice_items'
        ];
        
        for (var table in tables) {
          if (data.containsKey(table)) {
            for (var item in data[table] as List) {
              await txn.insert(table, item as Map<String, dynamic>);
            }
          }
        }
      });
    } catch (e) {
      print('Error importing: $e');
    }
  }

  // ============ دوال مساعدة ============
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final customers = await getAccounts(type: 'customer');
      final suppliers = await getAccounts(type: 'supplier');
      final employees = await getEmployees();
      final totalExpenses = await getTotalExpenses();
      final totalSales = await getTotalSales();
      
      return {
        'customers': customers.length,
        'suppliers': suppliers.length,
        'employees': employees.length,
        'expenses': totalExpenses,
        'sales': totalSales,
        'profit': totalSales - totalExpenses,
      };
    } catch (e) {
      return {
        'customers': 0,
        'suppliers': 0,
        'employees': 0,
        'expenses': 0,
        'sales': 0,
        'profit': 0,
      };
    }
  }
}
