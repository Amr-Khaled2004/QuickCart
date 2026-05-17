import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.emoji,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String emoji;
}
