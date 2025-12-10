# Dual API Architecture

## Overview

The SIREN Marketplace uses two separate API services:

### 1. Core API

**Base URL**: `https://api.core.dev.siren.dhi-cm.com/api/v1`

**Purpose**: Authentication and user account management

**Endpoints**:

- `POST /accounts/authorize` - Login and get JWT token
- `POST /accounts/unauthorize` - Logout
- `GET /accounts/my-profile` - Get current user profile
- `PATCH /accounts/update-profile` - Update user profile
- `GET /accounts/list` - List all accounts
- `POST /accounts/toggle-notifications` - Toggle notifications

### 2. Marketplace API

**Base URL**: `https://api.marketplace.dev.siren.dhi-cm.com/api/v1`

**Purpose**: Marketplace operations (catches, offers, orders, messages, reviews)

**Endpoints**:

- `/fish_catches` - Fish catch management
- `/offers` - Offer management
- `/sale_orders` - Order management
- `/messages` - Messaging
- `/reviews` - Reviews
- `/products`, `/markets`, `/species`, `/gears` - Reference data

## Usage

### Creating API Clients

```dart
// For authentication and user management
final coreClient = ApiClient.core();

// For marketplace operations
final marketplaceClient = ApiClient.marketplace();
```

### Example: Authentication Flow

```dart
// 1. Login using Core API
final authDataSource = AuthApiDataSource(
  client: ApiClient.core(),
);

final authResponse = await authDataSource.authorize(username, password);

// 2. Store JWT token
await tokenStorage.saveToken(authResponse.token);

// 3. Use Marketplace API with token
final catchDataSource = CatchApiDataSource(
  client: ApiClient.marketplace(),
);

// Token is automatically added to requests via interceptor
final catches = await catchDataSource.getAll();
```

## Token Management

The JWT token obtained from the Core API is automatically:

1. Stored securely using `flutter_secure_storage`
2. Added to all subsequent requests (both Core and Marketplace)
3. Refreshed when expired (if refresh endpoint available)
4. Cleared on logout

## Configuration

Both base URLs are configured in `.env`:

```env
API_CORE_BASE_URL=https://api.core.dev.siren.dhi-cm.com/api/v1
API_MARKETPLACE_BASE_URL=https://api.marketplace.dev.siren.dhi-cm.com/api/v1
```

## Implementation Notes

- Both clients share the same `TokenStorage` instance
- Both clients use the same `ApiInterceptor` for token injection
- The interceptor skips adding tokens to `/authorize` and `/unauthorize` endpoints
- All other endpoints automatically include the JWT token in the `Authorization` header
