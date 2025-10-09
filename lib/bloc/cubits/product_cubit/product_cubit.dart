import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/constants/types.dart' show Product;
import 'package:siren_marketplace/data/mock_repo.dart' show Repository;

class ProductCubit extends Cubit<List<Product>> {
  final Repository repository;

  ProductCubit(this.repository) : super([]);

  Future<void> loadProducts() async {
    final products = await repository.getAvailableProducts();
    emit(products);
  }
}
