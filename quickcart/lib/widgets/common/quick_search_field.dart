import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

class QuickSearchField extends StatelessWidget {
  const QuickSearchField({super.key, required this.hint, this.light = false});

  final String hint;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: light ? Colors.white70 : AppColors.textMuted, fontSize: 12.sp),
        prefixIcon: Icon(Icons.search, color: light ? Colors.white70 : AppColors.primary),
        filled: true,
        fillColor: light ? Colors.white.withValues(alpha: 0.16) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
      ),
    );
  }
}
