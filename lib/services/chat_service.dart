import 'dart:async';

import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/models/chat.dart';
import 'package:flutter_marketplace_template/models/message.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/logger_service.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';

abstract class IChatService {
  /// Ancienne méthode conservée temporairement
  /// pour compatibilité avec le reste du projet.
  Future<FetchResponse<String>> getOrCreateChat({
    required String receiverId,
    required String placeName,
  });

  /// Nouvelle méthode Koteka.
  Future<FetchResponse<String>> getOrCreateConversation({
    required int annonceId,
  });

  Future<FetchResponse<DateTime?>> getChatDeletedAt({
    required String chatId,
  });

  Future<void> setChatLastMessageAt({
    required String chatId,
    required DateTime timestamp,
  });

  Future<void> setLastReadMessageAt({
    required String chatId,
    required String userId,
    required String lastMessageId,
    required DateTime timestamp,
  });

  Future<FetchResponse<Message>> sendMessage({
    required String senderId,
    required String chatId,
    required String text,
    String? replyTo,
  });

  Future<FetchResponse<Map<String, (DateTime?, String?)>>>
      fetchLastReadTimestampsForUser({
    required String userId,
  });

  Future<FetchResponse<String>> fetchChatParticipantId({
    required String chatId,
    required String userId,
  });

  Future<FetchResponse<Map<String, String>>>
      fetchChatParticipantsIdForUser({
    required String userId,
  });

  Stream<List<Message>> subscribeMessagesForChat({
    required String userId,
    required String chatId,
  });

  Stream<List<Chat>> subscribeToChatsUpdates(
    List<String> chatIds,
  );

  Future<void> deleteUserChats(String userId);
}

class ChatServiceSupabase implements IChatService {
  final IUserService _userService;

  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static const String annonces = 'annonces';

  ChatServiceSupabase(this._userService);

  String? _currentUserId() {
    final serviceUserId =
        _userService.getCurrentUserId();

    if (serviceUserId != null &&
        serviceUserId.isNotEmpty) {
      return serviceUserId;
    }

    return supabase.auth.currentUser?.id;
  }

  // =========================================================
  // CRÉER / RÉCUPÉRER UNE CONVERSATION POUR UNE ANNONCE
  // =========================================================

  @override
  Future<FetchResponse<String>>
      getOrCreateConversation({
    required int annonceId,
  }) async {
    try {
      final buyerId = _currentUserId();

      if (buyerId == null || buyerId.isEmpty) {
        return FetchOneFailure(
          'Utilisateur non connecté',
        );
      }

      final annonce = await supabase
          .from(annonces)
          .select('id, user_id')
          .eq('id', annonceId)
          .maybeSingle();

      if (annonce == null) {
        return FetchOneFailure(
          'Annonce introuvable',
        );
      }

      final sellerId =
          annonce['user_id']?.toString();

      if (sellerId == null ||
          sellerId.isEmpty) {
        return FetchOneFailure(
          'Cette annonce ne possède pas de vendeur.',
        );
      }

      if (sellerId == buyerId) {
        return FetchOneFailure(
          'Vous ne pouvez pas vous envoyer un message sur votre propre annonce.',
        );
      }

      final existing = await supabase
          .from(conversations)
          .select('id')
          .eq('annonce_id', annonceId)
          .eq('buyer_id', buyerId)
          .eq('seller_id', sellerId)
          .maybeSingle();

      if (existing != null) {
        return FetchOneSuccess(
          existing['id'].toString(),
        );
      }

      try {
        final created = await supabase
            .from(conversations)
            .insert({
              'annonce_id': annonceId,
              'buyer_id': buyerId,
              'seller_id': sellerId,
            })
            .select('id')
            .single();

        return FetchOneSuccess(
          created['id'].toString(),
        );
      } catch (_) {
        // Protection contre deux créations simultanées.
        // La contrainte UNIQUE côté Supabase garantit
        // qu'une seule conversation existe.

        final existingAfterConflict =
            await supabase
                .from(conversations)
                .select('id')
                .eq('annonce_id', annonceId)
                .eq('buyer_id', buyerId)
                .eq('seller_id', sellerId)
                .maybeSingle();

        if (existingAfterConflict != null) {
          return FetchOneSuccess(
            existingAfterConflict['id']
                .toString(),
          );
        }

        rethrow;
      }
    } catch (e) {
      return FetchOneFailure(
        'Erreur lors de l’ouverture de la conversation : $e',
      );
    }
  }

