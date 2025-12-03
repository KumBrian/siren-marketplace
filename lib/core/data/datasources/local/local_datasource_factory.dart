import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'local_catch_datasource.dart';
import 'local_offer_datasource.dart';
import 'local_order_datasource.dart';
import 'local_review_datasource.dart';
import 'local_session_datasource.dart';
import 'local_user_datasource.dart';

class LocalDataSources {
  final LocalUserDataSource userDataSource;
  final LocalCatchDataSource catchDataSource;
  final LocalOfferDataSource offerDataSource;
  final LocalOrderDataSource orderDataSource;
  final LocalReviewDataSource reviewDataSource;
  final LocalSessionDataSource sessionDataSource;

  LocalDataSources({
    required this.userDataSource,
    required this.catchDataSource,
    required this.offerDataSource,
    required this.orderDataSource,
    required this.reviewDataSource,
    required this.sessionDataSource,
  });
}

class LocalDataSourceFactory {
  static LocalDataSources create(DatabaseHelper dbHelper) {
    return LocalDataSources(
      userDataSource: LocalUserDataSource(dbHelper: dbHelper),
      catchDataSource: LocalCatchDataSource(dbHelper: dbHelper),
      offerDataSource: LocalOfferDataSource(dbHelper: dbHelper),
      orderDataSource: LocalOrderDataSource(dbHelper: dbHelper),
      reviewDataSource: LocalReviewDataSource(dbHelper: dbHelper),
      sessionDataSource: LocalSessionDataSource(),
    );
  }
}
