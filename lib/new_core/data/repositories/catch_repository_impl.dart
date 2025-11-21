import '../../domain/entities/catch.dart';
import '../../domain/enums/catch_status.dart';
import '../../domain/repositories/i_catch_repository.dart';
import '../datasources/interfaces/i_catch_datasource.dart';
import '../mappers/catch_mapper.dart';

class CatchRepositoryImpl implements ICatchRepository {
  final ICatchDataSource dataSource;

  CatchRepositoryImpl({required this.dataSource});

  @override
  Future<String> create(Catch catch_) async {
    final model = CatchMapper.toModel(catch_);
    return await dataSource.create(model);
  }

  @override
  Future<Catch?> getById(String catchId) async {
    final model = await dataSource.getById(catchId);
    return model != null ? CatchMapper.toEntity(model) : null;
  }

  @override
  Future<List<Catch>> getByFisherId(String fisherId) async {
    final models = await dataSource.getByFisherId(fisherId);
    return models.map((m) => CatchMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Catch>> getAvailableCatches() async {
    final models = await dataSource.getByStatus(CatchStatus.available);
    return models.map((m) => CatchMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Catch>> getByStatus(CatchStatus status) async {
    final models = await dataSource.getByStatus(status);
    return models.map((m) => CatchMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Catch>> getExpiredCatches() async {
    return await getByStatus(CatchStatus.expired);
  }

  @override
  Future<List<Catch>> getCatchesForDeletion() async {
    final expired = await getExpiredCatches();
    return expired.where((c) => c.shouldBeDeleted).toList();
  }

  @override
  Future<void> update(Catch catch_) async {
    final model = CatchMapper.toModel(catch_);
    await dataSource.update(model);
  }

  @override
  Future<void> delete(String catchId) async {
    await dataSource.delete(catchId);
  }

  @override
  Future<void> updateBatch(List<Catch> catches) async {
    final models = catches.map((c) => CatchMapper.toModel(c)).toList();
    await dataSource.updateBatch(models);
  }

  @override
  Future<void> deleteBatch(List<String> catchIds) async {
    await dataSource.deleteBatch(catchIds);
  }
}
