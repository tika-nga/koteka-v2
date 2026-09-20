import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/models/message.dart';
import 'package:flutter_marketplace_template/view_models/chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  // Conservés pour compatibilité avec les appels existants.
  final DateTime? chatDeletedAt;
  final String? lastReadMessageId;
  final bool hasUnreadMessages;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.chatDeletedAt,
    this.lastReadMessageId,
    this.hasUnreadMessages = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  late ChatViewModel _chatVM;

  @override
  void initState() {
    super.initState();

    _chatVM = context.read<ChatViewModel>();

    _chatVM.setChatId(widget.chatId);
    _chatVM.setChatDeletedAt(widget.chatDeletedAt);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatVM.enterChat(widget.chatId);
    });
  }

  @override
  void dispose() {
    _markLastMessageAsRead();
    _chatVM.exitChat();
    _messageController.dispose();

    super.dispose();
  }

  Future<void> _markLastMessageAsRead() async {
    final messages = _chatVM.messages;

    if (messages.isEmpty) return;

    final currentUserId = _chatVM.userId;

    if (currentUserId == null) return;

    Message? lastReceivedMessage;

    for (final message in messages.reversed) {
      if (message.senderId != currentUserId) {
        lastReceivedMessage = message;
        break;
      }
    }

    if (lastReceivedMessage == null) return;

    await _chatVM.saveLastReadMessageAt(
      lastReceivedMessage.id,
      DateTime.now(),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    _messageController.clear();

    await _chatVM.sendMessage(
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = context.watch<ChatViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      appBar: CustomAppBar(
        showTitle: false,
        showMenu: false,
        showChat: false,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: chatVM.subscribeChatUpdates(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Impossible de charger les messages.\n'
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  final messages = snapshot.data!;

                  chatVM.setMessages(messages);

                  if (messages.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucun message pour le moment.\n'
                          'Envoyez le premier message.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(
                              16,
                              20,
                              94,
                              0.7,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final reversedMessages =
                      messages.reversed.toList();

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: reversedMessages.length,
                    itemBuilder: (context, index) {
                      final message =
                          reversedMessages[index];

                      final isMine =
                          message.senderId ==
                              chatVM.userId;

                      return _MessageBubble(
                        message: message,
                        isMine: isMine,
                      );
                    },
                  );
                },
              ),
            ),

            if (chatVM.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.red.shade50,
                child: Text(
                  chatVM.error!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                  ),
                ),
              ),

            Container(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText:
                            'Écrivez un message…',
                        filled: true,
                        fillColor:
                            const Color(0xFFF5F5F7),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!chatVM.isSending) {
                          _sendMessage();
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton.filled(
                    onPressed:
                        chatVM.isSending
                            ? null
                            : _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          const Color.fromRGBO(
                        16,
                        20,
                        94,
                        1,
                      ),
                    ),
                    icon:
                        chatVM.isSending
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;

  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:'
        '${message.createdAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment:
          isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.78,
        ),
        margin: const EdgeInsets.only(
          bottom: 8,
        ),
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          12,
          7,
        ),
        decoration: BoxDecoration(
          color:
              isMine
                  ? const Color.fromRGBO(
                    16,
                    20,
                    94,
                    1,
                  )
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isMine
                  ? null
                  : const [
                    BoxShadow(
                      color: Color.fromRGBO(
                        0,
                        0,
                        0,
                        0.05,
                      ),
                      blurRadius: 4,
                    ),
                  ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isMine
                          ? Colors.white
                          : const Color.fromRGBO(
                            16,
                            20,
                            94,
                            1,
                          ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isMine
                            ? Colors.white70
                            : Colors.grey,
                  ),
                ),

                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.readAt != null
                        ? Icons.done_all
                        : Icons.done,
                    size: 15,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
