import 'dart:convert';
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final int price;
  final int? oldPrice;
  final String specsJson; // JSON string
  final int stock;
  final double rating;
  final int reviewCount;
  final String imagePath; // local asset path
  final List<String> images;
  final Map<String, dynamic> attributes; // socket, ramType, etc for compatibility
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    this.oldPrice,
    required this.specsJson,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    required this.imagePath,
    required this.images,
    required this.attributes,
    required this.createdAt,
  });

  int get discountPercent {
    if (oldPrice == null || oldPrice! <= price) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  Map<String, dynamic> get specs {
    try {
      return jsonDecode(specsJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      brand: map['brand'] as String,
      price: map['price'] as int,
      oldPrice: map['old_price'] as int?,
      specsJson: map['specs_json'] as String? ?? '{}',
      stock: map['stock'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] as int? ?? 0,
      imagePath: map['image_path'] as String? ?? '',
      images: _parseImages(map['images']),
      attributes: _parseAttributes(map['attributes']),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static List<String> _parseImages(dynamic raw) {
    if (raw == null) return [];
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
        return [raw];
      } catch (_) {
        return [raw];
      }
    }
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  static Map<String, dynamic> _parseAttributes(dynamic raw) {
    if (raw == null) return {};
    if (raw is String) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw as Map);
    }
    return {};
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'price': price,
      'old_price': oldPrice,
      'specs_json': specsJson,
      'stock': stock,
      'rating': rating,
      'review_count': reviewCount,
      'image_path': imagePath,
      'images': jsonEncode(images),
      'attributes': jsonEncode(attributes),
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? brand,
    int? price,
    int? oldPrice,
    String? specsJson,
    int? stock,
    double? rating,
    int? reviewCount,
    String? imagePath,
    List<String>? images,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      specsJson: specsJson ?? this.specsJson,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imagePath: imagePath ?? this.imagePath,
      images: images ?? this.images,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, category, brand, price];
}
