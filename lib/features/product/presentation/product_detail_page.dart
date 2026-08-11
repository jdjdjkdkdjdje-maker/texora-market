import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/cart_repository_impl.dart';
import '../../../data/repositories/favorite_repository_impl.dart';
import '../../../data/repositories/comparison_repository_impl.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../../main.dart';
import '../../../core/widgets/product_card.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isFavorite = false;
  bool _isInComparison = false;
  List<ProductModel> _recommended = [];
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final favRepo = context.read<FavoriteRepositoryImpl>();
    final compRepo = context.read<ComparisonRepositoryImpl>();
    final prodRepo = context.read<ProductRepositoryImpl>();
    final isFav = await favRepo.isFavorite(widget.product.id);
    final isComp = await compRepo.isInComparison(widget.product.id);
    final rec = await prodRepo.getRecommendedProducts(widget.product.id);
    setState(() {
      _isFavorite = isFav;
      _isInComparison = isComp;
      _recommended = rec;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: _isFavorite ? AppColors.error : null),
            onPressed: () async {
              final repo = context.read<FavoriteRepositoryImpl>();
              await repo.toggleFavorite(widget.product.id);
              final favs = await repo.getFavorites();
              if (mounted) context.read<FavoritesCounterProvider>().updateCount(favs.length);
              final isFav = await repo.isFavorite(widget.product.id);
              setState(() => _isFavorite = isFav);
            },
          ),
          IconButton(
            icon: Icon(_isInComparison ? Icons.compare_rounded : Icons.compare_arrows_rounded, color: _isInComparison ? AppColors.primary : null),
            onPressed: () async {
              final repo = context.read<ComparisonRepositoryImpl>();
              if (_isInComparison) {
                await repo.removeFromComparison(widget.product.id);
              } else {
                try {
                  await repo.addToComparison(widget.product.id);
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
              final isComp = await repo.isInComparison(widget.product.id);
              setState(() => _isInComparison = isComp);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Icon(_iconForCategory(widget.product.category), size: 100, color: AppColors.primary.withOpacity(0.7)),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand + rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(widget.product.brand, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text('${widget.product.rating} (${widget.product.reviewCount})', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.product.name, style: AppTextStyles.h2.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  const SizedBox(height: 8),
                  Text(widget.product.description, style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    children: [
                      Text(widget.product.price.toPrice, style: AppTextStyles.priceLarge.copyWith(color: AppColors.primary)),
                      const SizedBox(width: 12),
                      if (widget.product.oldPrice != null)
                        Text(AppFormatters.formatPrice(widget.product.oldPrice!), style: AppTextStyles.bodyMedium.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                  if (widget.product.discountPercent > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                      child: Text('-${widget.product.discountPercent}% chegirma', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Specs
                  Text('Texnik xususiyatlar', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Column(
                      children: widget.product.specs.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                              Text(e.value.toString(), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity
                  Row(
                    children: [
                      const Text('Miqdori:', style: AppTextStyles.h5),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            IconButton(onPressed: () => setState(() => _quantity = (_quantity - 1).clamp(1, 10)), icon: const Icon(Icons.remove_rounded)),
                            Text('$_quantity', style: AppTextStyles.h4),
                            IconButton(onPressed: () => setState(() => _quantity = (_quantity + 1).clamp(1, 10)), icon: const Icon(Icons.add_rounded)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text('Mavjud: ${widget.product.stock}', style: AppTextStyles.bodySmall.copyWith(color: widget.product.stock > 0 ? AppColors.success : AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recommended
                  if (_recommended.isNotEmpty) ...[
                    Text('O\'xshash mahsulotlar', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommended.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final p = _recommended[i];
                          return SizedBox(width: 180, child: ProductCard(product: p, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)))));
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isInComparison ? null : () async {
                    final repo = context.read<ComparisonRepositoryImpl>();
                    try {
                      await repo.addToComparison(widget.product.id);
                      setState(() => _isInComparison = true);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Taqqoslashga qo\'shildi')));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  icon: const Icon(Icons.compare_arrows_rounded),
                  label: Text(_isInComparison ? 'Taqqoslashda' : 'Taqqoslash'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: widget.product.stock <= 0 ? null : () async {
                    final repo = context.read<CartRepositoryImpl>();
                    await repo.addToCart(widget.product.id, _quantity);
                    final count = await repo.getCartCount();
                    if (mounted) context.read<CartCounterProvider>().updateCount(count);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.product.name} savatga qo\'shildi')));
                  },
                  icon: const Icon(Icons.shopping_cart_rounded),
                  label: Text('Savatga - ${AppFormatters.formatPrice(widget.product.price * _quantity)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'CPU':
        return Icons.memory_rounded;
      case 'GPU':
        return Icons.videogame_asset_rounded;
      case 'RAM':
        return Icons.sd_storage_rounded;
      case 'Motherboard':
        return Icons.developer_board_rounded;
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
