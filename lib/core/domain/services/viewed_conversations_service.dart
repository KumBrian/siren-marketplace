import 'package:shared_preferences/shared_preferences.dart';

abstract class IViewedConversationsService {
  /// Initialize the service
  Future<void> init();

  /// Mark a conversation as viewed with the given update timestamp
  Future<void> markAsViewed(String conversationId, DateTime dateUpdated);

  /// Check if the conversation's current update has been viewed
  bool isViewed(String conversationId, DateTime dateUpdated);
}

class ViewedConversationsService implements IViewedConversationsService {
  late SharedPreferences _prefs;
  static const String _keyPrefix = 'viewed_conversation_';

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> markAsViewed(String conversationId, DateTime dateUpdated) async {
    final key = '$_keyPrefix$conversationId';
    await _prefs.setString(key, dateUpdated.toIso8601String());
  }

  @override
  bool isViewed(String conversationId, DateTime dateUpdated) {
    final key = '$_keyPrefix$conversationId';
    final savedIsoString = _prefs.getString(key);

    if (savedIsoString == null) {
      return false;
    }

    final savedDate = DateTime.parse(savedIsoString);
    // If saved date is on or after the current update date, it's viewed.
    return savedDate.isAtSameMomentAs(dateUpdated) ||
        savedDate.isAfter(dateUpdated);
  }
}
