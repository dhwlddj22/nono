import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// 앱 시작 시 한 번만 호출
  static Future<void> init() async {
    // 타임존 설정
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 초기화
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS 초기화 (Darwin)
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(settings);
  }

  /// 매일 오후 10시 알림 예약
  static Future<void> scheduleDailyTenPM() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_channel_id', // 채널 ID
      'Daily Notifications', // 채널 이름
      channelDescription: '매일 오후 10시에 노이즈가드 사용을 유도하는 알림',
      importance: Importance.max,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      0,
      '🔔 노이즈가드 알림',
      '오늘도 노이즈가드와 함께 소음을 관리해 보세요!',
      _nextInstanceOfTenPM(),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 다음 오후 10시 시간 계산
  static tz.TZDateTime _nextInstanceOfTenPM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// 예약된 모든 알림 취소
  static Future<void> cancelAll() => _plugin.cancelAll();
}
