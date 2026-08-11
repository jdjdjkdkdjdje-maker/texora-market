import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/product_card.dart';
import '../../../data/repositories/favorite_repository_impl.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/cart_repository_impl.dart';
import '../../../main.dart';
import '../../product/presentation/product_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = true;
  List<ProductModel> _favorites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final repo = context.read<FavoriteRepositoryImpl>();
    final favs = await repo.getFavorites();
    setState(() {
      _favorites = favs;
      _isLoading = false;
    });
    if (mounted) context.read<FavoritesCounterProvider>().updateCount(favs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevimlilar'),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () async {
                await context.read<FavoriteRepositoryImpl>().clearFavorites();
                await _load();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Padding(padding: EdgeInsets.all(16), child: ProductGridSkeleton())
          : _favorites.isEmpty
              ? const EmptyFavorites()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: _favorites.length,
                    itemBuilder: (_, i) {
                      final product = _favorites[i];
                      return ProductCard(
                        product: product,
                        isFavorite: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))).then((_) => _load()),
                        onFavoriteTap: () async {
                          await context.read<FavoriteRepositoryImpl>().removeFavorite(product.id);
                          await _load();
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
                  ),
                ),
    );
  }
}
