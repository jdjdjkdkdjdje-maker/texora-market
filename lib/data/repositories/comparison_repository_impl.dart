import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/product_model.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/constants/app_constants.dart';

class ComparisonRepositoryImpl implements ComparisonRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  @override
  Future<List<ProductModel>> getComparisonProducts() async {
    final db = await _dbHelper.database;
    final compMaps = await db.query('comparison', orderBy: 'added_at DESC');
    List<ProductModel> list = [];
    for (var c in compMaps) {
      final pid = c['product_id'] as String;
      final pMaps = await db.query('products', where: 'id = ?', whereArgs: [pid], limit: 1);
      if (pMaps.isNotEmpty) list.add(ProductModel.fromMap(pMaps.first));
    }
    return list;
  }

  @override
  Future<void> addToComparison(String productId) async {
    final count = await getComparisonCount();
    if (count >= AppConstants.maxComparisonItems) {
      throw Exception('Maksimum ${AppConstants.maxComparisonItems} ta mahsulot taqqoslash mumkin');
    }
    final db = await _dbHelper.database;
    await db.insert('comparison', {
      'id': _uuid.v4(),
      'product_id': productId,
      'added_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeFromComparison(String productId) async {
    final db = await _dbHelper.database;
    await db.delete('comparison', where: 'product_id = ?', whereArgs: [productId]);
  }

  @override
  Future<void> clearComparison() async {
    final db = await _dbHelper.database;
    await db.delete('comparison');
  }

  @override
  Future<bool> isInComparison(String productId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('comparison', where: 'product_id = ?', whereArgs: [productId], limit: 1);
    return maps.isNotEmpty;
  }

  @override
  Future<int> getComparisonCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM comparison');
    return result.first['cnt'] as int? ?? 0;
  }
}
