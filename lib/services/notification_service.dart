import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// 앱 시작 시 단 한 번만 호출해주세요.
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    final didInitialize = await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('🔔 Notification tapped payload: ${response.payload}');
      },
    );
    debugPrint('✅ NotificationService initialized: $didInitialize');

    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        debugPrint('📲 Android notification permission granted: $granted');

        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            'daily_channel_id',
            'Daily Notifications',
            description: '매일 오후 10시에 노이즈가드 알림',
            importance: Importance.max,
          ),
        );

        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            'test_channel',
            'Test Notifications',
            description: '1분 뒤 테스트 알림',
            importance: Importance.max,
          ),
        );
      }
    }
  }

  static Future<void> scheduleDailyTenPM() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notifications',
      channelDescription: '매일 오후 10시에 노이즈가드 알림',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final scheduledDate = _nextInstanceOfTenPM();
    debugPrint('⏰ scheduleDailyTenPM(): scheduling at $scheduledDate');

    await _plugin.zonedSchedule(
      0,
      '🔔 노이즈가드 알림',
      '오늘도 노이즈가드와 함께 소음을 관리해 보세요!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('✅ scheduleDailyTenPM() complete');
  }

  static Future<void> scheduleTestOneMinute() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: '1분 뒤 테스트 알림',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(minutes: 1));
    debugPrint('🚀 scheduleTestOneMinute(): scheduling at $scheduled');

    await _plugin.zonedSchedule(
      999,
      '🛠️ 테스트 알림',
      '1분 뒤 잘 뜨는지 확인하세요!',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('✅ scheduleTestOneMinute() complete');
  }

  static Future<void> cancelAll() async {
    debugPrint('❌ cancelAll() called');
    await _plugin.cancelAll();
    debugPrint('❌ cancelAll() complete');
  }

  static tz.TZDateTime _nextInstanceOfTenPM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
