import '../../domain/entities/offer.dart';
import '../../domain/enums/offer_status.dart';
import '../../domain/repositories/i_offer_repository.dart';
import '../datasources/interfaces/i_offer_datasource.dart';
import '../mappers/offer_mapper.dart';

class OfferRepositoryImpl implements IOfferRepository {
  final IOfferDataSource dataSource;

  OfferRepositoryImpl({required this.dataSource});

  @override
  Future<String> create(Offer offer) async {
    final model = OfferMapper.toModel(offer);
    return await dataSource.create(model);
  }

  @override
  Future<Offer?> getById(String offerId) async {
    final model = await dataSource.getById(offerId);
    return model != null ? OfferMapper.toEntity(model) : null;
  }

  @override
  Future<List<Offer>> getByCatchId(String catchId) async {
    final models = await dataSource.getByCatchId(catchId);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByBuyerId(String buyerId) async {
    final models = await dataSource.getByBuyerId(buyerId);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByFisherId(String fisherId) async {
    final models = await dataSource.getByFisherId(fisherId);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByCatchIds(List<String> catchIds) async {
    final models = await dataSource.getByCatchIds(catchIds);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByStatus(OfferStatus status) async {
    final models = await dataSource.getByStatus(status);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getPendingForUser(String userId) async {
    final pending = await getByStatus(OfferStatus.pending);
    return pending.where((o) => o.isUsersTurn(userId)).toList();
  }

  @override
  Future<void> update(Offer offer) async {
    final model = OfferMapper.toModel(offer);
    await dataSource.update(model);
  }

  @override
  Future<void> delete(String offerId) async {
    await dataSource.delete(offerId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dataSource.transaction(action);
  }
}
