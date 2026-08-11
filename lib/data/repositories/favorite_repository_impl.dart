import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  @override
  Future<List<ProductModel>> getFavorites() async {
    final db = await _dbHelper.database;
    final favMaps = await db.query('favorites', orderBy: 'added_at DESC');
    List<ProductModel> products = [];
    for (var fav in favMaps) {
      final productId = fav['product_id'] as String;
      final productMaps = await db.query('products', where: 'id = ?', whereArgs: [productId], limit: 1);
      if (productMaps.isNotEmpty) {
        products.add(ProductModel.fromMap(productMaps.first));
      }
    }
    return products;
  }

  @override
  Future<bool> isFavorite(String productId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('favorites', where: 'product_id = ?', whereArgs: [productId], limit: 1);
    return maps.isNotEmpty;
  }

  @override
  Future<void> addFavorite(String productId) async {
    final db = await _dbHelper.database;
    await db.insert('favorites', {
      'id': _uuid.v4(),
      'product_id': productId,
      'added_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeFavorite(String productId) async {
    final db = await _dbHelper.database;
    await db.delete('favorites', where: 'product_id = ?', whereArgs: [productId]);
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    final fav = await isFavorite(productId);
    if (fav) {
      await removeFavorite(productId);
    } else {
      await addFavorite(productId);
    }
  }

  @override
  Future<void> clearFavorites() async {
    final db = await _dbHelper.database;
    await db.delete('favorites');
  }
}
