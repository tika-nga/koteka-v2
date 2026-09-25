import 'package:flutter/material.dart';

import 'package:flutter_marketplace_template/models/chat.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';

class ChatsListViewModel extends ChangeNotifier {
  final IChatService _chatService;
  final IUserService _userService;

  String? _userId;
  bool _isLoading = false;
  String? _error;

  int _unreadMessagesCount = 0;

  final Map<String, (DateTime?, String?)>
      _chatIdlastReadAt = {};

  final Map<String, String>
      _chatIdChatParticipantName = {};

  ChatsListViewModel(
    this._chatService,
    this._userService,
  );

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get userId => _userId;

  int get unreadMessagesCount =>
      _unreadMessagesCount;

  Map<String, (DateTime?, String?)>
      get chatIdlastReadAt =>
          _chatIdlastReadAt;

  Map<String, String>
      get chatIdChatParticipantName =>
          _chatIdChatParticipantName;

  void _loadUser() {
    _userId =
        _userService.getCurrentUserId();
  }

  Future<bool> _checkUserId() async {
    if (_userId == null ||
        _userId!.isEmpty) {
      _loadUser();
    }

    if (_userId == null ||
        _userId!.isEmpty) {
      _error =
          'Utilisateur non connecté';

      _unreadMessagesCount = 0;

      return false;
    }

    return true;
  }

  // =========================================================
  // CHARGER LE NOMBRE TOTAL DE MESSAGES NON LUS
  // =========================================================

  Future<void>
      refreshUnreadMessagesCount() async {
    if (!await _checkUserId()) {
      notifyListeners();
      return;
    }

    try {
      final count =
          await _chatService
              .fetchUnreadMessagesCount(
        userId: _userId!,
      );

      if (_unreadMessagesCount != count) {
        _unreadMessagesCount = count;
        notifyListeners();
      }
    } catch (_) {
      // On conserve le compteur actuel
      // si une erreur réseau temporaire survient.
    }
  }

  // =========================================================
  // ENTRER DANS LA LISTE DES CONVERSATIONS
  // =========================================================

  Future<void> enterChatsList() async {
    if (!await _checkUserId()) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _chatService
              .fetchLastReadTimestampsForUser(
        userId: _userId!,
      );

      if (response
          is FetchOneSuccess<
              Map<
                  String,
                  (DateTime?, String?)>>) {
        _chatIdlastReadAt
          ..clear()
          ..addAll(response.item);
      }

      final participants =
          await _chatService
              .fetchChatParticipantsIdForUser(
        userId: _userId!,
      );

      if (participants
          is FetchOneSuccess<
              Map<String, String>>) {
        _chatIdChatParticipantName
            .clear();

        for (final entry
            in participants.item.entries) {
          _chatIdChatParticipantName[
              entry.key] = 'Utilisateur';
        }
      }

      _unreadMessagesCount =
          await _chatService
              .fetchUnreadMessagesCount(
        userId: _userId!,
      );
    } catch (e) {
      _error =
          'Impossible de charger les conversations : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // NOMS DES PARTICIPANTS
  // =========================================================

  Future<void>
      fetchChatsParticipantNames() async {
    if (!await _checkUserId()) {
      return;
    }

    final response =
        await _chatService
            .fetchChatParticipantsIdForUser(
      userId: _userId!,
    );

    if (response
        is FetchOneSuccess<
            Map<String, String>>) {
      _chatIdChatParticipantName.clear();

      for (final entry
          in response.item.entries) {
        _chatIdChatParticipantName[
            entry.key] = 'Utilisateur';
      }

      notifyListeners();
    }
  }

  Future<void> checkChatName({
    required String chatId,
  }) async {
    if (_chatIdChatParticipantName
        .containsKey(chatId)) {
      return;
    }

    if (!await _checkUserId()) {
      return;
    }

    final response =
        await _chatService
            .fetchChatParticipantId(
      chatId: chatId,
      userId: _userId!,
    );

    if (response
        is FetchOneSuccess<String>) {
      _chatIdChatParticipantName[
          chatId] = 'Utilisateur';

      notifyListeners();
    }
  }

  // =========================================================
  // TEMPS RÉEL DES CONVERSATIONS
  // =========================================================

  Stream<List<Chat>>
      subscribeChatsUpdates() {
    if (_userId == null ||
        _userId!.isEmpty) {
      _loadUser();
    }

    if (_userId == null ||
        _userId!.isEmpty) {
      return Stream.value([]);
    }

    return _chatService
        .subscribeToChatsUpdates(
      const [],
    );
  }

  // =========================================================
  // MARQUER UNE CONVERSATION COMME LUE
  // =========================================================

  void markChatAsRead({
    required String chatId,
    required DateTime lastReadAt,
    String? lastMessageId,
  }) {
    _chatIdlastReadAt[chatId] = (
      lastReadAt,
      lastMessageId,
    );

    notifyListeners();

    refreshUnreadMessagesCount();
  }

  void updateChatReadState({
    required String chatId,
    required DateTime timestamp,
    String? lastMessageId,
  }) {
    _chatIdlastReadAt[chatId] = (
      timestamp,
      lastMessageId,
    );

    notifyListeners();

    refreshUnreadMessagesCount();
  }
}
