import 'package:flutter/material.dart';
// Blocs & Cubits
import 'package:siren_marketplace/core/config/app_config.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/services/seeder.dart';
import 'package:siren_marketplace/core/di/injector.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/providers/router_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:siren_marketplace/core/providers/error_provider.dart';
import 'package:siren_marketplace/core/widgets/offline_banner.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Use a variable to handle the provider container, so it can be accessed in the error handler
  ProviderContainer? container;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp();

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
      final createdContainer = ProviderContainer();
      container = createdContainer;

      // Set up provider invalidation for catch published events (API mode only)
      if (AppConfig.isApiMode) {
        setupProviderInvalidation(createdContainer);
      }

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError caught: ${details.exception}');
      };

      runApp(
        UncontrolledProviderScope(
          container: createdContainer,
          child: const MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('Caught error in runZonedGuarded: $error');
      debugPrint(stackTrace.toString());

      if (container != null) {
        // Use the provider container to get the ErrorDialogService
        try {
          final errorDialogService = container!.read(
            errorDialogServiceProvider,
          );
          errorDialogService.showErrorDialog(
            title: 'Unexpected Error',
            message: 'An unexpected error occurred. Please try again.',
          );
        } catch (e) {
          debugPrint('Failed to show error dialog: $e');
        }
      } else {
        debugPrint(
          'Error occurred before ProviderContainer was initialized. cannot show dialog.',
        );
      }
    },
  );
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
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            // Offline indicator overlay
            Positioned(top: 50, right: 50, child: const OfflineIndicator()),
          ],
        );
      },
    );
  }
}
