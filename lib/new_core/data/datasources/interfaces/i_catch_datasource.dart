import '../../../domain/enums/catch_status.dart';
import '../../models/catch_model.dart';

abstract class ICatchDataSource {
  Future<String> create(CatchModel catchItem);

  Future<CatchModel?> getById(String catchId);

  Future<List<CatchModel>> getByFisherId(String fisherId);

  Future<List<CatchModel>> getByStatus(CatchStatus status);

  Future<List<CatchModel>> getAll();

  Future<void> update(CatchModel catchItem);

  Future<void> delete(String catchId);

  Future<void> updateBatch(List<CatchModel> catches);

  Future<void> deleteBatch(List<String> catchIds);
}
