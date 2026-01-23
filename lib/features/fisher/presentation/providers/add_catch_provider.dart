import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/product_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';

class AddCatchState {
  final int currentStep;

  // Step 1: Gear and Environment Data
  final double? meshSize; // Fingers
  final double? gearLength; // meters
  final double? gearWidth; // meters
  final String? gearNature; // Cotton, Monofilament, Multifilament
  final double? waterDepth; // meters
  final double? fishingTime; // hours

  // Step 2: Species Selection
  final Species? selectedSpecies;

  // Step 2 Data
  final double? estimatedWeight;
  final double? averageSize;
  final int? estimatedCount;
  final int? numberOfShrimps;

  // Selling Data
  final bool isSelling;
  final double? quantityToSell;
  final double? pricePerKg;

  // Step 4 Data
  final String? notes;

  // Location Data
  final String? observationId;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final bool isLoadingLocation;
  final bool isSubmitting;

  // Images (Strings for now, representing paths or assets)
  final List<String> images;

  const AddCatchState({
    this.currentStep = 0,
    this.meshSize,
    this.gearLength,
    this.gearWidth,
    this.gearNature,
    this.waterDepth,
    this.fishingTime,
    this.selectedSpecies,
    this.estimatedWeight,
    this.averageSize,
    this.estimatedCount,
    this.numberOfShrimps,
    this.isSelling = false,
    this.quantityToSell,
    this.pricePerKg,
    this.notes,
    this.observationId,
    this.locationName,
    this.latitude,
    this.longitude,
    this.isLoadingLocation = false,
    this.isSubmitting = false,
    this.images = const [],
  });

