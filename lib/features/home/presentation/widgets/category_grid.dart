import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CategoryGrid extends StatelessWidget {
  final List<String> categories;
  const CategoryGrid({super.key, required this.categories});

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'CPU':
        return Icons.memory_rounded;
      case 'Motherboard':
        return Icons.developer_board_rounded;
      case 'RAM':
        return Icons.sd_storage_rounded;
      case 'GPU':
        return Icons.videogame_asset_rounded;
      case 'SSD':
        return Icons.storage_rounded;
      case 'PSU':
        return Icons.power_rounded;
      case 'Case':
        return Icons.computer_rounded;
      case 'Cooler':
        return Icons.ac_unit_rounded;
      case 'Laptop':
        return Icons.laptop_rounded;
      case 'Smartphone':
        return Icons.smartphone_rounded;
      case 'Monitor':
        return Icons.monitor_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final cat = categories[i];
          return InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 72,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconForCategory(cat), color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(cat, style: AppTextStyles.labelSmall.copyWith(fontSize: 10), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
