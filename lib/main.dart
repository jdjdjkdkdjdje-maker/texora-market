import 'package:flutter/material.dart';
import 'data/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  runApp(const MaterialApp(
    home: Scaffold(body: Center(child: Text('TEXORA DB Test'))),
  ));
}
