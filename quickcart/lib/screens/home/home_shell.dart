import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../widgets/navigation/quick_bottom_nav.dart';
import '../cart/cart_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final index = context.watch<AppStateProvider>().tabIndex;
    const pages = [
      HomeScreen(),
      CartScreen(showNav: false),
      FavoritesScreen(showNav: false),
      ProfileScreen(showNav: false),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: const QuickBottomNav(),
    );
  }
}
