import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/models/message.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatViewModel extends ChangeNotifier {
  final IUserService _userService;
  final IChatService _chatService;

  String? _chatId;
  DateTime? _chatDeletedAt;

  List<Message> _messages = [];

  bool _isSending = false;

  String? _error;
  String? _userId;

  Stream<List<Message>>?
      _chatUpdatesStream;

  Message? _replyingTo;

  final ItemScrollController
      itemScrollController =
      ItemScrollController();

  final ItemPositionsListener
      itemPositionsListener =
      ItemPositionsListener.create();

  List<Message> get messages => _messages;

  bool get isSending => _isSending;

  String? get error => _error;

  String? get userId => _userId;

  Message? get replyingTo => _replyingTo;

  DateTime? get chatDeletedAt =>
      _chatDeletedAt;

  ChatViewModel(
    this._userService,
    this._chatService,
  ) {
    _loadUser();
  }

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

  void setChatId(String chatId) {
    _chatId = chatId;
  }

  void setChatDeletedAt(
    DateTime? deletedAt,
  ) {
    _chatDeletedAt = deletedAt;
  }

  void setMessages(
    List<Message> newMessages,
  ) {
    _messages = newMessages;
  }

  // Conservé temporairement afin que
  // l'ancien écran compile jusqu'au Bloc 2.
  void setReply(Message message) {
    _replyingTo = message;
    notifyListeners();
  }

  void clearReply() {
    _replyingTo = null;
    notifyListeners();
  }

  void scrollToMessageById(
    String messageId,
  ) {
    final index = _messages.indexWhere(
      (message) =>
          message.id == messageId,
    );

    if (index == -1) return;

    if (!itemScrollController.isAttached) {
      return;
    }

    itemScrollController.scrollTo(
      index: index,
      duration:
          const Duration(
            milliseconds: 300,
          ),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void scrollToBottom({
    bool animated = true,
  }) {
    if (_messages.isEmpty) return;

    if (!itemScrollController.isAttached) {
      return;
    }

    itemScrollController.scrollTo(
      index: 0,
      duration:
          animated
              ? const Duration(
                milliseconds: 300,
              )
              : Duration.zero,
      curve: Curves.easeOut,
    );
  }

  bool get isAtBottom {
    final positions =
        itemPositionsListener
            .itemPositions
            .value;

    if (positions.isEmpty) {
      return true;
    }

    return positions.any(
      (position) =>
          position.index == 0 &&
          position.itemTrailingEdge >=
              0.95,
    );
  }

  Future<void> sendMessage({
    required String text,
  }) async {
    if (!await _checkUserId()) {
      notifyListeners();
      return;
    }

    if (_chatId == null ||
        _chatId!.isEmpty) {
      _error =
          'Conversation introuvable';
      notifyListeners();
      return;
    }

    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    _isSending = true;
    _error = null;

    notifyListeners();

    try {
      final response =
          await _chatService.sendMessage(
        senderId: _userId!,
        chatId: _chatId!,
        text: cleanText,
      );

      if (response
          is FetchOneFailure<Message>) {
        _error = response.message;
      }
    } finally {
      _isSending = false;
      _replyingTo = null;
      notifyListeners();
    }
  }

  Future<void> saveLastReadMessageAt(
    String lastMessageId,
    DateTime timestamp,
  ) async {
    if (!await _checkUserId()) {
      notifyListeners();
      return;
    }

    if (_chatId == null ||
        _chatId!.isEmpty) {
      return;
    }

    await _chatService
        .setLastReadMessageAt(
      chatId: _chatId!,
      userId: _userId!,
      lastMessageId:
          lastMessageId,
      timestamp: timestamp,
    );
  }

  Stream<List<Message>>
      subscribeChatUpdates() {
    if (_chatId == null ||
        _chatId!.isEmpty) {
      _error =
          'Conversation non définie';

      return Stream.value([]);
    }

    if (_userId == null ||
        _userId!.isEmpty) {
      _loadUser();
    }

    if (_userId == null ||
        _userId!.isEmpty) {
      return Stream.value([]);
    }

    _chatUpdatesStream =
        _chatService
            .subscribeMessagesForChat(
      userId: _userId!,
      chatId: _chatId!,
    );

    return _chatUpdatesStream!;
  }

  Future<void> enterChat(
    String chatId,
  ) async {
    _chatId = chatId;
    _chatUpdatesStream = null;
  }

  void exitChat() {
    _chatDeletedAt = null;
    _replyingTo = null;
    _chatUpdatesStream = null;
  }
}
