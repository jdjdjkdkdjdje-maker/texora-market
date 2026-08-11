import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_text_styles.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'data/repositories/favorite_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/comparison_repository_impl.dart';
import 'data/repositories/pc_builder_repository_impl.dart';
import 'features/home/presentation/home_page.dart';
import 'features/catalog/presentation/catalog_page.dart';
import 'features/cart/presentation/cart_page.dart';
import 'features/favorites/presentation/favorites_page.dart';
import 'features/profile/presentation/profile_page.dart';
import 'core/theme/app_colors.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  runApp(const TexoraApp());
}

class TexoraApp extends StatefulWidget {
  const TexoraApp({super.key});

  @override
  State<TexoraApp> createState() => _TexoraAppState();
}

class _TexoraAppState extends State<TexoraApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductRepositoryImpl>(create: (_) => ProductRepositoryImpl()),
        Provider<CartRepositoryImpl>(create: (_) => CartRepositoryImpl()),
        Provider<FavoriteRepositoryImpl>(create: (_) => FavoriteRepositoryImpl()),
        Provider<UserRepositoryImpl>(create: (_) => UserRepositoryImpl()),
        Provider<OrderRepositoryImpl>(create: (_) => OrderRepositoryImpl()),
        Provider<ComparisonRepositoryImpl>(create: (_) => ComparisonRepositoryImpl()),
        Provider<PcBuilderRepositoryImpl>(create: (_) => PcBuilderRepositoryImpl()),
        ChangeNotifierProvider(create: (_) => CartCounterProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesCounterProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('uz', 'UZ'),
          Locale('en', 'US'),
          Locale('ru', 'RU'),
        ],
        home: AppInitializer(toggleTheme: _toggleTheme, currentTheme: _themeMode),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;
  final ThemeMode currentTheme;
  const AppInitializer({super.key, required this.toggleTheme, required this.currentTheme});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  String _loadingText = AppStrings.splashLoading;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Splash -> DB init -> Seed check -> Load local data -> Check user -> Home
    setState(() => _loadingText = AppStrings.dbInit);
    await Future.delayed(const Duration(milliseconds: 600));
    final dbHelper = DatabaseHelper();
    await dbHelper.database;

    setState(() => _loadingText = AppStrings.seedCheck);
    await Future.delayed(const Duration(milliseconds: 500));
    final count = await dbHelper.getProductsCount();
    // Ensure products exist
    if (count == 0) {
      // Seed already done in onCreate, but handle edge
    }

    setState(() => _loadingText = 'Ma\'lumotlar yuklanmoqda...');
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'T',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TEXORA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Professional Tech Marketplace',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      const SizedBox(height: 16),
                      Text(
                        _loadingText,
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MainNavigation(toggleTheme: widget.toggleTheme, currentTheme: widget.currentTheme);
  }
}

class MainNavigation extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;
  final ThemeMode currentTheme;
  const MainNavigation({super.key, required this.toggleTheme, required this.currentTheme});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(toggleTheme: widget.toggleTheme, currentTheme: widget.currentTheme),
      const CatalogPage(),
      const CartPage(),
      const FavoritesPage(),
      ProfilePage(toggleTheme: widget.toggleTheme, currentTheme: widget.currentTheme),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        height: 72,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Bosh sahifa'),
          const NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category_rounded), label: 'Katalog'),
          NavigationDestination(
            icon: Badge(
              label: Consumer<CartCounterProvider>(builder: (_, p, __) => Text('${p.count}')),
              isLabelVisible: context.watch<CartCounterProvider>().count > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Consumer<CartCounterProvider>(builder: (_, p, __) => Text('${p.count}')),
              isLabelVisible: context.watch<CartCounterProvider>().count > 0,
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Savat',
          ),
          NavigationDestination(
            icon: Badge(
              label: Consumer<FavoritesCounterProvider>(builder: (_, p, __) => Text('${p.count}')),
              isLabelVisible: context.watch<FavoritesCounterProvider>().count > 0,
              child: const Icon(Icons.favorite_border_rounded),
            ),
            selectedIcon: Badge(
              label: Consumer<FavoritesCounterProvider>(builder: (_, p, __) => Text('${p.count}')),
              isLabelVisible: context.watch<FavoritesCounterProvider>().count > 0,
              child: const Icon(Icons.favorite_rounded),
            ),
            label: 'Sevimlilar',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}

class CartCounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void updateCount(int c) {
    _count = c;
    notifyListeners();
  }
}

class FavoritesCounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void updateCount(int c) {
    _count = c;
    notifyListeners();
  }
}
