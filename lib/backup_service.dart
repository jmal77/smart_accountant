// lib/backup_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';

class BackupService {
  // ============ تصدير ومشاركة النسخة الاحتياطية ============
  static Future<void> exportAndShare() async {
    try {
      final db = DatabaseHelper();
      final jsonData = await db.exportToJson();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_$timestamp.json';
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      
      await file.writeAsString(jsonData);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📊 نسخة احتياطية من بيانات المحاسب المالي\n'
               '📅 التاريخ: ${DateTime.now().toLocal().toString().split(' ')[0]}\n'
               '⚠️ احتفظ بهذا الملف في مكان آمن',
      );
    } catch (e) {
      throw Exception('فشل إنشاء النسخة الاحتياطية: $e');
    }
  }

  // ============ استيراد من نص JSON ============
  static Future<void> importFromJsonString(String jsonString) async {
    try {
      final data = json.decode(jsonString);
      
      if (!data.containsKey('version')) {
        throw Exception('ملف غير صالح - لا يحتوي على رقم الإصدار');
      }
      
      if (data['version'] != 2) {
        throw Exception('إصدار غير مدعوم - الإصدار الحالي: ${data['version']}');
      }
      
      final db = DatabaseHelper();
      await db.importFromJson(data);
    } on FormatException {
      throw Exception('ملف JSON غير صحيح');
    } catch (e) {
      throw Exception('فشل استيراد البيانات: $e');
    }
  }

  // ============ استيراد من ملف ============
  static Future<void> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('الملف غير موجود');
      }
      
      final content = await file.readAsString();
      await importFromJsonString(content);
    } catch (e) {
      throw Exception('فشل استيراد الملف: $e');
    }
  }

  // ============ التحقق من صحة ملف النسخ الاحتياطي ============
  static Future<bool> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }
      
      final content = await file.readAsString();
      final data = json.decode(content);
      
      return data.containsKey('version') && data['version'] == 2;
    } catch (e) {
      return false;
    }
  }
}
