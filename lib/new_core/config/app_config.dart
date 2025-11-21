/// Configuration for data source selection
enum DataSourceMode {
  demo, // Use in-memory demo data
  local, // Use SQLite (to be implemented)
  api, // Use remote API (to be implemented)
}

class AppConfig {
  static DataSourceMode mode = DataSourceMode.demo;

  static bool get isDemoMode => mode == DataSourceMode.demo;

  static bool get isLocalMode => mode == DataSourceMode.local;

  static bool get isApiMode => mode == DataSourceMode.api;

  /// Switch data source mode at runtime
  static void setMode(DataSourceMode newMode) {
    mode = newMode;
  }
}
