import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20.r)),
                  child: Text('Exclusive Deal!', style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                ),
                SizedBox(height: 8.h),
                Text(title, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900, height: 1.05)),
                SizedBox(height: 4.h),
                Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                SizedBox(height: 10.h),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accent, minimumSize: Size(88.w, 34.h)),
                  onPressed: () {},
                  child: Text('Grab it now!', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.white, size: 88.sp),
        ],
      ),
    );
  }
}
