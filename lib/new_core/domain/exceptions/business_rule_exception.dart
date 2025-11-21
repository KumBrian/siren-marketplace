import 'domain_exception.dart';

/// Thrown when a business rule is violated
class BusinessRuleException extends DomainException {
  BusinessRuleException(
    super.message, {
    super.code = 'BUSINESS_RULE_VIOLATION',
  });
}
