# Fisheries Marketplace - Clean Architecture Design

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│                  (BLoC/Cubit - Update Later)                │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Entities (Business Logic)                          │    │
│  │  • User, Catch, Offer, Order, Review              │    │
│  ├────────────────────────────────────────────────────┤    │
│  │ Value Objects                                       │    │
│  │  • Price, Weight, Rating, OfferTerms               │    │
│  ├────────────────────────────────────────────────────┤    │
│  │ Repository Interfaces (Contracts)                   │    │
│  │  • ICatchRepository, IOfferRepository, etc.        │    │
│  ├────────────────────────────────────────────────────┤    │
│  │ Domain Services (Complex Business Logic)           │    │
│  │  • NegotiationService, ExpirationService, etc.     │    │
│  └────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Models/DTOs (Serialization)                        │    │
│  │  • CatchModel, OfferModel, OrderModel              │    │
│  ├────────────────────────────────────────────────────┤    │
│  │ Data Sources (Abstraction)                         │    │
│  │  • IRemoteDataSource ◄──► ApiDataSource            │    │
│  │  • ILocalDataSource  ◄──► SqliteDataSource         │    │
│  │  • IDemoDataSource   ◄──► DemoDataSource           │    │
│  ├────────────────────────────────────────────────────┤    │
│  │ Repository Implementations                          │    │
│  │  • CatchRepositoryImpl                              │    │
│  │  • Uses DataSource + Mapper                         │    │
│  ├────────────────────────────────────────────────────┤    │
│  │ Mappers (DTO ↔ Entity Conversion)                  │    │
│  │  • CatchMapper, OfferMapper, etc.                  │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Folder Structure

```
lib/
├── core/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   ├── catch.dart
│   │   │   ├── offer.dart
│   │   │   ├── order.dart
│   │   │   └── review.dart
│   │   ├── value_objects/
│   │   │   ├── price.dart
│   │   │   ├── weight.dart
│   │   │   ├── rating.dart
│   │   │   └── offer_terms.dart
│   │   ├── repositories/
│   │   │   ├── i_catch_repository.dart
│   │   │   ├── i_offer_repository.dart
│   │   │   ├── i_order_repository.dart
│   │   │   ├── i_user_repository.dart
│   │   │   └── i_review_repository.dart
│   │   ├── services/
│   │   │   ├── negotiation_service.dart
│   │   │   ├── expiration_service.dart
│   │   │   ├── rating_service.dart
│   │   │   └── marketplace_service.dart
│   │   └── enums/
│   │       ├── user_role.dart
│   │       ├── catch_status.dart
│   │       ├── offer_status.dart
│   │       └── order_status.dart
│   │
│   └── data/
│       ├── models/
│       │   ├── catch_model.dart
│       │   ├── offer_model.dart
│       │   ├── order_model.dart
│       │   ├── user_model.dart
│       │   └── review_model.dart
│       ├── datasources/
│       │   ├── interfaces/
│       │   │   ├── i_remote_datasource.dart
│       │   │   ├── i_local_datasource.dart
│       │   │   └── i_demo_datasource.dart
│       │   ├── remote/
│       │   │   └── api_datasource.dart
│       │   ├── local/
│       │   │   └── sqlite_datasource.dart
│       │   └── demo/
│       │       └── demo_datasource.dart
│       ├── repositories/
│       │   ├── catch_repository_impl.dart
│       │   ├── offer_repository_impl.dart
│       │   ├── order_repository_impl.dart
│       │   ├── user_repository_impl.dart
│       │   └── review_repository_impl.dart
│       └── mappers/
│           ├── catch_mapper.dart
│           ├── offer_mapper.dart
│           ├── order_mapper.dart
│           ├── user_mapper.dart
│           └── review_mapper.dart
│
└── features/
    ├── fisher/
    │   └── (existing fisher features)
    └── buyer/
        └── (existing buyer features)
```

---

## 🎯 Key Design Principles

### 1. **Separation of Concerns**

- **Domain Layer**: Pure business logic, no dependencies on Flutter/SQLite/HTTP
- **Data Layer**: Handles persistence, API calls, serialization
- **Presentation Layer**: UI and state management

### 2. **Dependency Inversion**

- Domain layer defines interfaces
- Data layer implements them
- Presentation depends on domain interfaces, not implementations

