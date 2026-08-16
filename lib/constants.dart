// lib/constants.dart

import 'package:flutter/material.dart';

/// ============================================
/// 📌 الألوان الرئيسية للتطبيق
/// ============================================
class AppColors {
  // الألوان الأساسية
  static const int bg = 0xFF0A0E21;        // لون الخلفية الرئيسي
  static const int card = 0xFF1A1A2E;      // لون البطاقات
  static const int gold = 0xFFFFD700;      // اللون الذهبي
  static const int accent = 0xFFFFD700;    // لون الإبراز
  
  // ألوان الحالات
  static const int success = 0xFF00E676;   // أخضر للنجاح
  static const int danger = 0xFFFF1744;    // أحمر للخطأ
  static const int warning = 0xFFFFAB00;   // برتقالي للتحذير
  static const int info = 0xFF2979FF;      // أزرق للمعلومات
  
  // ألوان النصوص
  static const int textPrimary = 0xFFFFFFFF;   // أبيض
  static const int textSecondary = 0xFFB0BEC5; // رمادي فاتح
  static const int textDark = 0xFF263238;      // أسود غامق
}

/// ============================================
/// 📌 النصوص الثابتة للتطبيق
/// ============================================
class AppStrings {
  static const String appName = 'المحاسب المالي';
  static const String appNameEn = 'Smart Accountant';
  
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String search = 'بحث';
  static const String loading = 'جاري التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String error = 'حدث خطأ';
  static const String success = 'تم بنجاح';
  
  static const String confirmDelete = 'هل أنت متأكد من الحذف؟';
  static const String confirmDeleteMessage = 'لا يمكن استرجاع البيانات بعد الحذف';
  
  static const String dashboard = 'الرئيسية';
  static const String customers = 'العملاء';
  static const String suppliers = 'الموردين';
  static const String employees = 'الموظفين';
  static const String expenses = 'المصاريف';
  static const String inventory = 'المخزون';
  static const String invoices = 'الفواتير';
}

/// ============================================
/// 📌 أحجام الخطوط
/// ============================================
class AppFontSizes {
  static const double small = 12.0;
  static const double medium = 14.0;
  static const double normal = 16.0;
  static const double large = 18.0;
  static const double xLarge = 22.0;
  static const double xxLarge = 26.0;
  static const double title = 32.0;
}

/// ============================================
/// 📌 المسافات
/// ============================================
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

/// ============================================
/// 📌 الرسوم المتحركة
/// ============================================
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
}

/// ============================================
/// 📌 أرقام الهواتف
/// ============================================
class AppContacts {
  static const String phoneNumber = "+967736666007";
  static const String whatsappNumber = "967736666007";
  static const String email = "support@smartaccountant.com";
}

/// ============================================
/// 📌 أنواع الفواتير
/// ============================================
class InvoiceTypes {
  static const String sale = 'sale';
  static const String purchase = 'purchase';
  
  static String getDisplayName(String type) {
    switch (type) {
      case sale:
        return 'فاتورة مبيعات';
      case purchase:
        return 'فاتورة مشتريات';
      default:
        return type;
    }
  }
}

/// ============================================
/// 📌 حالات الفواتير
/// ============================================
class InvoiceStatus {
  static const String pending = 'pending';
  static const String paid = 'paid';
  static const String partiallyPaid = 'partially_paid';
  
  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'قيد الانتظار';
      case paid:
        return 'مدفوعة';
      case partiallyPaid:
        return 'مدفوعة جزئياً';
      default:
        return status;
    }
  }
  
  static Color getColor(String status) {
    switch (status) {
      case pending:
        return const Color(AppColors.warning);
      case paid:
        return const Color(AppColors.success);
      case partiallyPaid:
        return const Color(AppColors.info);
      default:
        return Colors.grey;
    }
  }
}

/// ============================================
/// 📌 أنواع الحسابات
/// ============================================
class AccountTypes {
  static const String customer = 'customer';
  static const String supplier = 'supplier';
  
  static String getDisplayName(String type) {
    switch (type) {
      case customer:
        return 'عميل';
      case supplier:
        return 'مورد';
      default:
        return type;
    }
  }
}
