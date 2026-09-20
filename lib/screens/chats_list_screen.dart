import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/models/chat.dart';
import 'package:flutter_marketplace_template/screens/chat_screen.dart';
import 'package:flutter_marketplace_template/view_models/chats_list_view_model.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({
    super.key,
  });

  @override
  State<ChatsListScreen> createState() =>
      _ChatsListScreenState();
}

class _ChatsListScreenState
    extends State<ChatsListScreen> {
  late final ChatsListViewModel chatsListVM;

  @override
  void initState() {
    super.initState();

    chatsListVM =
        context.read<ChatsListViewModel>();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      chatsListVM.enterChatsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatsListVM =
        context.watch<ChatsListViewModel>();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F7),

      appBar: CustomAppBar(
        showTitle: true,
        showMenu: false,
        showChat: false,
      ),

      body: StreamBuilder<List<Chat>>(
        stream:
            chatsListVM
                .subscribeChatsUpdates(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Impossible de charger les conversations.\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          if (chatsListVM.isLoading ||
              !snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator
                      .adaptive(),
            );
          }

          final chats = snapshot.data!;

          if (chats.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .chat_bubble_outline_rounded,
                      size: 54,
                      color:
                          Color.fromRGBO(
                        16,
                        20,
                        94,
                        0.5,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Aucune conversation',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Color.fromRGBO(
                          16,
                          20,
                          94,
                          1,
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Lorsque vous contactez un vendeur, '
                      'la conversation apparaîtra ici.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            Color.fromRGBO(
                          16,
                          20,
                          94,
                          0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding:
                const EdgeInsets.all(12),
            itemCount: chats.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(
                      height: 8,
                    ),
            itemBuilder:
                (context, index) {
              final chat =
                  chats[index];

              final date =
                  chat.lastMessageAt ??
                      chat.createdAt;

              return Material(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                ChatScreen(
                          chatId:
                              chat.id,
                          chatDeletedAt:
                              chat.deletedAt,
                          lastReadMessageId:
                              chatsListVM
                                  .chatIdlastReadAt[
                                      chat.id]
                                  ?.$2,
                          hasUnreadMessages:
                              false,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color.fromRGBO(
                              16,
                              20,
                              94,
                              0.08,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child:
                              const Icon(
                            Icons
                                .chat_bubble_outline,
                            color:
                                Color.fromRGBO(
                              16,
                              20,
                              94,
                              1,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                chat.annonceId !=
                                        null
                                    ? 'Annonce #${chat.annonceId}'
                                    : 'Conversation',
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color:
                                      Color.fromRGBO(
                                    16,
                                    20,
                                    94,
                                    1,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                'Ouvrir la conversation',
                                style:
                                    TextStyle(
                                  fontSize:
                                      14,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Text(
                          _formatDate(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),

                        const SizedBox(
                          width: 3,
                        ),

                        const Icon(
                          Icons
                              .chevron_right_rounded,
                          color:
                              Color.fromRGBO(
                            16,
                            20,
                            94,
                            0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final sameDay =
        now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;

    if (sameDay) {
      return '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }
}
