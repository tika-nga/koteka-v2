import 'package:flutter/material.dart';

import 'package:flutter_marketplace_template/models/chat.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/places_service.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';

class ChatsListViewModel extends ChangeNotifier {
  final IPlacesService _placesService;
  final IChatService _chatService;
  final IUserService _userService;

  String? _userId;
  bool _isLoading = false;
  String? _error;

  final Map<String, (DateTime?, String?)> _chatIdlastReadAt = {};

  final Map<String, String> _chatIdChatParticipantName = {};

  /// IMPORTANT :
  /// L'ordre reste identique à celui déjà utilisé dans app.dart :
  ///
  /// IPlacesService
  /// IChatService
  /// IUserService
  ChatsListViewModel(
    this._placesService,
    this._chatService,
    this._userService,
  );

  bool get isLoading => _isLoading;

  String? get error => _error;

  Map<String, (DateTime?, String?)> get chatIdlastReadAt =>
      _chatIdlastReadAt;

  Map<String, String> get chatIdChatParticipantName =>
      _chatIdChatParticipantName;

  void _loadUser() {
    _userId = _userService.getCurrentUserId();
  }

  Future<bool> _checkUserId() async {
    if (_userId == null || _userId!.isEmpty) {
      _loadUser();
    }

    if (_userId == null || _userId!.isEmpty) {
      _error = 'Utilisateur non connecté';
      return false;
    }

    return true;
  }

  /// Chargement initial de la liste des conversations.
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
          await _chatService.fetchLastReadTimestampsForUser(
        userId: _userId!,
      );

      if (response
          is FetchOneSuccess<Map<String, (DateTime?, String?)>>) {
        _chatIdlastReadAt
          ..clear()
          ..addAll(response.item);
      }

      final participants =
          await _chatService.fetchChatParticipantsIdForUser(
        userId: _userId!,
      );

      if (participants
          is FetchOneSuccess<Map<String, String>>) {
        for (final entry in participants.item.entries) {
          _chatIdChatParticipantName[entry.key] = 'Utilisateur';
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

  /// Conservé pour compatibilité avec l'écran actuel.
  Future<void> fetchChatsParticipantNames() async {
    if (!await _checkUserId()) {
      return;
    }

    final response =
        await _chatService.fetchChatParticipantsIdForUser(
      userId: _userId!,
    );

    if (response
        is FetchOneSuccess<Map<String, String>>) {
      for (final entry in response.item.entries) {
        _chatIdChatParticipantName[entry.key] = 'Utilisateur';
      }

      notifyListeners();
    }
  }

  /// Vérifie le participant d'une conversation.
  Future<void> checkChatName({
    required String chatId,
  }) async {
    if (_chatIdChatParticipantName.containsKey(chatId)) {
      return;
    }

    if (!await _checkUserId()) {
      return;
    }

    final response =
        await _chatService.fetchChatParticipantId(
      chatId: chatId,
      userId: _userId!,
    );

    if (response is FetchOneSuccess<String>) {
      // Le nom réel sera relié au profil utilisateur
      // dans une prochaine étape.
      _chatIdChatParticipantName[chatId] = 'Utilisateur';

      notifyListeners();
    }
  }

  /// Flux des conversations de l'utilisateur connecté.
  Stream<List<Chat>> subscribeChatsUpdates() {
    if (_userId == null || _userId!.isEmpty) {
      _loadUser();
    }

    if (_userId == null || _userId!.isEmpty) {
      return Stream.value([]);
    }

    return _chatService.subscribeToChatsUpdates(
      const [],
    );
  }

  /// Version sans paramètres.
  ///
  /// Elle est conservée pour que l'actuel chat_screen.dart
  /// puisse encore appeler :
  ///
  /// markChatAsRead()
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
  }

  notifyListeners();
}

  /// Cette méthode servira ensuite à mettre à jour localement
  /// les informations précises de lecture.
  void updateChatReadState({
    required String chatId,
    required DateTime timestamp,
    String? lastMessageId,
  }) {
    _chatIdlastReadAt[chatId] =
        (timestamp, lastMessageId);

    notifyListeners();
  }
}
