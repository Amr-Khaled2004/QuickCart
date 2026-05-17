import '../data/dummy_data.dart';
import '../models/product.dart';

class MockGroceryService {
  const MockGroceryService();

  List<Product> getProducts() => DummyData.products;

  List<Product> getProductsByCategory(String category) =>
      DummyData.byCategory(category);
}
