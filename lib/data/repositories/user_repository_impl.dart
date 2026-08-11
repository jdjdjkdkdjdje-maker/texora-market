import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import '../../domain/repositories/product_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppKeys.prefUserId);
    if (userId == null) return null;
    return getUserById(userId);
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  @override
  Future<String> createUser({required String name, required String phone}) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.insert('users', {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar_path': null,
      'created_at': now,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.prefUserId, id);

    return id;
  }

  @override
  Future<void> updateUser(user) async {
    final u = user as UserModel;
    final db = await _dbHelper.database;
    await db.update('users', u.toMap(), where: 'id = ?', whereArgs: [u.id]);
  }

  @override
  Future<void> deleteUser(String id) async {
    final db = await _dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppKeys.prefUserId);
  }

  @override
  Future<List<AddressModel>> getAddresses(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('addresses', where: 'user_id = ?', whereArgs: [userId]);
    return maps.map((e) => AddressModel.fromMap(e)).toList();
  }

  @override
  Future<void> addAddress(address) async {
    final a = address as AddressModel;
    final db = await _dbHelper.database;
    await db.insert('addresses', a.toMap());
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    final db = await _dbHelper.database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [addressId]);
  }

  @override
  Future<void> setDefaultAddress(String addressId, String userId) async {
    final db = await _dbHelper.database;
    await db.update('addresses', {'is_default': 0}, where: 'user_id = ?', whereArgs: [userId]);
    await db.update('addresses', {'is_default': 1}, where: 'id = ?', whereArgs: [addressId]);
  }
}
