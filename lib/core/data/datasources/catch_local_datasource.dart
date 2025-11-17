import 'package:sqflite/sqflite.dart';

import '../../data/database/database_helper.dart';
import '../datasources/catch_datasource.dart';
import '../persistence/catch_entity.dart';

class CatchLocalDataSource implements CatchDataSource {
  final DatabaseHelper dbHelper;

  CatchLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => await dbHelper.database;

  @override
  Future<void> insertCatch(CatchEntity entity) async {
    final db = await _db;
    await db.insert(
      'catches',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCatch(String id) async {
    final db = await _db;
    await db.delete('catches', where: 'catch_id = ?', whereArgs: [id]);
  }

  @override
  Future<List<CatchEntity>> getAllCatches() async {
    final db = await _db;
    final rows = await db.query('catches', orderBy: 'date_created DESC');
    return rows.map(CatchEntity.fromMap).toList();
  }

  @override
  Future<CatchEntity?> getCatchById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'catches',
      where: 'catch_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CatchEntity.fromMap(rows.first);
  }

  @override
  Future<List<CatchEntity>> getCatchesByFisherId(String fisherId) async {
    final db = await _db;
    final rows = await db.query(
      'catches',
      where: 'fisher_id = ?',
      whereArgs: [fisherId],
      orderBy: 'date_created DESC',
    );
    return rows.map(CatchEntity.fromMap).toList();
  }

  @override
  Future<void> updateCatch(CatchEntity entity) async {
    final db = await _db;
    await db.update(
      'catches',
      entity.toMap(),
      where: 'catch_id = ?',
      whereArgs: [entity.id],
    );
  }
}
