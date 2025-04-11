import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_detail_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text("채팅 기록")),
        body: Center(child: Text("로그인이 필요합니다.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("채팅 기록"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_history')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          final Map<String, List<QueryDocumentSnapshot>> grouped = {};

          for (var doc in docs) {
            final date = DateFormat('yy/MM/dd').format((doc['timestamp'] as Timestamp).toDate());
            grouped.putIfAbsent(date, () => []).add(doc);
          }

          return ListView(
            children: grouped.entries.map((entry) {
              final date = entry.key;
              final firstMessage = entry.value.first['text'].toString().split('\n').first;

              return ListTile(
                title: Text(firstMessage, style: TextStyle(color: Colors.white)),
                subtitle: Text(date, style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(dateKey: date),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
