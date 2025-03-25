import 'package:flutter/material.dart';
import 'message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user || message.type == MessageType.file;

    final bubbleColor = message.type == MessageType.user
        ? Colors.green
        : message.type == MessageType.ai
        ? Colors.white12
        : Colors.green;

    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    Widget contentWidget;

    if (message.type == MessageType.image) {
      contentWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(message.content, width: 250),
      );
    } else {
      contentWidget = Text(
        message.content,
        style: TextStyle(color: isUser ? Colors.white : Colors.white70),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: contentWidget,
          ),
          SizedBox(height: 2),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
