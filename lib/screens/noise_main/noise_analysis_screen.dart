import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nono/screens/noise_main/chat_bubble.dart';
import 'package:nono/screens/noise_main/message.dart';
import 'package:nono/screens/noise_main/my_page/my_page_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'openai_service.dart';

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

    final messages = snapshot.docs.map((doc) => Message.fromFirestore(doc.data())).toList();

    setState(() {
      _messages.clear();
      final List<Message> filtered = [];
      for (int i = 0; i < messages.length; i++) {
        final current = messages[i];
        if (current.type == MessageType.chart && i > 0 && messages[i - 1].type == MessageType.chart) {
          continue;
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
      chartData: null,
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
      _messages.insert(0, message);
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
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 50),
            const Text(
              '채팅 기록',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.grey),
            ..._messages
                .where((msg) => msg.type == MessageType.user)
                .map((msg) => ListTile(
              title: Text(msg.content,
                  style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(msg.timestamp.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ))
                .toList(),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("NO!SE GUARD"),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPageScreen()));
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
                return ChatBubble(message: message);
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
