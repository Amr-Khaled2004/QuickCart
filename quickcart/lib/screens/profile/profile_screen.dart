import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/navigation/quick_bottom_nav.dart';
import '../admin/admin_products_screen.dart';
import '../auth/login_screen.dart';

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

    void showPersonalInfoForm() {
      final nameController = TextEditingController(text: provider.userName);
      final emailController = TextEditingController(text: provider.userEmail);
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Edit Personal Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<AppStateProvider>().updatePersonalInfo(
                  name: nameController.text,
                  email: emailController.text,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    void showAddressForm() {
      final labelController = TextEditingController();
      final detailsController = TextEditingController();
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: 'Full address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final label = labelController.text.trim();
                final details = detailsController.text.trim();
                if (label.isEmpty || details.isEmpty) return;
                context.read<AppStateProvider>().addAddress(
                  label: label,
                  details: details,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    void showPaymentForm() {
      final labelController = TextEditingController(text: 'Visa');
      final numberController = TextEditingController();
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Card label'),
              ),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Card number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (numberController.text.trim().length < 4) return;
                context.read<AppStateProvider>().addPaymentMethod(
                  label: labelController.text,
                  cardNumber: numberController.text,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
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
                  onTap: showPersonalInfoForm,
                ),
                _ProfileAction(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  onTap: () {
                    final addresses = context
                        .read<AppStateProvider>()
                        .addresses;
                    showProfilePanel('Saved Addresses', [
                      if (addresses.isEmpty)
                        const _EmptyPanel(
                          icon: Icons.location_off_outlined,
                          text: 'No saved addresses yet.',
                        )
                      else
                        for (final address in addresses)
                          _AddressPanel(address: address),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: Size(double.infinity, 44.h),
                        ),
                        onPressed: showAddressForm,
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Add address'),
                      ),
                    ]);
                  },
                ),
                _ProfileAction(
                  icon: Icons.credit_card,
                  title: 'Payment Methods',
                  onTap: () {
                    final methods = context
                        .read<AppStateProvider>()
                        .paymentMethods;
                    showProfilePanel('Payment Methods', [
                      if (methods.isEmpty)
                        const _EmptyPanel(
                          icon: Icons.credit_card_off_outlined,
                          text: 'No payment methods added yet.',
                        )
                      else
                        for (final method in methods)
                          _PaymentPanel(method: method),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: Size(double.infinity, 44.h),
                        ),
                        onPressed: showPaymentForm,
                        icon: const Icon(Icons.add_card),
                        label: const Text('Add payment method'),
                      ),
                    ]);
                  },
                ),
                if (provider.isAdmin)
                  _ProfileAction(
                    icon: Icons.inventory_2_outlined,
                    title: 'Admin Products',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AdminProductsScreen.routeName,
                    ),
                  ),
              ],
            ),
            _ProfileSection(
              title: 'Orders',
              children: [
                _ProfileAction(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order History',
                  onTap: () {
                    final orders = context.read<AppStateProvider>().orders;
                    final panels = orders.isEmpty
                        ? const <Widget>[
                            _EmptyPanel(
                              icon: Icons.receipt_long_outlined,
                              text: 'You have not placed any orders yet.',
                            ),
                          ]
                        : orders
                              .map((order) => _OrderPanel(order: order))
                              .toList();
                    showProfilePanel('Order History', panels);
                  },
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
            _ProfileSection(
              title: 'Session',
              children: [
                _ProfileAction(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    context.read<AppStateProvider>().logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginScreen.routeName,
                      (route) => false,
                    );
                  },
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

class _OrderPanel extends StatelessWidget {
  const _OrderPanel({required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${order.placedAt.month}/${order.placedAt.day}/${order.placedAt.year}',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            order.items.join(', '),
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            order.address,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            order.paymentLabel,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Total: ${formatEgp(order.total)}',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressPanel extends StatelessWidget {
  const _AddressPanel({required this.address});

  final UserAddress address;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isSelected = provider.selectedAddress?.id == address.id;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.location_on_outlined,
            color: isSelected ? AppColors.success : AppColors.primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  address.details,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Use this address',
            onPressed: () => provider.selectAddress(address.id),
            icon: const Icon(Icons.radio_button_checked),
          ),
          IconButton(
            tooltip: 'Remove address',
            onPressed: () => provider.removeAddress(address.id),
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _PaymentPanel extends StatelessWidget {
  const _PaymentPanel({required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isSelected = provider.selectedPaymentMethod?.id == method.id;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.credit_card,
            color: isSelected ? AppColors.success : AppColors.primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '${method.label} ending ${method.last4}',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Use this card',
            onPressed: () => provider.selectPaymentMethod(method.id),
            icon: const Icon(Icons.radio_button_checked),
          ),
          IconButton(
            tooltip: 'Remove card',
            onPressed: () => provider.removePaymentMethod(method.id),
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
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
