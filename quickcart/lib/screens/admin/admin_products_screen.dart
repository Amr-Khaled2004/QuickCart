import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/currency.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  static const routeName = '/admin-products';

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  void _openForm([Product? product]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ProductForm(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Product'),
      ),
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
                    'Admin Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (provider.products.isEmpty)
              Padding(
                padding: EdgeInsets.all(18.w),
                child: const Text('No products in Firestore yet.'),
              )
            else
              for (final product in provider.products)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: product.imageUrl.isEmpty
                        ? null
                        : NetworkImage(product.imageUrl),
                    backgroundColor: AppColors.pinkBackground,
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.category} - ${formatEgp(product.price)} - stock ${product.stock}',
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => _openForm(product),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => context
                            .read<AppStateProvider>()
                            .deleteProduct(product.id),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                        ),
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

class _ProductForm extends StatefulWidget {
  const _ProductForm({this.product});

  final Product? product;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _categoryController;
  late final TextEditingController _stockController;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _imageController = TextEditingController(text: product?.imageUrl ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _stockController = TextEditingController(
      text: product == null ? '' : product.stock.toString(),
    );
    _discountController = TextEditingController(
      text: product == null ? '0' : product.discount.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      category: _categoryController.text.trim().toLowerCase(),
      image: _imageController.text.trim(),
      rating: widget.product?.rating ?? 4.8,
      price: double.parse(_priceController.text.trim()),
      discount: int.tryParse(_discountController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      stock: int.parse(_stockController.text.trim()),
      createdAt: widget.product?.createdAt,
    );
    final provider = context.read<AppStateProvider>();
    if (widget.product == null) {
      await provider.addProduct(product);
    } else {
      await provider.updateProduct(product);
    }
    if (!mounted) return;
    if (provider.lastError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.lastError!)));
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 18.h,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.product == null ? 'Add Product' : 'Update Product',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 12.h),
            _AdminField(controller: _nameController, label: 'Name'),
            _AdminField(
              controller: _descriptionController,
              label: 'Description',
            ),
            _AdminField(controller: _categoryController, label: 'Category'),
            _AdminField(controller: _imageController, label: 'Image URL'),
            _AdminField(
              controller: _priceController,
              label: 'Price',
              keyboardType: TextInputType.number,
            ),
            _AdminField(
              controller: _stockController,
              label: 'Stock',
              keyboardType: TextInputType.number,
            ),
            _AdminField(
              controller: _discountController,
              label: 'Discount',
              keyboardType: TextInputType.number,
              requiredField: false,
            ),
            SizedBox(height: 10.h),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 48.h),
              ),
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminField extends StatelessWidget {
  const _AdminField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.requiredField = true,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (requiredField && (value?.trim().isEmpty ?? true)) {
            return 'Required';
          }
          if (keyboardType == TextInputType.number &&
              value != null &&
              value.trim().isNotEmpty &&
              double.tryParse(value.trim()) == null) {
            return 'Enter a number';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
