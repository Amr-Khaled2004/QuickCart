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
  const ProductListTile({super.key, required this.product, this.showFavorite = false});

  final Product product;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isFavorite = provider.favorites.contains(product.id);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, ProductDetailsScreen.routeName, arguments: product.id),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(imageUrl: product.image, width: 52.w, height: 52.w, fit: BoxFit.cover),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                  Text('1 kg | Farm raised', style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.accent, size: 13.sp),
                      Text(' ${product.rating}', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatEgp(product.price), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12.sp)),
                SizedBox(height: 5.h),
                if (showFavorite)
                  IconButton.filled(
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => provider.toggleFavorite(product.id),
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 18.sp),
                  )
                else
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: Size(52.w, 26.h), padding: EdgeInsets.zero),
                    onPressed: () => provider.addToCart(product.id),
                    child: Text('+ Add', style: TextStyle(fontSize: 10.sp)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
