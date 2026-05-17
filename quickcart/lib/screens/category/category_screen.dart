import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/common/cart_icon_button.dart';
import '../../widgets/common/promo_banner.dart';
import '../../widgets/common/quick_search_field.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/product/product_card.dart';
import '../home/home_shell.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  static const routeName = '/category';

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _query = '';
  String _filter = 'All';

  void _openCart() {
    context.read<AppStateProvider>().setTab(1);
    Navigator.popUntil(context, ModalRoute.withName(HomeShell.routeName));
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments as String?;
    final category = arg ?? 'fruits';
    final provider = context.watch<AppStateProvider>();
    final categoryProducts = provider.productsByCategory(category);
    final baseProducts = categoryProducts.isEmpty && category != 'all'
        ? provider.products
        : categoryProducts;
    final query = _query.toLowerCase();
    final products = baseProducts.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        'Tropical' =>
          product.name.toLowerCase().contains('watermelon') ||
              product.name.toLowerCase().contains('grapes'),
        'Organic' =>
          product.category == 'fruits' || product.category == 'vegetables',
        'On Sale' => product.discount > 0,
        _ => true,
      };
      return matchesSearch && matchesFilter;
    }).toList();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _CategoryHeader(
                title: _label(category),
                onCartTap: _openCart,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
                child: QuickSearchField(
                  hint: 'Search ${_label(category).toLowerCase()}...',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _FilterChips(
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
            ),
            SliverToBoxAdapter(
              child: PromoBanner(
                title: 'Tropical Fruits\nBuy 2 Get 1 Free',
                subtitle: 'This week only!',
                icon: Icons.local_florist,
                onTap: () => setState(() => _filter = 'Tropical'),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Featured',
                onActionTap: () => setState(() {
                  _filter = 'All';
                  _query = '';
                }),
              ),
            ),
            SliverToBoxAdapter(child: _FeaturedList(products: products)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'All ${_label(category)}',
                action: null,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 20.h),
              sliver: SliverGrid.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 520
                      ? 3
                      : 2,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (_, index) =>
                    ProductCard(product: products[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(String value) {
    if (value == 'all') return 'Products';
    if (value == 'organic') return 'Organic';
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title, required this.onCartTap});

  final String title;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 22.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
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
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          CartIconButton(onPressed: onCartTap),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Tropical', 'Organic', 'On Sale'];
    return SizedBox(
      height: 56.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (_, index) => ChoiceChip(
          label: Text(filters[index]),
          selected: selected == filters[index],
          onSelected: (_) => onSelected(filters[index]),
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: selected == filters[index]
                ? Colors.white
                : AppColors.textDark,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

class _FeaturedList extends StatelessWidget {
  const _FeaturedList({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        scrollDirection: Axis.horizontal,
        itemCount: products.take(3).length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (_, index) => SizedBox(
          width: 132.w,
          child: ProductCard(
            product: products[index],
            compact: true,
            heroEnabled: false,
          ),
        ),
      ),
    );
  }
}
