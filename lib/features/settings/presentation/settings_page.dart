import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/services/secure_storage_service.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;
  final ThemeMode currentTheme;
  const SettingsPage({super.key, required this.toggleTheme, required this.currentTheme});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _language = 'uz';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString(AppKeys.prefLanguage) ?? 'uz';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Umumiy', [
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.palette_rounded, color: AppColors.primary)),
              title: const Text('Tema'),
              subtitle: Text(widget.currentTheme == ThemeMode.dark ? 'Qorong\'u' : widget.currentTheme == ThemeMode.light ? 'Yorug\'' : 'Tizim'),
              trailing: DropdownButton<ThemeMode>(
                value: widget.currentTheme,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Tizim')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Yorug\'')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Qorong\'u')),
                ],
                onChanged: (v) {
                  if (v != null) widget.toggleTheme(v);
                },
              ),
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.language_rounded, color: AppColors.secondary)),
              title: const Text('Til'),
              subtitle: Text(_language == 'uz' ? 'O\'zbekcha' : _language == 'ru' ? 'Русский' : 'English'),
              trailing: DropdownButton<String>(
                value: _language,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'uz', child: Text('UZ')),
                  DropdownMenuItem(value: 'ru', child: Text('RU')),
                  DropdownMenuItem(value: 'en', child: Text('EN')),
                ],
                onChanged: (v) async {
                  if (v != null) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(AppKeys.prefLanguage, v);
                    setState(() => _language = v);
                  }
                },
              ),
            ),
            SwitchListTile(
              secondary: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.notifications_rounded, color: AppColors.warning)),
              title: const Text('Bildirishnomalar'),
              subtitle: const Text('Yangiliklar va chegirmalar'),
              value: _notificationsEnabled,
              onChanged: (v) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('notifications', v);
                setState(() => _notificationsEnabled = v);
              },
            ),
          ]),

          const SizedBox(height: 16),
          _buildSection('Ma\'lumotlar', [
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.cleaning_services_rounded, color: AppColors.info)),
              title: const Text('Cache tozalash'),
              subtitle: const Text('Vaqtinchalik fayllarni tozalash'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () async {
                final dbHelper = DatabaseHelper();
                await dbHelper.clearCache();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache tozalandi')));
              },
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.delete_forever_rounded, color: AppColors.error)),
              title: const Text('Ma\'lumotlarni tozalash'),
              subtitle: const Text('Savat, sevimlilar, buyurtmalar'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () async {
                final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Ma\'lumotlarni tozalash'), content: const Text('Barcha lokal ma\'lumotlar o\'chiriladi. Davom etasizmi?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ha', style: TextStyle(color: AppColors.error)))]));
                if (confirm == true) {
                  final dbHelper = DatabaseHelper();
                  await dbHelper.clearAllData();
                  final secure = SecureStorageService();
                  await secure.deleteAll();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barcha ma\'lumotlar tozalandi')));
                }
              },
            ),
          ]),

          const SizedBox(height: 16),
          _buildSection('Xavfsizlik va huquq', [
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.privacy_tip_rounded, color: AppColors.success)),
              title: const Text('Maxfiylik'),
              subtitle: const Text('Maxfiylik siyosati'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => _showInfoDialog('Maxfiylik siyosati', 'TEXORA barcha ma\'lumotlarni lokal saqlaydi. Hech qanday serverga yuborilmaydi. Ma\'lumotlaringiz faqat telefoningizda saqlanadi.'),
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.gavel_rounded, color: AppColors.primary)),
              title: const Text('Foydalanish shartlari'),
              subtitle: const Text('Shartlar va qoidalar'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => _showInfoDialog('Foydalanish shartlari', 'TEXORA marketplace dan foydalanish bepul. Barcha narxlar so\'mda. Buyurtmalar lokal saqlanadi. Test to\'lov rejimi.'),
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.info_rounded, color: AppColors.accent)),
              title: const Text('Ilova haqida'),
              subtitle: const Text('TEXORA v1.0.0 - Professional Tech Marketplace'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => _showInfoDialog('TEXORA haqida', 'TEXORA - O\'zbekiston uchun professional texnika marketplace.\n\n• Offline ishlaydi\n• Lokal database (SQLite)\n• PC Builder\n• TEXORA AI\n• Repository pattern\n• Material 3 dizayn\n\nVersiya: 1.0.0+1\nIshlab chiqaruvchi: TEXORA Team'),
            ),
          ]),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('T', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primary)))),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TEXORA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text('Professional tech marketplace\nOffline-first, local database', style: TextStyle(color: Colors.white70, fontSize: 12))])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.all(16), child: Text(title, style: AppTextStyles.h4)), ...children]),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(title), content: Text(content), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Yopish'))]));
  }
}
