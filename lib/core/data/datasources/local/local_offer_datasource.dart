import 'package:sqflite/sqflite.dart';
import '../../../../core/data/database/database_helper.dart';
import '../../../../core/domain/enums/offer_status.dart';
import '../../models/offer_model.dart';
import '../interfaces/i_offer_datasource.dart';

class LocalOfferDataSource implements IOfferDataSource {
  final DatabaseHelper dbHelper;

  LocalOfferDataSource({required this.dbHelper});

  @override
  Future<String> create(OfferModel offer) async {
    final db = await dbHelper.database;
    await db.insert(
      'offers',
      offer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return offer.id;
  }

  @override
  Future<List<OfferModel>> getAllOffers() async {
    final maps = await dbHelper.getAllOfferMaps();
    return maps.map((m) => OfferModel.fromMap(m)).toList();
  }

  @override
  Future<OfferModel?> getById(String offerId) async {
    final map = await dbHelper.getOfferMapById(offerId);
    return map != null ? OfferModel.fromMap(map) : null;
  }

  @override
  Future<List<OfferModel>> getByCatchId(String catchId) async {
    final maps = await dbHelper.getOfferMapsByCatchId(catchId);
    return maps.map((m) => OfferModel.fromMap(m)).toList();
  }

  @override
  Future<List<OfferModel>> getByBuyerId(String buyerId) async {
    final maps = await dbHelper.getOfferMapsByBuyerId(buyerId);
    return maps.map((m) => OfferModel.fromMap(m)).toList();
  }

  @override
  Future<List<OfferModel>> getByFisherId(String fisherId) async {
    final maps = await dbHelper.getOfferMapsByFisherId(fisherId);
    return maps.map((m) => OfferModel.fromMap(m)).toList();
  }

  @override
  Future<List<OfferModel>> getByCatchIds(List<String> catchIds) async {
    final maps = await dbHelper.getOfferMapsByCatchIds(catchIds);
    return maps.map((m) => OfferModel.fromMap(m)).toList();
  }

  @override
  Future<List<OfferModel>> getByStatus(OfferStatus status) async {
    final maps = await dbHelper.getOfferMapsByStatus(status.name);
    return maps.map((m) => OfferModel.fromMap(m)).toList();
  }

  @override
  Future<void> update(OfferModel offer) async {
    final db = await dbHelper.database;
    await db.update(
      'offers',
      offer.toMap(),
      where: 'offer_id = ?',
      whereArgs: [offer.id],
    );
  }

  @override
  Future<void> delete(String offerId) async {
    final db = await dbHelper.database;
    await db.delete('offers', where: 'offer_id = ?', whereArgs: [offerId]);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dbHelper.transaction(action);
  }
}
