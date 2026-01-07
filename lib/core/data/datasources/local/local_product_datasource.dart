import 'package:siren_marketplace/core/data/database/database_helper.dart';
import '../../models/product_model.dart';

abstract class LocalProductDataSource {
  /// Save a batch of products to local storage
  Future<void> saveBatch(List<ProductModel> products);

  /// Get all cached products
  Future<List<ProductModel>> getAllProducts();

  /// Get cached product by ID
  Future<ProductModel?> getProductById(String id);

  /// Get cached products by fisher ID
  Future<List<ProductModel>> getProductsByFisherId(String fisherId);
}

class LocalProductDataSourceImpl implements LocalProductDataSource {
  final DatabaseHelper dbHelper;

  LocalProductDataSourceImpl({required this.dbHelper});

  @override
  Future<void> saveBatch(List<ProductModel> products) async {
    final maps = products.map((e) => e.toMap()).toList();
    await dbHelper.insertProductsBatch(maps);
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final maps = await dbHelper.getAllProducts();
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByFisherId(String fisherId) async {
    final maps = await dbHelper.getProductsByFisherId(fisherId);
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final map = await dbHelper.getProductById(id);
    if (map != null) {
      return ProductModel.fromMap(map);
    }
    return null;
  }
}
