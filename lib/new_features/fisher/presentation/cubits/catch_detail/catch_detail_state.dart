import 'package:equatable/equatable.dart';

import '../../../../../new_core/domain/entities/catch.dart';
import '../../../../../new_core/domain/entities/offer.dart';
import '../../../../../new_core/domain/enums/offer_status.dart';

abstract class CatchDetailState extends Equatable {
  const CatchDetailState();

  @override
  List<Object?> get props => [];
}

class CatchDetailInitial extends CatchDetailState {
  const CatchDetailInitial();
}

class CatchDetailLoading extends CatchDetailState {
  const CatchDetailLoading();
}

class CatchDetailLoaded extends CatchDetailState {
  final Catch catch_;
  final List<Offer> offers;
  final OfferStatus? filterStatus;
  final bool isUpdating;

  const CatchDetailLoaded({
    required this.catch_,
    required this.offers,
    this.filterStatus,
    this.isUpdating = false,
  });

  CatchDetailLoaded copyWith({
    Catch? catch_,
    List<Offer>? offers,
    OfferStatus? filterStatus,
    bool? isUpdating,
    bool clearFilter = false,
  }) {
    return CatchDetailLoaded(
      catch_: catch_ ?? this.catch_,
      offers: offers ?? this.offers,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [catch_, offers, filterStatus, isUpdating];
}

class CatchDetailError extends CatchDetailState {
  final String message;

  const CatchDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
