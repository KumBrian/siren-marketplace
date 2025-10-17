import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/app_user.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final DatabaseHelper dbHelper;

  UserRepository({required this.dbHelper});

  // 1. INSERT: Renaming to the method used in the Seeder
  Future<void> insertUser(AppUser user) async {
    final db = await dbHelper.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. QUERY ALL: REQUIRED BY SEEDER to check if the table is empty
  Future<List<Map<String, dynamic>>> getAllUserMaps() async {
    final db = await dbHelper.database;
    return await db.query('users');
  }

  // 3. QUERY FIRST FISHER (Raw Map)
  Future<Map<String, dynamic>?> getFirstFisherMap() async {
    final db = await dbHelper.database;
    final data = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [Role.fisher.name],
      limit: 1,
    );

    if (data.isEmpty) return null;
    return data.first;
  }

  // 4. QUERY FIRST BUYER (Raw Map)
  Future<Map<String, dynamic>?> getFirstBuyerMap() async {
    final db = await dbHelper.database;
    final data = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [Role.buyer.name],
      limit: 1,
    );

    if (data.isEmpty) return null;
    return data.first;
  }

  // 5. QUERY BY ID (Raw Map)
  Future<Map<String, dynamic>?> getUserMapById(String id) async {
    final db = await dbHelper.database;
    final data = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (data.isEmpty) return null;
    return data.first;
  }

  // 6. UPDATE/DELETE methods (Placeholder for completeness, not used by Seeder)
  Future<void> updateUser(AppUser user) async {
    final db = await dbHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
