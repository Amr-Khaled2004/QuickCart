import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/currency.dart';
import '../auth/login_screen.dart';

class AdminAccountDetails {
  const AdminAccountDetails._();

  static const name = 'QuickCart Admin';
  static const email = 'admin@quickcart.com';
}

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  static const routeName = '/admin-products';

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  static const _brand = AppColors.primary;
  static const _brandDark = AppColors.primaryDark;
  static const _surface = Color(0xFFFFF6FC);
  static const _line = Color(0xFFEAD7F4);
  static const _sections = ['Dashboard', 'Products', 'Orders'];

  String _query = '';
  String _selectedSection = 'Dashboard';

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
    if (!provider.isAdmin) return const _AdminAccessDenied();

    final products = provider.products.where((product) {
      final query = _query.toLowerCase();
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
    }).toList();
    final orders = provider.adminOrders;
    final lowStock = provider.products
        .where((product) => product.stock > 0 && product.stock <= 10)
        .toList();
    final totalSales = orders.fold<double>(
      0,
      (sum, order) =>
          order.status == 'cancelled' ? sum : sum + order.totalPrice,
    );
    final customers = orders.map((order) => order.userId).toSet().length;

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Row(
              children: [
                if (wide)
                  _AdminSidebar(
                    selected: _selectedSection,
                    sections: _sections,
                    onSelected: (section) =>
                        setState(() => _selectedSection = section),
                  ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _AdminTopBar(
                          section: _selectedSection,
                          onSearchChanged: (value) =>
                              setState(() => _query = value),
                          onAddProduct: () => _openForm(),
                        ),
                      ),
                      if (!wide)
                        SliverToBoxAdapter(
                          child: _MobileNavStrip(
                            selected: _selectedSection,
                            sections: _sections,
                            onSelected: (section) =>
                                setState(() => _selectedSection = section),
                          ),
                        ),
                      SliverPadding(
                        padding: EdgeInsets.all(18.w),
                        sliver: SliverList.list(
                          children: [
                            if (_selectedSection == 'Dashboard') ...[
                              _OverviewGrid(
                                orders: orders.length,
                                sales: totalSales,
                                products: provider.products.length,
                                customers: customers,
                              ),
                              SizedBox(height: 16.h),
                            ],
                            _DashboardGrid(
                              section: _selectedSection,
                              products: products,
                              orders: orders,
                              lowStock: lowStock,
                              onEdit: _openForm,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selected,
    required this.sections,
    required this.onSelected,
  });

  final String selected;
  final List<String> sections;
  final ValueChanged<String> onSelected;

  static const _icons = {
    'Dashboard': Icons.dashboard_outlined,
    'Products': Icons.inventory_2_outlined,
    'Orders': Icons.receipt_long_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 238,
      color: _AdminProductsScreenState._brandDark,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_grocery_store, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'QuickCart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (final section in sections)
            _SidebarItem(
              icon: _icons[section] ?? Icons.circle_outlined,
              label: section,
              selected: selected == section,
              onTap: () => onSelected(section),
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              context.read<AppStateProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.routeName,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white70),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileNavStrip extends StatelessWidget {
  const _MobileNavStrip({
    required this.selected,
    required this.sections,
    required this.onSelected,
  });

  final String selected;
  final List<String> sections;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final section = sections[index];
          final active = selected == section;
          return ChoiceChip(
            label: Text(section),
            selected: active,
            onSelected: (_) => onSelected(section),
            side: BorderSide.none,
            selectedColor: _AdminProductsScreenState._brand,
            backgroundColor: active
                ? _AdminProductsScreenState._brand
                : Colors.white,
            labelStyle: TextStyle(
              color: active ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          );
        },
        separatorBuilder: (_, index) => SizedBox(width: 8.w),
        itemCount: sections.length,
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.section,
    required this.onSearchChanged,
    required this.onAddProduct,
  });

  final String section;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 14.h),
      color: _AdminProductsScreenState._brand,
      child: Wrap(
        spacing: 14.w,
        runSpacing: 12.h,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 160.w.clamp(130, 190),
            child: Text(
              section,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 320.w.clamp(240, 420),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products and orders...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            onPressed: onAddProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AdminAccountDetails.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                provider.userEmail.isEmpty
                    ? AdminAccountDetails.email
                    : provider.userEmail,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            onPressed: () {
              context.read<AppStateProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.routeName,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({
    required this.orders,
    required this.sales,
    required this.products,
    required this.customers,
  });

  final int orders;
  final double sales;
  final int products;
  final int customers;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1000
        ? 4
        : width >= 620
        ? 2
        : 1;
    final cards = [
      _MetricData('Total Orders', '$orders', Icons.receipt_long_outlined),
      _MetricData('Total Sales', formatEgp(sales), Icons.payments_outlined),
      _MetricData('Total Products', '$products', Icons.inventory_2_outlined),
      _MetricData('Total Customers', '$customers', Icons.people_outline),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        mainAxisExtent: 108.h,
      ),
      itemBuilder: (_, index) => _MetricCard(data: cards[index]),
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AdminProductsScreenState._line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _AdminProductsScreenState._brand.withValues(
              alpha: 0.12,
            ),
            child: Icon(data.icon, color: _AdminProductsScreenState._brand),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                ),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid({
    required this.section,
    required this.products,
    required this.orders,
    required this.lowStock,
    required this.onEdit,
  });

  final String section;
  final List<Product> products;
  final List<OrderModel> orders;
  final List<Product> lowStock;
  final ValueChanged<Product> onEdit;

  @override
  Widget build(BuildContext context) {
    if (section == 'Products') {
      return _ProductManagementTable(products: products, onEdit: onEdit);
    }
    if (section == 'Orders') {
      return _OrdersManagementPanel(orders: orders);
    }

    final wide = MediaQuery.sizeOf(context).width >= 980;
    final children = [
      _OrderStatusPanel(orders: orders),
      _LowStockPanel(products: lowStock),
    ];
    if (!wide) {
      return Column(
        children: [
          for (final child in children) ...[child, SizedBox(height: 14.h)],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children.first),
        SizedBox(width: 14.w),
        Expanded(child: children[1]),
      ],
    );
  }
}

class _ProductManagementTable extends StatelessWidget {
  const _ProductManagementTable({required this.products, required this.onEdit});

  final List<Product> products;
  final ValueChanged<Product> onEdit;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppStateProvider>();
    final compact = MediaQuery.sizeOf(context).width < 720;
    return _Panel(
      title: 'All Products',
      child: products.isEmpty
          ? _EmptyProductsSeed()
          : compact
          ? _CompactProductList(
              products: products,
              onEdit: onEdit,
              provider: provider,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  _AdminProductsScreenState._surface,
                ),
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: products.map((product) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Text(
                            product.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      DataCell(Text(product.category)),
                      DataCell(Text(formatEgp(product.price))),
                      DataCell(Text('${product.stock}')),
                      DataCell(
                        _StatusPill(product.stock > 0 ? 'Active' : 'Out'),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Decrease stock',
                              onPressed: product.stock == 0
                                  ? null
                                  : () => provider.decreaseProductStock(
                                      product.id,
                                    ),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            IconButton(
                              tooltip: 'Increase stock',
                              onPressed: () =>
                                  provider.increaseProductStock(product.id),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => onEdit(product),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Edit'),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () =>
                                  provider.deleteProduct(product.id),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _CompactProductList extends StatelessWidget {
  const _CompactProductList({
    required this.products,
    required this.onEdit,
    required this.provider,
  });

  final List<Product> products;
  final ValueChanged<Product> onEdit;
  final AppStateProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final product in products) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _AdminProductsScreenState._surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _AdminProductsScreenState._line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    _StatusPill(product.stock > 0 ? 'Active' : 'Out'),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 12.w,
                  runSpacing: 6.h,
                  children: [
                    _ProductMeta(label: 'Category', value: product.category),
                    _ProductMeta(
                      label: 'Price',
                      value: formatEgp(product.price),
                    ),
                    _ProductMeta(label: 'Stock', value: '${product.stock}'),
                  ],
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Decrease stock',
                      onPressed: product.stock == 0
                          ? null
                          : () => provider.decreaseProductStock(product.id),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Increase stock',
                      onPressed: () =>
                          provider.increaseProductStock(product.id),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    FilledButton.icon(
                      onPressed: () => onEdit(product),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Delete',
                      onPressed: () => provider.deleteProduct(product.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

class _ProductMeta extends StatelessWidget {
  const _ProductMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersManagementPanel extends StatelessWidget {
  const _OrdersManagementPanel({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppStateProvider>();
    final compact = MediaQuery.sizeOf(context).width < 720;
    return _Panel(
      title: 'All Orders',
      child: orders.isEmpty
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Text('No customer orders yet.'),
            )
          : compact
          ? _CompactOrderList(
              orders: orders,
              provider: provider,
              onDelete: (order) =>
                  _confirmDeleteOrder(context, provider, order),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  _AdminProductsScreenState._surface,
                ),
                columns: const [
                  DataColumn(label: Text('Order')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Items')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: orders.map((order) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            order.id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            order.userId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text('${order.items.length}')),
                      DataCell(Text(formatEgp(order.totalPrice))),
                      DataCell(_OrderStatusDropdown(order: order)),
                      DataCell(
                        IconButton(
                          tooltip: 'Delete order',
                          onPressed: () =>
                              _confirmDeleteOrder(context, provider, order),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Future<void> _confirmDeleteOrder(
    BuildContext context,
    AppStateProvider provider,
    OrderModel order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete order?'),
          content: const Text(
            'This removes the order from Firebase. If it was active, stock will be returned first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    await provider.deleteOrder(order.id);
    if (!context.mounted || provider.lastError == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(provider.lastError!)));
  }
}

class _CompactOrderList extends StatelessWidget {
  const _CompactOrderList({
    required this.orders,
    required this.provider,
    required this.onDelete,
  });

  final List<OrderModel> orders;
  final AppStateProvider provider;
  final ValueChanged<OrderModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final order in orders) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _AdminProductsScreenState._surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _AdminProductsScreenState._line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order ${order.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    _StatusPill(order.status == 'cancelled' ? 'Out' : 'Active'),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 12.w,
                  runSpacing: 6.h,
                  children: [
                    _ProductMeta(label: 'Customer', value: order.userId),
                    _ProductMeta(
                      label: 'Items',
                      value: '${order.items.length}',
                    ),
                    _ProductMeta(
                      label: 'Total',
                      value: formatEgp(order.totalPrice),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(child: _OrderStatusDropdown(order: order)),
                    SizedBox(width: 8.w),
                    IconButton.filledTonal(
                      tooltip: 'Delete order',
                      onPressed: () => onDelete(order),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

class _OrderStatusDropdown extends StatelessWidget {
  const _OrderStatusDropdown({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppStateProvider>();
    return DropdownButton<String>(
      value: _orderStatuses.contains(order.status) ? order.status : 'pending',
      items: _orderStatuses
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      onChanged: (status) {
        if (status == null || status == order.status) return;
        provider.updateOrderStatus(orderId: order.id, status: status);
      },
    );
  }
}

class _EmptyProductsSeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(18.w),
      child: Column(
        children: [
          const Text('No products in Firestore yet.'),
          SizedBox(height: 12.h),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _AdminProductsScreenState._brand,
            ),
            onPressed: () async {
              final state = context.read<AppStateProvider>();
              await state.seedDefaultProducts();
              if (!context.mounted || state.lastError == null) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.lastError!)));
            },
            icon: const Icon(Icons.add_box_outlined),
            label: const Text('Add default products'),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusPanel extends StatelessWidget {
  const _OrderStatusPanel({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    const statuses = [
      'pending',
      'preparing',
      'picked_up',
      'shipped',
      'delivered',
      'cancelled',
    ];
    return _Panel(
      title: 'Order Status',
      child: Column(
        children: [
          for (final status in statuses)
            _StatusRow(
              label: status,
              count: orders.where((order) => order.status == status).length,
              total: orders.length,
            ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.count,
    required this.total,
  });

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _title(label),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text('$count'),
            ],
          ),
          SizedBox(height: 5.h),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            color: _AdminProductsScreenState._brand,
            backgroundColor: _AdminProductsScreenState._line,
          ),
        ],
      ),
    );
  }

  String _title(String value) => value[0].toUpperCase() + value.substring(1);
}

const _orderStatuses = [
  'pending',
  'preparing',
  'picked_up',
  'shipped',
  'delivered',
  'cancelled',
];

class _LowStockPanel extends StatelessWidget {
  const _LowStockPanel({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Low Stock Alerts',
      child: products.isEmpty
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Text('All products have healthy stock.'),
            )
          : Column(
              children: [
                for (final product in products)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.danger,
                    ),
                    title: Text(product.name),
                    trailing: Text(
                      '${product.stock} left',
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AdminProductsScreenState._line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final active = label == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? _AdminProductsScreenState._brand.withValues(alpha: 0.12)
            : AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? _AdminProductsScreenState._brand : AppColors.danger,
          fontWeight: FontWeight.w900,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

class _AdminAccessDenied extends StatelessWidget {
  const _AdminAccessDenied();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, color: AppColors.primary, size: 42.sp),
                SizedBox(height: 12.h),
                Text(
                  'Admin access only',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Customers can browse and order products, but only admins can edit the catalog.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                ),
              ],
            ),
          ),
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
  static const _categories = {
    'fruits': 'Fruits',
    'vegetables': 'Vegetables',
    'dairy': 'Dairy',
    'meat': 'Meat',
    'bakery': 'Bakery',
    'snacks': 'Snacks',
  };

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _stockController;
  late final TextEditingController _discountController;
  late String _category;

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
    _category = _categories.containsKey(product?.category)
        ? product!.category
        : 'fruits';
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
    _stockController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      category: _category,
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
            _CategoryField(
              value: _category,
              categories: _categories,
              onChanged: (value) => setState(() => _category = value),
            ),
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
                backgroundColor: _AdminProductsScreenState._brand,
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

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.value,
    required this.categories,
    required this.onChanged,
  });

  final String value;
  final Map<String, String> categories;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: categories.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        decoration: InputDecoration(
          labelText: 'Category',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
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
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
