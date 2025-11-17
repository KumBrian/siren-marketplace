import '../../domain/models/user.dart';
import '../datasources/user_datasource.dart';

class UserRepository {
  final UserDataSource dataSource;

  UserRepository({required this.dataSource});

  Future<void> createOrReplaceUser(User u) => dataSource.insertUser(u);

  Future<User?> getUserById(String id) => dataSource.getUserById(id);

  Future<List<User>> getAllUsers() => dataSource.getAllUsers();

  Future<void> updateUser(User u) => dataSource.updateUser(u);

  Future<void> deleteUser(String id) => dataSource.deleteUser(id);
}
