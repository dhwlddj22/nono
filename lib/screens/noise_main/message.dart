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
    return Message(
      content: data['text'],
      type: MessageType.values.firstWhere(
            (e) => e.toString().split('.').last == data['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      url: data['url'],
      chartData: data['chartData'] != null
          ? List<double>.from(data['chartData'].map((e) => e.toDouble()))
          : null,
    );
  }
}

