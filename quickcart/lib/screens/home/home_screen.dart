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
import '../deals/deal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;
  String _query = '';

  void _openCart() => context.read<AppStateProvider>().setTab(1);

  void _showAddressSheet() {
    final provider = context.read<AppStateProvider>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10.h),
            for (final address in provider.addresses)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  provider.selectedAddress?.id == address.id
                      ? Icons.check_circle
                      : Icons.location_on_outlined,
                  color: provider.selectedAddress?.id == address.id
                      ? AppColors.success
                      : AppColors.primary,
                ),
                title: Text(address.label),
                subtitle: Text(address.details),
                onTap: () {
                  context.read<AppStateProvider>().selectAddress(address.id);
                  Navigator.pop(sheetContext);
                },
              ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 46.h),
              ),
              onPressed: () {
                Navigator.pop(sheetContext);
                _showAddressForm();
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add new address'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressForm() {
    final labelController = TextEditingController();
    final detailsController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(labelText: 'Full address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final label = labelController.text.trim();
              final details = detailsController.text.trim();
              if (label.isEmpty || details.isEmpty) return;
              context.read<AppStateProvider>().addAddress(
                label: label,
                details: details,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

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
    final allProducts = context.watch<AppStateProvider>().products;
    final products = allProducts.where((product) {
      final query = _query.toLowerCase();
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
    }).toList();
    final visibleProducts = products.isEmpty ? allProducts : products;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              onSearchChanged: (value) => setState(() => _query = value),
              onCartTap: _openCart,
              onNotificationsTap: _showNotifications,
              onAddressTap: _showAddressSheet,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 16.h),
                CarouselSlider(
                  items: [
                    PromoBanner(
                      title: 'Fresh Fruits\nUp to 30% off',
                      subtitle: 'Limited time offer today',
                      icon: Icons.shopping_cart_outlined,
                      onTap: () => Navigator.pushNamed(
                        context,
                        DealScreen.routeName,
                        arguments: 'fruit',
                      ),
                    ),
                    PromoBanner(
                      title: 'Organic Picks\nDelivered Fast',
                      subtitle: 'Fresh from trusted farms',
                      icon: Icons.eco_outlined,
                      onTap: () => Navigator.pushNamed(
                        context,
                        DealScreen.routeName,
                        arguments: 'organic',
                      ),
                    ),
                  ],
                  options: CarouselOptions(
                    height: 210.h,
                    viewportFraction: 0.94,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.14,
                    onPageChanged: (index, reason) =>
                        setState(() => _bannerIndex = index),
                  ),
                ),
                SizedBox(height: 8.h),
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
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverGrid.builder(
              itemCount: DummyData.categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width > 520 ? 4 : 3,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 1,
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
              height: 222.h,
              child: visibleProducts.isEmpty
                  ? const _EmptyProducts()
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: visibleProducts.take(4).length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 14.w),
                      itemBuilder: (_, index) => ProductCard(
                        product: visibleProducts[index],
                        compact: true,
                      ),
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
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No products available yet.',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onSearchChanged,
    required this.onCartTap,
    required this.onNotificationsTap,
    required this.onAddressTap,
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCartTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onAddressTap;

  @override
  Widget build(BuildContext context) {
    final address = context.watch<AppStateProvider>().selectedAddress;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 22.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: onAddressTap,
            child: Text(
              'Deliver to',
              style: TextStyle(color: Colors.white70, fontSize: 11.sp),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: onAddressTap,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          address?.details ?? 'Add delivery address',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ],
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
          SizedBox(height: 16.h),
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
