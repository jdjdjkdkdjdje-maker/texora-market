import 'package:flutter_test/flutter_test.dart';
import 'package:texora_market/data/models/cart_model.dart';
import 'package:texora_market/data/models/product_model.dart';

void main() {
  group('Cart Logic', () {
    test('total price calculation', () {
      final product = ProductModel(
        id: 'p1',
        name: 'CPU',
        description: '',
        category: 'CPU',
        brand: 'Intel',
        price: 2000000,
        specsJson: '{}',
        stock: 5,
        rating: 4.5,
        reviewCount: 10,
        imagePath: '',
        images: [],
        attributes: {},
        createdAt: DateTime.now(),
      );

      final cartItem = CartItemModel(
        id: 'c1',
        productId: 'p1',
        quantity: 2,
        addedAt: DateTime.now(),
        product: product,
      );

      expect(cartItem.totalPrice, 4000000);
    });

    test('quantity clamping logic (1..10)', () {
      int clamp(int qty) => qty.clamp(1, 10);
      expect(clamp(0), 1);
      expect(clamp(11), 10);
      expect(clamp(5), 5);
    });
  });

  group('PC Builder Price Calculation', () {
    test('total price calculation for build', () {
      final prices = {'CPU': 3000000, 'GPU': 5000000, 'RAM': 1200000, 'SSD': 800000};
      int total = prices.values.fold(0, (sum, price) => sum + price);
      expect(total, 10000000);
    });

    test('compatibility check - socket matching', () {
      bool checkSocket(String cpuSocket, String mbSocket) => cpuSocket == mbSocket;
      expect(checkSocket('LGA1700', 'LGA1700'), true);
      expect(checkSocket('LGA1700', 'AM5'), false);
    });

    test('PSU wattage check', () {
      bool checkPsu(int gpuPower, int psuWatt) => psuWatt >= (gpuPower + 300);
      expect(checkPsu(220, 750), true);
      expect(checkPsu(450, 650), false);
    });
  });
}
