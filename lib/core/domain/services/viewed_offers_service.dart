import 'package:shared_preferences/shared_preferences.dart';

abstract class IViewedOffersService {
  /// Initialize the service
  Future<void> init();

  /// Mark an offer as viewed with the given update timestamp
  Future<void> markAsViewed(String offerId, DateTime dateUpdated);

  /// Check if the offer's current update has been viewed
  bool isViewed(String offerId, DateTime dateUpdated);
}

class ViewedOffersService implements IViewedOffersService {
  late SharedPreferences _prefs;
  static const String _keyPrefix = 'viewed_offer_';

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> markAsViewed(String offerId, DateTime dateUpdated) async {
    final key = '$_keyPrefix$offerId';
    await _prefs.setString(key, dateUpdated.toIso8601String());
  }

  @override
  bool isViewed(String offerId, DateTime dateUpdated) {
    final key = '$_keyPrefix$offerId';
    final savedIsoString = _prefs.getString(key);

    if (savedIsoString == null) {
      return false;
    }

    final savedDate = DateTime.parse(savedIsoString);
    // If saved date is on or after the current update date, it's viewed.
    // Using isAtSameMomentAs to rely on exact timestamp matching which is robust for API responses.
    return savedDate.isAtSameMomentAs(dateUpdated) ||
        savedDate.isAfter(dateUpdated);
  }
}
