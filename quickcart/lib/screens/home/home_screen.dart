import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../widgets/common/promo_banner.dart';
import '../../widgets/common/quick_search_field.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/home/category_tile.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/product_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final products = DummyData.products;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header()),
          SliverToBoxAdapter(
            child: Column(
              children: [
                CarouselSlider(
                  items: const [
                    PromoBanner(title: 'Fresh Fruits\nUp to 30% off', subtitle: 'Limited time offer today', icon: Icons.shopping_cart_outlined),
                    PromoBanner(title: 'Organic Picks\nDelivered Fast', subtitle: 'Fresh from trusted farms', icon: Icons.eco_outlined),
                  ],
                  options: CarouselOptions(
                    height: 168.h,
                    viewportFraction: 1,
                    autoPlay: true,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) => setState(() => _bannerIndex = index),
                  ),
                ),
                AnimatedSmoothIndicator(
                  activeIndex: _bannerIndex,
                  count: 2,
                  effect: WormEffect(dotHeight: 4.h, dotWidth: 18.w, activeDotColor: AppColors.primary, dotColor: Colors.white),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Categories')),
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
              itemBuilder: (_, index) => CategoryTile(category: DummyData.categories[index]),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Flash Sale', action: '20:23:56')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (context, index) => SizedBox(width: 12.w),
                itemBuilder: (_, index) => ProductCard(product: products[index], compact: true),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Best Sellers')),
          SliverList.builder(
            itemCount: 4,
            itemBuilder: (_, index) => ProductListTile(product: products[index + 3]),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 18.h)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('9:35', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 10.h),
          Text('Deliver to', style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
          Row(
            children: [
              Expanded(child: Text('Cairo, Egypt', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900))),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          SizedBox(height: 14.h),
          const QuickSearchField(hint: 'Search for groceries...', light: true),
        ],
      ),
    );
  }
}
