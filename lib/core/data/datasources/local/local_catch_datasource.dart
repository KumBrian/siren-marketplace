import 'package:sqflite/sqflite.dart';
import '../../../../core/data/database/database_helper.dart';
import '../../../../core/domain/enums/catch_status.dart';
import '../../models/catch_model.dart';
import '../interfaces/i_catch_datasource.dart';

class LocalCatchDataSource implements ICatchDataSource {
  final DatabaseHelper dbHelper;

  LocalCatchDataSource({required this.dbHelper});

  @override
  Future<String> create(CatchModel catchItem) async {
    final db = await dbHelper.database;
    await db.insert(
      'catches',
      catchItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return catchItem.id;
  }

  @override
  Future<CatchModel?> getById(String catchId) async {
    final map = await dbHelper.getCatchMapById(catchId);
    return map != null ? CatchModel.fromMap(map) : null;
  }

  @override
  Future<List<CatchModel>> getByFisherId(String fisherId) async {
    final maps = await dbHelper.getCatchMapsByFisherId(fisherId);
    return maps.map((m) => CatchModel.fromMap(m)).toList();
  }

  @override
  Future<List<CatchModel>> getByStatus(CatchStatus status) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'catches',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'date_created DESC',
    );
    return maps.map((m) => CatchModel.fromMap(m)).toList();
  }

  @override
  Future<List<CatchModel>> getAll() async {
    final maps = await dbHelper.getCatchMapsForMarket();
    return maps.map((m) => CatchModel.fromMap(m)).toList();
  }

  @override
  Future<void> update(CatchModel catchItem) async {
    final db = await dbHelper.database;
    await db.update(
      'catches',
      catchItem.toMap(),
      where: 'catch_id = ?',
      whereArgs: [catchItem.id],
    );
  }

  @override
  Future<void> delete(String catchId) async {
    final db = await dbHelper.database;
    await db.delete('catches', where: 'catch_id = ?', whereArgs: [catchId]);
  }

  @override
  Future<void> saveBatch(List<CatchModel> catches) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final catchItem in catches) {
      batch.insert(
        'catches',
        catchItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateBatch(List<CatchModel> catches) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final catchItem in catches) {
      batch.update(
        'catches',
        catchItem.toMap(),
        where: 'catch_id = ?',
        whereArgs: [catchItem.id],
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteBatch(List<String> catchIds) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final id in catchIds) {
      batch.delete('catches', where: 'catch_id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }
}
