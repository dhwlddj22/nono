// lib/screens/notification_settings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nono/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _user = FirebaseAuth.instance.currentUser!;
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    // 1) 알림 서비스 초기화
    await NotificationService.init();

    // 2) Firestore에서 저장된 설정 불러오기
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();
    final data = doc.data();
    setState(() {
      _enabled = data?['notificationsEnabled'] ?? true;
      _loading = false;
    });

    // 3) 만약 켜져 있었다면 예약 알림 유지
    if (_enabled) {
      await NotificationService.scheduleDailyTenPM();
    }
  }

  Future<void> _onToggleChanged(bool val) async {
    setState(() => _enabled = val);

    // Firestore에 저장
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .set({'notificationsEnabled': val}, SetOptions(merge: true));

    // 알림 예약 / 취소
    if (val) {
      await NotificationService.scheduleDailyTenPM();
    } else {
      await NotificationService.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SwitchListTile(
          title: const Text('앱 알림 받기'),
          subtitle: const Text('매일 오후 10시에 노이즈가드 알림을 받습니다'),
          value: _enabled,
          onChanged: _onToggleChanged,
          activeColor: Colors.green, // ✅ 초록색으로 설정

        ),
      ),
    );
  }
}
