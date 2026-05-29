import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/product/product_card.dart';
import '../category/category_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  static const routeName = '/product';
  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final product = provider.productById(widget.productId);
    if (product == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('Product not found.'))),
      );
    }
    if (quantity > product.stock && product.stock > 0) {
      quantity = product.stock;
    }
    final related = provider.products
        .where(
          (item) => item.category == product.category && item.id != product.id,
        )
        .toList();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ImageHeader(product: product)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 27.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Text(
                          formatEgp(product.price),
                          style: TextStyle(
                            fontSize: 22.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.accent),
                        Text(
                          ' ${product.rating}  |  Stock: ${product.stock}',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13.sp,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        _QuantitySelector(
                          quantity: quantity,
                          onMinus: () => setState(
                            () => quantity = quantity > 1 ? quantity - 1 : 1,
                          ),
                          onPlus: quantity >= product.stock
                              ? null
                              : () => setState(() => quantity++),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            onPressed: product.stock <= 0
                                ? null
                                : () async {
                                    final state = context
                                        .read<AppStateProvider>();
                                    await state.addToCart(
                                      product.id,
                                      quantity: quantity,
                                    );
                                    if (!context.mounted) return;
                                    if (state.lastError != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(state.lastError!),
                                        ),
                                      );
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to cart.'),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text('Add to cart'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Related Products',
                onActionTap: () => Navigator.pushNamed(
                  context,
                  CategoryScreen.routeName,
                  arguments: product.category,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 190.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) =>
                      ProductCard(product: related[index], compact: true),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ),
      ),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  const _ImageHeader({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'product-${product.id}',
          child: CachedNetworkImage(
            imageUrl: product.image,
            width: double.infinity,
            height: 330.h,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 14.h,
          left: 14.w,
          child: IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          ),
        ),
        Positioned(
          top: 14.h,
          right: 14.w,
          child: Consumer<AppStateProvider>(
            builder: (context, provider, _) {
              final isFavorite = provider.favorites.contains(product.id);
              return IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => provider.toggleFavorite(product.id),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          _QuantityButton(icon: Icons.remove, onTap: onMinus),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              '$quantity',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
            ),
          ),
          _QuantityButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 34.w,
      child: IconButton.filled(
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: onTap == null
              ? AppColors.textMuted
              : AppColors.primary,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 17.sp),
      ),
    );
  }
}
