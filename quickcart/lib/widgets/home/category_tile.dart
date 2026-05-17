import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../models/category_item.dart';
import '../../screens/category/category_screen.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category});

  final CategoryItem category;

  @override
  Widget build(BuildContext context) {
    final routeCategory = switch (category.name) {
      'Veggies' => 'vegetables',
      _ => category.name.toLowerCase(),
    };
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => Navigator.pushNamed(
        context,
        CategoryScreen.routeName,
        arguments: routeCategory,
      ),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: category.name == 'Dairy'
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(category.emoji, style: TextStyle(fontSize: 25.sp)),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: category.name == 'Dairy'
                    ? AppColors.textDark
                    : Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
