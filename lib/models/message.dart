import 'package:flutter_marketplace_template/models/message_reply.dart';

/// Message d'une conversation Koteka.
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String type;
  final String text;
  final String metadata;
  final String? replyTo;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? readAt;
  final MessageReply? reply;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    required this.text,
    required this.metadata,
    this.replyTo,
    this.reply,
    required this.createdAt,
    required this.editedAt,
    this.readAt,
  });

  factory Message.fromJson(
    Map<String, dynamic> json, {
    MessageReply? reply,
  }) {
    return Message(
      id: json['id'].toString(),

      chatId:
          (json['conversation_id'] ??
                  json['chat_id'] ??
                  '')
              .toString(),

      senderId:
          (json['sender_id'] ?? '')
              .toString(),

      type:
          (json['type'] ?? 'text')
              .toString(),

      text:
          (json['text'] ??
                  json['content'] ??
                  '')
              .toString(),

      metadata:
          (json['metadata'] ?? '{}')
              .toString(),

      replyTo:
          json['reply_to']?.toString(),

      createdAt:
          DateTime.tryParse(
            json['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),

      editedAt:
          DateTime.tryParse(
            json['edited_at']?.toString() ?? '',
          ),

      readAt:
          DateTime.tryParse(
            json['read_at']?.toString() ?? '',
          ),

      reply: reply,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': chatId,
      'sender_id': senderId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? text,
    String? chatId,
    DateTime? createdAt,
    String? type,
    String? metadata,
    DateTime? editedAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      replyTo: replyTo,
      reply: reply,
    );
  }
}
