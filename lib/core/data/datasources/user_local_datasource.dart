import 'package:sqflite/sqflite.dart';

import '../../data/database/database_helper.dart';
import '../../domain/models/user.dart';
import '../datasources/user_datasource.dart';
import '../persistence/user_entity.dart';

class UserLocalDataSource implements UserDataSource {
  final DatabaseHelper dbHelper;

  UserLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => await dbHelper.database;

  @override
  Future<void> insertUser(User user) async {
    final db = await _db;
    final ent = UserEntity.fromDomain(user);
    await db.insert(
      'users',
      ent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    final db = await _db;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<User>> getAllUsers() async {
    final db = await _db;
    final rows = await db.query('users');
    return rows.map((r) => UserEntity.fromMap(r).toDomain()).toList();
  }

  @override
  Future<User?> getUserById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserEntity.fromMap(rows.first).toDomain();
  }

  @override
  Future<void> updateUser(User user) async {
    final db = await _db;
    final ent = UserEntity.fromDomain(user);
    await db.update(
      'users',
      ent.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
