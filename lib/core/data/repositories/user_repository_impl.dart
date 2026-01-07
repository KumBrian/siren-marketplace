import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/value_objects/rating.dart';
import '../../services/connectivity_service.dart';
import '../datasources/interfaces/i_user_datasource.dart';
import '../mappers/user_mapper.dart';

class UserRepositoryImpl implements IUserRepository {
  final IUserDataSource localDataSource;
  final IUserDataSource? remoteDataSource;
  final ConnectivityService? connectivityService;

  UserRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
    this.connectivityService,
  });

  @override
  Future<User?> getById(String userId) async {
    // 1. Try Remote if available
    if (remoteDataSource != null &&
        (await connectivityService?.hasConnection ?? true)) {
      try {
        final model = await remoteDataSource!.getById(userId);
        if (model != null) {
          // Cache to local
          try {
            await localDataSource.update(model);
          } catch (e) {
            print('DEBUG: Failed to cache user $userId: $e');
          }
          return UserMapper.toEntity(model);
        }
      } catch (e) {
        print('DEBUG: Failed to fetch user $userId from remote: $e');
        // Fallback to local
      }
    }

    // 2. Fallback to Local
    final model = await localDataSource.getById(userId);
    return model != null ? UserMapper.toEntity(model) : null;
  }

  @override
  Future<List<User>> getByIds(List<String> userIds) async {
    if (remoteDataSource != null &&
        (await connectivityService?.hasConnection ?? true)) {
      try {
        final models = await remoteDataSource!.getByIds(userIds);
        // Cache all
        for (final model in models) {
          try {
            await localDataSource.update(model);
          } catch (_) {}
        }
        return models.map((m) => UserMapper.toEntity(m)).toList();
      } catch (e) {
        // Fallback
      }
    }

    final models = await localDataSource.getByIds(userIds);
    return models.map((m) => UserMapper.toEntity(m)).toList();
  }

  @override
  Future<void> updateRole(String userId, UserRole role) async {
    // 1. Update Remote if available
    if (remoteDataSource != null &&
        (await connectivityService?.hasConnection ?? true)) {
      try {
        final model = await remoteDataSource!.getById(userId);
        if (model != null) {
          final updatedUser = model.copyWith(currentRole: role);
          final updatedModel = UserMapper.toModel(updatedUser);
          await remoteDataSource!.update(updatedModel);
        }
      } catch (e) {
        print('DEBUG: Failed to update role on remote: $e');
      }
    }

    // 2. Update Local
    final model = await localDataSource.getById(userId);
    if (model != null) {
      final updatedUser = model.copyWith(currentRole: role);
      final updatedModel = UserMapper.toModel(updatedUser);
      await localDataSource.update(updatedModel);
    }
  }

  @override
  Future<void> updateRating({
    required String userId,
    required Rating rating,
    required int reviewCount,
  }) async {
    if (remoteDataSource != null) {
      await remoteDataSource!.updateRating(
        userId: userId,
        rating: rating.value,
        reviewCount: reviewCount,
      );
    }
    await localDataSource.updateRating(
      userId: userId,
      rating: rating.value,
      reviewCount: reviewCount,
    );
  }

  @override
  Future<void> update(User user) async {
    final model = UserMapper.toModel(user);
    if (remoteDataSource != null) {
      await remoteDataSource!.update(model);
    }
    await localDataSource.update(model);
  }

  @override
  Future<void> create(User user) async {
    final model = UserMapper.toModel(user);
    if (remoteDataSource != null) {
      await remoteDataSource!.create(model);
    }
    await localDataSource.create(model);
  }

  @override
  Future<bool> exists(String userId) async {
    // Check local first for speed? Or remote for accuracy?
    // "Exists" usually implies "is registered".
    if (remoteDataSource != null &&
        (await connectivityService?.hasConnection ?? true)) {
      try {
        return await remoteDataSource!.exists(userId);
      } catch (_) {}
    }
    return await localDataSource.exists(userId);
  }

  @override
  Future<User?> getFirstFisher() async {
    if (remoteDataSource != null &&
        (await connectivityService?.hasConnection ?? true)) {
      try {
        final model = await remoteDataSource!.getFirstFisher();
        if (model != null) {
          await localDataSource.update(model); // Cache
          return UserMapper.toEntity(model);
        }
      } catch (_) {}
    }
    final model = await localDataSource.getFirstFisher();
    if (model == null) return null;
    return UserMapper.toEntity(model);
  }

  @override
  Future<User?> getFirstBuyer() async {
    if (remoteDataSource != null &&
        (await connectivityService?.hasConnection ?? true)) {
      try {
        final model = await remoteDataSource!.getFirstBuyer();
        if (model != null) {
          await localDataSource.update(model); // Cache
          return UserMapper.toEntity(model);
        }
      } catch (_) {}
    }
    final model = await localDataSource.getFirstBuyer();
    if (model == null) return null;
    return UserMapper.toEntity(model);
  }
}
