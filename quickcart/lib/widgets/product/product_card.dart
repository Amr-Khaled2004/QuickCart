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
  });

  final Product product;
  final bool compact;
  final bool heroEnabled;

  @override
  Widget build(BuildContext context) {
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
              child: Stack(
                children: [
                  if (heroEnabled)
                    Hero(
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
                  else
                    ClipRRect(
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
                  if (product.discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${product.discount}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
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
              '1 kg',
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
                SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: IconButton.filled(
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () =>
                        context.read<AppStateProvider>().addToCart(product.id),
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
