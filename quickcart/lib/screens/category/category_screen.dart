import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../models/product.dart';
import '../../widgets/common/promo_banner.dart';
import '../../widgets/common/quick_search_field.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/product/product_card.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const routeName = '/category';

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments as String?;
    final category = arg ?? 'fruits';
    final products = DummyData.byCategory(category).isEmpty ? DummyData.products : DummyData.byCategory(category);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _CategoryHeader(title: _label(category))),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
                child: const QuickSearchField(hint: 'Search fruits...'),
              ),
            ),
            SliverToBoxAdapter(child: _FilterChips()),
            const SliverToBoxAdapter(
              child: PromoBanner(title: 'Tropical Fruits\nBuy 2 Get 1 Free', subtitle: 'This week only!', icon: Icons.local_florist),
            ),
            const SliverToBoxAdapter(child: SectionHeader(title: 'Featured')),
            SliverToBoxAdapter(child: _FeaturedList(products: products)),
            const SliverToBoxAdapter(child: SectionHeader(title: 'All Fruits', action: null)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 20.h),
              sliver: SliverGrid.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 520 ? 3 : 2,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (_, index) => ProductCard(product: products[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(String value) => value[0].toUpperCase() + value.substring(1);
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 22.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      child: Row(
        children: [
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: 8.w),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900)),
          const Spacer(),
          const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Tropical', 'Organic', 'On Sale'];
    return SizedBox(
      height: 56.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (_, index) => Chip(
          label: Text(filters[index]),
          backgroundColor: index == 0 ? AppColors.primary : Colors.white,
          labelStyle: TextStyle(color: index == 0 ? Colors.white : AppColors.textDark, fontSize: 11.sp, fontWeight: FontWeight.w700),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

class _FeaturedList extends StatelessWidget {
  const _FeaturedList({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        scrollDirection: Axis.horizontal,
        itemCount: products.take(3).length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (_, index) => SizedBox(
          width: 132.w,
          child: ProductCard(product: products[index], compact: true, heroEnabled: false),
        ),
      ),
    );
  }
}
