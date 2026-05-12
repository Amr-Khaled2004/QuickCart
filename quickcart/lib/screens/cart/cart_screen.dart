import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/common/quick_search_field.dart';
import '../../widgets/navigation/quick_bottom_nav.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.showNav = true});

  static const routeName = '/cart';
  final bool showNav;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final products = provider.cartProducts;
    final subtotal = products.fold<double>(0, (sum, item) => sum + item.price * (provider.cart[item.id] ?? 1));
    return Scaffold(
      bottomNavigationBar: showNav ? const QuickBottomNav() : null,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 22.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
              ),
              child: Text('My Cart', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900)),
            ),
            SizedBox(height: 12.h),
            for (final product in products) _CartItem(productId: product.id),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: const QuickSearchField(hint: 'Enter promo code'),
            ),
            _Summary(subtotal: subtotal),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: 16.h)),
                onPressed: () {},
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final product = DummyData.products.firstWhere((item) => item.id == productId);
    final quantity = provider.cart[productId] ?? 1;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(imageUrl: product.image, width: 62.w, height: 62.w, fit: BoxFit.cover),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900)),
                Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    _QtyButton(icon: Icons.remove, onTap: () => provider.decrementCart(productId)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text('$quantity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp)),
                    ),
                    _QtyButton(icon: Icons.add, onTap: () => provider.addToCart(productId)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => provider.removeFromCart(productId),
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 26.w,
      child: IconButton.filled(
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
        onPressed: onTap,
        icon: Icon(icon, size: 14.sp),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    const delivery = 2.50;
    final total = subtotal + delivery;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r)),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: subtotal),
          const _SummaryRow(label: 'Delivery', value: delivery),
          Divider(height: 24.h),
          _SummaryRow(label: 'Total', value: total, bold: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w600)),
        const Spacer(),
        Text('\$${value.toStringAsFixed(2)}', style: TextStyle(color: AppColors.primary, fontWeight: bold ? FontWeight.w900 : FontWeight.w700)),
      ],
    );
  }
}
