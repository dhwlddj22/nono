import 'package:intl/intl.dart';

class NoisePromptBuilder {
  static String build({
    required double averageDb,
    required double peakDb,
    DateTime? time,
  }) {
    final now = time ?? DateTime.now();
    final timeFormatted = DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(now);
    final timeContext = _getTimeContext(now);

    return '''
$timeFormatted 기준, $timeContext 시간대에 측정한 층간 소음 데이터입니다.
- 평균 소음: ${averageDb.toStringAsFixed(2)} dB
- 최고 소음: ${peakDb.toStringAsFixed(2)} dB

이 수치들이 생활 소음 기준에 비춰 문제가 되는 수준인지,
법적 기준, 일반적인 피해 인정 사례 등을 참고해 분석해 주세요.
또한, 어떤 조치를 취하는 것이 적절할지도 알려주세요.
''';
  }

  static String _getTimeContext(DateTime now) {
    final hour = now.hour;

    if (hour >= 23 || hour < 6) {
      return "야간 (조용해야 할 시간)";
    } else if (hour >= 6 && hour < 18) {
      return "주간";
    } else {
      return "저녁 (생활 소음이 제한되는 시간)";
    }
  }
}
