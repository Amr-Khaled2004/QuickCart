import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/cart_item.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/common/quick_search_field.dart';
import '../../widgets/navigation/quick_bottom_nav.dart';
import '../payment/payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.showNav = true});

  static const routeName = '/cart';
  final bool showNav;

  @override
  Widget build(BuildContext context) {
    final items = context.select<AppStateProvider, List<CartItem>>(
      (provider) => provider.cartItems,
    );
    final subtotal = context.select<AppStateProvider, double>(
      (provider) => provider.cartSubtotal,
    );
    final deliveryFee = context.select<AppStateProvider, double>(
      (provider) => provider.deliveryFee,
    );
    return Scaffold(
      bottomNavigationBar: showNav ? const QuickBottomNav() : null,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 22.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28.r),
                ),
              ),
              child: Text(
                'My Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.all(18.w),
                child: Container(
                  padding: EdgeInsets.all(22.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.primary,
                        size: 42.sp,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Add products from the home page to see them here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final item in items)
                _CartItem(key: ValueKey(item.productId), item: item),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: const QuickSearchField(hint: 'Enter promo code'),
            ),
            _Summary(subtotal: subtotal, delivery: deliveryFee),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                onPressed: items.isEmpty
                    ? null
                    : () =>
                          Navigator.pushNamed(context, PaymentScreen.routeName),
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
  const _CartItem({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final productId = item.productId;
    final stock = context.select<AppStateProvider, int>(
      (provider) => provider.stockFor(productId),
    );
    final provider = context.read<AppStateProvider>();
    final quantity = item.quantity;
    final canIncrease = quantity < stock;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 62.w,
              height: 62.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  formatEgp(item.price),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stock > 0 ? 'Stock: $stock' : 'Out of stock',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => provider.decrementCart(productId),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: canIncrease
                          ? () async {
                              await provider.addToCart(productId);
                              if (!context.mounted ||
                                  provider.lastError == null) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.lastError!)),
                              );
                            }
                          : null,
                    ),
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 26.w,
      child: IconButton.filled(
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: onTap == null
              ? AppColors.textMuted
              : AppColors.primary,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 14.sp),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.subtotal, required this.delivery});

  final double subtotal;
  final double delivery;

  @override
  Widget build(BuildContext context) {
    final total = subtotal + delivery;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: subtotal),
          _SummaryRow(label: 'Delivery', value: delivery),
          Divider(height: 24.h),
          _SummaryRow(label: 'Total', value: total, bold: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          formatEgp(value),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
