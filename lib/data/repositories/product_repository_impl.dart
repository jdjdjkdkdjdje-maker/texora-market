import '../database/database_helper.dart';
import '../models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final db = await _dbHelper.database;
    final maps = await db.query('products', orderBy: 'created_at DESC');
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final db = await _dbHelper.database;
    final maps = await db.query('products', where: 'category = ?', whereArgs: [category], orderBy: 'rating DESC');
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.trim().isEmpty) return getAllProducts();
    final db = await _dbHelper.database;
    final q = '%${query.trim()}%';
    final maps = await db.query(
      'products',
      where: 'name LIKE ? OR description LIKE ? OR brand LIKE ? OR category LIKE ?',
      whereArgs: [q, q, q, q],
      orderBy: 'rating DESC',
    );
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<List<ProductModel>> filterProducts({
    String? category,
    String? brand,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
    bool? inStock,
  }) async {
    final db = await _dbHelper.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }
    if (brand != null && brand.isNotEmpty) {
      whereClauses.add('brand = ?');
      whereArgs.add(brand);
    }
    if (minPrice != null) {
      whereClauses.add('price >= ?');
      whereArgs.add(minPrice);
    }
    if (maxPrice != null) {
      whereClauses.add('price <= ?');
      whereArgs.add(maxPrice);
    }
    if (inStock == true) {
      whereClauses.add('stock > 0');
    }

    String orderBy = 'created_at DESC';
    if (sortBy != null) {
      switch (sortBy) {
        case 'price_asc':
          orderBy = 'price ASC';
          break;
        case 'price_desc':
          orderBy = 'price DESC';
          break;
        case 'rating':
          orderBy = 'rating DESC';
          break;
        case 'name':
          orderBy = 'name ASC';
          break;
        default:
          orderBy = 'created_at DESC';
      }
    }

    final maps = await db.query(
      'products',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy,
    );
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  @override
  Future<List<String>> getCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories');
    return maps.map((e) => e['name'] as String).toList();
  }

  @override
  Future<List<String>> getBrands() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT DISTINCT brand FROM products ORDER BY brand ASC');
    return result.map((e) => e['brand'] as String).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await _dbHelper.database;
    final placeholders = ids.map((_) => '?').join(',');
    final maps = await db.query('products', where: 'id IN ($placeholders)', whereArgs: ids);
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<List<ProductModel>> getRecommendedProducts(String productId) async {
    final db = await _dbHelper.database;
    final product = await getProductById(productId);
    if (product == null) return [];
    final maps = await db.query(
      'products',
      where: 'category = ? AND id != ?',
      whereArgs: [product.category, productId],
      orderBy: 'rating DESC',
      limit: 6,
    );
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }
}
