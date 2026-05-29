import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../screens/product/product_details_screen.dart';
import '../../utils/currency.dart';

class ProductListTile extends StatelessWidget {
  const ProductListTile({
    super.key,
    required this.product,
    this.showFavorite = false,
  });

  final Product product;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isFavorite = provider.favorites.contains(product.id);
    final canAdd = provider.canAddToCart(product.id);
    final imageSize = (68.w * MediaQuery.devicePixelRatioOf(context)).round();
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        ProductDetailsScreen.routeName,
        arguments: product.id,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: 68.w,
                height: 68.w,
                fit: BoxFit.cover,
                memCacheWidth: imageSize,
                placeholder: (context, url) => Container(
                  width: 68.w,
                  height: 68.w,
                  color: AppColors.pinkBackground.withValues(alpha: 0.35),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 68.w,
                  height: 68.w,
                  color: AppColors.pinkBackground.withValues(alpha: 0.35),
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    product.stock > 0
                        ? 'Stock: ${product.stock}'
                        : 'Out of stock',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.accent, size: 13.sp),
                      Text(
                        ' ${product.rating}',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatEgp(product.price),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 7.h),
                if (showFavorite)
                  IconButton.filled(
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () => provider.toggleFavorite(product.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 18.sp,
                    ),
                  )
                else
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: canAdd
                          ? AppColors.primary
                          : AppColors.textMuted,
                      minimumSize: Size(58.w, 30.h),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: canAdd
                        ? () async {
                            await provider.addToCart(product.id);
                            if (!context.mounted ||
                                provider.lastError == null) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.lastError!)),
                            );
                          }
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Only ${product.stock} items available in stock',
                              ),
                            ),
                          ),
                    child: Text('+ Add', style: TextStyle(fontSize: 10.5.sp)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
