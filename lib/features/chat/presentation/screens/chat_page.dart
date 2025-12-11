import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/message.dart';
import 'package:siren_marketplace/core/domain/services/message_service.dart';
import 'package:siren_marketplace/core/providers/conversation_providers.dart';
import 'package:siren_marketplace/core/providers/message_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';

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

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) return;

    final conversation = await ref.read(
      conversationProvider(widget.conversationId).future,
    );
    if (conversation == null) return;

    final receiverId = conversation.getOtherParticipantId(currentUser.id);

    try {
      final messageService = sl<MessageService>();
      await messageService.sendMessage(
        senderId: currentUser.id,
        receiverId: receiverId,
        content: content,
      );

      // Clear the text field
      _messageController.clear();
      setState(() {
        showSend = false;
      });

      // Invalidate providers to refresh the conversation data
      ref.invalidate(conversationMessagesProvider(widget.conversationId));
      ref.invalidate(conversationProvider(widget.conversationId));
      ref.invalidate(userConversationsProvider(currentUser.id));

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
    final conversationAsync = ref.watch(
      conversationProvider(widget.conversationId),
    );
    final currentUserAsync = ref.watch(currentUserProvider);

    return conversationAsync.when(
      data: (conversation) {
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

        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return const Scaffold(
                body: Center(child: Text('User not found')),
              );
            }

            final otherUserId = conversation.getOtherParticipantId(
              currentUser.id,
            );

            return Scaffold(
              appBar: _buildAppBar(context, otherUserId),
              body: Column(
                children: [
                  Expanded(
                    child: _ChatView(
                      conversationId: widget.conversationId,
                      currentUserId: currentUser.id,
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
          error: (error, _) =>
              Scaffold(body: Center(child: Text('Error: $error'))),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text('Error loading conversation: $error')),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String otherUserId) {
    final userAsync = ref.watch(userProvider(otherUserId));

    return AppBar(
      leading: const BackButton(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      scrolledUnderElevation: 0,
      title: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Text('Loading...');
          }

          return Row(
            children: [
              ErrorHandlingCircleAvatar(
                avatarUrl: user.avatarUrl ?? 'assets/images/user-profile.png',
                radius: 20,
              ),
              const SizedBox(width: 12),
              Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.textBlue,
                ),
              ),
            ],
          );
        },
        loading: () => const Text('Loading...'),
        error: (_, __) => const Text('Error'),
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
                        // Icon for image/gallery
                        // IconButton(
                        //   icon: const Icon(
                        //     Icons.image_outlined,
                        //     color: Colors.grey,
                        //   ),
                        //   onPressed: () {},
                        // ),
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
  final String currentUserId;
  final ScrollController scrollController;

  const _ChatView({
    required this.conversationId,
    required this.currentUserId,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsRead();
    });
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) return;

      final messageService = sl<MessageService>();
      await messageService.markConversationAsRead(
        widget.conversationId,
        currentUser.id,
      );

      // Refresh conversation and conversation list to update unread count
      ref.invalidate(conversationProvider(widget.conversationId));
      ref.invalidate(userConversationsProvider(currentUser.id));
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
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
    final messagesAsync = ref.watch(
      conversationMessagesProvider(widget.conversationId),
    );

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

        // ScrollView reversed to show latest messages at the bottom
        return ListView.builder(
          controller: widget.scrollController,
          reverse: true, // Display messages from bottom up
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final reversedIndex = messages.length - 1 - index;
            final message = messages[reversedIndex];

            // Determine if a date divider should be shown before this message
            bool showDateDivider = false;
            if (reversedIndex == 0) {
              // Always show divider for the very first message
              showDateDivider = true;
            } else {
              final previousMessage = messages[reversedIndex - 1];
              // Check if the day of the current message is different from the previous one
              if (message.timestamp.day != previousMessage.timestamp.day) {
                showDateDivider = true;
              }
            }

            // Build the list item
            return Column(
              children: [
                if (showDateDivider)
                  _DateDivider(
                    date: message.timestamp,
                    formatter: _formatDateDivider,
                  ),
                _MessageBubble(
                  message: message,
                  currentUserId: widget.currentUserId,
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
  final String currentUserId;

  const _MessageBubble({required this.message, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isSentBy(currentUserId);
    final bool isSystemMessage = message.isSystemMessage;

    // System messages are centered
    if (isSystemMessage) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gray300.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textGray,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
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
              DateFormat('hh:mm a').format(message.timestamp),
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
