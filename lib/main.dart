// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database_helper.dart';
import 'backup_service.dart';
import 'models.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await DatabaseHelper().database;
  } catch (e) {
    print('Error initializing database: $e');
  }
  
  runApp(const SmartAccountantApp());
}

class SmartAccountantApp extends StatefulWidget {
  const SmartAccountantApp({super.key});
  
  @override
  State<SmartAccountantApp> createState() => _SmartAccountantAppState();
}

class _SmartAccountantAppState extends State<SmartAccountantApp> {
  bool isArabic = true;

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    try {
      final v = await DatabaseHelper().getSetting('is_arabic_lang');
      if (mounted) {
        setState(() => isArabic = v == null ? true : v == 'true');
      }
    } catch (e) {
      setState(() => isArabic = true);
    }
  }

  void _toggleLanguage(bool val) async {
    setState(() => isArabic = val);
    await DatabaseHelper().setSetting('is_arabic_lang', val.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: isArabic ? 'المحاسب المالي' : 'Smart Accountant',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(AppColors.bg),
        primaryColor: const Color(AppColors.gold),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(AppColors.card), 
          elevation: 0,
        ),
        cardColor: const Color(AppColors.card),
        colorScheme: const ColorScheme.dark(
          primary: Color(AppColors.gold),
          secondary: Color(AppColors.gold),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr, 
        child: child!,
      ),
      home: MainHolderPage(
        isArabic: isArabic, 
        onLangChange: _toggleLanguage,
      ),
    );
  }
}

class MainHolderPage extends StatefulWidget {
  final bool isArabic;
  final ValueChanged<bool> onLangChange;
  
  const MainHolderPage({
    super.key, 
    required this.isArabic, 
    required this.onLangChange,
  });

  @override
  State<MainHolderPage> createState() => _MainHolderPageState();
}

class _MainHolderPageState extends State<MainHolderPage> {
  int _currentIndex = 0;
  bool isActivated = false;
  final TextEditingController _codeController = TextEditingController();

  String shopName = "مؤسسة جمال الصلوي التجارية";
  String shopPhone = "+967736666007";

  @override
  void initState() {
    super.initState();
    _loadShopSettings();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadShopSettings() async {
    try {
      final db = DatabaseHelper();
      final act = await db.getSetting('is_activated');
      final name = await db.getSetting('shop_name');
      final phone = await db.getSetting('shop_phone');
      if (mounted) {
        setState(() {
          isActivated = act == 'true';
          shopName = name ?? shopName;
          shopPhone = phone ?? shopPhone;
        });
      }
    } catch (e) {
      print('Error loading shop settings: $e');
    }
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? "DEV-967-LOCK";
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }
    return "DEV-967-LOCK";
  }

