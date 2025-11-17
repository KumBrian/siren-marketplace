import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/data/persistence/offer_entity.dart';
import 'package:sqflite/sqflite.dart';

import 'offer_datasource.dart';

class OfferLocalDataSource implements OfferDataSource {
  final DatabaseHelper dbHelper;

  OfferLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => await dbHelper.database;

  @override
  Future<void> insertOffer(OfferEntity entity) async {
    final db = await _db;
    await db.insert(
      'offers',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateOffer(OfferEntity entity) async {
    final db = await _db;
    // handle both 'offer_id' and 'id' in case columns differ
    final id = entity.map['offer_id'] ?? entity.map['id'];
    await db.update(
      'offers',
      entity.toMap(),
      where: 'offer_id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteOffer(String offerId) async {
    final db = await _db;
    await db.delete('offers', where: 'offer_id = ?', whereArgs: [offerId]);
  }

  @override
  Future<OfferEntity?> getOfferById(String offerId) async {
    final db = await _db;
    final rows = await db.query(
      'offers',
      where: 'offer_id = ?',
      whereArgs: [offerId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return OfferEntity.fromMap(rows.first);
  }

  @override
  Future<List<OfferEntity>> getOffersByCatchId(String catchId) async {
    final db = await _db;
    final rows = await db.query(
      'offers',
      where: 'catch_id = ?',
      whereArgs: [catchId],
      orderBy: 'date_created DESC',
    );
    return rows.map(OfferEntity.fromMap).toList();
  }

  @override
  Future<List<OfferEntity>> getOffersByCatchIds(List<String> catchIds) async {
    if (catchIds.isEmpty) return [];
    final db = await _db;
    final placeholders = List.filled(catchIds.length, '?').join(',');
    final rows = await db.query(
      'offers',
      where: 'catch_id IN ($placeholders)',
      whereArgs: catchIds,
      orderBy: 'date_created DESC',
    );
    return rows.map(OfferEntity.fromMap).toList();
  }

  @override
  Future<List<OfferEntity>> getOffersByBuyerId(String buyerId) async {
    final db = await _db;
    final rows = await db.query(
      'offers',
      where: 'buyer_id = ?',
      whereArgs: [buyerId],
      orderBy: 'date_created DESC',
    );
    return rows.map(OfferEntity.fromMap).toList();
  }

  @override
  Future<List<OfferEntity>> getOffersByFisherId(String fisherId) async {
    final db = await _db;
    final rows = await db.query(
      'offers',
      where: 'fisher_id = ?',
      whereArgs: [fisherId],
      orderBy: 'date_created DESC',
    );
    return rows.map(OfferEntity.fromMap).toList();
  }

  @override
  Future<List<OfferEntity>> getAllOffers() async {
    final db = await _db;
    final rows = await db.query('offers', orderBy: 'date_created DESC');
    return rows.map(OfferEntity.fromMap).toList();
  }

  @override
  Future<List<OfferEntity>> getOffersByStatus(String status) async {
    final db = await _db;
    final rows = await db.query(
      'offers',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'date_created DESC',
    );
    return rows.map(OfferEntity.fromMap).toList();
  }
}
