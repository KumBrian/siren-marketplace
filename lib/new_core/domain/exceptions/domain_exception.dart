abstract class DomainException implements Exception {
  final String message;
  final String? code;

  DomainException(this.message, {this.code});

  @override
  String toString() => code != null ? '[$code] $message' : message;
}
