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
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => Navigator.pushNamed(context, CategoryScreen.routeName, arguments: category.name.toLowerCase()),
      child: Container(
        decoration: BoxDecoration(color: category.color, borderRadius: BorderRadius.circular(16.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 30.sp, color: category.name == 'Dairy' ? AppColors.textDark : Colors.white),
            SizedBox(height: 7.h),
            Text(category.name, style: TextStyle(fontSize: 11.sp, color: category.name == 'Dairy' ? AppColors.textDark : Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
