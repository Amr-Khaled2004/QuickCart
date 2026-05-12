import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/common/promo_banner.dart';
import '../../widgets/common/quick_search_field.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/navigation/quick_bottom_nav.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/product_list_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.showNav = true});

  static const routeName = '/favorites';
  final bool showNav;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppStateProvider>().favoriteProducts;
    return Scaffold(
      bottomNavigationBar: showNav ? const QuickBottomNav() : null,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _FavoritesHeader(count: favorites.length)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 8.h),
                child: const QuickSearchField(hint: 'Search favorites...'),
              ),
            ),
            SliverList.builder(
              itemCount: favorites.length,
              itemBuilder: (_, index) => ProductListTile(product: favorites[index], showFavorite: true),
            ),
            const SliverToBoxAdapter(child: SectionHeader(title: 'Recently Viewed', action: null)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 182.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) => ProductCard(product: DummyData.products[index + 1], compact: true),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 14.h)),
            const SliverToBoxAdapter(
              child: PromoBanner(title: 'New Chocolate Bars\nJust Dropped!', subtitle: 'Grab now at a huge discount', icon: Icons.cookie),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Favorites', style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
              Text('Saved Items', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900)),
            ],
          ),
          const Spacer(),
          Chip(label: Text('$count items'), backgroundColor: AppColors.accent, labelStyle: const TextStyle(color: Colors.white)),
          SizedBox(width: 8.w),
          const Icon(Icons.filter_alt_outlined, color: Colors.white),
        ],
      ),
    );
  }
}
