import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/cart_repository_impl.dart';
import '../../../data/repositories/favorite_repository_impl.dart';
import '../../../main.dart';
import '../../catalog/presentation/catalog_page.dart';
import '../../product/presentation/product_detail_page.dart';
import '../../search/presentation/search_page.dart';
import '../../comparison/presentation/comparison_page.dart';
import '../../pc_builder/presentation/pc_builder_page.dart';
import '../../texora_ai/presentation/texora_ai_page.dart';
import '../../cart/presentation/cart_page.dart';
import 'widgets/banner_slider.dart';
import 'widgets/category_grid.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;
  final ThemeMode currentTheme;
  const HomePage({super.key, required this.toggleTheme, required this.currentTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _featured = [];
  List<ProductModel> _topRated = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final productRepo = context.read<ProductRepositoryImpl>();
    final products = await productRepo.getAllProducts();
    final categories = await productRepo.getCategories();

    // Featured: with discount
    var featured = products.where((p) => p.discountPercent > 0).toList();
    featured.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    var top = products.toList()..sort((a, b) => b.rating.compareTo(a.rating));

    setState(() {
      _allProducts = products;
      _featured = featured.take(6).toList();
      _topRated = top.take(6).toList();
      _categories = categories;
      _isLoading = false;
    });

    // Update counters
    final cartRepo = context.read<CartRepositoryImpl>();
    final count = await cartRepo.getCartCount();
    if (mounted) context.read<CartCounterProvider>().updateCount(count);

    final favRepo = context.read<FavoriteRepositoryImpl>();
    final favs = await favRepo.getFavorites();
    if (mounted) context.read<FavoritesCounterProvider>().updateCount(favs.length);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TEXORA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1)),
                Text('Tech Marketplace', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ComparisonPage()));
            },
            icon: const Icon(Icons.compare_arrows_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  BannerSkeleton(),
                  SizedBox(height: 16),
                  ProductGridSkeleton(count: 4),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BannerSlider(),
                    const SizedBox(height: 12),

                    // Quick actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _QuickAction(
                            icon: Icons.computer_rounded,
                            label: 'PC Yig\'ish',
                            color: AppColors.primary,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PcBuilderPage())),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.smart_toy_rounded,
                            label: 'TEXORA AI',
                            color: AppColors.secondary,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TexoraAiPage())),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.local_offer_rounded,
                            label: 'Chegirmalar',
                            color: AppColors.accent,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogPage(initialFilter: 'discount'))),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.category_rounded,
                            label: 'Katalog',
                            color: AppColors.success,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogPage())),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kategoriyalar', style: AppTextStyles.h3.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogPage())),
                            child: const Text('Barchasi'),
                          ),
                        ],
                      ),
                    ),
                    CategoryGrid(categories: _categories),

                    const SizedBox(height: 20),

                    // Featured
                    if (_featured.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('🔥 Chegirmadagi mahsulotlar', style: AppTextStyles.h3.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 280,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: _featured.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final product = _featured[i];
                            return SizedBox(
                              width: 180,
                              child: FutureBuilder<bool>(
                                future: context.read<FavoriteRepositoryImpl>().isFavorite(product.id),
                                builder: (ctx, snap) {
                                  final isFav = snap.data ?? false;
                                  return ProductCard(
                                    product: product,
                                    isFavorite: isFav,
                                    onTap: () => _openProduct(product),
                                    onFavoriteTap: () => _toggleFavorite(product),
                                    onAddToCart: () => _addToCart(product),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Top rated
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('⭐ Mashhur mahsulotlar', style: AppTextStyles.h3.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _topRated.length,
                        itemBuilder: (_, i) {
                          final product = _topRated[i];
                          return FutureBuilder<bool>(
                            future: context.read<FavoriteRepositoryImpl>().isFavorite(product.id),
                            builder: (ctx, snap) {
                              final isFav = snap.data ?? false;
                              return ProductCard(
                                product: product,
                                isFavorite: isFav,
                                onTap: () => _openProduct(product),
                                onFavoriteTap: () => _toggleFavorite(product),
                                onAddToCart: () => _addToCart(product),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Info cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.offline_bolt_rounded, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  Text('Offline ishlaydi', style: AppTextStyles.h5.copyWith(color: AppColors.primary)),
                                  const SizedBox(height: 4),
                                  const Text('Internet bo\'lmasa ham barcha funksiyalar ishlaydi', style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.success.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: AppColors.success),
                                  const SizedBox(height: 8),
                                  Text('Kafolat bor', style: AppTextStyles.h5.copyWith(color: AppColors.success)),
                                  const SizedBox(height: 4),
                                  const Text('Barcha mahsulotlarga rasmiy kafolat', style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _openProduct(ProductModel product) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
  }

  Future<void> _toggleFavorite(ProductModel product) async {
    final repo = context.read<FavoriteRepositoryImpl>();
    await repo.toggleFavorite(product.id);
    final favs = await repo.getFavorites();
    if (mounted) context.read<FavoritesCounterProvider>().updateCount(favs.length);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(await repo.isFavorite(product.id) ? 'Sevimlilarga qo\'shildi' : 'Sevimlilardan olib tashlandi'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _addToCart(ProductModel product) async {
    final repo = context.read<CartRepositoryImpl>();
    await repo.addToCart(product.id, 1);
    final count = await repo.getCartCount();
    if (mounted) context.read<CartCounterProvider>().updateCount(count);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} savatga qo\'shildi'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Savat', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()))),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 11), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
