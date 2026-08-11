import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/comparison_repository_impl.dart';
import '../../../data/models/product_model.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  bool _isLoading = true;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final repo = context.read<ComparisonRepositoryImpl>();
    final prods = await repo.getComparisonProducts();
    setState(() {
      _products = prods;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taqqoslash'),
        actions: [
          if (_products.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () async {
                await context.read<ComparisonRepositoryImpl>().clearComparison();
                await _load();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const EmptyComparison()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Labels column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 100),
                                  _buildLabel('Narx'),
                                  _buildLabel('Brend'),
                                  _buildLabel('Kategoriya'),
                                  _buildLabel('Reyting'),
                                  _buildLabel('Mavjud'),
                                  const SizedBox(height: 12),
                                  const Text('Xususiyatlar:', style: AppTextStyles.h4),
                                  const SizedBox(height: 8),
                                  ..._allSpecKeys().map(_buildLabel),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Products columns
                              Row(
                                children: _products.map((p) {
                                  return Container(
                                    width: 180,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 100,
                                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                                          child: Center(child: Icon(_iconForCategory(p.category), size: 40, color: AppColors.primary)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(p.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 12),
                                              Text(p.price.toPrice, style: AppTextStyles.priceMedium.copyWith(color: AppColors.primary, fontSize: 14)),
                                              const SizedBox(height: 8),
                                              Text(p.brand, style: AppTextStyles.bodySmall),
                                              Text(p.category, style: AppTextStyles.bodySmall),
                                              Text('${p.rating} ⭐', style: AppTextStyles.bodySmall),
                                              Text(p.stock > 0 ? 'Mavjud' : 'Tugagan', style: AppTextStyles.bodySmall.copyWith(color: p.stock > 0 ? AppColors.success : AppColors.error)),
                                              const SizedBox(height: 20),
                                              ..._allSpecKeys().map((key) {
                                                final val = p.specs[key]?.toString() ?? '-';
                                                return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(val, style: AppTextStyles.bodySmall, textAlign: TextAlign.center));
                                              }),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton(
                                                  onPressed: () async {
                                                    await context.read<ComparisonRepositoryImpl>().removeFromComparison(p.id);
                                                    await _load();
                                                  },
                                                  child: const Text('Olib tashlash'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      height: 32,
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  List<String> _allSpecKeys() {
    final Set<String> keys = {};
    for (var p in _products) {
      keys.addAll(p.specs.keys);
    }
    return keys.toList();
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'CPU':
        return Icons.memory_rounded;
      case 'GPU':
        return Icons.videogame_asset_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
