import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/i_session_repository.dart';
import '../datasources/interfaces/i_session_datasource.dart';
import '../mappers/user_mapper.dart';

class SessionRepositoryImpl implements ISessionRepository {
  final ISessionDataSource dataSource;

  SessionRepositoryImpl({required this.dataSource});

  @override
  Future<User?> getCurrentUser() async {
    final model = await dataSource.getCurrentUser();
    return model != null ? UserMapper.toEntity(model) : null;
  }

  @override
  Future<UserRole?> getCurrentRole() async {
    final roleString = await dataSource.getCurrentRole();
    if (roleString == null) return null;

    return UserRole.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () => UserRole.buyer,
    );
  }

  @override
  Future<void> saveCurrentUser(User user) async {
    final model = UserMapper.toModel(user);
    await dataSource.saveCurrentUser(model);
  }

  @override
  Future<void> saveCurrentRole(UserRole role) async {
    await dataSource.saveCurrentRole(role.name);
  }

  @override
  Future<void> clearSession() async {
    await dataSource.clearSession();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await dataSource.isLoggedIn();
  }
}
