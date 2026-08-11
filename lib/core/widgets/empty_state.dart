import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: customIcon ??
                  Icon(
                    icon,
                    size: 48,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyCart extends StatelessWidget {
  final VoidCallback? onBrowse;
  const EmptyCart({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Savatingiz hozircha bo\'sh.',
      subtitle: 'Mahsulotlarni savatga qo\'shing va xaridni boshlang. Eng yaxshi texnikalar sizni kutmoqda.',
      actionLabel: 'Xaridni boshlash',
      onAction: onBrowse,
    );
  }
}

class EmptyFavorites extends StatelessWidget {
  final VoidCallback? onBrowse;
  const EmptyFavorites({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'Sevimlilar bo\'sh',
      subtitle: 'Yoqtirgan mahsulotlaringizni shu yerga saqlang.',
      actionLabel: 'Mahsulotlarni ko\'rish',
      onAction: onBrowse,
    );
  }
}

class EmptyOrders extends StatelessWidget {
  final VoidCallback? onBrowse;
  const EmptyOrders({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Buyurtmalar yo\'q',
      subtitle: 'Siz hali hech narsa buyurtma qilmagansiz.',
      actionLabel: 'Xarid qilish',
      onAction: onBrowse,
    );
  }
}

class EmptySearch extends StatelessWidget {
  final String query;
  const EmptySearch({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Hech narsa topilmadi',
      subtitle: '"$query" bo\'yicha mahsulot topilmadi. Boshqa so\'z bilan qidirib ko\'ring.',
    );
  }
}

class EmptyComparison extends StatelessWidget {
  final VoidCallback? onBrowse;
  const EmptyComparison({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.compare_arrows_rounded,
      title: 'Taqqoslash bo\'sh',
      subtitle: 'Taqqoslash uchun mahsulotlar qo\'shing. 4 tagacha mahsulotni solishtirishingiz mumkin.',
      actionLabel: 'Mahsulot tanlash',
      onAction: onBrowse,
    );
  }
}
