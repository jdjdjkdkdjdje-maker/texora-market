import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final String id;
  final String productId;
  final int quantity;
  final DateTime addedAt;
  final ProductModel? product; // populated via join

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.addedAt,
    this.product,
  });

  int get totalPrice => (product?.price ?? 0) * quantity;

  factory CartItemModel.fromMap(Map<String, dynamic> map, {ProductModel? product}) {
    return CartItemModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      quantity: map['quantity'] as int? ?? 1,
      addedAt: DateTime.tryParse(map['added_at'] as String? ?? '') ?? DateTime.now(),
      product: product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }

  CartItemModel copyWith({int? quantity, ProductModel? product}) {
    return CartItemModel(
      id: id,
      productId: productId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt,
      product: product ?? this.product,
    );
  }

  @override
  List<Object?> get props => [id, productId, quantity];
}

class PcBuildModel extends Equatable {
  final String id;
  final String name;
  final Map<String, String?> components; // type -> productId
  final int totalPrice;
  final DateTime createdAt;

  const PcBuildModel({
    required this.id,
    required this.name,
    required this.components,
    required this.totalPrice,
    required this.createdAt,
  });

  factory PcBuildModel.fromMap(Map<String, dynamic> map) {
    return PcBuildModel(
      id: map['id'] as String,
      name: map['name'] as String,
      components: {
        'CPU': map['cpu_id'] as String?,
        'Motherboard': map['motherboard_id'] as String?,
        'RAM': map['ram_id'] as String?,
        'GPU': map['gpu_id'] as String?,
        'SSD': map['ssd_id'] as String?,
        'PSU': map['psu_id'] as String?,
        'Case': map['case_id'] as String?,
        'Cooler': map['cooler_id'] as String?,
      },
      totalPrice: map['total_price'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, totalPrice];
}
