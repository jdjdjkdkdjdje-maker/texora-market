import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'product_model.dart';

class OrderModel extends Equatable {
  final String id;
  final String userId;
  final int totalPrice;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final String? addressId;
  final String paymentMethod;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    this.addressId,
    required this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, {List<OrderItemModel> items = const []}) {
    return OrderModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      totalPrice: map['total_price'] as int,
      status: map['status'] as String,
      addressId: map['address_id'] as String?,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'total_price': totalPrice,
      'status': status,
      'address_id': addressId,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, totalPrice, status];
}

class OrderItemModel extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final int priceAtPurchase;
  final ProductModel? product;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    this.product,
  });

  int get total => priceAtPurchase * quantity;

  factory OrderItemModel.fromMap(Map<String, dynamic> map, {ProductModel? product}) {
    return OrderItemModel(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      quantity: map['quantity'] as int,
      priceAtPurchase: map['price_at_purchase'] as int,
      product: product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
    };
  }

  @override
  List<Object?> get props => [id, orderId, productId];
}
