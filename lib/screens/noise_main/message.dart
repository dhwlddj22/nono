import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { user, ai, audio, chart }

class Message {
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? url;
  final List<double>? chartData;

  Message({
    required this.content,
    required this.type,
    required this.timestamp,
    this.url,
    this.chartData,
  });

  factory Message.fromFirestore(Map<String, dynamic> data) {
    final text = data['text'] ?? '';
    final timestamp = data['timestamp'];
    final rawType = data['type'];

    // type이 null일 경우 기본값 user
    final type = MessageType.values.firstWhere(
          (e) => e.toString().split('.').last == rawType,
      orElse: () => MessageType.user,
    );

    return Message(
      content: text,
      type: type,
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      url: data['url'],
      chartData: data['chartData'] != null
          ? List<double>.from(data['chartData'].map((e) => e.toDouble()))
          : null,
    );
  }

}

