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
  const ProductCard({super.key, required this.product, this.compact = false, this.heroEnabled = true});

  final Product product;
  final bool compact;
  final bool heroEnabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => Navigator.pushNamed(context, ProductDetailsScreen.routeName, arguments: product.id),
      child: Container(
        width: compact ? 132.w : null,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 5))],
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
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (product.discount > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(12.r)),
                        child: Text('${product.discount}%', style: TextStyle(color: Colors.white, fontSize: 9.sp)),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800)),
            Text('1 kg', style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
            Row(
              children: [
                Text(formatEgp(product.price), style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w900)),
                const Spacer(),
                SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: IconButton.filled(
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => context.read<AppStateProvider>().addToCart(product.id),
                    icon: Icon(Icons.add, size: 17.sp),
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
