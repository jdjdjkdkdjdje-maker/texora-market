import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/cart_repository_impl.dart';
import '../../../data/repositories/favorite_repository_impl.dart';
import '../../../main.dart';
import '../../product/presentation/product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<ProductModel> _results = [];
  bool _isLoading = false;
  String _lastQuery = '';

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _lastQuery = '';
      });
      return;
    }
    setState(() => _isLoading = true);
    final repo = context.read<ProductRepositoryImpl>();
    final results = await repo.searchProducts(query);
    setState(() {
      _results = results;
      _lastQuery = query;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Qidirish... masalan RTX 4060',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                _search('');
              },
            ),
          ),
          onChanged: (v) => _search(v),
          onSubmitted: (v) => _search(v),
        ),
      ),
      body: _isLoading
          ? const Padding(padding: EdgeInsets.all(16), child: ProductGridSkeleton())
          : _controller.text.isEmpty
              ? const EmptyState(icon: Icons.search_rounded, title: 'Mahsulot qidirish', subtitle: 'Nom, brend yoki kategoriya bo\'yicha qidiring')
              : _results.isEmpty
                  ? EmptySearch(query: _lastQuery)
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final product = _results[i];
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
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} savatga qo\'shildi')));
                              },
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
