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

  // Informations de l'annonce associée.
  String? annonceTitle;
  String? annonceImageUrl;

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
    this.annonceTitle,
    this.annonceImageUrl,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageId,
    this.lastMessageCreatedAt,
    this.lastMessageReadAt,
    this.deletedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'].toString(),

      type:
          (json['type'] ?? 'private')
              .toString(),

      title:
          json['title']?.to
