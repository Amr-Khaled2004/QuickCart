import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cartSize = compact ? 42.0 : 68.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shopping_cart, color: AppColors.lavender, size: cartSize.sp),
        SizedBox(width: 8.w),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: compact ? 26.sp : 38.sp,
              color: AppColors.lavender,
              height: 0.9,
            ),
            children: const [
              TextSpan(text: 'Quick\n'),
              TextSpan(text: 'Cart', style: TextStyle(color: AppColors.accent)),
            ],
          ),
        ),
      ],
    );
  }
}
