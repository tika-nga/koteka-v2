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

  Future<int> fetchUnreadMessagesCount({
    required String userId,
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
        final existingAfterConflict =
            await supabase
                .from(conversations)
                .select('id')
                .eq(
                  'annonce_id',
                  annonceId,
                )
                .eq(
                  'buyer_id',
                  buyerId,
                )
                .eq(
                  'seller_id',
                  sellerId,
                )
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
    // updated_at est mis à jour automatiquement
    // par le trigger Supabase.
  }

  // =========================================================
  // ENVOYER UN MESSAGE
  // =========================================================

  @override
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

    // Vérifie que l'utilisateur connecté
    // appartient bien à cette conversation.
    final conversation =
        await supabase
            .from(conversations)
            .select(
              'buyer_id, seller_id',
            )
            .eq(
              'id',
              chatId,
            )
            .maybeSingle();

    if (conversation == null) {
      return FetchOneFailure(
        'Conversation introuvable.',
      );
    }

    final buyerId =
        conversation['buyer_id']
            ?.toString();

    final sellerId =
        conversation['seller_id']
            ?.toString();

    if (currentUserId != buyerId &&
        currentUserId != sellerId) {
      return FetchOneFailure(
        'Vous ne participez pas à cette conversation.',
      );
    }

    final response =
        await supabase
            .from(messages)
            .insert({
              'conversation_id':
                  chatId,
              'sender_id':
                  currentUserId,
              'text':
                  cleanText,
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
        .eq(
          'conversation_id',
          chatId,
        )
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

    // Quand l'utilisateur ouvre la conversation,
    // tous les messages reçus encore non lus
    // dans cette conversation deviennent lus.
    await supabase
        .from(messages)
        .update({
          'read_at':
              timestamp.toIso8601String(),
        })
        .eq(
          'conversation_id',
          chatId,
        )
        .neq(
          'sender_id',
          userId,
        )
        .isFilter(
          'read_at',
          null,
        );
  } catch (e) {
    Log.warning(
      'Erreur lors du marquage des messages comme lus : $e',
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
            .neq(
              'sender_id',
              userId,
            )
            .not(
              'read_at',
              'is',
              null,
            )
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
          .select(
            'buyer_id, seller_id',
          )
          .eq(
            'id',
            chatId,
          )
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
        return FetchOneSuccess(
          sellerId,
        );
      }

      if (sellerId == userId) {
        return FetchOneSuccess(
          buyerId,
        );
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
        final id =
            row['id'].toString();

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

    if (userId == null ||
        userId.isEmpty) {
      return Stream.value([]);
    }

    return supabase
        .from(conversations)
        .stream(
          primaryKey: ['id'],
        )
        .map((rows) {
          final visibleRows =
              rows.where(
            (row) =>
                row['buyer_id']
                        ?.toString() ==
                    userId ||
                row['seller_id']
                        ?.toString() ==
                    userId,
          );

          final chats =
              visibleRows
                  .map(
                    (row) =>
                        Chat.fromJson(row),
                  )
                  .toList();

          chats.sort((a, b) {
            final aDate =
                a.lastMessageAt ??
                    a.createdAt;

            final bDate =
                b.lastMessageAt ??
                    b.createdAt;

            return bDate.compareTo(
              aDate,
            );
          });

          return chats;
        })
        .asyncMap((chats) async {
          for (final chat in chats) {
            // Informations de l'annonce.
            if (chat.annonceId != null) {
              final annonce =
                  await supabase
                      .from(annonces)
                      .select(
                        'title, imageUrl',
                      )
                      .eq(
                        'id',
                        chat.annonceId!,
                      )
                      .maybeSingle();

              if (annonce != null) {
                chat.annonceTitle =
                    annonce['title']
                        ?.toString();

                chat.annonceImageUrl =
                    annonce['imageUrl']
                        ?.toString();
              }
            }

            // Dernier message.
            final lastMessage =
                await supabase
                    .from(messages)
                    .select(
                      'id, sender_id, text, created_at, read_at',
                    )
                    .eq(
                      'conversation_id',
                      chat.id,
                    )
                    .order(
                      'created_at',
                      ascending: false,
                    )
                    .limit(1)
                    .maybeSingle();

            if (lastMessage != null) {
              chat.lastMessageId =
                  lastMessage['id']
                      ?.toString();

              chat.lastMessageSenderId =
                  lastMessage['sender_id']
                      ?.toString();

              chat.lastMessageText =
                  lastMessage['text']
                      ?.toString();

              chat.lastMessageCreatedAt =
                  DateTime.tryParse(
                lastMessage['created_at']
                        ?.toString() ??
                    '',
              );

              chat.lastMessageReadAt =
                  DateTime.tryParse(
                lastMessage['read_at']
                        ?.toString() ??
                    '',
              );
            }
          }

          return chats;
        });
  }

  // =========================================================
  // NOMBRE TOTAL DE MESSAGES NON LUS
  // =========================================================

  @override
  Future<int> fetchUnreadMessagesCount({
    required String userId,
  }) async {
    try {
      final conversationRows =
          await supabase
              .from(conversations)
              .select(
                'id, buyer_id, seller_id',
              );

      final conversationIds =
          conversationRows
              .where(
                (row) =>
                    row['buyer_id']
                            ?.toString() ==
                        userId ||
                    row['seller_id']
                            ?.toString() ==
                        userId,
              )
              .map(
                (row) =>
                    row['id'].toString(),
              )
              .toList();

      if (conversationIds.isEmpty) {
        return 0;
      }

      int unreadCount = 0;

      for (final chatId
          in conversationIds) {
        final rows =
            await supabase
                .from(messages)
                .select('id')
                .eq(
                  'conversation_id',
                  chatId,
                )
                .neq(
                  'sender_id',
                  userId,
                )
                .isFilter(
                  'read_at',
                  null,
                );

        unreadCount += rows.length;
      }

      return unreadCount;
    } catch (e) {
      Log.warning(
        'Erreur compteur messages non lus : $e',
      );

      return 0;
    }
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
