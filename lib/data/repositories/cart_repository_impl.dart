import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final db = await _dbHelper.database;
    final cartMaps = await db.query('cart_items', orderBy: 'added_at DESC');
    List<CartItemModel> items = [];
    for (var map in cartMaps) {
      final productId = map['product_id'] as String;
      final productMaps = await db.query('products', where: 'id = ?', whereArgs: [productId], limit: 1);
      ProductModel? product;
      if (productMaps.isNotEmpty) {
        product = ProductModel.fromMap(productMaps.first);
      }
      items.add(CartItemModel.fromMap(map, product: product));
    }
    return items;
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    final db = await _dbHelper.database;
    final existing = await db.query('cart_items', where: 'product_id = ?', whereArgs: [productId], limit: 1);
    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      final newQty = (currentQty + quantity).clamp(1, 10);
      await db.update('cart_items', {'quantity': newQty}, where: 'product_id = ?', whereArgs: [productId]);
    } else {
      await db.insert('cart_items', {
        'id': _uuid.v4(),
        'product_id': productId,
        'quantity': quantity.clamp(1, 10),
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }
    final db = await _dbHelper.database;
    await db.update('cart_items', {'quantity': quantity.clamp(1, 10)}, where: 'id = ?', whereArgs: [cartItemId]);
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    final db = await _dbHelper.database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);
  }

  @override
  Future<void> clearCart() async {
    final db = await _dbHelper.database;
    await db.delete('cart_items');
  }

  @override
  Future<int> getCartTotalPrice() async {
    final items = await getCartItems();
    int total = 0;
    for (var item in items) {
      total += item.totalPrice;
    }
    return total;
  }

  @override
  Future<int> getCartCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(quantity) as total FROM cart_items');
    return (result.first['total'] as int?) ?? 0;
  }
}
