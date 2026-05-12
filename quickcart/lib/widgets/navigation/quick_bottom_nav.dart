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
    final cartCount = context.watch<AppStateProvider>().cartItemCount;
    return NavigationBar(
      height: 62.h,
      backgroundColor: Colors.white,
      elevation: 8,
      indicatorColor: AppColors.primary.withValues(alpha: 0.1),
      selectedIndex: selected,
      onDestinationSelected: context.read<AppStateProvider>().setTab,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: _CartNavIcon(
            count: cartCount,
            icon: Icons.shopping_cart_outlined,
          ),
          selectedIcon: _CartNavIcon(
            count: cartCount,
            icon: Icons.shopping_cart,
          ),
          label: 'Cart',
        ),
        const NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Saved',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  const _CartNavIcon({required this.count, required this.icon});

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8.w,
            top: -7.h,
            child: Container(
              constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.white, width: 1.3),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
