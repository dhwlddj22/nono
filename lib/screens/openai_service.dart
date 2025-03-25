import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _apiKey = "YOUR_OPENAI_API_KEY"; // 여기에 실제 API 키 입력
  static const String _whisperUrl = "https://api.openai.com/v1/audio/transcriptions";
  static const String _chatGptUrl = "https://api.openai.com/v1/chat/completions";

  /// Whisper API로 음성 파일을 텍스트로 변환
  static Future<String?> transcribeAudio(File audioFile) async {
    var request = http.MultipartRequest("POST", Uri.parse(_whisperUrl))
      ..headers['Authorization'] = "Bearer $_apiKey"
      ..fields['model'] = "whisper-1"
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      return jsonResponse['text']; // 변환된 텍스트 반환
    } else {
      print("Whisper 오류: ${response.statusCode} - $responseBody");
      return null;
    }
  }

  /// ChatGPT API로 소음 텍스트 분석
  static Future<String?> analyzeNoise(String text) async {
    final body = {
      "model": "gpt-4", // 또는 "gpt-3.5-turbo"
      "messages": [
        {
          "role": "system",
          "content": "너는 층간 소음 전문가야. 사용자가 보낸 텍스트에서 소음 정보를 분석해줘."
        },
        {
          "role": "user",
          "content": text,
        }
      ],
      "temperature": 0.7,
    };

    final response = await http.post(
      Uri.parse(_chatGptUrl),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['choices'][0]['message']['content'];
    } else {
      print("ChatGPT 오류: ${response.statusCode} - ${response.body}");
      return null;
    }
  }
}
