class OfferEntity {
  final String offerId;
  final Map<String, dynamic> map;

  OfferEntity({required this.offerId, required this.map});

  factory OfferEntity.fromMap(Map<String, dynamic> m) {
    final id = (m['offer_id'] ?? m['id']) as String;
    return OfferEntity(offerId: id, map: m);
  }

  Map<String, dynamic> toMap() => map;
}
