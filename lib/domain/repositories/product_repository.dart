import '../../data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getAllProducts();
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> filterProducts({
    String? category,
    String? brand,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
    bool? inStock,
  });
  Future<ProductModel?> getProductById(String id);
  Future<List<String>> getCategories();
  Future<List<String>> getBrands();
  Future<List<ProductModel>> getProductsByIds(List<String> ids);
  Future<List<ProductModel>> getRecommendedProducts(String productId);
}

abstract class CartRepository {
  Future<List<dynamic>> getCartItems(); // CartItemModel with product
  Future<void> addToCart(String productId, int quantity);
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> clearCart();
  Future<int> getCartTotalPrice();
  Future<int> getCartCount();
}

abstract class FavoriteRepository {
  Future<List<ProductModel>> getFavorites();
  Future<bool> isFavorite(String productId);
  Future<void> toggleFavorite(String productId);
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
  Future<void> clearFavorites();
}

abstract class OrderRepository {
  Future<List<dynamic>> getOrders(String userId);
  Future<dynamic> getOrderById(String orderId);
  Future<String> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int totalPrice,
    String? addressId,
    String paymentMethod = 'cash',
  });
  Future<void> updateOrderStatus(String orderId, String status);
}

abstract class UserRepository {
  Future<dynamic> getCurrentUser();
  Future<dynamic> getUserById(String id);
  Future<String> createUser({required String name, required String phone});
  Future<void> updateUser(dynamic user);
  Future<void> deleteUser(String id);
  Future<List<dynamic>> getAddresses(String userId);
  Future<void> addAddress(dynamic address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId, String userId);
}

abstract class ComparisonRepository {
  Future<List<ProductModel>> getComparisonProducts();
  Future<void> addToComparison(String productId);
  Future<void> removeFromComparison(String productId);
  Future<void> clearComparison();
  Future<bool> isInComparison(String productId);
  Future<int> getComparisonCount();
}

abstract class PcBuilderRepository {
  Future<List<ProductModel>> getProductsForType(String type);
  Future<List<dynamic>> getSavedBuilds();
  Future<String> saveBuild({
    required String name,
    required Map<String, String?> components,
    required int totalPrice,
  });
  Future<void> deleteBuild(String buildId);
  Future<Map<String, bool>> checkCompatibility(Map<String, ProductModel?> selected);
}
