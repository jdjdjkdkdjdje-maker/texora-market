class AppConstants {
  static const String appName = 'TEXORA';
  static const String appTagline = 'Professional Tech Marketplace';
  static const String dbName = 'texora_local.db';
  static const int dbVersion = 1;

  static const String currency = 'so\'m';
  static const String currencySymbol = 'UZS';

  static const List<String> categories = [
    'CPU',
    'Motherboard',
    'RAM',
    'GPU',
    'SSD',
    'PSU',
    'Case',
    'Cooler',
    'Laptop',
    'Smartphone',
    'Monitor',
    'Keyboard',
    'Mouse',
    'Headset',
  ];

  static const List<String> pcBuilderTypes = [
    'CPU',
    'Motherboard',
    'RAM',
    'GPU',
    'SSD',
    'PSU',
    'Case',
    'Cooler',
  ];

  static const int maxComparisonItems = 4;
  static const int maxCartQuantity = 10;

  // Compatibility rules simplified
  static const Map<String, List<String>> socketCompatibility = {
    'LGA1700': ['LGA1700'],
    'AM5': ['AM5'],
    'AM4': ['AM4'],
    'LGA1200': ['LGA1200'],
  };

  static const Map<String, List<String>> ramCompatibility = {
    'DDR5': ['DDR5'],
    'DDR4': ['DDR4'],
  };
}

class AppStrings {
  static const String emptyCart = 'Savatingiz hozircha bo\'sh.';
  static const String emptyCartDesc = 'Mahsulot qo\'shing va xaridni boshlang.';
  static const String emptyFavorites = 'Yoqtirgan mahsulotlaringizni shu yerga saqlang.';
  static const String emptyFavoritesDesc = 'Sevimlilar ro\'yxati bo\'sh. Yurakchani bosing.';
  static const String emptyOrders = 'Buyurtmalar yo\'q.';
  static const String emptySearch = 'Hech narsa topilmadi.';
  static const String emptyComparison = 'Taqqoslash uchun mahsulot qo\'shing.';
  static const String errorGeneral = 'Nimadir noto\'g\'ri ketdi.';
  static const String errorRetry = 'Qayta urinish';
  static const String noInternetAi = 'TEXORA AI ishlashi uchun internetga ulaning.';
  static const String offlineMode = 'Offline rejim';

  static const String splashLoading = 'TEXORA yuklanmoqda...';
  static const String dbInit = 'Ma\'lumotlar bazasi ishga tushmoqda...';
  static const String seedCheck = 'Mahsulotlar tekshirilmoqda...';
}

class AppKeys {
  static const String secureApiKey = 'texora_ai_api_key';
  static const String prefIsFirstLaunch = 'is_first_launch';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefUserId = 'current_user_id';
}
