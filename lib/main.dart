import 'package:flutter/material.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/product_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  final repo = ProductRepositoryImpl();
  final products = await repo.getAllProducts();
  runApp(MaterialApp(
    home: Scaffold(body: Center(child: Text('TEXORA ${products.length} products'))),
  ));
}
