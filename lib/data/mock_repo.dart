import 'package:siren_marketplace/constants/types.dart';

abstract class Repository {
  // This is the interface
  Role get role;

  Future<Role> getUserRole();

  Future<Fisher> getFisher();

  Future<Buyer> getBuyer();

  Future<List<Product>> getAvailableProducts();
}
