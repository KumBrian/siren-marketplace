import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/features/chat/data/models/message_card_prop.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(child: _ChatView()),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: const BackButton(),
      title: Row(
        children: [
          // 🔹 Profile Image with Status Indicator
          Stack(
            children: [
              const ErrorHandlingCircleAvatar(
                // Replace with actual image asset
                avatarUrl: 'assets/images/user-profile.png',
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green, // Online indicator color
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white100, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // 🔹 User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ethan Carter",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  Text(
                    "4.8 (254 Reviews)",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }

  final TextEditingController _messageController = TextEditingController();
  bool showSend = false;

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
                        IconButton(
                          icon: const Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {},
                        ),
                        // Icon for emoji/stickers
                        IconButton(
                          icon: const Icon(
                            Icons.sentiment_satisfied_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {},
                        ),
                        showSend
                            ? IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: AppColors.textBlue,
                                ),
                                onPressed: () {},
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
// 🔹 Message Data and View Logic
// ----------------------------------------------------------------------

class _ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  // Mock Messages based on the screenshot, using the current date/time as a reference
  // We offset the date to simulate a conversation that started "yesterday" and continued "today"

  final DateTime today = DateTime.now();
  late final DateTime yesterday;

  late final List<MessageCardProp> _messages;

  @override
  void initState() {
    super.initState();
    yesterday = today.subtract(const Duration(days: 1));

    // Convert screenshot times (15:18, 15:20) into full DateTime objects
    _messages = [
      // --- YESTERDAY'S MESSAGES (Simulating date change) ---
      MessageCardProp(
        text: "Hi! Are you still selling the fish?",
        timestamp: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          14,
          00,
        ),
        sender: Sender.me,
      ),
      MessageCardProp(
        text: "Yes, I have some fresh catch. What quantity do you need?",
        timestamp: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          14,
          05,
        ),
        sender: Sender.other,
      ),

      // --- TODAY'S MESSAGES (Matching screenshot times) ---
      MessageCardProp(
        text: "Hello, Transaction confirmed for 6 kg of fish at 15,000 CFA",
        timestamp: DateTime(today.year, today.month, today.day, 15, 18),
        sender: Sender.other,
      ),
      MessageCardProp(
        text: "Great, thank you! Is the fish fresh from today?",
        timestamp: DateTime(today.year, today.month, today.day, 15, 20),
        sender: Sender.me,
      ),
      MessageCardProp(
        text: "Yes, it was caught this morning. Very fresh.",
        timestamp: DateTime(today.year, today.month, today.day, 15, 20, 5),
        // Slight offset
        sender: Sender.other,
      ),
      MessageCardProp(
        text: "Perfect. When can we meet for the exchange?",
        timestamp: DateTime(today.year, today.month, today.day, 15, 20, 10),
        sender: Sender.me,
      ),
      MessageCardProp(
        text: "I am available this afternoon.",
        timestamp: DateTime(today.year, today.month, today.day, 15, 20, 15),
        sender: Sender.other,
      ),
      MessageCardProp(
        text: "Could we meet around 4 PM?",
        timestamp: DateTime(today.year, today.month, today.day, 16, 00), // 4 PM
        sender: Sender.me,
      ),
    ];
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
    // ScrollView reversed to show latest messages at the bottom
    return ListView.builder(
      reverse: true, // Display messages from bottom up
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = _messages.length - 1 - index;
        final message = _messages[reversedIndex];

        // Determine if a date divider should be shown before this message
        bool showDateDivider = false;
        if (reversedIndex == 0) {
          // Always show divider for the very first message
          showDateDivider = true;
        } else {
          final previousMessage = _messages[reversedIndex - 1];
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
            _MessageBubble(message: message),
          ],
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
// 🔹 Individual Message Bubble Widget
// ----------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final MessageCardProp message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.sender == Sender.me;

    // Alignment (right for me, left for other)
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    // Main Axis Alignment for Row (end for me, start for other)
    final _ = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
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
                message.text,
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