  // =========================================================
  // ANCIENNE MÉTHODE
  // =========================================================

  @override
  Future<FetchResponse<String>> getOrCreateChat({
    required String receiverId,
    required String placeName,
  }) async {
    return FetchOneFailure(
      'Cette ancienne méthode de conversation n’est plus utilisée par Koteka.',
    );
  }

  // =========================================================
  // COMPATIBILITÉ ANCIEN CHATSCREEN
  // =========================================================

  @override
  Future<FetchResponse<DateTime?>>
      getChatDeletedAt({
    required String chatId,
  }) async {
    return FetchOneSuccess(null);
  }

  @override
  Future<void> setChatLastMessageAt({
    required String chatId,
    required DateTime timestamp,
  }) async {
    // updated_at est maintenant mis à jour automatiquement
    // par le trigger Supabase créé précédemment.
  }

  // =========================================================
  // ENVOYER UN MESSAGE
  // =========================================================

  @override
  Future<FetchResponse<Message>> sendMessage({
    required String senderId,
    required String chatId,
    required String text,
    String? replyTo,
  }) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return FetchOneFailure(
        'Le message est vide.',
      );
    }

    try {
      final currentUserId = _currentUserId();

      if (currentUserId == null ||
          currentUserId.isEmpty) {
        return FetchOneFailure(
          'Utilisateur non connecté',
        );
      }

      if (currentUserId != senderId) {
        return FetchOneFailure(
          'Utilisateur invalide.',
        );
      }

      final response = await supabase
          .from(messages)
          .insert({
            'conversation_id': chatId,
            'sender_id': currentUserId,
            'text': cleanText,
          })
          .select()
          .single();

      return FetchOneSuccess(
        Message.fromJson(response),
      );
    } catch (e) {
      return FetchOneFailure(
        'Erreur lors de l’envoi du message : $e',
      );
    }
  }

  // =========================================================
  // MESSAGES TEMPS RÉEL
  // =========================================================

  @override
  Stream<List<Message>>
      subscribeMessagesForChat({
    required String userId,
    required String chatId,
  }) {
    return supabase
        .from(messages)
        .stream(primaryKey: ['id'])
        .eq('conversation_id', chatId)
        .order('created_at')
        .map(
          (rows) => rows
              .map(
                (row) =>
                    Message.fromJson(row),
              )
              .toList(),
        );
  }

  // =========================================================
  // MARQUER UN MESSAGE COMME LU
  // =========================================================

  @override
  Future<void> setLastReadMessageAt({
    required String chatId,
    required String userId,
    required String lastMessageId,
    required DateTime timestamp,
  }) async {
    try {
      final currentUserId = _currentUserId();

      if (currentUserId == null ||
          currentUserId != userId) {
        return;
      }

      await supabase
          .from(messages)
          .update({
            'read_at':
                timestamp.toIso8601String(),
          })
          .eq('id', lastMessageId)
          .eq('conversation_id', chatId)
          .neq('sender_id', userId);
    } catch (e) {
      Log.warning(
        'Erreur lors du marquage du message comme lu : $e',
      );
    }
  }

  // =========================================================
  // INFORMATIONS DE LECTURE
  // =========================================================

  @override
  Future<
      FetchResponse<
          Map<String, (DateTime?, String?)>>>
      fetchLastReadTimestampsForUser({
    required String userId,
  }) async {
    try {
      final conversationsResponse =
          await supabase
              .from(conversations)
              .select('id')
              .or(
                'buyer_id.eq.$userId,seller_id.eq.$userId',
              );

      final Map<
          String,
          (DateTime?, String?)> result = {};

      for (final conversation
          in conversationsResponse) {
        final conversationId =
            conversation['id'].toString();

        final lastRead = await supabase
            .from(messages)
            .select(
              'id, created_at, read_at',
            )
            .eq(
              'conversation_id',
              conversationId,
            )
            .neq('sender_id', userId)
            .not('read_at', 'is', null)
            .order(
              'created_at',
              ascending: false,
            )
            .limit(1)
            .maybeSingle();

        if (lastRead == null) {
          result[conversationId] =
              (null, null);
        } else {
          result[conversationId] = (
            DateTime.tryParse(
              lastRead['read_at']
                      ?.toString() ??
                  '',
            ),
            lastRead['id']?.toString(),
          );
        }
      }

      return FetchOneSuccess(result);
    } catch (e) {
      return FetchOneFailure(
        'Erreur lors de la lecture des messages : $e',
      );
    }
  }

  // =========================================================
  // AUTRE PARTICIPANT
  // =========================================================

  @override
  Future<FetchResponse<String>>
      fetchChatParticipantId({
    required String chatId,
    required String userId,
  }) async {
    try {
      final response = await supabase
          .from(conversations)
          .select('buyer_id, seller_id')
          .eq('id', chatId)
          .maybeSingle();

      if (response == null) {
        return FetchOneFailure(
          'Conversation introuvable',
        );
      }

      final buyerId =
          response['buyer_id'].toString();

      final sellerId =
          response['seller_id'].toString();

      if (buyerId == userId) {
        return FetchOneSuccess(sellerId);
      }

      if (sellerId == userId) {
        return FetchOneSuccess(buyerId);
      }

      return FetchOneFailure(
        'Utilisateur absent de cette conversation.',
      );
    } catch (e) {
      return FetchOneFailure(
        'Erreur participant : $e',
      );
    }
  }

  @override
  Future<FetchResponse<Map<String, String>>>
      fetchChatParticipantsIdForUser({
    required String userId,
  }) async {
    try {
      final response = await supabase
          .from(conversations)
          .select(
            'id, buyer_id, seller_id',
          )
          .or(
            'buyer_id.eq.$userId,seller_id.eq.$userId',
          );

      final Map<String, String> result = {};

      for (final row in response) {
        final id = row['id'].toString();

        final buyerId =
            row['buyer_id'].toString();

        final sellerId =
            row['seller_id'].toString();

        result[id] =
            buyerId == userId
                ? sellerId
                : buyerId;
      }

      return FetchOneSuccess(result);
    } catch (e) {
      return FetchOneFailure(
        'Erreur participants : $e',
      );
    }
  }

  // =========================================================
  // LISTE DES CONVERSATIONS
  // =========================================================

  @override
  Stream<List<Chat>> subscribeToChatsUpdates(
    List<String> chatIds,
  ) {
    final userId = _currentUserId();

    if (userId == null || userId.isEmpty) {
      return Stream.value([]);
    }

    return supabase
        .from(conversations)
        .stream(primaryKey: ['id'])
        .map((rows) {
          final visibleRows = rows.where(
            (row) =>
                row['buyer_id'] == userId ||
                row['seller_id'] == userId,
          );

          final chats = visibleRows
              .map(
                (row) => Chat.fromJson(row),
              )
              .toList();

          chats.sort((a, b) {
            final aDate =
                a.lastMessageAt ??
                    a.createdAt;

            final bDate =
                b.lastMessageAt ??
                    b.createdAt;

            return bDate.compareTo(aDate);
          });

          return chats;
        });
  }

  // =========================================================
  // SUPPRESSION DU COMPTE
  // =========================================================

  @override
  Future<void> deleteUserChats(
    String userId,
  ) async {
    // Les conversations utilisent ON DELETE CASCADE
    // sur buyer_id / seller_id.
    //
    // La suppression définitive de auth.users
    // doit rester une opération serveur sécurisée.
    Log.info(
      'Les conversations Koteka sont liées au compte utilisateur.',
    );
  }
}
