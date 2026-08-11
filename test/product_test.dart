import 'package:flutter_test/flutter_test.dart';
import 'package:texora_market/data/models/product_model.dart';

void main() {
  group('Product Model', () {
    test('discount calculation', () {
      final product = ProductModel(
        id: '1',
        name: 'Test CPU',
        description: 'Desc',
        category: 'CPU',
        brand: 'Intel',
        price: 1000000,
        oldPrice: 1200000,
        specsJson: '{}',
        stock: 10,
        rating: 4.5,
        reviewCount: 10,
        imagePath: '',
        images: [],
        attributes: {},
        createdAt: DateTime.now(),
      );
      expect(product.discountPercent, 17);
    });

    test('toMap and fromMap', () {
      final now = DateTime.now();
      final product = ProductModel(
        id: 'test-id',
        name: 'RTX 4060',
        description: 'Gaming GPU',
        category: 'GPU',
        brand: 'MSI',
        price: 4850000,
        oldPrice: 5200000,
        specsJson: '{"vram":"8GB"}',
        stock: 12,
        rating: 4.7,
        reviewCount: 68,
        imagePath: 'assets/images/products/gpu-4060.png',
        images: ['assets/images/products/gpu-4060.png'],
        attributes: {'power': 115},
        createdAt: now,
      );

      final map = product.toMap();
      final restored = ProductModel.fromMap(map);

      expect(restored.id, product.id);
      expect(restored.price, product.price);
      expect(restored.name, product.name);
    });
  });
}
