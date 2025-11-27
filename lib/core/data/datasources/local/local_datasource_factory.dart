import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'local_user_datasource.dart';

class LocalDataSources {
  final LocalUserDataSource userDataSource;
  // Add other local data sources here as they are implemented
  // final LocalCatchDataSource catchDataSource;
  // ...

  LocalDataSources({required this.userDataSource});
}

class LocalDataSourceFactory {
  static LocalDataSources create(DatabaseHelper dbHelper) {
    return LocalDataSources(
      userDataSource: LocalUserDataSource(dbHelper: dbHelper),
    );
  }
}
