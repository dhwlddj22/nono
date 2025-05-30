import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:just_audio/just_audio.dart';
import 'message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user || message.type == MessageType.audio;
    final bubbleColor = isUser ? const Color(0xFF58B721) : Colors.white24;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    Widget contentWidget;

    if (message.type == MessageType.audio && message.url != null) {
      contentWidget = GestureDetector(
        onTap: () async {
          final uri = Uri.parse(message.url!);
          /*
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("파일을 열 수 없습니다.")),
            );
          }
          */
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("파일을 열 수 없습니다.")),
            );
          }

        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.audiotrack, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message.content,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else if (message.type == MessageType.chart && message.chartData != null) {
      final points = message.chartData!
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();

      contentWidget = SizedBox(
        height: 150,
        width: 250,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.grey.shade800,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      "${spot.y.toStringAsFixed(2)} dB", // ✅ 툴팁 소수점 2자리 + dB
                      const TextStyle(color: Colors.white),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: points,
                isCurved: true,
                color: const Color(0xFF58B721),
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.green.withOpacity(0.3),
                ),
              )
            ],
          ),
        ),
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
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: contentWidget,
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(message.timestamp),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
