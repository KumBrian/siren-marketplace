import 'domain_exception.dart';

/// Thrown when an entity is not found
class NotFoundException extends DomainException {
  final String entityType;
  final String entityId;

  NotFoundException({required this.entityType, required this.entityId})
    : super('$entityType with id $entityId not found', code: 'NOT_FOUND');
}
