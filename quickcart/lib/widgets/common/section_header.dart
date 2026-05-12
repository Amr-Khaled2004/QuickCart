import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action = 'See all +'});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const Spacer(),
          if (action != null)
            Text(
              action!,
              style: TextStyle(fontSize: 11.sp, color: AppColors.accent, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
