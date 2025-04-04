import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatGPTService {
  static const String _apiEndpoint = 'YOUR_CHATGPT_API_ENDPOINT';
  static const String _apiKey = 'YOUR_CHATGPT_API_KEY';

  static Future<void> sendToChatGPT(double decibel, String filePath) async {
    String prompt = '이 소음의 평균 데시벨은 $decibel dB입니다. 이 소음에 대해 분석해 주세요.';

    var request = http.MultipartRequest('POST', Uri.parse(_apiEndpoint))
      ..headers['Authorization'] = 'Bearer $_apiKey'
      ..fields['prompt'] = prompt
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      String analysisResult = jsonResponse['choices'][0]['text'];
      print('ChatGPT 응답: $analysisResult');
    } else {
      print('ChatGPT 요청 실패: ${response.statusCode}');
    }
  }
}
