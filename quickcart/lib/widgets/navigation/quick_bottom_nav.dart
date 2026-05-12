import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/app_state_provider.dart';

class QuickBottomNav extends StatelessWidget {
  const QuickBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<AppStateProvider>().tabIndex;
    return NavigationBar(
      height: 62.h,
      backgroundColor: Colors.white,
      elevation: 8,
      indicatorColor: AppColors.primary.withValues(alpha: 0.1),
      selectedIndex: selected,
      onDestinationSelected: context.read<AppStateProvider>().setTab,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
        NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Saved'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
