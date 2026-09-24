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

  // Informations du dernier message.
  String? lastMessageText;
  String? lastMessageSenderId;
  String? lastMessageId;
  DateTime? lastMessageCreatedAt;
  DateTime? lastMessageReadAt;

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
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageId,
    this.lastMessageCreatedAt,
    this.lastMessageReadAt,
    this.deletedAt,
  });

  factory Chat.fromJson(
    Map<String, dynamic> json,
  ) {
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
                  json['annonce_id']
                          ?.toString() ??
                      '',
                ),

      buyerId:
          json['buyer_id']?.toString(),

      sellerId:
          json['seller_id']?.toString(),

      createdAt:
          DateTime.tryParse(
            json['created_at']
                    ?.toString() ??
                '',
          ) ??
          DateTime.now(),

      lastMessageAt:
          DateTime.tryParse(
        json['updated_at']?.toString() ??
            json['last_message_at']
                ?.toString() ??
            '',
      ),

      deletedAt:
          DateTime.tryParse(
        json['deleted_at']?.toString() ??
            '',
      ),
    );
  }

  /// Indique si le dernier message reçu
  /// n'a pas encore été lu.
  bool isUnreadFor(
    String currentUserId,
  ) {
    if (lastMessageId == null ||
        lastMessageSenderId == null) {
      return false;
    }

    // Son propre message n'est jamais
    // considéré comme non lu.
    if (lastMessageSenderId ==
        currentUserId) {
      return false;
    }

    return lastMessageReadAt == null;
  }
}
