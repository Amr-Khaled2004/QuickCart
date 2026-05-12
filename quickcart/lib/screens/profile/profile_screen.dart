import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../widgets/navigation/quick_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showNav = true});

  static const routeName = '/profile';
  final bool showNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: showNav ? const QuickBottomNav() : null,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Profile', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900)),
                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34.r,
                        backgroundColor: AppColors.lavender,
                        child: Text('M', style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w900)),
                      ),
                      SizedBox(width: 14.w),
                      Text('Mohamed Ahmed', style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -18.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 38.w),
                child: Row(
                  children: const [
                    Expanded(child: _StatCard(value: '20', label: 'Orders')),
                    Expanded(child: _StatCard(value: '3', label: 'Favorites')),
                    Expanded(child: _StatCard(value: '340', label: 'Points', accent: true)),
                  ],
                ),
              ),
            ),
            _ProfileSection(
              title: 'Account',
              children: const [
                _ProfileAction(icon: Icons.person_outline, title: 'Personal Info'),
                _ProfileAction(icon: Icons.location_on_outlined, title: 'Saved Addresses'),
                _ProfileAction(icon: Icons.credit_card, title: 'Payment Methods'),
              ],
            ),
            _ProfileSection(
              title: 'Orders',
              children: const [
                _ProfileAction(icon: Icons.receipt_long_outlined, title: 'Order History'),
                _ProfileAction(icon: Icons.access_time, title: 'Track Order'),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, this.accent = false});

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: accent ? AppColors.accent : Colors.white, fontWeight: FontWeight.w900, fontSize: 13.sp)),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 10.sp)),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(14.r)),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(9.r)),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
