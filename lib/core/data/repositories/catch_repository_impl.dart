import '../../domain/entities/catch.dart';
import '../../domain/enums/catch_status.dart';
import '../../domain/repositories/i_catch_repository.dart';
import '../datasources/interfaces/i_catch_datasource.dart';
import '../mappers/catch_mapper.dart';

import '../../services/connectivity_service.dart';

class CatchRepositoryImpl implements ICatchRepository {
  final ICatchDataSource remoteDataSource;
  final ICatchDataSource localDataSource;
  final ConnectivityService connectivityService;

  CatchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  Future<bool> get _isOffline async {
    final status = await connectivityService.checkConnectivity();
    return status == NetworkStatus.offline;
  }

  @override
  Future<String> create(Catch catch_) async {
    final model = CatchMapper.toModel(catch_);
    return await remoteDataSource.create(model);
  }

  @override
  Future<void> saveDraft(Catch catch_) async {
    final model = CatchMapper.toModel(catch_);
    await localDataSource.create(model);
  }

  @override
  Future<String> publishDraft(Catch draft) async {
    // 1. Check if it's a local draft in SQLite
    // We use a try-catch or nullable check if getById throws or returns null
    // Assuming getById returns null if not found.
    bool isLocal = false;
    try {
      final localCatch = await localDataSource.getById(draft.id);
      if (localCatch != null) {
        isLocal = true;
      }
    } catch (_) {}

    if (isLocal) {
      // It is a LOCAL draft.
      // Create in remote (uploads images + creates entity)
      final catchToPublish = draft.copyWith(status: CatchStatus.available);
      final model = CatchMapper.toModel(catchToPublish);

      final newId = await remoteDataSource.create(model);

      // Delete local draft
      await localDataSource.delete(draft.id);

      return newId;
    } else {
      // It is a REMOTE draft (already uploaded).
      // Just update the status on the backend.
      final catchToPublish = draft.copyWith(status: CatchStatus.available);
      await update(catchToPublish);
      return draft.id;
    }
  }

  @override
  Future<Catch?> getById(String catchId) async {
    // Optimization: check offline first
    if (await _isOffline) {
      final localModel = await localDataSource.getById(catchId);
      return localModel != null ? CatchMapper.toEntity(localModel) : null;
    }

    // Try local first (for drafts)
    try {
      final localModel = await localDataSource.getById(catchId);
      if (localModel != null) {
        return CatchMapper.toEntity(localModel);
      }
    } catch (_) {
      // Ignore error and try remote
    }

    final model = await remoteDataSource.getById(catchId);
    if (model != null) {
      await localDataSource.saveBatch([model]);
    }
    return model != null ? CatchMapper.toEntity(model) : null;
  }

  @override
  Future<List<Catch>> getByFisherId(String fisherId) async {
    // 1. Get drafts locally
    final draftModels = await localDataSource.getByStatus(CatchStatus.draft);
    final draftCatches = draftModels
        .map((m) => CatchMapper.toEntity(m))
        .toList();

    List<Catch> remoteCatches = [];

    // Optimization: if offline, just get non-drafts locally
    if (await _isOffline) {
      final localModels = await localDataSource.getByFisherId(fisherId);
      // Filter out drafts as we already have them
      remoteCatches = localModels
          .where((m) => m.status != CatchStatus.draft.name)
          .map((m) => CatchMapper.toEntity(m))
          .toList();
      return [...draftCatches, ...remoteCatches];
    }

    try {
      // 2. Try fetching remote catches
      final remoteModels = await remoteDataSource.getByFisherId(fisherId);

      // 3. Cache them locally
      await localDataSource.saveBatch(remoteModels);

      remoteCatches = remoteModels.map((m) => CatchMapper.toEntity(m)).toList();
    } catch (e) {
      // 4. Fallback: fetch from local cache (excluding drafts which we already have)
      try {
        final localModels = await localDataSource.getByFisherId(fisherId);
        // Filter out drafts as we already have them
        remoteCatches = localModels
            .where((m) => m.status != CatchStatus.draft.name)
            .map((m) => CatchMapper.toEntity(m))
            .toList();
      } catch (_) {}
    }

    // Merge: drafts first, then remote/cached
    return [...draftCatches, ...remoteCatches];
  }

  @override
  Future<List<Catch>> getAvailableCatches() async {
    if (await _isOffline) {
      final models = await localDataSource.getByStatus(CatchStatus.available);
      return models.map((m) => CatchMapper.toEntity(m)).toList();
    }

    try {
      final models = await remoteDataSource.getByStatus(CatchStatus.available);
      // Cache locally
      await localDataSource.saveBatch(models);
      return models.map((m) => CatchMapper.toEntity(m)).toList();
    } catch (e) {
      // Fallback to local
      final models = await localDataSource.getByStatus(CatchStatus.available);
      return models.map((m) => CatchMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Catch>> getByStatus(CatchStatus status) async {
    List<Catch> remoteCatches = [];

    // Check offline for non-drafts
    if (status != CatchStatus.draft && await _isOffline) {
      final localModels = await localDataSource.getByStatus(status);
      return localModels.map((m) => CatchMapper.toEntity(m)).toList();
    }

    // Attempt remote fetch and cache if not looking for local-only drafts
    if (status != CatchStatus.draft) {
      try {
        final remoteModels = await remoteDataSource.getByStatus(status);
        await localDataSource.saveBatch(remoteModels);
        remoteCatches = remoteModels
            .map((m) => CatchMapper.toEntity(m))
            .toList();
      } catch (e) {
        // Fallback
        final localModels = await localDataSource.getByStatus(status);
        remoteCatches = localModels
            .map((m) => CatchMapper.toEntity(m))
            .toList();
      }
    }

    // If specifically asking for drafts, or we just want everything including drafts
    if (status == CatchStatus.draft) {
      final localModels = await localDataSource.getByStatus(status);
      final localCatches = localModels
          .map((m) => CatchMapper.toEntity(m))
          .toList();
      // For draft status, we usually only care about local, but if we had remote logic before, keep it?
      // Usually drafts are local-only.
      return localCatches;
    }

    return remoteCatches;
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
    if (catch_.status == CatchStatus.draft) {
      await localDataSource.update(model);
    } else {
      await remoteDataSource.update(model);
    }
  }

  @override
  Future<void> delete(String catchId) async {
    // Try delete both to be safe
    try {
      await localDataSource.delete(catchId);
    } catch (_) {}
    await remoteDataSource.delete(catchId);
  }

  @override
  Future<void> updateBatch(List<Catch> catches) async {
    final models = catches.map((c) => CatchMapper.toModel(c)).toList();
    await remoteDataSource.updateBatch(models);
  }

  @override
  Future<void> deleteBatch(List<String> catchIds) async {
    try {
      await localDataSource.deleteBatch(catchIds);
    } catch (_) {}
    await remoteDataSource.deleteBatch(catchIds);
  }

  @override
  Future<void> saveLocalBatch(List<Catch> catches) async {
    final models = catches
        .map((entity) => CatchMapper.toModel(entity))
        .toList();
    await localDataSource.saveBatch(models);
  }
}
