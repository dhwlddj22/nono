import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nono/screens/noise_main/message.dart';
import 'package:nono/screens/noise_main/chat_bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'openai_service.dart';
import 'record_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String dateKey;

  const ChatDetailScreen({super.key, required this.dateKey});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _addMessage(String content, MessageType type) async {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();

    if (content.trim().isNotEmpty && user != null) {
      await FirebaseFirestore.instance.collection('chat_history').add({
        'text': content,
        'type': type.toString().split('.').last,
        'timestamp': Timestamp.fromDate(now),
        'userId': user.uid,
      });
    }
  }

  Future<void> _sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    _addMessage(userInput, MessageType.user);
    _controller.clear();
    setState(() => _isLoading = true);

    final reply = await OpenAIService.analyzeNoise(userInput);
    _addMessage(reply ?? "AI 응답 실패", MessageType.ai);

    setState(() => _isLoading = false);
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    // Firebase Storage 업로드
    final ref = FirebaseStorage.instance
        .ref('uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    await ref.putFile(file);

    final downloadUrl = await ref.getDownloadURL();

    // Firestore에 메시지로 저장
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('chat_history').add({
        'text': fileName,
        'url': downloadUrl,
        'type': 'file',
        'userId': user.uid,
        'timestamp': Timestamp.now(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("${widget.dateKey} 채팅 기록"),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Color(0xFF58B721),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              final recordState = context.findAncestorStateOfType<RecordScreenState>();
              recordState?.setState(() {
                viewMode = ViewMode.idle;
              });
            },
          ),
        ),
        body: const Center(child: Text("로그인이 필요합니다.")),
      );
    }

    late DateTime startOfDay;
    late DateTime endOfDay;

    try {
      final parts = widget.dateKey.split('/');
      final year = 2000 + int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      startOfDay = DateTime(year, month, day);
      endOfDay = startOfDay.add(const Duration(days: 1));
    } catch (e) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("날짜 오류"),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: Text(
            "날짜 포맷 오류: 올바르지 않은 dateKey입니다.",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${widget.dateKey} 채팅 기록"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFF58B721),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            final recordState = context.findAncestorStateOfType<RecordScreenState>();
            recordState?.setState(() {
              viewMode = ViewMode.idle;
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_history')
                  .where('userId', isEqualTo: currentUser.uid)
                  .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
                  .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final msg = Message(
                      content: data['text'],
                      type: MessageType.values.firstWhere((e) => e.toString().split('.').last == data['type']),
                      timestamp: (data['timestamp'] as Timestamp).toDate(),
                      url: data['url'],
                      chartData: data['chartData'] != null
                          ? List<double>.from((data['chartData'] as List).map((e) => (e as num).toDouble()))
                          : null,
                    );

                    return ChatBubble(message: msg);
                  },
                );
              },
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
            // 📎 파일 첨부 버튼
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.white),
              onPressed: _pickAndUploadFile,
            ),
            // 입력창
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
                    hintText: "녹음 파일을 추가하거나 AI와 대화해보세요.",
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
