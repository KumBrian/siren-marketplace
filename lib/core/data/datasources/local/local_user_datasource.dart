import 'package:sqflite/sqflite.dart';
import '../../../../core/data/database/database_helper.dart';
import '../../models/user_model.dart';
import '../interfaces/i_user_datasource.dart';

class LocalUserDataSource implements IUserDataSource {
  final DatabaseHelper dbHelper;

  LocalUserDataSource({required this.dbHelper});

  @override
  Future<UserModel?> getById(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  @override
  Future<List<UserModel>> getByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final db = await dbHelper.database;
    final placeholders = List.filled(userIds.length, '?').join(', ');

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id IN ($placeholders)',
      whereArgs: userIds,
    );

    return maps.map((m) => UserModel.fromMap(m)).toList();
  }

  @override
  Future<void> create(UserModel user) async {
    final db = await dbHelper.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(UserModel user) async {
    final db = await dbHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<void> updateRating({
    required String userId,
    required double rating,
    required int reviewCount,
  }) async {
    await dbHelper.updateUserRatingMetrics(
      userId: userId,
      newAverageRating: rating,
      newReviewCount: reviewCount,
    );
  }

  @override
  Future<bool> exists(String userId) async {
    final user = await getById(userId);
    return user != null;
  }

  @override
  Future<UserModel?> getFirstFisher() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['fisher'],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  @override
  Future<UserModel?> getFirstBuyer() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['buyer'],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  // Additional methods needed for Seeder or specific queries

  Future<List<UserModel>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((m) => UserModel.fromMap(m)).toList();
  }
}
