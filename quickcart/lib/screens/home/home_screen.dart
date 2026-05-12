import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/common/cart_icon_button.dart';
import '../../widgets/common/promo_banner.dart';
import '../../widgets/common/quick_search_field.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/home/category_tile.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/product_list_tile.dart';
import '../category/category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;
  String _query = '';

  void _openCart() => context.read<AppStateProvider>().setTab(1);

  void _showNotifications() {
    final orderCount = context.read<AppStateProvider>().orderCount;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10.h),
            if (orderCount == 0)
              const ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text('No order notifications yet.'),
              )
            else
              const ListTile(
                leading: Icon(Icons.local_shipping_outlined),
                title: Text('Your latest grocery order is being prepared.'),
              ),
            const ListTile(
              leading: Icon(Icons.discount_outlined),
              title: Text('Fresh fruit deals are live today.'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = DummyData.products.where((product) {
      final query = _query.toLowerCase();
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
    }).toList();
    final visibleProducts = products.isEmpty ? DummyData.products : products;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              onSearchChanged: (value) => setState(() => _query = value),
              onCartTap: _openCart,
              onNotificationsTap: _showNotifications,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                CarouselSlider(
                  items: [
                    PromoBanner(
                      title: 'Fresh Fruits\nUp to 30% off',
                      subtitle: 'Limited time offer today',
                      icon: Icons.shopping_cart_outlined,
                      onTap: () => Navigator.pushNamed(
                        context,
                        CategoryScreen.routeName,
                        arguments: 'fruits',
                      ),
                    ),
                    PromoBanner(
                      title: 'Organic Picks\nDelivered Fast',
                      subtitle: 'Fresh from trusted farms',
                      icon: Icons.eco_outlined,
                      onTap: () => Navigator.pushNamed(
                        context,
                        CategoryScreen.routeName,
                        arguments: 'organic',
                      ),
                    ),
                  ],
                  options: CarouselOptions(
                    height: 192.h,
                    viewportFraction: 1,
                    autoPlay: true,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) =>
                        setState(() => _bannerIndex = index),
                  ),
                ),
                AnimatedSmoothIndicator(
                  activeIndex: _bannerIndex,
                  count: 2,
                  effect: WormEffect(
                    dotHeight: 4.h,
                    dotWidth: 18.w,
                    activeDotColor: AppColors.primary,
                    dotColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Categories',
              onActionTap: () => Navigator.pushNamed(
                context,
                CategoryScreen.routeName,
                arguments: 'all',
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            sliver: SliverGrid.builder(
              itemCount: DummyData.categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width > 520 ? 4 : 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (_, index) =>
                  CategoryTile(category: DummyData.categories[index]),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Flash Sale',
              onActionTap: () => Navigator.pushNamed(
                context,
                CategoryScreen.routeName,
                arguments: 'all',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                scrollDirection: Axis.horizontal,
                itemCount: visibleProducts.take(4).length,
                separatorBuilder: (context, index) => SizedBox(width: 12.w),
                itemBuilder: (_, index) =>
                    ProductCard(product: visibleProducts[index], compact: true),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Best Sellers',
              onActionTap: () => Navigator.pushNamed(
                context,
                CategoryScreen.routeName,
                arguments: 'all',
              ),
            ),
          ),
          SliverList.builder(
            itemCount: visibleProducts.skip(3).take(4).length,
            itemBuilder: (_, index) => ProductListTile(
              product:
                  visibleProducts[index + (visibleProducts.length > 3 ? 3 : 0)],
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 18.h)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onSearchChanged,
    required this.onCartTap,
    required this.onNotificationsTap,
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCartTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9:35',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Deliver to',
            style: TextStyle(color: Colors.white70, fontSize: 11.sp),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cairo, Egypt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: onNotificationsTap,
                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),
              CartIconButton(onPressed: onCartTap),
            ],
          ),
          SizedBox(height: 14.h),
          QuickSearchField(
            hint: 'Search for groceries...',
            light: true,
            onChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }
}
