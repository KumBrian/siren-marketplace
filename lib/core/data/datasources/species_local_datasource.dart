import 'package:sqflite/sqflite.dart';

import '../../data/database/database_helper.dart';
import '../datasources/species_datasource.dart';
import '../persistence/species_entity.dart';

class SpeciesLocalDataSource implements SpeciesDataSource {
  final DatabaseHelper dbHelper;

  SpeciesLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => await dbHelper.database;

  @override
  Future<void> insertSpecies(SpeciesEntity entity) async {
    final db = await _db;
    await db.insert(
      'species',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteSpecies(String id) async {
    final db = await _db;
    await db.delete('species', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<SpeciesEntity>> getAllSpecies() async {
    final db = await _db;
    final rows = await db.query('species');
    return rows.map(SpeciesEntity.fromMap).toList();
  }

  @override
  Future<SpeciesEntity?> getSpeciesById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'species',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SpeciesEntity.fromMap(rows.first);
  }

  @override
  Future<void> updateSpecies(SpeciesEntity entity) async {
    final db = await _db;
    await db.update(
      'species',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }
}
