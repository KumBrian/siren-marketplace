import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/api_exception.dart';
import '../../../../core/data/api/models/auth_api_models.dart';
import '../../../../core/data/mappers/account_api_mapper.dart';
import '../../../../core/data/mappers/user_mapper.dart';
import '../../models/user_model.dart';
import '../interfaces/i_user_datasource.dart';

class UserApiDataSource implements IUserDataSource {
  final ApiClient _client;

  UserApiDataSource({required ApiClient client}) : _client = client;

  @override
  Future<UserModel?> getById(String userId) async {
    try {
      final response = await _client.get(ApiConfig.account(userId));
      var data = response.data;
      if (data is List) {
        if (data.isEmpty) return null;
        data = data.first;
      }
      final account = AccountApiModel.fromJson(data);
      final user = AccountApiMapper.toDomain(account);
      return UserMapper.toModel(user);
    } catch (e) {
      if (e is NotFoundException) return null;
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> getByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    // Assuming API supports filtering by IDs, or we fetch list and filter
    // For now, let's try fetching individual users in parallel (not efficient but safe)
    // TODO: Optimize with bulk fetch endpoint if available
    final futures = userIds.map((id) => getById(id));
    final results = await Future.wait(futures);
    return results.whereType<UserModel>().toList();
  }

  @override
  Future<void> create(UserModel user) async {
    // User creation is handled via Auth registration
    throw UnimplementedError('User creation should be done via Auth API');
  }

  @override
  Future<void> update(UserModel user) async {
    // Map UserModel back to API request
    // We only update profile fields
    final data = {
      'name': user.name,
      'phone': null, // UserModel doesn't have phone
      'avatar': user.avatarUrl,
    };

    await _client.patch(ApiConfig.updateProfile, data: data);
  }

  @override
  Future<void> updateRating({
    required String userId,
    required double rating,
    required int reviewCount,
  }) async {
    // Rating is calculated by backend based on reviews
    // We cannot directly update it
    // Just log or ignore
    print('Warning: Direct rating update not supported by API');
  }

  @override
  Future<bool> exists(String userId) async {
    final user = await getById(userId);
    return user != null;
  }

  @override
  Future<UserModel?> getFirstFisher() async {
    try {
      final response = await _client.get(
        ApiConfig.accountsList,
        queryParameters: {'role': 'fisher', 'limit': 1},
      );

      final List data = response.data['data'] ?? [];
      if (data.isEmpty) return null;

      final account = AccountApiModel.fromJson(data.first);
      final user = AccountApiMapper.toDomain(account);
      return UserMapper.toModel(user);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel?> getFirstBuyer() async {
    try {
      final response = await _client.get(
        ApiConfig.accountsList,
        queryParameters: {'role': 'buyer', 'limit': 1},
      );

      final List data = response.data['data'] ?? [];
      if (data.isEmpty) return null;

      final account = AccountApiModel.fromJson(data.first);
      final user = AccountApiMapper.toDomain(account);
      return UserMapper.toModel(user);
    } catch (e) {
      return null;
    }
  }
}
