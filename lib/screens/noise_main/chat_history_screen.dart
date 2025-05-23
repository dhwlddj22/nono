import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:nono/screens/noise_main/record_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  final String? selectedDate;
  final VoidCallback onExit;

  const ChatHistoryScreen({
    super.key,
    required this.selectedDate,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("채팅 기록"),
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
              indent: 16,     // 왼쪽 여백
              endIndent: 16,  // 오른쪽 여백
              color: Color(0xFF58B721),
            ),
          ),
        ),
        body: const Center(child: Text("로그인이 필요합니다.")),
      );
    }

    final parsedDate = DateFormat('yy/MM/dd').parse(selectedDate!);
    final startOfDay = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if(viewMode == ViewMode.history) {
              onExit(); // viewMode 변경
            } else {
              Navigator.pop(context);
            }
          }
        ),
        title: const Text("채팅 기록"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            indent: 16,     // 왼쪽 여백
            endIndent: 16,  // 오른쪽 여백
            color: Color(0xFF58B721),
          ),
        ),
        backgroundColor: Colors.black
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('chat_history')
          .where('userId', isEqualTo: currentUser.uid)
          .where('type', isEqualTo: 'ai') // AI 응답만 필터링
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .orderBy('timestamp', descending: true)
          .limit(30)
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final grouped = <String, List<DocumentSnapshot>>{};

          // 그룹화 과정
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['type'] == 'ai') {
              final timestamp = data['timestamp'] as Timestamp;
              final date = DateFormat('yy/MM/dd').format(timestamp.toDate());
              grouped.putIfAbsent(date, () => []).add(doc);
            }
          }

          // UI용으로 모든 그룹을 병합하고 시간순 정렬
          final flatList = grouped.values.expand((list) => list).toList()
            ..sort((a, b) {
              final t1 = (a.data() as Map)['timestamp'] as Timestamp;
              final t2 = (b.data() as Map)['timestamp'] as Timestamp;
              return t1.compareTo(t2);
            });

          return ListView.builder(
            itemCount: flatList.length,
            itemBuilder: (context, index) {
              final doc = flatList[index];
              final data = doc.data() as Map<String, dynamic>;
              final text = data['text'];
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedDate = DateFormat('yy/MM/dd').format(timestamp);

              return Column(
                children: [
                  ListTile(
                    title: Text(
                      text,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      final recordState = context.findAncestorStateOfType<RecordScreenState>();
                      if (recordState != null) {
                        recordState.setState(() {
                          viewMode = ViewMode.detail;
                          recordState.selectedFormattedDate = formattedDate;
                        });
                      }
                    },
                  ),
                  const Divider(color: Colors.grey, indent: 16, endIndent: 16),
                ],
              );
            },
          );
        }
      )
    );
  }
}