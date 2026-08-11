import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/cart_repository_impl.dart';
import '../../../data/models/cart_model.dart';
import '../../../main.dart';
import '../../checkout/presentation/checkout_page.dart';
import '../../product/presentation/product_detail_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;
  List<CartItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final repo = context.read<CartRepositoryImpl>();
    final items = await repo.getCartItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
    final count = await repo.getCartCount();
    if (mounted) context.read<CartCounterProvider>().updateCount(count);
  }

  int get _totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savat'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () async {
                final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Savatni tozalash'), content: const Text('Barcha mahsulotlar o\'chiriladimi?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ha'))]));
                if (confirm == true) {
                  await context.read<CartRepositoryImpl>().clearCart();
                  await _load();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Padding(padding: EdgeInsets.all(16), child: ListSkeleton())
          : _items.isEmpty
              ? EmptyCart(onBrowse: () => DefaultTabController.of(context)?.animateTo(0))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final item = _items[i];
                          final product = item.product;
                          if (product == null) return const SizedBox();
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(_iconForCategory(product.category), size: 32, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(product.brand, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                                      const SizedBox(height: 6),
                                      Text(product.price.toPrice, style: AppTextStyles.priceMedium.copyWith(color: AppColors.primary, fontSize: 14)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              await context.read<CartRepositoryImpl>().updateQuantity(item.id, item.quantity - 1);
                                              await _load();
                                            },
                                            child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.remove_rounded, size: 16)),
                                          ),
                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${item.quantity}', style: AppTextStyles.h5)),
                                          InkWell(
                                            onTap: () async {
                                              await context.read<CartRepositoryImpl>().updateQuantity(item.id, item.quantity + 1);
                                              await _load();
                                            },
                                            child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_rounded, size: 16)),
                                          ),
                                          const Spacer(),
                                          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error), onPressed: () async { await context.read<CartRepositoryImpl>().removeFromCart(item.id); await _load(); }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight, border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight))),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Mahsulotlar (${_items.length})', style: AppTextStyles.bodyMedium), Text(_totalPrice.toPrice, style: AppTextStyles.bodyMedium)]),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Yetkazib berish', style: AppTextStyles.bodyMedium), Text('Bepul', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success))]),
                            const Divider(height: 24),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Jami:', style: AppTextStyles.h3), Text(_totalPrice.toPrice, style: AppTextStyles.priceLarge.copyWith(color: AppColors.primary))]),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage(totalPrice: _totalPrice, items: _items))),
                                child: const Text('Buyurtma berish'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'CPU':
        return Icons.memory_rounded;
      case 'GPU':
        return Icons.videogame_asset_rounded;
      case 'RAM':
        return Icons.sd_storage_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
