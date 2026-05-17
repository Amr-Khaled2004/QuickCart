import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/currency.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  static const routeName = '/payment';

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  String _method = 'Card';

  @override
  void dispose() {
    _cardController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final provider = context.read<AppStateProvider>();
    if (provider.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a delivery address first.')),
      );
      return;
    }
    var paymentLabel = 'Cash on delivery';
    if (_method == 'Card') {
      final savedMethod = provider.selectedPaymentMethod;
      if (savedMethod != null && _cardController.text.trim().isEmpty) {
        paymentLabel = '${savedMethod.label} ending ${savedMethod.last4}';
      } else {
        if (!(_formKey.currentState?.validate() ?? false)) return;
        provider.addPaymentMethod(
          label: _nameController.text.trim().isEmpty
              ? 'Card'
              : _nameController.text.trim(),
          cardNumber: _cardController.text,
        );
        final addedMethod = provider.selectedPaymentMethod;
        paymentLabel = addedMethod == null
            ? 'Card'
            : '${addedMethod.label} ending ${addedMethod.last4}';
      }
    }
    await provider.placeOrder(paymentLabel: paymentLabel);
    if (!mounted) return;
    if (provider.lastError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.lastError!)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order placed successfully.')));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _showAddressForm() {
    final labelController = TextEditingController();
    final detailsController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Delivery Address'),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final items = provider.cartItems;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 22.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28.r),
                ),
              ),
              child: Row(
                children: [
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                    ),
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Card',
                        label: Text('Card'),
                        icon: Icon(Icons.credit_card),
                      ),
                      ButtonSegment(
                        value: 'Cash',
                        label: Text('Cash'),
                        icon: Icon(Icons.payments_outlined),
                      ),
                    ],
                    selected: {_method},
                    onSelectionChanged: (value) =>
                        setState(() => _method = value.first),
                  ),
                  SizedBox(height: 16.h),
                  _AddressSelector(onAddAddress: _showAddressForm),
                  SizedBox(height: 16.h),
                  if (_method == 'Card')
                    _SavedPaymentSelector(
                      onUseNewCard: () {
                        context.read<AppStateProvider>().selectPaymentMethod(
                          '',
                        );
                      },
                    ),
                  if (_method == 'Card') SizedBox(height: 12.h),
                  if (_method == 'Card' &&
                      provider.selectedPaymentMethod == null)
                    _CardForm(
                      formKey: _formKey,
                      cardController: _cardController,
                      nameController: _nameController,
                      expiryController: _expiryController,
                      cvvController: _cvvController,
                    ),
                  if (_method == 'Cash')
                    _InfoBox(
                      icon: Icons.local_shipping_outlined,
                      text: 'Pay with cash when your groceries arrive.',
                    ),
                  SizedBox(height: 18.h),
                  _OrderSummary(
                    itemCount: provider.cartItemCount,
                    subtotal: provider.cartSubtotal,
                    delivery: provider.deliveryFee,
                    total: provider.cartTotal,
                  ),
                  SizedBox(height: 18.h),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: Size(double.infinity, 52.h),
                    ),
                    onPressed: items.isEmpty || provider.isBusy
                        ? null
                        : _placeOrder,
                    child: provider.isBusy
                        ? SizedBox.square(
                            dimension: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Place Order'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardForm extends StatelessWidget {
  const _CardForm({
    required this.formKey,
    required this.cardController,
    required this.nameController,
    required this.expiryController,
    required this.cvvController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cardController;
  final TextEditingController nameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _PaymentField(
            controller: nameController,
            label: 'Name on card',
            icon: Icons.person_outline,
          ),
          SizedBox(height: 12.h),
          _PaymentField(
            controller: cardController,
            label: 'Card number',
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            minLength: 12,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _PaymentField(
                  controller: expiryController,
                  label: 'MM/YY',
                  icon: Icons.calendar_today_outlined,
                  minLength: 4,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PaymentField(
                  controller: cvvController,
                  label: 'CVV',
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  minLength: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressSelector extends StatelessWidget {
  const _AddressSelector({required this.onAddAddress});

  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          for (final address in provider.addresses)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                provider.selectedAddress?.id == address.id
                    ? Icons.check_circle
                    : Icons.location_on_outlined,
                color: provider.selectedAddress?.id == address.id
                    ? AppColors.success
                    : AppColors.primary,
              ),
              title: Text(address.label),
              subtitle: Text(address.details),
              onTap: () => provider.selectAddress(address.id),
            ),
          TextButton.icon(
            onPressed: onAddAddress,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add address'),
          ),
        ],
      ),
    );
  }
}

class _SavedPaymentSelector extends StatelessWidget {
  const _SavedPaymentSelector({required this.onUseNewCard});

  final VoidCallback onUseNewCard;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    if (provider.paymentMethods.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved Cards',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          for (final method in provider.paymentMethods)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                provider.selectedPaymentMethod?.id == method.id
                    ? Icons.check_circle
                    : Icons.credit_card,
                color: provider.selectedPaymentMethod?.id == method.id
                    ? AppColors.success
                    : AppColors.primary,
              ),
              title: Text('${method.label} ending ${method.last4}'),
              onTap: () => provider.selectPaymentMethod(method.id),
            ),
          TextButton.icon(
            onPressed: onUseNewCard,
            icon: const Icon(Icons.add_card),
            label: const Text('Use new card'),
          ),
        ],
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  const _PaymentField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.minLength = 2,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int minLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.length < minLength) return 'Required';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.itemCount,
    required this.subtotal,
    required this.delivery,
    required this.total,
  });

  final int itemCount;
  final double subtotal;
  final double delivery;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Items', value: '$itemCount'),
          _SummaryRow(label: 'Subtotal', value: formatEgp(subtotal)),
          _SummaryRow(label: 'Delivery', value: formatEgp(delivery)),
          Divider(height: 24.h),
          _SummaryRow(label: 'Total', value: formatEgp(total), bold: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
