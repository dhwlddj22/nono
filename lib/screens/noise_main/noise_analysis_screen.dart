import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nono/screens/noise_main/chat_history_screen.dart';
import "package:nono/screens/noise_main/message.dart";
import 'package:nono/screens/noise_main/chat_bubble.dart';
import 'openai_service.dart';
import 'my_page_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class NoiseAnalysisChatScreen extends StatefulWidget {
  final String? initialInput;

  const NoiseAnalysisChatScreen({super.key, this.initialInput});

  @override
  _NoiseAnalysisChatScreenState createState() => _NoiseAnalysisChatScreenState();
}

class _NoiseAnalysisChatScreenState extends State<NoiseAnalysisChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    if (widget.initialInput != null && widget.initialInput!.trim().isNotEmpty) {
      _autoAnalyze(widget.initialInput!);
    }
  }

  Future<void> _fetchMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('chat_history')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    final messages = snapshot.docs.map((doc) {
      final data = doc.data();
      return Message.fromFirestore(data);
    }).toList();

    setState(() {
      _messages.clear();

      // 🔍 중복되는 "chart → 바로 아래 또 chart" 구조만 제거
      final List<Message> filtered = [];
      for (int i = 0; i < messages.length; i++) {
        final current = messages[i];

        if (current.type == MessageType.chart) {
          // 바로 다음 메시지가 또 chart라면 이건 중복 → 건너뜀
          if (i > 0 && messages[i - 1].type == MessageType.chart) {
            continue;
          }
        }

        filtered.add(current);
      }

      _messages.addAll(filtered);
    });
  }

  Future<void> _autoAnalyze(String text) async {
    _addMessage(text, MessageType.user);
    setState(() => _isLoading = true);

    final reply = await OpenAIService.analyzeNoise(text);
    _addMessage(reply ?? "AI 응답 실패", MessageType.ai);

    setState(() => _isLoading = false);
  }




  void _addMessage(String content, MessageType type) {
    final user = FirebaseAuth.instance.currentUser;
    final message = Message(
      content: content,
      type: type,
      timestamp: DateTime.now(),
      chartData: null, // ✅ 무조건 null 처리
    );

    if (content.trim().isNotEmpty && user != null) {
      FirebaseFirestore.instance.collection('chat_history').add({
        'text': content,
        'type': type.toString().split('.').last,
        'timestamp': Timestamp.now(),
        'userId': user.uid,
      });
    }

    setState(() {
      _messages.insert(0, message); // ✅ UI 렌더링에 사용되는 메시지에도 chartData 없음
    });
  }



  Future<void> _sendMessage() async {
    final userInput = _controller.text.trim();

    if (userInput.isNotEmpty) {
      _addMessage(userInput, MessageType.user);
      _controller.clear();

      setState(() => _isLoading = true);

      final aiReply = await OpenAIService.analyzeNoise(userInput);
      _addMessage(aiReply ?? "AI 응답 실패", MessageType.ai);

      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      final file = File(result.files.single.path!);
      final fileName = 'recordings/${DateTime.now().toIso8601String()}.aac';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      try {
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();

        _addMessage(downloadUrl, MessageType.audio);
      } catch (e) {
        print('파일 업로드 실패: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파일 업로드에 실패했습니다.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("NO!SE GUARD"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatHistoryScreen(
                    selectedDate: '',
                    onExit: () {},
                  )
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPageScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(top: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Column(
                  crossAxisAlignment: message.type == MessageType.user
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    ChatBubble(message: message),
                    
                    if (message.chartData != null)
                      SizedBox(
                        height: 160,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: message.chartData!
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                                      .toList(),
                                  isCurved: true,
                                  color: Colors.green,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (_selectedFile != null)
            Container(
              margin: const EdgeInsets.only(left: 16, bottom: 6),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    _selectedFile!.path.split('/').last,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.white),
              onPressed: _pickFile,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "원하는 분석 내용을 입력해보세요.",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                : FloatingActionButton(
              onPressed: _sendMessage,
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.arrow_forward, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
