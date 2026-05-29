import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../screens/product/product_details_screen.dart';
import '../../utils/currency.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.compact = false,
    this.heroEnabled = true,
    this.showAddButton = true,
  });

  final Product product;
  final bool compact;
  final bool heroEnabled;
  final bool showAddButton;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final canAdd = provider.canAddToCart(product.id);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final imageWidth = ((compact ? 150.w : 180.w) * pixelRatio).round();
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () => Navigator.pushNamed(
        context,
        ProductDetailsScreen.routeName,
        arguments: product.id,
      ),
      child: Container(
        width: compact ? 150.w : null,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: heroEnabled
                  ? Hero(
                      tag: 'product-${product.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: imageWidth,
                          placeholder: (context, url) => Container(
                            color: AppColors.pinkBackground.withValues(
                              alpha: 0.35,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.pinkBackground.withValues(
                              alpha: 0.35,
                            ),
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: imageWidth,
                        placeholder: (context, url) => Container(
                          color: AppColors.pinkBackground.withValues(
                            alpha: 0.35,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.pinkBackground.withValues(
                            alpha: 0.35,
                          ),
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 10.h),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 2.h),
            Text(
              product.stock > 0 ? 'Stock: ${product.stock}' : 'Out of stock',
              style: TextStyle(fontSize: 10.5.sp, color: AppColors.textMuted),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  formatEgp(product.price),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (showAddButton)
                  SizedBox(
                    width: 32.w,
                    height: 32.w,
                    child: IconButton.filled(
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: canAdd
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      onPressed: canAdd
                          ? () async {
                              final state = context.read<AppStateProvider>();
                              await state.addToCart(product.id);
                              if (!context.mounted || state.lastError == null) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.lastError!)),
                              );
                            }
                          : () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Only ${product.stock} items available in stock',
                                ),
                              ),
                            ),
                      icon: Icon(Icons.add, size: 18.sp),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
