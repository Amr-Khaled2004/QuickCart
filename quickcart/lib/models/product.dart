class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.rating,
    required this.price,
    required this.discount,
    required this.description,
  });

  final String id;
  final String name;
  final String category;
  final String image;
  final double rating;
  final double price;
  final int discount;
  final String description;
}