### 3. **Single Source of Truth**

- Remove denormalized data (names, ratings in offers)
- Let repositories handle joins when needed
- Keep domain entities normalized

### 4. **Testability**

- All business logic in domain services (easily testable)
- Mock repositories using interfaces
- No Flutter/SQLite dependencies in domain layer

### 5. **API Readiness**

- Swap `DemoDataSource` with `ApiDataSource`
- Repository implementations remain unchanged
- Use environment flag to toggle data sources

---

## 🔄 Data Flow Examples

### Example 1: Fisher Lists a Catch

```
UI → BLoC → MarketplaceService.createCatch()
    → ICatchRepository.create()
    → CatchRepositoryImpl
    → DataSource (Demo/API/Local)
    → CatchMapper (Entity → Model)
    → Persist
```

### Example 2: Buyer Makes Offer

```
UI → BLoC → NegotiationService.createOffer()
    → IOfferRepository.create()
    → Validates business rules
    → OfferRepositoryImpl
    → DataSource
    → Persist
```

### Example 3: Accept Offer → Create Order

```
UI → BLoC → NegotiationService.acceptOffer()
    → Validates offer status
    → IOrderRepository.create()
    → Updates offer status
    → Both operations in transaction
    → Returns Order entity
```

---

## 🗄️ Database vs Domain Entities

### ❌ Old Approach (Denormalized)

```dart
// Offer stores redundant data
class Offer {
  final String fisherName; // ❌ Duplicated
  final double fisherRating; // ❌ Duplicated
  final String catchName; // ❌ Duplicated
  final String catchImageUrl; // ❌ Duplicated
}
```

### ✅ New Approach (Normalized)

```dart
// Domain Entity - Clean relationships
class Offer {
  final String id;
  final String catchId; // ✅ Reference only
  final String fisherId; // ✅ Reference only
  final String buyerId; // ✅ Reference only
  final OfferTerms terms; // ✅ Value object
  final OfferStatus status; // ✅ Enum
}

// Repository handles joins when UI needs it
class OfferWithDetails {
  final Offer offer;
  final User fisher;
  final User buyer;
  final Catch

  catch;
}
```

---

## 🎲 Demo Data Strategy

### Config-Based Data Source Selection

```dart
// config.dart
enum DataSourceMode {
  demo, // Use seeded SQLite data
  local, // Use actual SQLite with real data
  api, // Use remote API
}

class AppConfig {
  static DataSourceMode mode = DataSourceMode.demo;
}
```

### Repository Factory

```dart
// di/injection.dart
ICatchRepository getCatchRepository() {
  switch (AppConfig.mode) {
    case DataSourceMode.demo:
      return CatchRepositoryImpl(
        dataSource: DemoDataSource(),
      );
    case DataSourceMode.api:
      return CatchRepositoryImpl(
        dataSource: ApiDataSource(),
      );
    case DataSourceMode.local:
      return CatchRepositoryImpl(
        dataSource: SqliteDataSource(),
      );
  }
}
```

---

## 🔐 User Role Management

### Session Service

```dart
class SessionService {
  User? _currentUser;
  UserRole? _currentRole;

  // Called on app start
  Future<void> initialize() async {
    _currentUser = await _loadUserFromStorage();
    _currentRole = await _loadRoleFromStorage();
  }

  // Switch role anytime
  Future<void> switchRole(UserRole newRole) async {
    _currentRole = newRole;
    await _saveRoleToStorage(newRole);
    // Emit event to refresh UI
  }

  UserRole get currentRole => _currentRole ?? UserRole.buyer;

  User get currentUser => _currentUser!;
}
```

---

## ⚙️ Domain Services

### NegotiationService (Complex Business Logic)

