// import 'package:flutter/foundation.dart';
// import 'package:siren_marketplace/core/data/database/database_helper.dart';
//
// /// The ReviewRepository handles all persistent storage operations related to
// /// user ratings and reviews, utilizing the application's Sqflite DatabaseHelper.
// class ReviewRepository {
//   final DatabaseHelper _dbHelper;
//
//   /// Constructor: Requires the DatabaseHelper instance.
//   ReviewRepository(this._dbHelper);
//
//   /// Fetches all review documents where the given [userId] is the user who was rated.
//   ///
//   /// This method is used by the ReviewsCubit to display the list of reviews
//   /// and calculate the aggregate statistics.
//   ///
//   /// @param userId The ID of the user whose reviews are being retrieved (the rated user).
//   /// @returns A Future that resolves to a list of raw Map data for the ReviewsCubit.
//   Future<List<Map<String, dynamic>>> getReviewsForUser(String userId) async {
//     try {
//       // Delegate the fetch operation directly to the DatabaseHelper.
//       final reviewMaps = await _dbHelper.getRatingsByUserId(userId);
//
//       // The map keys must align with the Review.fromMap factory constructor
//       // expected by the ReviewsCubit. Sqflite uses snake_case, which matches.
//       return reviewMaps;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Sqflite Error (getReviewsForUser): $e');
//       }
//       rethrow;
//     }
//   }
// }
