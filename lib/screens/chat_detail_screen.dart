import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'message.dart';
import 'chat_bubble.dart';
import 'openai_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String dateKey;

  ChatDetailScreen({required this.dateKey});

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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.dateKey)),
        body: Center(child: Text("로그인이 필요합니다.")),
      );
    }

    final parts = widget.dateKey.split('/');
    final year = 2000 + int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final startOfDay = DateTime(year, month, day);
    final endOfDay = startOfDay.add(Duration(days: 1));


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.dateKey, style: TextStyle(color: Colors.white)),
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
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final msg = Message(
                      content: doc['text'],
                      type: MessageType.values.firstWhere((e) => e.toString().split('.').last == doc['type']),
                      timestamp: (doc['timestamp'] as Timestamp).toDate(),
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
        padding: EdgeInsets.fromLTRB(10, 6, 10, 10),
        child: Row(
          children: [
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
                    hintText: "메시지를 입력해보세요",
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
