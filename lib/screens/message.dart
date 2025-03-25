enum MessageType { user, ai, file, image }

class Message {
  final String content;
  final MessageType type;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.type,
    required this.timestamp,
  });
}
