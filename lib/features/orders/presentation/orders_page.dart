import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/order_repository_impl.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/models/order_model.dart';
import '../../product/presentation/product_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _isLoading = true;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final userRepo = context.read<UserRepositoryImpl>();
    final user = await userRepo.getCurrentUser();
    if (user == null) {
      setState(() {
        _orders = [];
        _isLoading = false;
      });
      return;
    }
    final orderRepo = context.read<OrderRepositoryImpl>();
    final orders = await orderRepo.getOrders(user.id);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtmalar')),
      body: _isLoading
          ? const Padding(padding: EdgeInsets.all(16), child: ListSkeleton())
          : _orders.isEmpty
              ? const EmptyOrders()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final order = _orders[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Buyurtma #${order.id.substring(0, 8)}', style: AppTextStyles.h5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: _statusColor(order.status).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Text(_statusText(order.status), style: AppTextStyles.labelSmall.copyWith(color: _statusColor(order.status))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(AppFormatters.formatDateTime(order.createdAt), style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                            const Divider(height: 20),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item.product?.name ?? item.productId, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      Text('x${item.quantity}'),
                                      const SizedBox(width: 8),
                                      Text(AppFormatters.formatPrice(item.total), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                )),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Jami:', style: AppTextStyles.h5),
                                Text(order.totalPrice.toPrice, style: AppTextStyles.priceMedium.copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'shipped':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Kutilmoqda';
      case 'confirmed':
        return 'Tasdiqlangan';
      case 'shipped':
        return 'Yo\'lda';
      case 'delivered':
        return 'Yetkazildi';
      case 'cancelled':
        return 'Bekor qilindi';
      default:
        return status;
    }
  }
}
