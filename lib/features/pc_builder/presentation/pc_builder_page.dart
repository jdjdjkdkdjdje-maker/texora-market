import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/pc_builder_repository_impl.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_model.dart';

class PcBuilderPage extends StatefulWidget {
  const PcBuilderPage({super.key});

  @override
  State<PcBuilderPage> createState() => _PcBuilderPageState();
}

class _PcBuilderPageState extends State<PcBuilderPage> {
  Map<String, ProductModel?> _selected = {};
  bool _isLoading = true;
  Map<String, bool> _compatibility = {'Overall': true};
  int _totalPrice = 0;
  List<PcBuildModel> _savedBuilds = [];

  @override
  void initState() {
    super.initState();
    for (var type in AppConstants.pcBuilderTypes) {
      _selected[type] = null;
    }
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    setState(() => _isLoading = true);
    final repo = context.read<PcBuilderRepositoryImpl>();
    final builds = await repo.getSavedBuilds();
    setState(() {
      _savedBuilds = builds;
      _isLoading = false;
    });
    _calculateTotal();
  }

  void _calculateTotal() {
    int total = 0;
    _selected.forEach((key, product) {
      if (product != null) total += product.price;
    });
    setState(() => _totalPrice = total);
    _checkCompatibility();
  }

  Future<void> _checkCompatibility() async {
    final repo = context.read<PcBuilderRepositoryImpl>();
    final result = await repo.checkCompatibility(_selected);
    setState(() => _compatibility = result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompatible = _compatibility['Overall'] ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kompyuter Yig\'ish'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _selected.values.where((e) => e != null).isEmpty ? null : _saveBuild,
          ),
        ],
      ),
      body: Column(
        children: [
          // Total price bar
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Umumiy narx:', style: AppTextStyles.h4),
                    Text(_totalPrice.toPrice, style: AppTextStyles.priceLarge.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                // Compatibility indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCompatible ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isCompatible ? AppColors.success : AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(isCompatible ? Icons.check_circle_rounded : Icons.error_rounded, size: 18, color: isCompatible ? AppColors.success : AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isCompatible ? 'Moslik tekshirildi - hammasi mos' : 'Moslik xatosi: ${_compatibility.entries.where((e) => e.key != 'Overall' && e.value == false).map((e) => e.key).join(', ')}',
                          style: AppTextStyles.bodySmall.copyWith(color: isCompatible ? AppColors.success : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                // Breakdown
                if (_selected.values.any((e) => e != null)) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...AppConstants.pcBuilderTypes.map((type) {
                    final product = _selected[type];
                    if (product == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(type, style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          Expanded(child: Text(product.name, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                          const SizedBox(width: 8),
                          Text(product.price.toPrice, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jami:', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
                      Text(_totalPrice.toPrice, style: AppTextStyles.h4.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: AppConstants.pcBuilderTypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final type = AppConstants.pcBuilderTypes[i];
                final product = _selected[type];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: product != null ? AppColors.primary.withOpacity(0.3) : (isDark ? AppColors.borderDark : AppColors.borderLight))),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_iconForType(type), color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                            const SizedBox(height: 4),
                            Text(product?.name ?? 'Tanlanmagan', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (product != null) Text(product.price.toPrice, style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      if (product != null)
                        IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => setState(() { _selected[type] = null; _calculateTotal(); }))
                      else
                        ElevatedButton(onPressed: () => _selectProduct(type), child: const Text('Tanlash')),
                    ],
                  ),
                );
              },
            ),
          ),

          // Saved builds
          if (_savedBuilds.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saqlangan yig\'ishlar', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _savedBuilds.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final build = _savedBuilds[i];
                        return Container(
                          width: 160,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.backgroundLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(build.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(build.totalPrice.toPrice, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight, border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight))),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () { setState(() { for (var k in _selected.keys) _selected[k] = null; _calculateTotal(); }); }, child: const Text('Tozalash'))),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _selected.values.where((e) => e != null).isEmpty ? null : () => _showBuildSummary(),
                  child: Text('Yig\'ishni ko\'rish - ${_totalPrice.toPrice}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectProduct(String type) async {
    final repo = context.read<PcBuilderRepositoryImpl>();
    final products = await repo.getProductsForType(type);
    if (!mounted) return;
    final selected = await showModalBottomSheet<ProductModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('$type tanlash', style: AppTextStyles.h3),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final product = products[i];
                      return ListTile(
                        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(_iconForType(type), color: AppColors.primary)),
                        title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${product.price.toPrice} • ${product.brand} • ⭐ ${product.rating}'),
                        onTap: () => Navigator.pop(ctx, product),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selected[type] = selected;
      });
      _calculateTotal();
    }
  }

  Future<void> _saveBuild() async {
    final controller = TextEditingController(text: 'Mening PC ${DateTime.now().day}.${DateTime.now().month}');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yig\'ishni saqlash'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nom')),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor')), ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Saqlash'))],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final repo = context.read<PcBuilderRepositoryImpl>();
      final components = <String, String?>{};
      _selected.forEach((key, value) => components[key] = value?.id);
      await repo.saveBuild(name: name, components: components, totalPrice: _totalPrice);
      await _loadSaved();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yig\'ish saqlandi')));
    }
  }

  void _showBuildSummary() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PC Yig\'ish xulosasi', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              ...AppConstants.pcBuilderTypes.map((type) {
                final product = _selected[type];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(type, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      Expanded(child: Text(product?.name ?? 'Tanlanmagan', textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Jami:', style: AppTextStyles.h3), Text(_totalPrice.toPrice, style: AppTextStyles.priceLarge.copyWith(color: AppColors.primary))]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Yopish'))),
            ],
          ),
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
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
      default:
        return Icons.category_rounded;
    }
  }
}
