# Hexagonal Architecture Migration Analysis

> Analysis of current Siren Marketplace architecture and requirements for migration to Hexagonal (Ports & Adapters) Architecture.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [What is Hexagonal Architecture?](#what-is-hexagonal-architecture)
3. [Current Architecture Assessment](#current-architecture-assessment)
4. [Gap Analysis](#gap-analysis)
5. [Migration Requirements](#migration-requirements)
6. [Detailed Migration Steps](#detailed-migration-steps)
7. [Effort Estimation](#effort-estimation)
8. [Recommended Approach](#recommended-approach)

---

## Executive Summary

### Current State

The Siren Marketplace already implements **Clean Architecture** with clear domain, data, and presentation layers. This provides a solid foundation for hexagonal migration.

### Key Findings

| Aspect                      | Current State                | Hexagonal Requirement | Gap Level |
| --------------------------- | ---------------------------- | --------------------- | --------- |
| Domain Layer Purity         | ✅ Good - No Flutter imports | Pure with ports       | 🟢 Low    |
| Repository Interfaces       | ✅ Good - Abstractions exist | Outbound ports        | 🟢 Low    |
| Use Cases/Application Layer | ⚠️ Missing                   | Inbound ports         | 🟡 Medium |
| DI in Presentation          | ❌ Direct `sl<>` access      | Adapter injection     | 🔴 High   |
| Infrastructure Isolation    | ⚠️ Partial                   | Full adapter pattern  | 🟡 Medium |
| UI Business Logic           | ❌ Embedded in screens       | Strict separation     | 🔴 High   |

### Bottom Line

Migration is **feasible** with moderate effort. The largest work items are:

1. Introducing an Application Layer with Use Cases
2. Removing direct service locator access from UI components
3. Creating proper Driving Adapters for presentation

---

## What is Hexagonal Architecture?

Hexagonal Architecture (Ports & Adapters), created by Alistair Cockburn, structures applications to be independent of frameworks, UI, databases, and external services.

```
                    ┌─────────────────────────────────────────┐
                    │              DRIVING SIDE               │
                    │  (UI, API Controllers, CLI, Tests)      │
                    └─────────────────┬───────────────────────┘
                                      │
                           ┌──────────▼──────────┐
                           │    INBOUND PORTS    │
                           │    (Use Cases)      │
                           └──────────┬──────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │         APPLICATION CORE          │
                    │  ┌───────────────────────────┐   │
                    │  │      DOMAIN MODEL         │   │
                    │  │  (Entities, Value Objects,│   │
                    │  │   Domain Services)        │   │
                    │  └───────────────────────────┘   │
                    └─────────────────┬─────────────────┘
                                      │
                           ┌──────────▼──────────┐
                           │   OUTBOUND PORTS    │
                           │   (Repository I/Fs) │
                           └──────────┬──────────┘
                                      │
                    ┌─────────────────▼───────────────────────┐
                    │              DRIVEN SIDE                │
                    │  (Database, API, File System, etc.)     │
                    └─────────────────────────────────────────┘
```

### Core Principles

1. **Ports**: Interfaces defining how the application communicates with the outside world
   - **Inbound/Driving Ports**: Entry points into the application (Use Cases)
   - **Outbound/Driven Ports**: Abstractions for external dependencies (Repositories)

2. **Adapters**: Implementations that connect external systems to ports
   - **Driving Adapters**: UI, API Controllers, CLI (call inbound ports)
   - **Driven Adapters**: Database, API clients, file systems (implement outbound ports)

3. **Dependency Rule**: Dependencies always point inward toward the domain

---

## Current Architecture Assessment

### ✅ What's Already Good

#### 1. Domain Layer is Clean

The domain entities have **no Flutter framework imports**:

```dart
// lib/core/domain/entities/offer.dart
import 'package:equatable/equatable.dart';  // ✅ Pure Dart library
import '../enums/offer_status.dart';
import '../value_objects/offer_terms.dart';
// No Flutter imports!
```

#### 2. Repository Interfaces Exist (Outbound Ports)

The app already defines abstract repository interfaces:

```dart
// lib/core/domain/repositories/i_offer_repository.dart
abstract class IOfferRepository {
  Future<String> create(Offer offer);
  Future<Offer?> getById(String offerId);
  Future<List<Offer>> getByBuyerId(String buyerId);
  // ...
}
```

#### 3. Value Objects Encapsulate Business Rules

```dart
// lib/core/domain/value_objects/offer_terms.dart
class OfferTerms extends Equatable {
  final Price totalPrice;
  final Weight weight;
  final PricePerKg pricePerKg;

  factory OfferTerms.create({
    required Price totalPrice,
    required Weight weight,
  }) {
    final pricePerKg = PricePerKg.calculate(totalPrice: totalPrice, weight: weight);
    return OfferTerms._(totalPrice: totalPrice, weight: weight, pricePerKg: pricePerKg);
  }
}
```

#### 4. Domain Services Orchestrate Business Logic

```dart
// lib/core/domain/services/negotiation_service.dart
class NegotiationService {
  final IOfferRepository _offerRepository;  // ✅ Depends on interface
  final IOrderRepository _orderRepository;

  Future<Offer> createOffer({...}) async {
    // Business logic here
  }
}
```

### ❌ What Needs Improvement

#### 1. No Application Layer / Use Cases

The current architecture jumps directly from Presentation → Domain Services:

```
Current:    UI → Domain Services → Repositories
Hexagonal:  UI → Use Cases (Application) → Domain Services → Repositories
```

#### 2. Direct Service Locator Access in UI (23+ occurrences)

UI components directly access the DI container:

```dart
// ❌ Anti-pattern: Direct sl<> access in screens
// lib/features/fisher/presentation/screens/catch_details.dart
final repository = sl<IProductRepository>();
await repository.deleteProduct(selectedCatch.id);
```

**Files with direct `sl<>` access in presentation:**

- `catch_details.dart` (2 occurrences)
- `catch_report_screen.dart` (2 occurrences)
- `order_details.dart` (2 occurrences - fisher & buyer)
- `add_catch_provider.dart` (2 occurrences)
- `login_controller.dart` (1 occurrence)
- `role_selection_provider.dart` (2 occurrences)
- `chat_providers.dart` (6 occurrences)
- `offer_actions_provider.dart` (2 occurrences)
- `shared_offer_details_provider.dart` (2 occurrences)
- `profile_route_widget.dart` (1 occurrence)

#### 3. Business Logic in UI Screens

Screens contain business logic that should be in Use Cases:

```dart
// ❌ Business logic in UI
// lib/features/fisher/presentation/screens/catch_details.dart
void _showEditCatchDialog(BuildContext context, Product selectedCatch) {
  // ...
  final double currentTotal = currentWeightInputKg * currentPricePerKg;  // Business logic
  // ...
  await repository.updateProduct(
    selectedCatch.id,
    pricePerKg: currentPricePerKg,
    finalPrice: currentTotal,
    availableWeight: currentWeightInputKg,
  );
}
```

#### 4. Providers Access Infrastructure Directly

Riverpod providers directly instantiate or access data sources:

```dart
// ❌ Provider coupling to infrastructure
// lib/features/chat/presentation/providers/chat_providers.dart
final chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  return ChatRepositoryImpl(
    sl<ChatApiDataSource>(),           // Direct DI access
    sl<IViewedConversationsService>(),
    sl<ConnectivityService>(),
    sl<IConversationRepository>(),
    sl<IUserRepository>(),
    // ...
  );
});
```

#### 5. Mixed Concerns in Repository Implementations

Repositories handle caching, connectivity checks, and data transformation:

```dart
// lib/core/data/repositories/offer_repository_impl.dart
class OfferRepositoryImpl implements IOfferRepository {
  Future<List<Offer>> getByBuyerId(String buyerId) async {
    if (await _isOffline) {                        // Infrastructure concern
      final models = await localDataSource.getByBuyerId(buyerId);
      return await _mapModelsToEntitiesWithUsers(models);  // Mapping concern
    }
    try {
      final models = await remoteDataSource.getByBuyerId(buyerId);
      await localDataSource.saveBatch(models);     // Caching concern
      return await _mapModelsToEntitiesWithUsers(models);
    } catch (e) {
      // Fallback logic
    }
  }
}
```

---

## Gap Analysis

### Layer Comparison

| Layer                           | Current Name          | Hexagonal Equivalent                | Status                     |
| ------------------------------- | --------------------- | ----------------------------------- | -------------------------- |
| `lib/core/domain/entities`      | Domain Entities       | Domain Model                        | ✅ Exists                  |
| `lib/core/domain/value_objects` | Value Objects         | Domain Model                        | ✅ Exists                  |
| `lib/core/domain/services`      | Domain Services       | Domain Services                     | ✅ Exists (but mixed)      |
| `lib/core/domain/repositories`  | Repository Interfaces | Outbound Ports                      | ✅ Exists                  |
| **Missing**                     | -                     | Application Layer (Use Cases)       | ❌ Missing                 |
| **Missing**                     | -                     | Inbound Ports (Use Case Interfaces) | ❌ Missing                 |
| `lib/core/data/repositories`    | Repository Impl       | Driven Adapters                     | ⚠️ Needs refactoring       |
| `lib/core/data/datasources/api` | API Data Sources      | Driven Adapters                     | ⚠️ Needs isolation         |
| `lib/features/*/presentation`   | UI Screens/Widgets    | Driving Adapters                    | ❌ Needs major refactoring |
| `lib/core/providers`            | Riverpod Providers    | Driving Adapters                    | ⚠️ Needs refactoring       |

### Dependency Flow Issues

**Current (Problematic):**

```
Presentation
    → GetIt (sl<>)
    → Repositories/Services directly
```

**Target (Hexagonal):**

```
Presentation (Driving Adapter)
    → Use Case Interfaces (Inbound Ports)
    → Use Case Implementations (Application Layer)
    → Repository Interfaces (Outbound Ports)
    → Repository Implementations (Driven Adapters)
```

---

## Migration Requirements

### 1. Introduce Application Layer (Use Cases)

Create use case classes that encapsulate single operations:

```dart
// NEW: lib/core/application/use_cases/accept_offer_use_case.dart
abstract class IAcceptOfferUseCase {
  Future<Order> execute(String offerId, String userId);
}

class AcceptOfferUseCase implements IAcceptOfferUseCase {
  final IOfferRepository _offerRepository;
  final IOrderRepository _orderRepository;

  AcceptOfferUseCase({
    required IOfferRepository offerRepository,
    required IOrderRepository orderRepository,
  }) : _offerRepository = offerRepository,
       _orderRepository = orderRepository;

  @override
  Future<Order> execute(String offerId, String userId) async {
    final offer = await _offerRepository.getById(offerId);
    if (offer == null) throw OfferNotFoundException(offerId);

    if (!offer.canBeAcceptedBy(userId)) {
      throw UnauthorizedOfferActionException();
    }

    final order = await _offerRepository.acceptOffer(offerId, ...);
    return order;
  }
}
```

### 2. Remove Direct `sl<>` Access from Presentation

Replace service locator access with provider injection:

```dart
// BEFORE ❌
void _showDeleteDialog(...) {
  final repository = sl<IProductRepository>();  // Direct access
  await repository.deleteProduct(selectedCatch.id);
}

// AFTER ✅
// Inject via Riverpod provider
final deleteProductUseCaseProvider = Provider<IDeleteProductUseCase>((ref) {
  return ref.watch(deleteProductUseCaseImplProvider);
});

// In widget
void _showDeleteDialog(...) {
  final deleteProduct = ref.read(deleteProductUseCaseProvider);
  await deleteProduct.execute(selectedCatch.id);
}
```

### 3. Create Driving Adapters (Controllers/ViewModels)

Introduce controllers that handle UI logic and use cases:

```dart
// NEW: lib/features/fisher/presentation/controllers/catch_details_controller.dart
class CatchDetailsController extends StateNotifier<CatchDetailsState> {
  final IGetProductByIdUseCase _getProductUseCase;
  final IDeleteProductUseCase _deleteProductUseCase;
  final IUpdateProductUseCase _updateProductUseCase;

  CatchDetailsController({
    required IGetProductByIdUseCase getProductUseCase,
    required IDeleteProductUseCase deleteProductUseCase,
    required IUpdateProductUseCase updateProductUseCase,
  }) : _getProductUseCase = getProductUseCase,
       _deleteProductUseCase = deleteProductUseCase,
       _updateProductUseCase = updateProductUseCase,
       super(CatchDetailsState.initial());

  Future<void> deleteProduct(String productId) async {
    state = state.copyWith(isDeleting: true);
    final result = await _deleteProductUseCase.execute(productId);
    // Handle result
  }
}
```

### 4. Refactor Repository Implementations

Separate caching/offline concerns into dedicated infrastructure services:

```dart
// Separate caching strategy
abstract class ICacheStrategy<T> {
  Future<List<T>> getFromCache(String key);
  Future<void> saveToCache(String key, List<T> data);
}

// Cleaner repository
class OfferRepositoryImpl implements IOfferRepository {
  final IOfferRemoteDataSource _remoteDataSource;
  final IOfferLocalDataSource _localDataSource;
  final ICacheStrategy<OfferModel> _cacheStrategy;
  final IConnectivityChecker _connectivityChecker;

  @override
  Future<List<Offer>> getByBuyerId(String buyerId) async {
    return _cacheStrategy.executeCacheFirst(
      cacheKey: 'offers_buyer_$buyerId',
      fetchRemote: () => _remoteDataSource.getByBuyerId(buyerId),
    );
  }
}
```

### 5. Restructure Project Folders

```
lib/
├── core/
│   ├── domain/                    # Domain Model (unchanged)
│   │   ├── entities/
│   │   ├── value_objects/
│   │   ├── enums/
│   │   ├── exceptions/
│   │   └── services/              # Pure domain services only
│   │
│   ├── application/               # NEW: Application Layer
│   │   ├── ports/
│   │   │   ├── inbound/           # Use case interfaces
│   │   │   └── outbound/          # Repository interfaces (moved from domain)
│   │   └── use_cases/             # Use case implementations
│   │
│   └── infrastructure/            # RENAMED from data
│       ├── adapters/
│       │   ├── driven/            # Repository implementations
│       │   │   ├── persistence/   # SQLite adapters
│       │   │   └── api/           # HTTP adapters
│       │   └── driving/           # Controllers, presenters
│       ├── di/                    # Dependency injection
│       └── services/              # Infrastructure services
│
└── features/
    └── */
        └── presentation/          # Pure UI (widgets only)
            ├── screens/
            ├── widgets/
            └── providers/          # Thin providers calling use cases
```

---

## Detailed Migration Steps

### Phase 1: Foundation (Low Risk)

1. ✅ Create `application/` directory structure
2. ✅ Move repository interfaces to `application/ports/outbound/`
3. ✅ Create use case interfaces in `application/ports/inbound/`
4. ✅ Test: Ensure existing functionality works unchanged

### Phase 2: Application Layer (Medium Risk)

5. Create use case implementations for each domain operation
6. Refactor `NegotiationService` → individual use cases:
   - `CreateOfferUseCase`
   - `AcceptOfferUseCase`
   - `RejectOfferUseCase`
   - `CounterOfferUseCase`
7. Create use case providers in Riverpod
8. Test: Verify use cases work correctly

### Phase 3: Presentation Refactoring (High Risk)

9. Create controller/state notifier for each major screen
10. Remove `sl<>` calls from UI components (23+ locations)
11. Move business logic from screens to controllers
12. Update providers to use use cases instead of direct repositories
13. Test: Full UI testing for each refactored screen

### Phase 4: Infrastructure Cleanup (Medium Risk)

14. Rename `data/` → `infrastructure/`
15. Separate caching concerns from repositories
16. Create proper adapter interfaces
17. Test: Integration tests for data layer

### Phase 5: Final Cleanup

18. Remove unused code
19. Update documentation
20. Final integration testing

---

## Effort Estimation

| Phase                             | Tasks                                   | Effort (Dev Days) | Risk   |
| --------------------------------- | --------------------------------------- | ----------------- | ------ |
| Phase 1: Foundation               | Directory structure, move interfaces    | 1-2 days          | Low    |
| Phase 2: Application Layer        | Create 15-20 use cases                  | 5-7 days          | Medium |
| Phase 3: Presentation Refactoring | Refactor 10+ screens, 23+ `sl<>` usages | 10-15 days        | High   |
| Phase 4: Infrastructure Cleanup   | Repository refactoring                  | 3-5 days          | Medium |
| Phase 5: Final Cleanup            | Documentation, cleanup                  | 2-3 days          | Low    |
| **Total**                         |                                         | **21-32 days**    |        |

### Key Risk Areas

1. **UI Regression**: Presentation refactoring may introduce UI bugs
2. **State Management**: Changing provider structure can break reactive updates
3. **Offline Mode**: Caching strategy changes may affect offline functionality

---

## Recommended Approach

### Option A: Incremental Migration (Recommended)

Migrate feature by feature, starting with the least complex:

1. **Start with**: `user` feature (simpler, fewer dependencies)
2. **Then**: `chat` feature (isolated, clear boundaries)
3. **Then**: `fisher` feature (core complexity)
4. **Finally**: `buyer` feature and `shared`

**Pros**: Lower risk, can ship incrementally, team learns as they go  
**Cons**: Longer total duration, mixed architectures temporarily

### Option B: Big Bang Migration

Refactor entire codebase at once.

**Pros**: Clean transition, no mixed architectures  
**Cons**: High risk, longer feature freeze, harder to debug

### My Recommendation: Option A

Start with a **pilot feature** (e.g., user profile) to:

1. Establish patterns and conventions
2. Validate the approach works
3. Create reusable base classes
4. Document the migration playbook

Then proceed with remaining features using the proven patterns.

---

## Summary Checklist

### What You Already Have ✅

- [x] Domain entities without framework dependencies
- [x] Repository interfaces (outbound ports)
- [x] Value objects with business rules
- [x] Domain services
- [x] Clear separation of domain and data layers

### What You Need to Add ⚠️

- [ ] Application layer with use cases
- [ ] Use case interfaces (inbound ports)
- [ ] Controllers/ViewModels for UI
- [ ] Proper driving adapters
- [ ] Remove direct `sl<>` access from presentation (23+ files)
- [ ] Move business logic out of UI screens

### Migration Complexity

- **Domain Layer**: Minimal changes (mostly reorganization)
- **Application Layer**: New code required
- **Infrastructure Layer**: Moderate refactoring
- **Presentation Layer**: Significant refactoring

---

## Next Steps

1. **Decide on migration approach** (Incremental vs Big Bang)
2. **Choose pilot feature** for initial migration
3. **Create migration branch** and establish patterns
4. **Document coding standards** for hexagonal architecture
5. **Set up testing strategy** for use cases

Would you like me to create a detailed implementation plan for any specific phase or feature?
