import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/features/chat/domain/entities/message.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/features/chat/presentation/providers/chat_providers.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatPage({super.key, required this.conversationId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool showSend = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    try {
      final controller = ref.read(chatControllerProvider);
      await controller.sendMessage(widget.conversationId, content);

      // Clear the text field
      _messageController.clear();
      setState(() {
        showSend = false;
      });

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We fetch all conversations and find the one we need.
    // Ideally we'd have a specific endpoint or provider for single conversation.
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }

        return conversationsAsync.when(
          data: (conversations) {
            final conversation = conversations
                .where((c) => c.id == widget.conversationId)
                .firstOrNull;

            if (conversation == null) {
              return Scaffold(
                appBar: AppBar(
                  leading: const BackButton(),
                  title: const Text('Conversation not found'),
                ),
                body: const Center(
                  child: Text('This conversation does not exist.'),
                ),
              );
            }

            // Mark conversation as read locally if it has unread messages
            // This relies on the repository returning unreadCount=0 if viewed locally
            if (conversation.unreadCount > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(chatControllerProvider)
                    .markConversationAsRead(widget.conversationId);
              });
            }

            // Identify other user with fallback for ID mismatch (Int vs UUID)
            bool isSourceMe = conversation.sourceAccount.id == currentUser.id;
            if (!isSourceMe &&
                conversation.sourceAccount.name == currentUser.name) {
              isSourceMe = true;
            }

            final otherUser = isSourceMe
                ? conversation.targetAccount
                : conversation.sourceAccount;

            return Scaffold(
              appBar: _buildAppBar(
                context,
                otherUser.name,
                otherUser.avatarUrl,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: _ChatView(
                      conversationId: widget.conversationId,
                      currentUser: currentUser,
                      scrollController: _scrollController,
                    ),
                  ),
                  _buildMessageComposer(),
                ],
              ),
            );
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) => Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: Center(child: Text('Error loading conversation: $error')),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    String otherUserName,
    String? otherUserAvatar,
  ) {
    return AppBar(
      leading: const BackButton(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          ErrorHandlingCircleAvatar(
            avatarUrl: otherUserAvatar ?? 'assets/images/user-profile.png',
            radius: 20,
          ),
          const SizedBox(width: 12),
          Text(
            otherUserName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textBlue,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Message Input Field
  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.white100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextField(
                  controller: _messageController,
                  maxLines: 5,
                  minLines: 1,
                  onChanged: (value) {
                    setState(() {
                      showSend = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Type here...",
                    filled: true,
                    fillColor: AppColors.gray300.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        showSend
                            ? IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: AppColors.textBlue,
                                ),
                                onPressed: _sendMessage,
                              )
                            : Container(),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 🔹 Message View Logic
// ----------------------------------------------------------------------

class _ChatView extends ConsumerStatefulWidget {
  final String conversationId;
  final User currentUser;
  final ScrollController scrollController;

  const _ChatView({
    required this.conversationId,
    required this.currentUser,
    required this.scrollController,
  });

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening the conversation
    // We need to wait for messages to be loaded to know which ones to mark
  }

  // Helper function to format the date banner (e.g., "TODAY, JULY 15")
  String _formatDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "TODAY, ${DateFormat('MMMM dd').format(date).toUpperCase()}";
    } else if (messageDate == yesterday) {
      return "YESTERDAY, ${DateFormat('MMMM dd').format(date).toUpperCase()}";
    } else {
      return DateFormat('EEEE, MMMM dd, yyyy').format(date).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet. Start the conversation!',
              style: TextStyle(color: AppColors.textGray),
            ),
          );
        }

        // Sort messages Descending by Date (Newest first) so they appear correctly
        // in a reversed ListView (Index 0 = Bottom = Newest).
        final sortedMessages = List<Message>.from(messages);
        sortedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView.builder(
          controller: widget.scrollController,
          reverse: true, // Display messages from bottom up
          itemCount: sortedMessages.length,
          itemBuilder: (context, index) {
            // Newest at index 0 (Bottom).

            final message = sortedMessages[index];
            final nextMessage = (index < sortedMessages.length - 1)
                ? sortedMessages[index + 1]
                : null;

            // Date divider logic:
            // Check if current message day is different from older message (next in list)
            bool showDateDivider = false;
            if (nextMessage == null) {
              // Top-most message (oldest loaded), always show date
              showDateDivider = true;
            } else if (message.createdAt.day != nextMessage.createdAt.day) {
              showDateDivider = true;
            }

            return Column(
              children: [
                if (showDateDivider)
                  _DateDivider(
                    date: message.createdAt,
                    formatter: _formatDateDivider,
                  ),
                _MessageBubble(
                  message: message,
                  currentUser: widget.currentUser,
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Error loading messages: $error')),
    );
  }
}

// ----------------------------------------------------------------------
// 🔹 Individual Message Bubble Widget
// ----------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final Message message;
  final User currentUser;

  const _MessageBubble({required this.message, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    bool isMe = message.sender.id == currentUser.id;
    // Fallback if IDs mismatch (e.g. Int ID vs UUID)
    if (!isMe && message.sender.name == currentUser.name) {
      isMe = true;
    }

    // Alignment (right for me, left for other)
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    // Bubble color
    final color = isMe ? AppColors.textBlue : AppColors.gray300;
    // Text color
    final textColor = isMe ? AppColors.white100 : Colors.black;
    // Border Radius
    final borderRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(12) : const Radius.circular(2),
      topRight: isMe ? const Radius.circular(2) : const Radius.circular(12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // 🔹 Message Bubble
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: borderRadius,
              ),
              child: Text(
                message.content,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
          ),

          // 🔹 Timestamp
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 8.0,
              right: isMe ? 8.0 : 0,
            ),
            child: Text(
              DateFormat('hh:mm a').format(message.createdAt),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 🔹 Date Divider Widget
// ----------------------------------------------------------------------

class _DateDivider extends StatelessWidget {
  final DateTime date;
  final String Function(DateTime) formatter;

  const _DateDivider({required this.date, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gray300.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            formatter(date),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
