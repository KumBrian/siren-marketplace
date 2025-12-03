import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/features/chat/data/conversation_repository.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:uuid/uuid.dart';

class ConversationSeeder {
  final Uuid _uuid = const Uuid();

  Future<void> seed(List<Offer> allOffers) async {
    final conversationRepository = sl<ConversationRepository>();
    final catchRepository = sl<ICatchRepository>();
    final userRepository = sl<IUserRepository>();

    final Map<String, Offer> uniqueConversations = {};
    for (final offer in allOffers) {
      final key = '${offer.buyerId}-${offer.fisherId}';
      if (!uniqueConversations.containsKey(key)) {
        uniqueConversations[key] = offer;
      }
    }

    // Early return if no conversations to seed
    if (uniqueConversations.isEmpty) {
      print('No conversations to seed.');
      return;
    }

    for (final offer in uniqueConversations.values) {
      final buyer = await userRepository.getById(offer.buyerId);
      final catchItem = await catchRepository.getById(offer.catchId);

      // Skip if buyer or catch not found
      if (buyer == null || catchItem == null) continue;

      final conv = ConversationPreview(
        id: _uuid.v4(),
        buyerId: offer.buyerId,
        fisherId: offer.fisherId,
        contactName: buyer.name,
        contactAvatarPath: buyer.avatarUrl ?? '',
        lastMessage: offer.status == OfferStatus.accepted
            ? 'The offer for ${catchItem.name} was accepted. Awaiting payment.'
            : 'Is this price negotiable for a bulk order?',
        lastMessageTime: offer.dateCreated.toIso8601String(),
        unreadCount: offer.status == OfferStatus.pending ? 1 : 0,
      );

      await conversationRepository.insertOrUpdateConversation(conv);
    }

    print('${uniqueConversations.length} conversations seeded.');
  }
}
