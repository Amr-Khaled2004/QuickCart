import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_colors.dart';
import 'screens/admin/admin_products_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/deals/deal_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/payment/payment_screen.dart';
import 'screens/product/product_details_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';

class QuickCartApp extends StatelessWidget {
  const QuickCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuickCart',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.card,
            ),
            scaffoldBackgroundColor: AppColors.pinkBackground,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            LoginScreen.routeName: (_) => const LoginScreen(),
            HomeShell.routeName: (_) => const HomeShell(),
            CategoryScreen.routeName: (_) => const CategoryScreen(),
            DealScreen.routeName: (_) => const DealScreen(),
            FavoritesScreen.routeName: (_) => const FavoritesScreen(),
            PaymentScreen.routeName: (_) => const PaymentScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
            CartScreen.routeName: (_) => const CartScreen(),
            AdminProductsScreen.routeName: (_) => const AdminProductsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == ProductDetailsScreen.routeName) {
              final productId = settings.arguments! as String;
              return MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(productId: productId),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
