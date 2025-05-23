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
    print("📦 Firestore 로드: ${data['type']}");

    List<double>? parsedChartData;
    if (data['chartData'] != null && data['chartData'] is List) {
      try {
        parsedChartData = List<double>.from(
            (data['chartData'] as List).map((e) => (e as num).toDouble())
        );
      } catch (e) {
        print("⚠️ chartData 파싱 실패: $e");
      }
    }

    return Message(
      content: data['text'],
      type: MessageType.values.firstWhere(
            (e) => e.toString().split('.').last == data['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      url: data['url'],
      chartData: parsedChartData,
    );
  }

}

