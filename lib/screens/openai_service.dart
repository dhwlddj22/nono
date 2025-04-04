import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {

  static const String _apiKey = ""; // 실제 키 입력
  static const String _whisperUrl = "https://api.openai.com/v1/audio/transcriptions";
  static const String _chatGptUrl = "https://api.openai.com/v1/chat/completions";

  static Future<String?> analyzeNoise(String text) async {
    final body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": "너는 층간 소음 분석 전문가야. 반드시 모든 응답은 한국어로만 작성해.",
        },
        {
          "role": "user",
          "content": text,
        }
      ],
      "temperature": 0.7,
    };

    try {
      final response = await http.post(
        Uri.parse(_chatGptUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        final reply = data['choices'][0]['message']['content'];
        return reply;
      } else {
        print("ChatGPT 오류: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("ChatGPT 예외 발생: $e");
      return null;
    }
  }
}
