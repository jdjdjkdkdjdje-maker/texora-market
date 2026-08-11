import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        avatar_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Addresses
    await db.execute('''
      CREATE TABLE addresses(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        full_address TEXT NOT NULL,
        extra TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Categories
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        parent_id TEXT,
        image_path TEXT
      )
    ''');

    // Brands
    await db.execute('''
      CREATE TABLE brands(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        logo_path TEXT
      )
    ''');

    // Products
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        brand TEXT NOT NULL,
        price INTEGER NOT NULL,
        old_price INTEGER,
        specs_json TEXT NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        rating REAL NOT NULL DEFAULT 0,
        review_count INTEGER NOT NULL DEFAULT 0,
        image_path TEXT NOT NULL,
        images TEXT NOT NULL DEFAULT '[]',
        attributes TEXT NOT NULL DEFAULT '{}',
        created_at TEXT NOT NULL
      )
    ''');

    // Cart
    await db.execute('''
      CREATE TABLE cart_items(
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        added_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    // Favorites
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL UNIQUE,
        added_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    // Orders
    await db.execute('''
      CREATE TABLE orders(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        total_price INTEGER NOT NULL,
        status TEXT NOT NULL,
        address_id TEXT,
        payment_method TEXT NOT NULL DEFAULT 'cash',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Order Items
    await db.execute('''
      CREATE TABLE order_items(
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price_at_purchase INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // PC Builds
    await db.execute('''
      CREATE TABLE pc_builds(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cpu_id TEXT,
        motherboard_id TEXT,
        ram_id TEXT,
        gpu_id TEXT,
        ssd_id TEXT,
        psu_id TEXT,
        case_id TEXT,
        cooler_id TEXT,
        total_price INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Comparison (temporary, stored locally)
    await db.execute('''
      CREATE TABLE comparison(
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL UNIQUE,
        added_at TEXT NOT NULL
      )
    ''');

    // Seed categories and products
    await SeedData.seedCategories(db);
    await SeedData.seedBrands(db);
    await SeedData.seedProducts(db);

    // Indexes for performance
    await db.execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_products_brand ON products(brand)');
    await db.execute('CREATE INDEX idx_products_price ON products(price)');
    await db.execute('CREATE INDEX idx_products_name ON products(name)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For future migrations
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('cart_items');
    await db.delete('favorites');
    await db.delete('order_items');
    await db.delete('orders');
    await db.delete('pc_builds');
    await db.delete('comparison');
    await db.delete('addresses');
    await db.delete('users');
  }

  Future<void> clearCache() async {
    // Clear non-essential cached data, keep products
    final db = await database;
    await db.delete('cart_items');
    await db.delete('comparison');
  }

  Future<int> getProductsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM products');
    return result.first['cnt'] as int? ?? 0;
  }
}
