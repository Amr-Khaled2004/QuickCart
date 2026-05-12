import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/app_state_provider.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({
    super.key,
    required this.onPressed,
    this.iconColor = Colors.white,
  });

  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final count = context.watch<AppStateProvider>().cartItemCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Cart',
          onPressed: onPressed,
          icon: Icon(Icons.shopping_cart_outlined, color: iconColor),
        ),
        if (count > 0)
          Positioned(
            right: 3.w,
            top: 3.h,
            child: Container(
              constraints: BoxConstraints(minWidth: 17.w, minHeight: 17.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(9.r),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
