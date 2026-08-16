// lib/models.dart

// ============ نموذج الحساب (عميل/مورد) ============
class Account {
  int? id;
  String name;
  String? phone;
  String? address;
  String type; // 'customer' أو 'supplier'
  double balance;
  int? createdAt;

  Account({
    this.id,
    required this.name,
    this.phone,
    this.address,
    required this.type,
    this.balance = 0,
    this.createdAt,
  });

  // تحويل الكائن إلى Map للتخزين في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'type': type,
      'balance': balance,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  // تحويل Map من قاعدة البيانات إلى كائن
  static Account fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      type: map['type'] as String,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] as int?,
    );
  }

  // نسخ الكائن مع تغيير بعض الخصائص
  Account copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? type,
    double? balance,
    int? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ============ نموذج الموظف ============
class Employee {
  int? id;
  String name;
  String? phone;
  String? position;
  double salary;
  int? hireDate;
  bool isActive;

  Employee({
    this.id,
    required this.name,
    this.phone,
    this.position,
    this.salary = 0,
    this.hireDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'position': position,
      'salary': salary,
      'hire_date': hireDate ?? DateTime.now().millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  static Employee fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      position: map['position'] as String?,
      salary: (map['salary'] as num?)?.toDouble() ?? 0,
      hireDate: map['hire_date'] as int?,
      isActive: (map['is_active'] as int?) == 1,
    );
  }
}

// ============ نموذج المصروف ============
class Expense {
  int? id;
  String description;
  double amount;
  String? category;
  int date;
  String? note;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String?,
      date: map['date'] as int,
      note: map['note'] as String?,
    );
  }
}

// ============ نموذج المخزون ============
class InventoryItem {
  int? id;
  String name;
  double quantity;
  String? unit;
  double price;
  String? category;
  int? supplierId;
  double minQuantity;

  InventoryItem({
    this.id,
    required this.name,
    this.quantity = 0,
    this.unit,
    this.price = 0,
    this.category,
    this.supplierId,
    this.minQuantity = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'category': category,
      'supplier_id': supplierId,
      'min_quantity': minQuantity,
    };
  }

  static InventoryItem fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String?,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String?,
      supplierId: map['supplier_id'] as int?,
      minQuantity: (map['min_quantity'] as num).toDouble(),
    );
  }
}

// ============ نموذج الفاتورة ============
class Invoice {
  int? id;
  String invoiceNumber;
  String type; // 'sale' أو 'purchase'
  int? customerId;
  int? supplierId;
  int date;
  double total;
  double paid;
  String status; // 'pending', 'paid', 'partially_paid'
  String? note;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.type,
    this.customerId,
    this.supplierId,
    required this.date,
    this.total = 0,
    this.paid = 0,
    this.status = 'pending',
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'type': type,
      'customer_id': customerId,
      'supplier_id': supplierId,
      'date': date,
      'total': total,
      'paid': paid,
      'status': status,
      'note': note,
    };
  }

  static Invoice fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as int?,
      invoiceNumber: map['invoice_number'] as String,
      type: map['type'] as String,
      customerId: map['customer_id'] as int?,
      supplierId: map['supplier_id'] as int?,
      date: map['date'] as int,
      total: (map['total'] as num).toDouble(),
      paid: (map['paid'] as num).toDouble(),
      status: map['status'] as String,
      note: map['note'] as String?,
    );
  }

  // حساب المبلغ المتبقي
  double get remaining => total - paid;
  
  // حساب النسبة المدفوعة
  double get paidPercentage => total > 0 ? (paid / total) * 100 : 0;
}

// ============ نموذج عناصر الفاتورة ============
class InvoiceItem {
  int? id;
  int invoiceId;
  String itemName;
  double quantity;
  double unitPrice;
  double total;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.itemName,
    this.quantity = 1,
    this.unitPrice = 0,
    this.total = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'item_name': itemName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
    };
  }

  static InvoiceItem fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int,
      itemName: map['item_name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
    );
  }
}

// ============ أنواع الحسابات (Enums) ============
enum AccountType {
  customer,
  supplier,
}

extension AccountTypeExtension on AccountType {
  String get value {
    switch (this) {
      case AccountType.customer:
        return 'customer';
      case AccountType.supplier:
        return 'supplier';
    }
  }
  
  String get displayName {
    switch (this) {
      case AccountType.customer:
        return 'عميل';
      case AccountType.supplier:
        return 'مورد';
    }
  }
}
