import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/common/cart_icon_button.dart';
import '../../widgets/common/promo_banner.dart';
import '../../widgets/common/quick_search_field.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/product/product_card.dart';
import '../home/home_shell.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  static const routeName = '/category';

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _query = '';

  void _openCart() {
    context.read<AppStateProvider>().setTab(1);
    Navigator.popUntil(context, ModalRoute.withName(HomeShell.routeName));
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments as String?;
    final category = arg ?? 'fruits';
    final allProducts = context.select<AppStateProvider, List<Product>>(
      (provider) => provider.products,
    );
    final baseProducts = category == 'all' || category == 'organic'
        ? allProducts
        : allProducts.where((product) => product.category == category).toList();
    final query = _query.toLowerCase();
    final products = baseProducts.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesSearch;
    }).toList();
    final featuredProducts = products
        .where((product) => product.discount > 0)
        .toList();
    final banner = _bannerFor(category);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _CategoryHeader(
                title: _label(category),
                onCartTap: _openCart,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
                child: QuickSearchField(
                  hint: 'Search ${_label(category).toLowerCase()}...',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
                child: PromoBanner(
                  title: banner.title,
                  subtitle: banner.subtitle,
                  icon: banner.icon,
                  margin: EdgeInsets.zero,
                  onTap: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Featured',
                onActionTap: () => setState(() {
                  _query = '';
                }),
              ),
            ),
            SliverToBoxAdapter(
              child: _FeaturedList(products: featuredProducts),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'All ${_label(category)}',
                action: null,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 20.h),
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

  String _label(String value) {
    if (value == 'all') return 'Products';
    if (value == 'organic') return 'Organic';
    return value[0].toUpperCase() + value.substring(1);
  }

  _CategoryBannerInfo _bannerFor(String category) {
    return switch (category) {
      'fruits' => const _CategoryBannerInfo(
        title: 'Tropical Fruits\nBuy 2 Get 1 Free',
        subtitle: 'Sweet picks for today only',
        icon: Icons.local_florist,
      ),
      'vegetables' => const _CategoryBannerInfo(
        title: 'Crisp Veggies\nFresh From The Farm',
        subtitle: 'Stock up on greens and roots',
        icon: Icons.eco_outlined,
      ),
      'dairy' => const _CategoryBannerInfo(
        title: 'Dairy Essentials\nCold And Creamy',
        subtitle: 'Milk, eggs, cheese, and more',
        icon: Icons.local_drink_outlined,
      ),
      'meat' => const _CategoryBannerInfo(
        title: 'Butcher Picks\nReady For Dinner',
        subtitle: 'Fresh cuts for easy meals',
        icon: Icons.set_meal_outlined,
      ),
      'bakery' => const _CategoryBannerInfo(
        title: 'Bakery Fresh\nWarm Loaves Await',
        subtitle: 'Toast, baguettes, and buttery bites',
        icon: Icons.bakery_dining_outlined,
      ),
      'snacks' => const _CategoryBannerInfo(
        title: 'New Chocolate\nJust Dropped!',
        subtitle: 'Sweet snacks for your cart',
        icon: Icons.cookie_outlined,
      ),
      _ => const _CategoryBannerInfo(
        title: 'Exclusive Deals\nFresh Finds Today',
        subtitle: 'Browse QuickCart favorites',
        icon: Icons.local_offer_outlined,
      ),
    };
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title, required this.onCartTap});

  final String title;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 22.h),
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
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          CartIconButton(onPressed: onCartTap),
        ],
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
          width: 150.w,
          child: ProductCard(
            product: products[index],
            compact: true,
            heroEnabled: false,
          ),
        ),
      ),
    );
  }
}

class _CategoryBannerInfo {
  const _CategoryBannerInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
