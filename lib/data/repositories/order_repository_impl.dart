import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    final db = await _dbHelper.database;
    final orderMaps = await db.query('orders', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    List<OrderModel> orders = [];
    for (var oMap in orderMaps) {
      final orderId = oMap['id'] as String;
      final itemMaps = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
      List<OrderItemModel> items = [];
      for (var iMap in itemMaps) {
        final prodMaps = await db.query('products', where: 'id = ?', whereArgs: [iMap['product_id']], limit: 1);
        ProductModel? product;
        if (prodMaps.isNotEmpty) product = ProductModel.fromMap(prodMaps.first);
        items.add(OrderItemModel.fromMap(iMap, product: product));
      }
      orders.add(OrderModel.fromMap(oMap, items: items));
    }
    return orders;
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final db = await _dbHelper.database;
    final orderMaps = await db.query('orders', where: 'id = ?', whereArgs: [orderId], limit: 1);
    if (orderMaps.isEmpty) return null;
    final itemMaps = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    List<OrderItemModel> items = [];
    for (var iMap in itemMaps) {
      final prodMaps = await db.query('products', where: 'id = ?', whereArgs: [iMap['product_id']], limit: 1);
      ProductModel? product;
      if (prodMaps.isNotEmpty) product = ProductModel.fromMap(prodMaps.first);
      items.add(OrderItemModel.fromMap(iMap, product: product));
    }
    return OrderModel.fromMap(orderMaps.first, items: items);
  }

  @override
  Future<String> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int totalPrice,
    String? addressId,
    String paymentMethod = 'cash',
  }) async {
    final db = await _dbHelper.database;
    final orderId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('orders', {
      'id': orderId,
      'user_id': userId,
      'total_price': totalPrice,
      'status': 'pending',
      'address_id': addressId,
      'payment_method': paymentMethod,
      'created_at': now,
    });

    for (var item in items) {
      await db.insert('order_items', {
        'id': _uuid.v4(),
        'order_id': orderId,
        'product_id': item['productId'],
        'quantity': item['quantity'],
        'price_at_purchase': item['price'],
      });
    }

    // Clear cart after order
    await db.delete('cart_items');

    return orderId;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await _dbHelper.database;
    await db.update('orders', {'status': status}, where: 'id = ?', whereArgs: [orderId]);
  }
}
