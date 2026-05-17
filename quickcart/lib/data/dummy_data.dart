import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/category_item.dart';
import '../models/product.dart';

class DummyData {
  const DummyData._();

  static const categories = [
    CategoryItem(
      name: 'Veggies',
      icon: Icons.eco,
      color: Color(0xFF4FB06D),
      emoji: '🥦',
    ),
    CategoryItem(
      name: 'Fruits',
      icon: Icons.apple,
      color: Color(0xFFE84343),
      emoji: '🍎',
    ),
    CategoryItem(
      name: 'Dairy',
      icon: Icons.local_drink,
      color: Colors.white,
      emoji: '🥛',
    ),
    CategoryItem(
      name: 'Meat',
      icon: Icons.set_meal,
      color: Color(0xFFC62828),
      emoji: '🍗',
    ),
    CategoryItem(
      name: 'Bakery',
      icon: Icons.bakery_dining,
      color: Color(0xFFE8B13D),
      emoji: '🍞',
    ),
    CategoryItem(
      name: 'Snacks',
      icon: Icons.cookie,
      color: Color(0xFF4D2434),
      emoji: '🍫',
    ),
  ];

  static const products = [
    Product(
      id: 'p1',
      name: 'Red Apples',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=1200&q=90',
      rating: 4.9,
      price: 145,
      discount: 12,
      description:
          'Crisp, sweet red apples picked fresh for healthy snacks, baking, and lunch boxes.',
    ),
    Product(
      id: 'p2',
      name: 'Green Apples',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      price: 160,
      discount: 10,
      description: 'Bright green apples with a refreshing tang and firm bite.',
    ),
    Product(
      id: 'p3',
      name: 'Seedless Grapes',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1537640538966-79f369143f8f?auto=format&fit=crop&w=1200&q=90',
      rating: 4.9,
      price: 135,
      discount: 10,
      description:
          'Imported seedless grapes with juicy sweetness in every handful.',
    ),
    Product(
      id: 'p4',
      name: 'Fresh Broccoli',
      category: 'vegetables',
      image:
          'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 75,
      discount: 8,
      description:
          'Green broccoli florets packed with flavor for stir fries, soups, and roasting.',
    ),
    Product(
      id: 'p5',
      name: 'Whole Toast',
      category: 'bakery',
      image:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=1200&q=90',
      rating: 4.6,
      price: 55,
      discount: 15,
      description:
          'Soft whole-grain toast slices baked fresh for breakfast and sandwiches.',
    ),
    Product(
      id: 'p6',
      name: 'Fresh Milk',
      category: 'dairy',
      image:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 48,
      discount: 0,
      description:
          'Creamy farm-raised milk for cereal, coffee, smoothies, and cooking.',
    ),
    Product(
      id: 'p7',
      name: 'Chicken Breast',
      category: 'meat',
      image:
          'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      price: 260,
      discount: 12,
      description: 'Lean chicken breast prepared for quick weeknight meals.',
    ),
    Product(
      id: 'p8',
      name: 'Chocolate Bars',
      category: 'snacks',
      image:
          'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?auto=format&fit=crop&w=1200&q=90',
      rating: 4.5,
      price: 45,
      discount: 20,
      description: 'Rich chocolate bars for a sweet treat during the day.',
    ),
    Product(
      id: 'p9',
      name: 'Watermelon',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1563114773-84221bd62daa?auto=format&fit=crop&w=1200&q=90',
      rating: 4.5,
      price: 28,
      discount: 15,
      description: 'Locally grown watermelon, cool and naturally sweet.',
    ),
  ];

  static List<Product> byCategory(String category) {
    return products.where((product) => product.category == category).toList();
  }

  static const promoColors = [AppColors.primary, AppColors.primaryDark];
}
