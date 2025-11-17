import 'package:siren_marketplace/core/data/persistence/catch_entity.dart';
import 'package:siren_marketplace/core/domain/models/catch.dart';

import '../datasources/catch_datasource.dart';

class CatchRepository {
  final CatchDataSource dataSource;

  CatchRepository({required this.dataSource});

  Future<void> createOrReplaceCatch(Catch c) async {
    final entity = CatchEntity.fromDomain(c);
    await dataSource.insertCatch(entity);
  }

  Future<Catch?> getCatchById(String id) async {
    final entity = await dataSource.getCatchById(id);
    if (entity == null) return null;
    return entity.toDomain();
  }

  Future<List<Catch>> getAllCatches() async {
    final entities = await dataSource.getAllCatches();
    return entities.map((e) => e.toDomain()).toList();
  }

  Future<List<Catch>> getCatchesByFisherId(String fisherId) async {
    final entities = await dataSource.getCatchesByFisherId(fisherId);
    return entities.map((e) => e.toDomain()).toList();
  }

  Future<void> updateCatch(Catch c) async {
    final entity = CatchEntity.fromDomain(c);
    await dataSource.updateCatch(entity);
  }

  Future<void> deleteCatch(String id) async {
    await dataSource.deleteCatch(id);
  }
}
