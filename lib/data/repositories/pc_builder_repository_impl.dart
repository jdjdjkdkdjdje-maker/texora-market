import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/constants/app_constants.dart';

class PcBuilderRepositoryImpl implements PcBuilderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  @override
  Future<List<ProductModel>> getProductsForType(String type) async {
    final db = await _dbHelper.database;
    final maps = await db.query('products', where: 'category = ?', whereArgs: [type], orderBy: 'price ASC');
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<List<PcBuildModel>> getSavedBuilds() async {
    final db = await _dbHelper.database;
    final maps = await db.query('pc_builds', orderBy: 'created_at DESC');
    return maps.map((e) => PcBuildModel.fromMap(e)).toList();
  }

  @override
  Future<String> saveBuild({
    required String name,
    required Map<String, String?> components,
    required int totalPrice,
  }) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    await db.insert('pc_builds', {
      'id': id,
      'name': name,
      'cpu_id': components['CPU'],
      'motherboard_id': components['Motherboard'],
      'ram_id': components['RAM'],
      'gpu_id': components['GPU'],
      'ssd_id': components['SSD'],
      'psu_id': components['PSU'],
      'case_id': components['Case'],
      'cooler_id': components['Cooler'],
      'total_price': totalPrice,
      'created_at': DateTime.now().toIso8601String(),
    });
    return id;
  }

  @override
  Future<void> deleteBuild(String buildId) async {
    final db = await _dbHelper.database;
    await db.delete('pc_builds', where: 'id = ?', whereArgs: [buildId]);
  }

  @override
  Future<Map<String, bool>> checkCompatibility(Map<String, ProductModel?> selected) async {
    Map<String, bool> result = {};
    final cpu = selected['CPU'];
    final mb = selected['Motherboard'];
    final ram = selected['RAM'];
    final gpu = selected['GPU'];
    final psu = selected['PSU'];

    // CPU - Motherboard socket check
    if (cpu != null && mb != null) {
      final cpuSocket = cpu.attributes['socket']?.toString();
      final mbSocket = mb.attributes['socket']?.toString();
      result['CPU-Motherboard'] = cpuSocket == mbSocket;
    } else {
      result['CPU-Motherboard'] = true;
    }

    // Motherboard - RAM type check
    if (mb != null && ram != null) {
      final mbRam = mb.attributes['ramType']?.toString();
      final ramType = ram.attributes['ramType']?.toString();
      result['Motherboard-RAM'] = mbRam == ramType;
    } else {
      result['Motherboard-RAM'] = true;
    }

    // PSU wattage check
    if (gpu != null && psu != null) {
      final gpuPower = gpu.attributes['power'] is int
          ? gpu.attributes['power'] as int
          : int.tryParse(gpu.attributes['power'].toString()) ?? 200;
      final psuWatt = psu.attributes['wattage'] is int
          ? psu.attributes['wattage'] as int
          : int.tryParse(psu.attributes['wattage'].toString()) ?? 500;
      // Simple rule: PSU should be at least GPU TDP + 300W
      result['GPU-PSU'] = psuWatt >= (gpuPower + 300);
    } else {
      result['GPU-PSU'] = true;
    }

    // Overall
    result['Overall'] = !result.values.contains(false);

    return result;
  }
}
