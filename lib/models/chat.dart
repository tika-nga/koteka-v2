/// Conversation Koteka entre un acheteur et un vendeur.
class Chat {
  final String id;

  final String type;
  final String? title;

  final int? annonceId;
  final String? buyerId;
  final String? sellerId;

  final DateTime createdAt;
  DateTime? lastMessageAt;

  // Conservé temporairement pour compatibilité
  // avec l'ancien écran ChatScreen.
  DateTime? deletedAt;

  Chat({
    required this.id,
    this.type = 'private',
    this.title,
    this.annonceId,
    this.buyerId,
    this.sellerId,
    required this.createdAt,
    this.lastMessageAt,
    this.deletedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'].toString(),

      type:
          (json['type'] ?? 'private')
              .toString(),

      title:
          json['title']?.toString(),

      annonceId:
          json['annonce_id'] is int
              ? json['annonce_id'] as int
              : int.tryParse(
                json['annonce_id']?.toString() ?? '',
              ),

      buyerId:
          json['buyer_id']?.toString(),

      sellerId:
          json['seller_id']?.toString(),

      createdAt:
          DateTime.tryParse(
            json['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),

      // Dans Koteka, updated_at représente
      // l'activité la plus récente de la conversation.
      lastMessageAt:
          DateTime.tryParse(
            json['updated_at']?.toString() ??
                json['last_message_at']?.toString() ??
                '',
          ),

      deletedAt:
          DateTime.tryParse(
            json['deleted_at']?.toString() ?? '',
          ),
    );
  }
}
