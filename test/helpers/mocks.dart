// This file is used to generate mocks for testing
// Run: flutter pub run build_runner build --delete-conflicting-outputs

import 'package:mockito/annotations.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_review_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_session_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/services/negotiation_service.dart';
import 'package:siren_marketplace/core/domain/services/rating_service.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';

// Generate mocks for all repositories
@GenerateMocks([
  ICatchRepository,
  IOfferRepository,
  IOrderRepository,
  IReviewRepository,
  ISessionRepository,
  IUserRepository,
])
void generateRepositoryMocks() {}

// Generate mocks for all services
@GenerateMocks([NegotiationService, RatingService, SessionService])
void generateServiceMocks() {}
