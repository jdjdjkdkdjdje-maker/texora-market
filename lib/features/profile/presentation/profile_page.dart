import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/models/user_model.dart';
import '../../orders/presentation/orders_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../favorites/presentation/favorites_page.dart';
import '../../comparison/presentation/comparison_page.dart';
import '../../pc_builder/presentation/pc_builder_page.dart';
import '../../texora_ai/presentation/texora_ai_page.dart';

class ProfilePage extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;
  final ThemeMode currentTheme;
  const ProfilePage({super.key, required this.toggleTheme, required this.currentTheme});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;
  bool _isLoading = true;
  List<AddressModel> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final repo = context.read<UserRepositoryImpl>();
    final user = await repo.getCurrentUser();
    List<AddressModel> addrs = [];
    if (user != null) {
      addrs = await repo.getAddresses(user.id);
    }
    setState(() {
      _user = user;
      _addresses = addrs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage(toggleTheme: widget.toggleTheme, currentTheme: widget.currentTheme))),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? _buildLoginPrompt(isDark)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)]),
                              child: Center(child: Text(_user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : 'U', style: AppTextStyles.h1.copyWith(color: AppColors.primary))),
                            ),
                            const SizedBox(height: 12),
                            Text(_user!.name, style: AppTextStyles.h2.copyWith(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(_user!.phone, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Menu
                      _buildSection('Asosiy', [
                        _buildMenuItem(icon: Icons.receipt_long_rounded, title: 'Buyurtmalar', subtitle: 'Buyurtmalar tarixi', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage()))),
                        _buildMenuItem(icon: Icons.favorite_rounded, title: 'Sevimlilar', subtitle: 'Yoqtirgan mahsulotlar', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()))),
                        _buildMenuItem(icon: Icons.compare_arrows_rounded, title: 'Taqqoslash', subtitle: 'Mahsulotlarni solishtirish', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComparisonPage()))),
                        _buildMenuItem(icon: Icons.computer_rounded, title: 'PC Yig\'ish', subtitle: 'Kompyuter yig\'ish', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PcBuilderPage()))),
                        _buildMenuItem(icon: Icons.smart_toy_rounded, title: 'TEXORA AI', subtitle: 'AI yordamchi', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TexoraAiPage()))),
                      ]),

                      const SizedBox(height: 16),
                      _buildSection('Manzillar', [
                        if (_addresses.isEmpty) const ListTile(title: Text('Manzil yo\'q'), subtitle: Text('Checkout da qo\'shing')),
                        ..._addresses.map((addr) => ListTile(leading: const Icon(Icons.location_on_rounded), title: Text(addr.title), subtitle: Text(addr.fullAddress), trailing: addr.isDefault ? const Icon(Icons.check_circle_rounded, color: AppColors.success) : null)),
                        ListTile(leading: const Icon(Icons.add_location_alt_rounded), title: const Text('Manzil qo\'shish'), onTap: _showAddAddressDialog),
                      ]),

                      const SizedBox(height: 16),
                      _buildSection('Sozlamalar', [
                        _buildMenuItem(icon: Icons.settings_rounded, title: 'Sozlamalar', subtitle: 'Tema, til, bildirishnomalar', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage(toggleTheme: widget.toggleTheme, currentTheme: widget.currentTheme)))),
                        _buildMenuItem(icon: Icons.help_outline_rounded, title: 'Yordam', subtitle: 'FAQ va qo\'llab-quvvatlash', onTap: () {}),
                        _buildMenuItem(icon: Icons.info_outline_rounded, title: 'Ilova haqida', subtitle: 'Versiya 1.0.0 - TEXORA', onTap: () {}),
                      ]),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Chiqish'), content: const Text('Profilingizdan chiqmoqchimisiz?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Chiqish'))]));
                            if (confirm == true) {
                              await context.read<UserRepositoryImpl>().deleteUser(_user!.id);
                              await _loadUser();
                            }
                          },
                          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                          label: const Text('Profilni o\'chirish', style: TextStyle(color: AppColors.error)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLoginPrompt(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text('Profil yarating', style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Buyurtmalarni kuzatish va tezroq xarid qilish uchun profil yarating', style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _showLoginDialog, child: const Text('Profil yaratish'))),
          const SizedBox(height: 12),
          Text('Hozir server bo\'lmagani uchun lokal account. Keyinchalik OTP qo\'shiladi.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(title, style: AppTextStyles.h4)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 20)), title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)), subtitle: Text(subtitle, style: AppTextStyles.bodySmall), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16), onTap: onTap);
  }

  void _showLoginDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profil yaratish'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Ism', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().isEmpty ? 'Ism kiriting' : null),
              const SizedBox(height: 12),
              TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefon', prefixIcon: Icon(Icons.phone_outlined), hintText: '90 123 45 67'), validator: (v) => v == null || v.trim().length < 9 ? 'Telefon noto\'g\'ri' : null, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              Text('SMS OTP keyinroq qo\'shiladi. Hozir lokal hisob.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final repo = context.read<UserRepositoryImpl>();
              await repo.createUser(name: nameController.text.trim(), phone: phoneController.text.trim());
              if (mounted) Navigator.pop(ctx);
              await _loadUser();
            },
            child: const Text('Yaratish'),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog() {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manzil qo\'shish'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: titleController, decoration: const InputDecoration(labelText: 'Nom (Uy, Ish)')),
              const SizedBox(height: 12),
              TextFormField(controller: addressController, decoration: const InputDecoration(labelText: 'To\'liq manzil'), validator: (v) => v == null || v.trim().isEmpty ? 'Manzil kiriting' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              if (_user == null) return;
              final repo = context.read<UserRepositoryImpl>();
              final addr = AddressModel(id: DateTime.now().millisecondsSinceEpoch.toString(), userId: _user!.id, title: titleController.text.trim().isEmpty ? 'Asosiy' : titleController.text.trim(), fullAddress: addressController.text.trim(), isDefault: _addresses.isEmpty);
              await repo.addAddress(addr);
              if (mounted) Navigator.pop(ctx);
              await _loadUser();
            },
            child: const Text('Qo\'shish'),
          ),
        ],
      ),
    );
  }
}
