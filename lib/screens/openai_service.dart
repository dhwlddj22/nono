import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OpenAIService {
  static const String _apiKey = "PRIVATE_KEY"; // 실제 키 입력
  static const String _whisperUrl = "https://api.openai.com/v1/audio/transcriptions";
  static const String _chatGptUrl = "https://api.openai.com/v1/chat/completions";

  static Future<String?> transcribeAudio(File audioFile) async {
    final request = http.MultipartRequest("POST", Uri.parse(_whisperUrl))
      ..headers['Authorization'] = "Bearer $_apiKey"
      ..fields['model'] = "whisper-1"
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        contentType: MediaType('audio', 'mpeg'), // ← 여기 중요!
      ));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Whisper 응답 상태: ${response.statusCode}");
      print("Whisper 응답 내용: $responseBody");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['text'];
      } else {
        print("Whisper 오류: ${response.statusCode} - $responseBody");
        return null;
      }
    } catch (e) {
      print("Whisper 예외 발생: $e");
      return null;
    }
  }


  static Future<String?> analyzeNoise(String text) async {

    final body = {
      "model": "gpt-3.5-turbo", // 비용 절감용 추천 / gpt-4
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
        try {
          final decodedBody = utf8.decode(response.bodyBytes);
          final data = jsonDecode(decodedBody);
          final reply = data['choices'][0]['message']['content'];

          print("GPT 최종 응답 내용: $reply");
          return reply;
        } catch (e) {
          print("GPT 응답 파싱 실패: $e");
          print("GPT 원문 응답: ${response.body}");
          return "AI 응답 파싱 실패";
        }
      }

      else {
        print("ChatGPT 오류: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("ChatGPT 예외 발생: $e");
      return null;
    }
  }
}
