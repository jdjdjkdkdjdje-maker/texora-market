import 'package:flutter_test/flutter_test.dart';
import 'package:texora_market/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('price formatting', () {
      expect(AppFormatters.formatPrice(1000000), '1 000 000 so\'m');
      expect(AppFormatters.formatPrice(2850000), '2 850 000 so\'m');
    });

    test('compact price', () {
      expect(AppFormatters.formatPriceCompact(1500000), '1.5 mln');
      expect(AppFormatters.formatPriceCompact(500000), '500 ming');
    });
  });

  group('Search and Filter', () {
    test('search logic case insensitive', () {
      String query = 'rtx';
      List<String> products = ['RTX 4060 Gaming', 'Ryzen 5 7600', 'Samsung SSD'];
      var filtered = products.where((p) => p.toLowerCase().contains(query.toLowerCase())).toList();
      expect(filtered.length, 1);
      expect(filtered.first, 'RTX 4060 Gaming');
    });

    test('filter by price range', () {
      List<int> prices = [1000000, 2000000, 3000000, 4000000];
      int min = 1500000;
      int max = 3500000;
      var filtered = prices.where((p) => p >= min && p <= max).toList();
      expect(filtered, [2000000, 3000000]);
    });
  });

  group('Order', () {
    test('order total calculation', () {
      List<Map<String, dynamic>> items = [
        {'price': 2000000, 'quantity': 2},
        {'price': 1000000, 'quantity': 1},
      ];
      int total = items.fold(0, (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int));
      expect(total, 5000000);
    });
  });
}