```dart
class NegotiationService {
  final IOfferRepository offerRepo;
  final IOrderRepository orderRepo;
  final ICatchRepository catchRepo;

  // Accept offer → Create order (Transaction)
  Future<Order> acceptOffer({
    required String offerId,
    required String userId,
  }) async {
    final offer = await offerRepo.getById(offerId);

    // Business rules validation
    if (offer.status != OfferStatus.pending) {
      throw OfferNotPendingException();
    }

    if (!offer.isUsersTurn(userId)) {
      throw NotUsersTurnException();
    }

    // Atomic transaction
    return await offerRepo.transaction(() async {
      final updatedOffer = offer.accept();
      await offerRepo.update(updatedOffer);

      final catch = await catchRepo.getById(offer.catchId);
      final order = Order.fromAcceptedOffer(
      offer: updatedOffer,
      catch: catch,
      );

      await orderRepo.create(order);
      return order;
      });
  }

  // Counter offer (Turn-based logic)
  Future<Offer> counterOffer({
    required String offerId,
    required OfferTerms newTerms,
    required String userId,
  }) async {
    final offer = await offerRepo.getById(offerId);

    // Validate turn
    if (!offer.isUsersTurn(userId)) {
      throw NotUsersTurnException();
    }

    final countered = offer.counter(
      newTerms: newTerms,
      byUser: userId,
    );

    await offerRepo.update(countered);
    return countered;
  }
}
```

### ExpirationService

```dart
class ExpirationService {
  final ICatchRepository catchRepo;

  // Run periodically (background job)
  Future<void> processExpirations() async {
    final catches = await catchRepo.getAllActive();

    for (final catch in catches) {
      if (catch.isExpired) {
        await catchRepo.update(
        catch.markAsExpired(),
    );
    }

    if (catch.shouldBeDeleted) {
    await catchRepo.delete(catch.id);
    }
  }
  }
}
```

### RatingService

```dart
class RatingService {
  final IReviewRepository reviewRepo;
  final IOrderRepository orderRepo;
  final IUserRepository userRepo;

  // Submit review for an order
  Future<void> submitReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
    required Rating rating,
    String? comment,
  }) async {
    final order = await orderRepo.getById(orderId);

    // Validate: Can't review twice
    if (order.hasReview(reviewerId, reviewedUserId)) {
      throw AlreadyReviewedException();
    }

    await reviewRepo.transaction(() async {
      final review = Review.create(
        orderId: orderId,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        rating: rating,
        comment: comment,
      );

      await reviewRepo.create(review);

      // Update user's aggregate rating
      final allReviews = await reviewRepo
          .getReviewsForUser(reviewedUserId);
      final avgRating = _calculateAverage(allReviews);

      await userRepo.updateRating(
        userId: reviewedUserId,
        rating: avgRating,
        reviewCount: allReviews.length,
      );
    });
  }
}
```

---

## 🧪 Testing Strategy

### Unit Tests (Domain Services)

```dart
test
('acceptOffer creates order and updates offer status
'
, () async {
// Arrange
final mockOfferRepo = MockOfferRepository();
final mockOrderRepo = MockOrderRepository();
final service = NegotiationService(
offerRepo: mockOfferRepo,
orderRepo: mockOrderRepo,
);

// Act
final order = await service.acceptOffer(
offerId: 'offer-1',
userId: 'fisher-1',
);

// Assert
expect(order.status, OrderStatus.active);
verify(mockOfferRepo.update(any)).called(1);
verify(mockOrderRepo.create(any)).called(1);
});
```

### Integration Tests (Repositories)

```dart
test
('CatchRepository fetches from demo data source
'
, () async {
final repo = CatchRepositoryImpl(
dataSource: DemoDataSource(),
);

final catches = await repo.getAllActive();

expect(catches.length, greaterThan(0));
expect(catches.first.status, CatchStatus.available);
});
```

---

## 🚀 Migration Path

### Phase 1: Setup (Current)

1. Create domain entities with business logic
2. Define repository interfaces
3. Create data models (DTOs)
4. Build mappers

### Phase 2: Demo Data

1. Implement `DemoDataSource` with seeded data
2. Test all flows with demo data
3. Validate business rules

### Phase 3: API Integration

1. Implement `ApiDataSource`
2. Add error handling, retry logic
3. Test with real backend
4. Toggle between demo/api via config

### Phase 4: Optimization

1. Add caching layer
2. Implement offline-first strategy
3. Add sync logic

---

## 📝 Next Steps

Ready to implement? I'll provide:

1. ✅ Domain entities with business logic
2. ✅ Repository interfaces
3. ✅ Data models and mappers
4. ✅ Demo data source implementation
5. ✅ Service layer implementations
6. ✅ Dependency injection setup

Which component would you like me to start with?