  AddCatchState copyWith({
    int? currentStep,
    double? meshSize,
    double? gearLength,
    double? gearWidth,
    String? gearNature,
    double? waterDepth,
    double? fishingTime,
    Species? selectedSpecies,
    double? estimatedWeight,
    double? averageSize,
    int? estimatedCount,
    int? numberOfShrimps,
    bool? isSelling,
    double? quantityToSell,
    double? pricePerKg,
    String? notes,
    String? observationId,
    String? locationName,
    double? latitude,
    double? longitude,
    bool? isLoadingLocation,
    List<String>? images,
    bool? isSubmitting,
  }) {
    return AddCatchState(
      currentStep: currentStep ?? this.currentStep,
      meshSize: meshSize ?? this.meshSize,
      gearLength: gearLength ?? this.gearLength,
      gearWidth: gearWidth ?? this.gearWidth,
      gearNature: gearNature ?? this.gearNature,
      waterDepth: waterDepth ?? this.waterDepth,
      fishingTime: fishingTime ?? this.fishingTime,
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      averageSize: averageSize ?? this.averageSize,
      estimatedCount: estimatedCount ?? this.estimatedCount,
      numberOfShrimps: numberOfShrimps ?? this.numberOfShrimps,
      isSelling: isSelling ?? this.isSelling,
      quantityToSell: quantityToSell ?? this.quantityToSell,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      notes: notes ?? this.notes,
      observationId: observationId ?? this.observationId,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      images: images ?? this.images,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  double get finalPrice {
    if (quantityToSell != null && pricePerKg != null) {
      return quantityToSell! * pricePerKg!;
    }
    return 0.0;
  }
}

class AddCatchNotifier extends StateNotifier<AddCatchState> {
  final Ref ref;
  final ImagePicker _picker = ImagePicker();

  AddCatchNotifier(this.ref) : super(const AddCatchState());

  void updateGearAndEnvironment({
    double? meshSize,
    double? gearLength,
    double? gearWidth,
    String? gearNature,
    double? waterDepth,
    double? fishingTime,
  }) {
    state = state.copyWith(
      meshSize: meshSize ?? state.meshSize,
      gearLength: gearLength ?? state.gearLength,
      gearWidth: gearWidth ?? state.gearWidth,
      gearNature: gearNature ?? state.gearNature,
      waterDepth: waterDepth ?? state.waterDepth,
      fishingTime: fishingTime ?? state.fishingTime,
    );
  }

  void selectSpecies(Species species) {
    state = state.copyWith(selectedSpecies: species);
  }

  void updateCatchDetails({
    double? weight,
    double? size,
    int? count,
    int? numberOfShrimps,
  }) {
    state = state.copyWith(
      estimatedWeight: weight ?? state.estimatedWeight,
      averageSize: size ?? state.averageSize,
      estimatedCount: count ?? state.estimatedCount,
      numberOfShrimps: numberOfShrimps ?? state.numberOfShrimps,
    );
  }

  void toggleSelling(bool value) {
    state = state.copyWith(isSelling: value);
  }

  Future<void> fetchLocation() async {
    state = state.copyWith(isLoadingLocation: true);
    try {
      // 1. Check Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          state = state.copyWith(isLoadingLocation: false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        state = state.copyWith(isLoadingLocation: false);
        return;
      }

      // 2. Get Position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Decode Location (Reverse Geocoding)
      String locationName = 'Unknown Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Construct a readable location string
          // e.g., "Bonanjo, Douala"
          locationName =
              "${place.locality ?? place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}";
          if (locationName.trim() == ',') {
            locationName =
                place.name ?? place.street ?? 'Unknown Location'; // Fallback
          }
        }
      } catch (e) {
        // Error decoding location
      }

      // 4. Generate Observation ID
      final observationId =
          'Obs-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // 5. Update State
      state = state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
        observationId: observationId,
        isLoadingLocation: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingLocation: false);
    }
  }

  void updateSellingDetails({double? quantity, double? price}) {
    state = state.copyWith(
      quantityToSell: quantity ?? state.quantityToSell,
      pricePerKg: price ?? state.pricePerKg,
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        addImage(image.path);
      }
    } catch (e) {
      // Error picking image
    }
  }

  void addImage(String imagePath) {
    state = state.copyWith(images: [...state.images, imagePath]);
  }

  void removeImage(int index) {
    final newImages = List<String>.from(state.images)..removeAt(index);
    state = state.copyWith(images: newImages);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  bool canProceed() {
    switch (state.currentStep) {
      case 0:
        return state.meshSize != null &&
            state.gearLength != null &&
            state.gearWidth != null &&
            state.gearNature != null &&
            state.waterDepth != null &&
            state.fishingTime != null;
      case 1:
        return state.selectedSpecies != null;
      case 2:
        // Basic validation for Step 3 (Calculations)
        if (state.estimatedWeight == null || state.estimatedCount == null) {
          return false;
        }
        if (state.isSelling) {
          if (state.quantityToSell == null || state.pricePerKg == null) {
            return false;
          }
          // Validation: Cannot sell more than caught
          if (state.estimatedWeight != null &&
              state.quantityToSell! > state.estimatedWeight!) {
            return false;
          }
        }
        return true;
      // Step 3 & 4 (Images & Review)
      default:
        return true;
    }
  }

  Future<bool> saveAsDraft() async {
    // Only basic validation: Needs at least location and species maybe?
    // Or allow completely empty? Drafts imply "Work in Progress".
    // For now, let's require at least Species to give it a name.

    if (state.selectedSpecies == null) {
      // Maybe ok? Name defaults to "Unknown Species" in submit logic.
    }

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        print("Error: User not found");
        return false;
      }

      final catchRepository = sl<ICatchRepository>();

      final catchId = DateTime.now().millisecondsSinceEpoch.toString();

      // Use species image if no images are selected (Temporary)
      List<String> catchImages = state.images;
      if (catchImages.isEmpty && state.selectedSpecies != null) {
        catchImages = [state.selectedSpecies!.image];
      }

      final catchEntity = Catch(
        id: catchId,
        name: state.selectedSpecies?.name ?? 'Unknown Species',
        datePosted: DateTime.now(),
        initialWeight: Weight.fromKg(state.estimatedWeight ?? 0),
        availableWeight: Weight.fromKg(
          0,
        ), // Drafts don't have available weight for sale yet
        pricePerKg: PricePerKg.fromAmount((state.pricePerKg ?? 0).round()),
        totalPrice: Price.fromAmount(state.finalPrice.round()),
        size: state.averageSize?.toString() ?? '0',
        market: "Douala",
        images: catchImages,
        species:
            state.selectedSpecies ??
            const Species(id: 'unknown', name: 'Unknown', image: '', uid: ''),
        fisherId: user.id,
        status: CatchStatus.draft, // FORCE DRAFT
        observationId: state.observationId ?? 'Obs-UNKNOWN',
        locationName: state.locationName ?? 'Unknown Location',
        latitude: state.latitude ?? 0.0,
        longitude: state.longitude ?? 0.0,
        meshSize: (state.meshSize ?? 0).toDouble(),
        gearLength: state.gearLength,
        gearWidth: state.gearWidth,
        gearNature: state.gearNature,
        waterDepth: state.waterDepth,
        fishingTime: state.fishingTime,
        numberOfShrimps: state.numberOfShrimps,
      );

      await catchRepository.saveDraft(catchEntity);

      // Invalidate providers
      ref.invalidate(fisherCatchesProvider);

      // Clear state
      state = const AddCatchState();

      return true;
    } catch (e) {
      print("Error saving draft: $e");
      return false;
    }
  }

  Future<bool> submit() async {
    if (!canProceed()) return false;
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        state = state.copyWith(isSubmitting: false);
        return false;
      }

      final catchRepository = sl<ICatchRepository>();

      final catchId = DateTime.now().millisecondsSinceEpoch.toString();

      // Use species image if no images are selected (Temporary)
      List<String> catchImages = state.images;
      // TODO: Restrict submitting without real photos in future
      if (catchImages.isEmpty && state.selectedSpecies != null) {
        catchImages = [state.selectedSpecies!.image];
      }

      final catchEntity = Catch(
        id: catchId,
        name: state.selectedSpecies?.name ?? 'Unknown Species',
        datePosted: DateTime.now(),
        initialWeight: Weight.fromKg(state.estimatedWeight ?? 0),
        availableWeight: state.isSelling
            ? Weight.fromKg(state.quantityToSell ?? 0)
            : Weight.fromKg(state.estimatedWeight ?? 0),
        pricePerKg: PricePerKg.fromAmount((state.pricePerKg ?? 0).round()),
        totalPrice: Price.fromAmount(state.finalPrice.round()),
        size: state.averageSize?.toString() ?? '0',
        market: "Douala", // Default for now
        images: catchImages,
        species:
            state.selectedSpecies ??
            const Species(id: 'unknown', name: 'Unknown', image: '', uid: ''),
        fisherId: user.id,
        status: state.isSelling ? CatchStatus.available : CatchStatus.draft,
        observationId: state.observationId ?? 'Obs-UNKNOWN',
        locationName: state.locationName ?? 'Unknown Location',
        latitude: state.latitude ?? 0.0,
        longitude: state.longitude ?? 0.0,
        meshSize: (state.meshSize ?? 0).toDouble(),
        gearLength: state.gearLength,
        gearWidth: state.gearWidth,
        gearNature: state.gearNature,
        waterDepth: state.waterDepth,
        fishingTime: state.fishingTime,
        numberOfShrimps: state.numberOfShrimps,
      );

      final isOnline = ref.read(isOnlineProvider);

      if (isOnline && state.isSelling) {
        try {
          await catchRepository.create(catchEntity);
        } catch (e) {
          // Fallback to draft
          await catchRepository.saveDraft(
            catchEntity.copyWith(status: CatchStatus.draft),
          );
        }
      } else {
        // Offline or explicitly not selling yet -> Save as Draft
        await catchRepository.saveDraft(
          catchEntity.copyWith(status: CatchStatus.draft),
        );
      }

      // Invalidate providers
      ref.invalidate(fisherCatchesProvider);

      if (state.isSelling) {
        // Invalidate product providers to refresh the lists
        ref.invalidate(fisherProductsProvider);
        ref.invalidate(availableProductsProvider);
      }

      // Clear state (isSubmitting will reset to false with new state)
      state = const AddCatchState();

      return true;
    } catch (e) {
      // Log error or handle it
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final addCatchProvider = StateNotifierProvider<AddCatchNotifier, AddCatchState>(
  (ref) {
    return AddCatchNotifier(ref);
  },
);
