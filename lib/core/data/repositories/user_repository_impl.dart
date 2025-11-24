import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/value_objects/rating.dart';
import '../datasources/interfaces/i_user_datasource.dart';
import '../mappers/user_mapper.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements IUserRepository {
  final IUserDataSource dataSource;

  UserRepositoryImpl({required this.dataSource});

  @override
  Future<User?> getById(String userId) async {
    final model = await dataSource.getById(userId);
    return model != null ? UserMapper.toEntity(model) : null;
  }

  @override
  Future<List<User>> getByIds(List<String> userIds) async {
    final models = await dataSource.getByIds(userIds);
    return models.map((m) => UserMapper.toEntity(m)).toList();
  }

  @override
  Future<void> updateRole(String userId, UserRole role) async {
    final model = await dataSource.getById(userId);
    if (model == null) throw ArgumentError('User not found');

    final updated = UserModel(
      id: model.id,
      name: model.name,
      avatarUrl: model.avatarUrl,
      rating: model.rating,
      reviewCount: model.reviewCount,
      currentRole: role.name,
    );

    await dataSource.update(updated);
  }

  @override
  Future<void> updateRating({
    required String userId,
    required Rating rating,
    required int reviewCount,
  }) async {
    await dataSource.updateRating(
      userId: userId,
      rating: rating.value,
      reviewCount: reviewCount,
    );
  }

  @override
  Future<void> update(User user) async {
    final model = UserMapper.toModel(user);
    await dataSource.update(model);
  }

  @override
  Future<bool> exists(String userId) async {
    return await dataSource.exists(userId);
  }
}
