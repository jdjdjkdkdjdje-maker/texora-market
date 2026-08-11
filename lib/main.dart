import 'package:flutter/material.dart';
import 'data/database/database_helper.dart';
import 'features/home/presentation/home_page.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'data/repositories/favorite_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/comparison_repository_impl.dart';
import 'data/repositories/pc_builder_repository_impl.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_colors.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  runApp(const TexoraApp());
}

class TexoraApp extends StatelessWidget {
  const TexoraApp({super.key});
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
        title: 'TEXORA',
        theme: AppTheme.lightTheme,
        home: HomePage(toggleTheme: (m){}, currentTheme: ThemeMode.system),
      ),
    );
  }
}

class CartCounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  void updateCount(int c) {_count=c; notifyListeners();}
}
class FavoritesCounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  void updateCount(int c) {_count=c; notifyListeners();}
}