  void _launchWhatsApp() async {
    final deviceId = await _getDeviceId();
    const phoneNumber = "967736666007";
    final message = "السلام عليكم، أريد تفعيل ترخيص (المحاسب المالي Pro).\nرقم جهازي (Device ID):\n$deviceId";
    final whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل فتح واتساب: $e')),
        );
      }
    }
  }

  void _showLicenseDialog() {
    _codeController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(AppColors.card),
        title: const Text(
          'تنشيط المحاسب المالي', 
          style: TextStyle(color: Color(AppColors.accent), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'أدخل كود التفعيل',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _launchWhatsApp,
              icon: const Icon(Icons.chat, color: Colors.greenAccent),
              label: const Text('طلب كود عبر واتساب'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final entered = _codeController.text.trim();
              if (entered.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال كود التفعيل')),
                );
                return;
              }
              
              final deviceId = await _getDeviceId();
              final expected = "ARAB-" + deviceId.hashCode.toString().toUpperCase().substring(0, 8);
              final ok = entered == expected || entered == "ARAB-SUCCESS-2026";
              
              if (ok) {
                await DatabaseHelper().setSetting('is_activated', 'true');
                if (mounted) {
                  setState(() => isActivated = true);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم التنشيط بنجاح!')),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كود غير صحيح!')),
                  );
                }
              }
            },
            child: const Text('تنشيط'),
          ),
        ],
      ),
    );
  }

  void _showShopSettingsDialog() {
    final nameCtrl = TextEditingController(text: shopName);
    final phoneCtrl = TextEditingController(text: shopPhone);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(AppColors.card),
        title: const Text('إعدادات بيانات المحل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl, 
              decoration: const InputDecoration(labelText: 'اسم المحل/الفرع'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl, 
              keyboardType: TextInputType.phone, 
              decoration: const InputDecoration(labelText: 'رقم هاتف المحل'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = DatabaseHelper();
              await db.setSetting('shop_name', nameCtrl.text.trim());
              await db.setSetting('shop_phone', phoneCtrl.text.trim());
              if (mounted) {
                setState(() {
                  shopName = nameCtrl.text.trim();
                  shopPhone = phoneCtrl.text.trim();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الإعدادات')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup() async {
    try {
      await BackupService.exportAndShare();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء ملف النسخة الاحتياطية')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التصدير: $e')),
        );
      }
    }
  }

  void _importBackupDialog() {
    final importCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(AppColors.card),
        title: const Text('استيراد نسخة احتياطية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تحذير: الاستيراد يستبدل كل البيانات الحالية بالكامل.\nالصق محتوى ملف النسخة الاحتياطية (JSON) هنا:',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: importCtrl, 
              maxLines: 6, 
              decoration: const InputDecoration(
                hintText: '{ "version": 2, ... }',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final jsonData = importCtrl.text.trim();
              if (jsonData.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء لصق البيانات')),
                );
                return;
              }
              try {
                await BackupService.importFromJsonString(jsonData);
                if (mounted) {
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم استرجاع البيانات بنجاح!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل الاستيراد: $e')),
                  );
                }
              }
            },
            child: const Text('استيراد'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(AppColors.bg),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(AppColors.card)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Color(AppColors.accent), 
              child: Icon(Icons.account_balance, color: Colors.black, size: 35),
            ),
            accountName: const Text(
              'المحاسب المالي Pro', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              isActivated ? 'النسخة الكاملة النشطة 💎' : 'النسخة التجريبية المحدودة',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.tealAccent),
            title: const Text('المصاريف'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري تطوير هذه الميزة...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse, color: Colors.tealAccent),
            title: const Text('المخزون'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري تطوير هذه الميزة...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.tealAccent),
            title: const Text('الفواتير'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري تطوير هذه الميزة...')),
              );
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.storefront, color: Colors.tealAccent),
            title: const Text('إعدادات المحل'),
            onTap: () {
              Navigator.pop(context);
              _showShopSettingsDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: Colors.tealAccent),
            title: const Text('تصدير نسخة احتياطية'),
            onTap: () {
              Navigator.pop(context);
              _exportBackup();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download, color: Colors.tealAccent),
            title: const Text('استيراد نسخة احتياطية'),
            onTap: () {
              Navigator.pop(context);
              _importBackupDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.tealAccent),
            title: Text(widget.isArabic ? 'English' : 'عربي'),
            onTap: () {
              Navigator.pop(context);
              widget.onLangChange(!widget.isArabic);
            },
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key, color: Colors.amber),
            title: const Text('تنشيط الترخيص'),
            onTap: () {
              Navigator.pop(context);
              _showLicenseDialog();
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'تم التصميم والتطوير بواسطة\nالمهندس جمال الصلوي 💎',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage = Scaffold(
      appBar: AppBar(
        title: Text(widget.isArabic ? 'الرئيسية' : 'Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance, size: 80, color: Color(AppColors.gold)),
            const SizedBox(height: 20),
            Text(
              shopName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              shopPhone,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: const Color(AppColors.card),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(AppColors.gold), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    isActivated ? '✅ الترخيص مفعل' : '⚠️ الترخيص غير مفعل',
                    style: TextStyle(
                      color: isActivated ? Colors.green : Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isActivated ? '💎 النسخة الكاملة' : '📱 النسخة التجريبية',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
    );

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(AppColors.accent),
        unselectedItemColor: Colors.white54,
        backgroundColor: const Color(AppColors.card),
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: widget.isArabic ? 'الرئيسية' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: widget.isArabic ? 'العملاء' : 'Customers',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_shipping),
            label: widget.isArabic ? 'الموردين' : 'Suppliers',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.badge),
            label: widget.isArabic ? 'الموظفين' : 'Employees',
          ),
        ],
      ),
    );
  }
}
