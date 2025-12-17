import 'package:flutter/material.dart';
// Blocs & Cubits
import 'package:siren_marketplace/core/config/app_config.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/services/seeder.dart';
import 'package:siren_marketplace/core/di/injector.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/providers/router_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize DI
  await initDependencies();

  // Seed database if in local mode
  if (AppConfig.isLocalMode) {
    final seeder = Seeder();
    await seeder.seedAll();
  }

  // Create provider container
  final container = ProviderContainer();

  // Set up provider invalidation for catch published events (API mode only)
  if (AppConfig.isApiMode) {
    setupProviderInvalidation(container);
  }

  // Run app
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue500),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      routerConfig: router,
    );
  }
}
