import 'package:siren_marketplace/core/data/persistence/catch_entity.dart';

abstract class CatchDataSource {
  Future<void> insertCatch(CatchEntity entity);

  Future<CatchEntity?> getCatchById(String id);

  Future<List<CatchEntity>> getAllCatches();

  Future<List<CatchEntity>> getCatchesByFisherId(String fisherId);

  Future<void> updateCatch(CatchEntity entity);

  Future<void> deleteCatch(String id);
}
