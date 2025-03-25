import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'message.dart';
import 'chat_bubble.dart';
import 'openai_service.dart';

class NoiseAnalysisChatScreen extends StatefulWidget {
  @override
  _NoiseAnalysisChatScreenState createState() => _NoiseAnalysisChatScreenState();
}

class _NoiseAnalysisChatScreenState extends State<NoiseAnalysisChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;

  void _addMessage(String content, MessageType type) {
    setState(() {
      _messages.insert(
        0,
        Message(content: content, type: type, timestamp: DateTime.now()),
      );
    });
  }

  Future<void> _sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty && _selectedFile == null) return;

    if (_selectedFile != null) {
      final fileName = _selectedFile!.path.split('/').last;
      _addMessage(fileName, MessageType.file);

      setState(() {
        _isLoading = true;
      });

      // 업로드 + Whisper + GPT
      try {
        final ref = FirebaseStorage.instance
            .ref('uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName');
        await ref.putFile(_selectedFile!);
        final transcript = await OpenAIService.transcribeAudio(_selectedFile!);
        if (transcript != null) {
          _addMessage(transcript, MessageType.user);

          final analysis = await OpenAIService.analyzeNoise(transcript);
          _addMessage(analysis ?? "분석 실패", MessageType.ai);
        } else {
          _addMessage("음성 인식 실패", MessageType.ai);
        }
      } catch (e) {
        _addMessage("에러 발생: $e", MessageType.ai);
      }

      setState(() {
        _isLoading = false;
        _selectedFile = null;
      });
    }

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
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("NO!SE GUARD"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.only(top: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) => ChatBubble(message: _messages[index]),
            ),
          ),
          if (_selectedFile != null)
            Container(
              margin: EdgeInsets.only(left: 16, bottom: 6),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.attach_file, color: Colors.green),
                  SizedBox(width: 6),
                  Text(
                    _selectedFile!.path.split('/').last,
                    style: TextStyle(color: Colors.green),
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
        padding: EdgeInsets.fromLTRB(10, 6, 10, 10),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: Colors.white),
              onPressed: _pickFile,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "원하는 분석 내용을 입력해보세요.",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            _isLoading
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                : FloatingActionButton(
              onPressed: _sendMessage,
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_forward, color: Colors.black),
              mini: true,
            ),
          ],
        ),
      ),
    );
  }
}
