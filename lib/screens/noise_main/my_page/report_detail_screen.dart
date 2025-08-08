// report_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final List<_RecordItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final futures = <Future<QuerySnapshot>>[
      userDoc.collection('callHistory').get(),
      userDoc.collection('counselingHistory').get(),
      userDoc.collection('govActions').get(),
      userDoc.collection('policeReports').get(),
    ];

    final results = await Future.wait(futures);

    final List<_RecordItem> all = [];

    // callHistory
    for (var doc in results[0].docs) {
      final ts = doc['timestamp'] as Timestamp?;
      if (ts != null) {
        all.add(_RecordItem(type: '관리사무소 전화', time: ts.toDate()));
      }
    }

    // counselingHistory
    for (var doc in results[1].docs) {
      final ts = doc['timestamp'] as Timestamp?;
      final type = doc['type'] as String?;
      if (ts != null && type != null) {
        final name = type == 'call' ? '콜 상담' : '인터넷 상담';
        all.add(_RecordItem(type: '상담 신청 ($name)', time: ts.toDate()));
      }
    }

    // govActions
    for (var doc in results[2].docs) {
      final ts = doc['timestamp'] as Timestamp?;
      final type = doc['type'] as String?;
      if (ts != null && type != null) {
        final name = type == 'measure' ? '소음 측정' : '신청서 양식';
        all.add(_RecordItem(type: name, time: ts.toDate()));
      }
    }

    // policeReports
    for (var doc in results[3].docs) {
      final ts = doc['timestamp'] as Timestamp?;
      final type = doc['type'] as String?;
      if (ts != null && type != null) {
        final name = type == 'sms' ? '경찰 문자 신고' : '경찰 전화 신고';
        all.add(_RecordItem(type: name, time: ts.toDate()));
      }
    }

    all.sort((a, b) => b.time.compareTo(a.time));

    setState(() {
      _items.clear();
      _items.addAll(all);
      _loading = false;
    });
  }

  String _formatDate(DateTime dt) {
    return DateFormat('yyyy.MM.dd HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신고 내역'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('기록된 내역이 없습니다.'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final item = _items[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            title: Text(item.type, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_formatDate(item.time)),
            leading: const Icon(Icons.history),
          );
        },
      ),
    );
  }
}

class _RecordItem {
  final String type;
  final DateTime time;

  _RecordItem({required this.type, required this.time});
}
