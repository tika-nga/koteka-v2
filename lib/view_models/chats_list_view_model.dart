import 'package:flutter/material.dart';

import 'package:flutter_marketplace_template/models/chat.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/places_service.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';

class ChatsListViewModel
    extends ChangeNotifier {
  final IChatService _chatService;
  final IUserService _userService;

  // Conservé dans le constructeur pour rester
  // compatible avec l'injection actuelle de l'application.
  final IPlacesService _placesService;

  String? _userId;

  bool _isLoading = false;

  String? _error;

  final Map<
      String,
      (DateTime?, String?)>
      _chatIdlastReadAt = {};

  final Map<String, String>
      _chatIdChatParticipantName = {};

  ChatsListViewModel(
    this._chatService,
    this._userService,
    this._placesService,
  );

  bool get isLoading => _isLoading;

  String? get error => _error;

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
      return false;
    }

    return true;
  }

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
                  (DateTime?,
                      String?)>>) {
        _chatIdlastReadAt
          ..clear()
          ..addAll(response.data);
      }

      final participants =
          await _chatService
              .fetchChatParticipantsIdForUser(
        userId: _userId!,
      );

      if (participants
          is FetchOneSuccess<
              Map<String, String>>) {
        for (final entry
            in participants.data.entries) {
          _chatIdChatParticipantName[
                  entry.key] =
              'Utilisateur';
        }
      }
    } catch (e) {
      _error =
          'Impossible de charger les conversations : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChatsParticipantNames()
      async {
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
      for (final entry
          in response.data.entries) {
        _chatIdChatParticipantName[
                entry.key] =
            'Utilisateur';
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
      // Le véritable nom du compte sera
      // relié au futur profil utilisateur.
      _chatIdChatParticipantName[
              chatId] =
          'Utilisateur';

      notifyListeners();
    }
  }

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

    // Le nouveau service ignore la liste vide
    // et récupère les conversations auxquelles
    // l'utilisateur participe.
    return _chatService
        .subscribeToChatsUpdates(
      const [],
    );
  }

  void markChatAsRead(
    String chatId,
    DateTime timestamp,
    String? lastMessageId,
  ) {
    _chatIdlastReadAt[chatId] =
        (timestamp, lastMessageId);

    notifyListeners();
  }
}
