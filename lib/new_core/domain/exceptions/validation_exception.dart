import 'domain_exception.dart';

/// Thrown when domain validation fails
class ValidationException extends DomainException {
  ValidationException(super.message, {super.code = 'VALIDATION_ERROR'});
}
