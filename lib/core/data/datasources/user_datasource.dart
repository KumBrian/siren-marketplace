import '../../domain/models/user.dart';

abstract class UserDataSource {
  Future<void> insertUser(User user);

  Future<User?> getUserById(String id);

  Future<List<User>> getAllUsers();

  Future<void> updateUser(User user);

  Future<void> deleteUser(String id);
}
