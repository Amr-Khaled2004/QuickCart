import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/navigation/quick_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showNav = true});

  static const routeName = '/profile';
  final bool showNav;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final userName = provider.userName;
    final initial = userName.isEmpty ? 'G' : userName[0].toUpperCase();

    void showProfilePanel(String title, List<Widget> children) {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => Padding(
          padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 12.h),
              ...children,
            ],
          ),
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar: showNav ? const QuickBottomNav() : null,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34.r,
                        backgroundColor: AppColors.lavender,
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
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
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '${provider.orderCount}',
                        label: 'Orders',
                      ),
                    ),
                    Expanded(
                      child: _StatCard(
                        value: '${provider.favorites.length}',
                        label: 'Favorites',
                      ),
                    ),
                    Expanded(
                      child: _StatCard(
                        value: '${provider.points}',
                        label: 'Points',
                        accent: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ProfileSection(
              title: 'Account',
              children: [
                _ProfileAction(
                  icon: Icons.person_outline,
                  title: 'Personal Info',
                  onTap: () => showProfilePanel('Personal Info', [
                    _InfoRow(label: 'Name', value: userName),
                    _InfoRow(
                      label: 'Email',
                      value: provider.userEmail.isEmpty
                          ? 'Not added'
                          : provider.userEmail,
                    ),
                  ]),
                ),
                _ProfileAction(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  onTap: () => showProfilePanel('Saved Addresses', const [
                    _EmptyPanel(
                      icon: Icons.location_off_outlined,
                      text: 'No saved addresses yet.',
                    ),
                  ]),
                ),
                _ProfileAction(
                  icon: Icons.credit_card,
                  title: 'Payment Methods',
                  onTap: () => showProfilePanel('Payment Methods', const [
                    _EmptyPanel(
                      icon: Icons.credit_card_off_outlined,
                      text: 'No payment methods added yet.',
                    ),
                  ]),
                ),
              ],
            ),
            _ProfileSection(
              title: 'Orders',
              children: [
                _ProfileAction(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order History',
                  onTap: () => showProfilePanel('Order History', const [
                    _EmptyPanel(
                      icon: Icons.receipt_long_outlined,
                      text: 'You have not placed any orders yet.',
                    ),
                  ]),
                ),
                _ProfileAction(
                  icon: Icons.access_time,
                  title: 'Track Order',
                  onTap: () => showProfilePanel('Track Order', const [
                    _EmptyPanel(
                      icon: Icons.local_shipping_outlined,
                      text: 'No active order to track.',
                    ),
                  ]),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 15.sp,
          color: AppColors.textDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 34.sp),
          SizedBox(height: 10.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.accent = false,
  });

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent ? AppColors.accent : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13.sp,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
