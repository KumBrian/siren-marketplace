import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/features/fisher/presentation/models/specie_widget_model.dart';

class AddCatchState {
  final int currentStep;
  final SpecieWidgetModel? selectedSpecies;

  // Step 2 Data
  final double? estimatedWeight;
  final double? averageSize;
  final int? estimatedCount;

  // Selling Data
  final bool isSelling;
  final double? quantityToSell;
  final double? pricePerKg;

  // Step 4 Data
  final String? notes;

  // Images (Strings for now, representing paths or assets)
  final List<String> images;

  const AddCatchState({
    this.currentStep = 0,
    this.selectedSpecies,
    this.estimatedWeight,
    this.averageSize,
    this.estimatedCount,
    this.isSelling = false,
    this.quantityToSell,
    this.pricePerKg,
    this.notes,
    this.images = const [],
  });

  AddCatchState copyWith({
    int? currentStep,
    SpecieWidgetModel? selectedSpecies,
    double? estimatedWeight,
    double? averageSize,
    int? estimatedCount,
    bool? isSelling,
    double? quantityToSell,
    double? pricePerKg,
    String? notes,
    List<String>? images,
  }) {
    return AddCatchState(
      currentStep: currentStep ?? this.currentStep,
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      averageSize: averageSize ?? this.averageSize,
      estimatedCount: estimatedCount ?? this.estimatedCount,
      isSelling: isSelling ?? this.isSelling,
      quantityToSell: quantityToSell ?? this.quantityToSell,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      notes: notes ?? this.notes,
      images: images ?? this.images,
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

  void selectSpecies(SpecieWidgetModel species) {
    state = state.copyWith(selectedSpecies: species);
  }

  void updateCatchDetails({double? weight, double? size, int? count}) {
    state = state.copyWith(
      estimatedWeight: weight ?? state.estimatedWeight,
      averageSize: size ?? state.averageSize,
      estimatedCount: count ?? state.estimatedCount,
    );
  }

  void toggleSelling(bool value) {
    state = state.copyWith(isSelling: value);
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
      print("Error picking image: $e");
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
    if (state.currentStep < 3) {
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
        return state.selectedSpecies != null;
      case 1:
        // Basic validation for Step 2
        if (state.estimatedWeight == null || state.estimatedCount == null)
          return false;
        if (state.isSelling) {
          if (state.quantityToSell == null || state.pricePerKg == null)
            return false;
          // Validation: Cannot sell more than caught
          if (state.estimatedWeight != null &&
              state.quantityToSell! > state.estimatedWeight!)
            return false;
        }
        return true;
      // Step 2 & 3 are less strict or depend on image upload implementation
      default:
        return true;
    }
  }

  Future<bool> submit() async {
    if (!canProceed()) return false;

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        print("Error: User not found");
        return false;
      }

      final catchRepository = sl<ICatchRepository>();

      final catchId = DateTime.now().millisecondsSinceEpoch.toString();

      final catchEntity = Catch(
        id: catchId,
        name: state.selectedSpecies?.name ?? 'Unknown Species',
        datePosted: DateTime.now(),
        initialWeight: Weight.fromKg(state.estimatedWeight ?? 0),
        availableWeight: state.isSelling
            ? Weight.fromKg(state.quantityToSell ?? 0)
            : Weight.fromKg(state.estimatedWeight ?? 0),
        pricePerKg: PricePerKg.fromAmount(
          ((state.pricePerKg ?? 0) * 100).round(),
        ),
        totalPrice: Price.fromMajor(state.finalPrice),
        size: state.averageSize?.toString() ?? '0',
        market: "Douala", // Default for now
        images: state.images,
        species: Species(
          id: state.selectedSpecies?.name ?? 'unknown',
          name: state.selectedSpecies?.name ?? 'Unknown',
        ),
        fisherId: user.id,
        status: state.isSelling ? CatchStatus.available : CatchStatus.draft,
      );

      await catchRepository.create(catchEntity);

      // Clear state
      state = const AddCatchState();

      return true;
    } catch (e) {
      // Log error or handle it
      print("Error submitting catch: $e");
      return false;
    }
  }
}

final addCatchProvider = StateNotifierProvider<AddCatchNotifier, AddCatchState>(
  (ref) {
    return AddCatchNotifier(ref);
  },
);
