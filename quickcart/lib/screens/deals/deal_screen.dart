import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/product/product_card.dart';

class DealScreen extends StatelessWidget {
  const DealScreen({super.key});

  static const routeName = '/deal';

  @override
  Widget build(BuildContext context) {
    final dealId =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'all';
    final deal = _dealFor(dealId);
    final products = context
        .watch<AppStateProvider>()
        .products
        .where(deal.matches)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _DealHeader(deal: deal)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 8.h),
                child: Text(
                  deal.description,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.sp,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 22.h),
              sliver: SliverGrid.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 520
                      ? 3
                      : 2,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (_, index) =>
                    ProductCard(product: products[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _DealInfo _dealFor(String id) {
    return switch (id) {
      'fruit' => _DealInfo(
        title: 'Fresh Fruit Deal',
        subtitle: 'Up to 30% off',
        description:
            'Sweet seasonal fruit deals for quick snacks, smoothies, and lunch boxes.',
        icon: Icons.apple,
        matches: (product) => product.category == 'fruits',
      ),
      'organic' => _DealInfo(
        title: 'Organic Picks',
        subtitle: 'Delivered fast',
        description:
            'Fresh produce picks with big flavor and daily grocery value.',
        icon: Icons.eco_outlined,
        matches: (product) =>
            product.category == 'fruits' || product.category == 'vegetables',
      ),
      'chocolate' => _DealInfo(
        title: 'Chocolate Drop',
        subtitle: 'Huge discount today',
        description: 'Snack deals for a sweet cart add-on before checkout.',
        icon: Icons.cookie,
        matches: (product) => product.name.toLowerCase().contains('chocolate'),
      ),
      _ => _DealInfo(
        title: 'Exclusive Deals',
        subtitle: 'Best savings now',
        description:
            'Browse every discounted item available in QuickCart today.',
        icon: Icons.local_offer_outlined,
        matches: (product) => product.discount > 0,
      ),
    };
  }
}

class _DealHeader extends StatelessWidget {
  const _DealHeader({required this.deal});

  final _DealInfo deal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      child: Row(
        children: [
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.18),
            ),
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.subtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                ),
                Text(
                  deal.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Icon(deal.icon, color: Colors.white, size: 44.sp),
        ],
      ),
    );
  }
}

class _DealInfo {
  const _DealInfo({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.matches,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool Function(Product product) matches;
}
