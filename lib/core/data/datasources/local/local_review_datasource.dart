import 'package:sqflite/sqflite.dart';
import '../../../../core/data/database/database_helper.dart';
import '../../models/review_model.dart';
import '../interfaces/i_review_datasource.dart';

class LocalReviewDataSource implements IReviewDataSource {
  final DatabaseHelper dbHelper;

  LocalReviewDataSource({required this.dbHelper});

  @override
  Future<String> create(ReviewModel review) async {
    final db = await dbHelper.database;
    await db.insert(
      'ratings',
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return review.id;
  }

  @override
  Future<ReviewModel?> getById(String reviewId) async {
    final map = await dbHelper.getReviewMapById(reviewId);
    return map != null ? ReviewModel.fromMap(map) : null;
  }

  @override
  Future<List<ReviewModel>> getReviewsForUser(String userId) async {
    final maps = await dbHelper.getRatingsByUserId(userId);
    return maps.map((m) => ReviewModel.fromMap(m)).toList();
  }

  @override
  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    final maps = await dbHelper.getReviewsByReviewerId(userId);
    return maps.map((m) => ReviewModel.fromMap(m)).toList();
  }

  @override
  Future<List<ReviewModel>> getReviewsForOrder(String orderId) async {
    final maps = await dbHelper.getReviewsForOrder(orderId);
    return maps.map((m) => ReviewModel.fromMap(m)).toList();
  }

  @override
  Future<bool> hasReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
  }) async {
    return await dbHelper.hasReview(
      orderId: orderId,
      reviewerId: reviewerId,
      reviewedUserId: reviewedUserId,
    );
  }

  @override
  Future<void> delete(String reviewId) async {
    await dbHelper.deleteReview(reviewId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dbHelper.transaction(action);
  }
}
