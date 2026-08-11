import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/cart_repository_impl.dart';
import '../../../data/repositories/favorite_repository_impl.dart';
import '../../../main.dart';
import '../../product/presentation/product_detail_page.dart';
import '../../search/presentation/search_page.dart';

class CatalogPage extends StatefulWidget {
  final String? initialFilter;
  const CatalogPage({super.key, this.initialFilter});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  bool _isLoading = true;
  List<ProductModel> _products = [];
  List<ProductModel> _filtered = [];
  List<String> _categories = [];
  List<String> _brands = [];

  String? _selectedCategory;
  String? _selectedBrand;
  String? _sortBy = 'rating';
  RangeValues _priceRange = const RangeValues(0, 26000000);
  bool _inStockOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = context.read<ProductRepositoryImpl>();
    final products = await repo.getAllProducts();
    final cats = await repo.getCategories();
    final brands = await repo.getBrands();

    setState(() {
      _products = products;
      _filtered = _applyFilters(products);
      _categories = cats;
      _brands = brands;
      _isLoading = false;
    });

    if (widget.initialFilter == 'discount') {
      setState(() {
        _filtered = products.where((p) => p.discountPercent > 0).toList();
      });
    }
  }

  List<ProductModel> _applyFilters(List<ProductModel> list) {
    var filtered = list.where((p) {
      if (_selectedCategory != null && p.category != _selectedCategory) return false;
      if (_selectedBrand != null && p.brand != _selectedBrand) return false;
      if (p.price < _priceRange.start || p.price > _priceRange.end) return false;
      if (_inStockOnly && p.stock <= 0) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  void _updateFilters() {
    setState(() {
      _filtered = _applyFilters(_products);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ChoiceChip(
                  label: const Text('Barchasi'),
                  selected: _selectedCategory == null,
                  onSelected: (v) {
                    if (v) {
                      setState(() => _selectedCategory = null);
                      _updateFilters();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ..._categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
                      onSelected: (v) {
                        setState(() => _selectedCategory = v ? cat : null);
                        _updateFilters();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sort and count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_filtered.length} ta mahsulot', style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'rating', child: Text('Reyting')),
                    DropdownMenuItem(value: 'price_asc', child: Text('Arzon avval')),
                    DropdownMenuItem(value: 'price_desc', child: Text('Qimmat avval')),
                    DropdownMenuItem(value: 'name', child: Text('Nom bo\'yicha')),
                  ],
                  onChanged: (v) {
                    setState(() => _sortBy = v);
                    _updateFilters();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(16), child: ProductGridSkeleton())
                : _filtered.isEmpty
                    ? const EmptyState(icon: Icons.category_outlined, title: 'Mahsulot topilmadi', subtitle: 'Filterlarni o\'zgartirib ko\'ring')
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final product = _filtered[i];
                          return FutureBuilder<bool>(
                            future: context.read<FavoriteRepositoryImpl>().isFavorite(product.id),
                            builder: (ctx, snap) {
                              return ProductCard(
                                product: product,
                                isFavorite: snap.data ?? false,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
                                onFavoriteTap: () async {
                                  final repo = context.read<FavoriteRepositoryImpl>();
                                  await repo.toggleFavorite(product.id);
                                  final favs = await repo.getFavorites();
                                  if (mounted) context.read<FavoritesCounterProvider>().updateCount(favs.length);
                                  setState(() {});
                                },
                                onAddToCart: () async {
                                  final repo = context.read<CartRepositoryImpl>();
                                  await repo.addToCart(product.id, 1);
                                  final count = await repo.getCartCount();
                                  if (mounted) context.read<CartCounterProvider>().updateCount(count);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} savatga qo\'shildi')));
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    const Text('Filterlar', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    const Text('Brend', style: AppTextStyles.h5),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Barchasi'),
                          selected: _selectedBrand == null,
                          onSelected: (v) {
                            if (v) {
                              setModalState(() => _selectedBrand = null);
                              setState(() => _selectedBrand = null);
                              _updateFilters();
                            }
                          },
                        ),
                        ..._brands.map(
                          (b) => ChoiceChip(
                            label: Text(b),
                            selected: _selectedBrand == b,
                            onSelected: (v) {
                              setModalState(() => _selectedBrand = v ? b : null);
                              setState(() => _selectedBrand = v ? b : null);
                              _updateFilters();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Narx oralig\'i', style: AppTextStyles.h5),
                    RangeSlider(
                      min: 0,
                      max: 26000000,
                      divisions: 26,
                      labels: RangeLabels('${(_priceRange.start / 1000000).toStringAsFixed(1)}M', '${(_priceRange.end / 1000000).toStringAsFixed(1)}M'),
                      values: _priceRange,
                      onChanged: (v) {
                        setModalState(() => _priceRange = v);
                      },
                      onChangeEnd: (v) {
                        setState(() => _priceRange = v);
                        _updateFilters();
                      },
                    ),
                    Text('${(_priceRange.start / 1000000).toStringAsFixed(1)} mln - ${(_priceRange.end / 1000000).toStringAsFixed(1)} mln so\'m'),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Faqat mavjudlari'),
                      value: _inStockOnly,
                      onChanged: (v) {
                        setModalState(() => _inStockOnly = v);
                        setState(() => _inStockOnly = v);
                        _updateFilters();
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _selectedBrand = null;
                            _priceRange = const RangeValues(0, 26000000);
                            _inStockOnly = false;
                            _searchQuery = '';
                          });
                          _updateFilters();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Tozalash'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
