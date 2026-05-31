import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants/app_colors.dart';
import '../../data/grocery_seed_data.dart';
import '../../models/app_notification.dart';
import '../../models/product.dart';
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
    context.read<AppStateProvider>().markNotificationsRead();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer<AppStateProvider>(
        builder: (context, provider, _) {
          final notifications = provider.notifications;
          return Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10.h),
                if (notifications.isEmpty)
                  const ListTile(
                    leading: Icon(Icons.notifications_none),
                    title: Text('No notifications yet.'),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 360.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      itemBuilder: (_, index) =>
                          _NotificationTile(notification: notifications[index]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = context.select<AppStateProvider, List<Product>>(
      (provider) => provider.products,
    );
    final query = _query.toLowerCase();
    final products = allProducts.where((product) {
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
    }).toList();
    final visibleProducts = products.isEmpty ? allProducts : products;
    final flashSaleProducts = visibleProducts
        .where((product) => product.discount > 0)
        .toList();
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
              itemCount: GrocerySeedData.categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width > 520 ? 4 : 3,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, index) =>
                  CategoryTile(category: GrocerySeedData.categories[index]),
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
              child: flashSaleProducts.isEmpty
                  ? const _EmptyProducts()
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: flashSaleProducts.take(4).length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 14.w),
                      itemBuilder: (_, index) => ProductCard(
                        product: flashSaleProducts[index],
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(switch (notification.type) {
        'offer' => Icons.local_offer_outlined,
        'order' => Icons.local_shipping_outlined,
        _ => Icons.notifications_none,
      }, color: notification.isRead ? AppColors.textMuted : AppColors.primary),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.w700 : FontWeight.w900,
        ),
      ),
      subtitle: Text(
        '${notification.body}\n${_relativeTime(notification.createdAt)}',
      ),
      isThreeLine: true,
    );
  }

  String _relativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} hr ago';
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
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
    final address = context.select<AppStateProvider, String?>(
      (provider) => provider.selectedAddress?.details,
    );
    final unreadCount = context.select<AppStateProvider, int>(
      (provider) => provider.unreadNotificationCount,
    );
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
                          address ?? 'Add delivery address',
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: onNotificationsTap,
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 5.w,
                      top: 5.h,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.w,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.white, width: 1.3),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
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
