// This file is used to generate mocks for testing
// Run: flutter pub run build_runner build --delete-conflicting-outputs

import 'package:mockito/annotations.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_review_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_session_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_product_repository.dart';
import 'package:siren_marketplace/core/domain/services/negotiation_service.dart';
import 'package:siren_marketplace/core/domain/services/rating_service.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';
import 'package:siren_marketplace/core/domain/services/message_service.dart';
import 'package:siren_marketplace/core/data/datasources/interfaces/i_catch_datasource.dart';
import 'package:siren_marketplace/core/data/datasources/interfaces/i_offer_datasource.dart';
import 'package:siren_marketplace/core/data/datasources/interfaces/i_order_datasource.dart';
import 'package:siren_marketplace/core/data/datasources/interfaces/i_review_datasource.dart';
import 'package:siren_marketplace/core/data/datasources/interfaces/i_session_datasource.dart';
import 'package:siren_marketplace/core/data/datasources/interfaces/i_user_datasource.dart';

// Generate mocks for all repositories
@GenerateMocks([
  ICatchRepository,
  IOfferRepository,
  IOrderRepository,
  IReviewRepository,
  ISessionRepository,
  IUserRepository,
  IProductRepository,
  MessageService,
])
void generateRepositoryMocks() {}

// Generate mocks for all services
@GenerateMocks([NegotiationService, RatingService, SessionService])
void generateServiceMocks() {}

// Generate mocks for all data sources
@GenerateMocks([
  ICatchDataSource,
  IOfferDataSource,
  IOrderDataSource,
  IReviewDataSource,
  ISessionDataSource,
  IUserDataSource,
])
void generateDataSourceMocks() {}
