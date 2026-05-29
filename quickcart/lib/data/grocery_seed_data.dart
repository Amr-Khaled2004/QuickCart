import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/category_item.dart';
import '../models/product.dart';

class GrocerySeedData {
  const GrocerySeedData._();

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
      id: 'seed-red-apples',
      name: 'Red Apples',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=1200&q=90',
      rating: 4.9,
      price: 145,
      discount: 12,
      description:
          'Crisp, sweet red apples picked fresh for healthy snacks, baking, and lunch boxes.',
      stock: 80,
    ),
    Product(
      id: 'seed-green-apples',
      name: 'Green Apples',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      price: 160,
      discount: 10,
      description: 'Bright green apples with a refreshing tang and firm bite.',
      stock: 70,
    ),
    Product(
      id: 'seed-seedless-grapes',
      name: 'Seedless Grapes',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1537640538966-79f369143f8f?auto=format&fit=crop&w=1200&q=90',
      rating: 4.9,
      price: 135,
      discount: 10,
      description:
          'Imported seedless grapes with juicy sweetness in every handful.',
      stock: 55,
    ),
    Product(
      id: 'seed-fresh-broccoli',
      name: 'Fresh Broccoli',
      category: 'vegetables',
      image:
          'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 75,
      discount: 8,
      description:
          'Green broccoli florets packed with flavor for stir fries, soups, and roasting.',
      stock: 65,
    ),
    Product(
      id: 'seed-whole-toast',
      name: 'Whole Toast',
      category: 'bakery',
      image:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=1200&q=90',
      rating: 4.6,
      price: 55,
      discount: 15,
      description:
          'Soft whole-grain toast slices baked fresh for breakfast and sandwiches.',
      stock: 45,
    ),
    Product(
      id: 'seed-fresh-milk',
      name: 'Fresh Milk',
      category: 'dairy',
      image:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 48,
      discount: 0,
      description:
          'Creamy farm-raised milk for cereal, coffee, smoothies, and cooking.',
      stock: 90,
    ),
    Product(
      id: 'seed-chicken-breast',
      name: 'Chicken Breast',
      category: 'meat',
      image:
          'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      price: 260,
      discount: 12,
      description: 'Lean chicken breast prepared for quick weeknight meals.',
      stock: 38,
    ),
    Product(
      id: 'seed-chocolate-bars',
      name: 'Chocolate Bars',
      category: 'snacks',
      image:
          'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?auto=format&fit=crop&w=1200&q=90',
      rating: 4.5,
      price: 45,
      discount: 20,
      description: 'Rich chocolate bars for a sweet treat during the day.',
      stock: 120,
    ),
    Product(
      id: 'seed-watermelon',
      name: 'Watermelon',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1563114773-84221bd62daa?auto=format&fit=crop&w=1200&q=90',
      rating: 4.5,
      price: 28,
      discount: 15,
      description: 'Locally grown watermelon, cool and naturally sweet.',
      stock: 42,
    ),
    Product(
      id: 'seed-bananas',
      name: 'Bananas',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 68,
      discount: 5,
      description:
          'Naturally sweet bananas for breakfast, smoothies, and quick energy.',
      stock: 95,
    ),
    Product(
      id: 'seed-strawberries',
      name: 'Fresh Strawberries',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=1200&q=90',
      rating: 4.9,
      price: 115,
      discount: 18,
      description:
          'Juicy strawberries with a bright, sweet flavor for desserts and snacks.',
      stock: 48,
    ),
    Product(
      id: 'seed-oranges',
      name: 'Baladi Oranges',
      category: 'fruits',
      image:
          'https://images.unsplash.com/photo-1582979512210-99b6a53386f9?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      price: 52,
      discount: 8,
      description: 'Fresh Egyptian oranges full of juice and citrus aroma.',
      stock: 88,
    ),
    Product(
      id: 'seed-tomatoes',
      name: 'Fresh Tomatoes',
      category: 'vegetables',
      image:
          'https://images.unsplash.com/photo-1546470427-e26264be0b0d?auto=format&fit=crop&w=1200&q=90',
      rating: 4.6,
      price: 32,
      discount: 0,
      description:
          'Ripe tomatoes for salads, sauces, sandwiches, and everyday cooking.',
      stock: 110,
    ),
    Product(
      id: 'seed-cucumbers',
      name: 'Cucumbers',
      category: 'vegetables',
      image:
          'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      price: 30,
      discount: 0,
      description:
          'Crunchy cucumbers with a cool fresh taste for salads and sides.',
      stock: 100,
    ),
    Product(
      id: 'seed-potatoes',
      name: 'Potatoes',
      category: 'vegetables',
      image:
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 25,
      discount: 0,
      description: 'Versatile potatoes for frying, baking, mashing, and stews.',
      stock: 150,
    ),
    Product(
      id: 'seed-carrots',
      name: 'Carrots',
      category: 'vegetables',
      image:
          'https://images.unsplash.com/photo-1445282768818-728615cc910a?auto=format&fit=crop&w=1200&q=90',
      rating: 4.6,
      price: 28,
      discount: 4,
      description:
          'Sweet crunchy carrots for soups, roasting, juices, and lunch boxes.',
      stock: 85,
    ),
    Product(
      id: 'seed-eggs',
      name: 'Farm Eggs',
      category: 'dairy',
      image:
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 165,
      discount: 6,
      description:
          'Fresh farm eggs packed by the dozen for breakfast and baking.',
      stock: 60,
    ),
    Product(
      id: 'seed-yogurt',
      name: 'Plain Yogurt',
      category: 'dairy',
      image:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      price: 42,
      discount: 0,
      description:
          'Creamy plain yogurt for breakfast bowls, dips, and light snacks.',
      stock: 75,
    ),
    Product(
      id: 'seed-cheddar-cheese',
      name: 'Cheddar Cheese',
      category: 'dairy',
      image:
          'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=1200&q=90',
      rating: 4.6,
      price: 125,
      discount: 10,
      description:
          'Sharp cheddar cheese slices for sandwiches, burgers, and platters.',
      stock: 40,
    ),
    Product(
      id: 'seed-minced-beef',
      name: 'Minced Beef',
      category: 'meat',
      image:
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?auto=format&fit=crop&w=1200&q=90',
      rating: 4.7,
      price: 340,
      discount: 8,
      description:
          'Fresh minced beef ready for kofta, pasta sauces, burgers, and pies.',
      stock: 32,
    ),
    Product(
      id: 'seed-salmon-fillet',
      name: 'Salmon Fillet',
      category: 'meat',
      image:
          'https://images.unsplash.com/photo-1574781330855-d0db8cc6a79c?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 520,
      discount: 14,
      description:
          'Tender salmon fillet with rich flavor for grilling, baking, or pan searing.',
      stock: 24,
    ),
    Product(
      id: 'seed-baguette',
      name: 'French Baguette',
      category: 'bakery',
      image:
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?auto=format&fit=crop&w=1200&q=90',
      rating: 4.6,
      price: 38,
      discount: 0,
      description:
          'Crispy golden baguette with a soft center, baked fresh daily.',
      stock: 50,
    ),
    Product(
      id: 'seed-croissants',
      name: 'Butter Croissants',
      category: 'bakery',
      image:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=1200&q=90',
      rating: 4.9,
      price: 72,
      discount: 12,
      description:
          'Flaky butter croissants for breakfast, coffee breaks, and desserts.',
      stock: 36,
    ),
    Product(
      id: 'seed-potato-chips',
      name: 'Potato Chips',
      category: 'snacks',
      image:
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?auto=format&fit=crop&w=1200&q=90',
      rating: 4.4,
      price: 35,
      discount: 10,
      description:
          'Crispy salted potato chips for movie nights and quick snacking.',
      stock: 130,
    ),
    Product(
      id: 'seed-mixed-nuts',
      name: 'Mixed Nuts',
      category: 'snacks',
      image:
          'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?auto=format&fit=crop&w=1200&q=90',
      rating: 4.8,
      price: 155,
      discount: 7,
      description: 'Roasted mixed nuts with almonds, cashews, and hazelnuts.',
      stock: 58,
    ),
    Product(
      id: 'seed-orange-juice',
      name: 'Orange Juice',
      category: 'dairy',
      image:
          'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=1200&q=90',
      rating: 4.6,
      price: 60,
      discount: 5,
      description:
          'Fresh orange juice with bright citrus flavor and no heavy aftertaste.',
      stock: 72,
    ),
  ];

  static List<Product> byCategory(String category) {
    return products.where((product) => product.category == category).toList();
  }

  static const promoColors = [AppColors.primary, AppColors.primaryDark];
}
