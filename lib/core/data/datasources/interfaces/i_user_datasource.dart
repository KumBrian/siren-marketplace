import '../../models/user_model.dart';

abstract class IUserDataSource {
  Future<UserModel?> getById(String userId);

  Future<List<UserModel>> getByIds(List<String> userIds);

  Future<void> create(UserModel user);

  Future<void> update(UserModel user);

  Future<void> updateRating({
    required String userId,
    required double rating,
    required int reviewCount,
  });

  Future<bool> exists(String userId);
}
