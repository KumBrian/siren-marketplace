import 'domain_exception.dart';

/// Thrown when a concurrency conflict occurs
class ConcurrencyException extends DomainException {
  ConcurrencyException(super.message, {super.code = 'CONCURRENCY_CONFLICT'});
}
