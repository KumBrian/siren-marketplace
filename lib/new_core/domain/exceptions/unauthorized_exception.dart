import 'domain_exception.dart';

/// Thrown when user is not authorized to perform an action
class UnauthorizedException extends DomainException {
  UnauthorizedException(super.message, {super.code = 'UNAUTHORIZED'});
}
