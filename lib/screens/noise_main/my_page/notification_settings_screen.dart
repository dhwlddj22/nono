import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nono/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() =>
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
    await NotificationService.init();

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();
    final wasEnabled = doc.data()?['notificationsEnabled'] as bool? ?? false;

    setState(() {
      _enabled = wasEnabled;
      _loading = false;
    });

    if (wasEnabled) {
      await NotificationService.scheduleDailyTenPM();
    }
  }

  Future<void> _onToggleChanged(bool val) async {
    if (val) {
      final status = await Permission.notification.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        setState(() => _enabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '알림 권한이 필요합니다.\n설정에서 허용해주세요.',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }
      await NotificationService.scheduleDailyTenPM();
    } else {
      await NotificationService.cancelAll();
    }

    setState(() => _enabled = val);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .set({'notificationsEnabled': val}, SetOptions(merge: true));
  }

  Future<void> _onTestPressed() async {
    debugPrint('🧪 테스트 버튼 누름');
    await NotificationService.scheduleTestOneMinute();
    debugPrint('🧪 테스트 예약 완료');
  }

  Future<void> _checkPendingNotifications() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final pending = await plugin.pendingNotificationRequests();
    debugPrint('🔍 예약된 알림 개수: ${pending.length}');
    for (final p in pending) {
      debugPrint('🔔 예약됨: id=${p.id}, title=${p.title}, body=${p.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('앱 알림 받기'),
              subtitle: const Text('매일 오후 10시에 노이즈가드 알림을 받습니다'),
              value: _enabled,
              onChanged: _onToggleChanged,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onTestPressed,
              child: const Text('1분 뒤 테스트 알림 예약'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _checkPendingNotifications,
              child: const Text('예약된 알림 보기'),
            ),
          ],
        ),
      ),
    );
  }
}
