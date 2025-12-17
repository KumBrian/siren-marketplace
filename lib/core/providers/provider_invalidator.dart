import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'catch_providers.dart';
import 'product_providers.dart';

/// Global ProviderContainer reference set by the app
/// This allows data sources to invalidate providers
ProviderContainer? _globalProviderContainer;

/// Set the global provider container
/// Should be called once in main() after creating the ProviderScope
void setGlobalProviderContainer(ProviderContainer container) {
  _globalProviderContainer = container;
}

/// Invalidate both catch and product providers
/// Called when a catch is published to marketplace and a product is created
void invalidateCatchAndProductProviders() {
  if (_globalProviderContainer == null) {
    print(
      'WARNING: Global provider container not set, cannot invalidate providers',
    );
    return;
  }

  print('DEBUG: Invalidating fisherCatchesProvider and fisherProductsProvider');

  // Invalidate catch providers
  _globalProviderContainer!.invalidate(fisherCatchesProvider);

  // Invalidate product providers (all pages)
  // Since fisherProductsProvider is a family provider, we need to invalidate it
  _globalProviderContainer!.invalidate(fisherProductsProvider);

  print('DEBUG: Providers invalidated successfully');
}
