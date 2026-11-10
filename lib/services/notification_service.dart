import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('[Notification] 알림 탭됨: ${details.payload}');
        },
      );

      // Android 13+ 알림 권한 요청
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('[NotificationService] 초기화 완료');
    } catch (e) {
      debugPrint('[NotificationService] 초기화 실패 (무시 가능): $e');
    }
  }

  static Future<void> showUpdateNotification({
    required int count,
    required String topHeadline,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'issue_radar_updates',
        '실시간 이슈 업데이트 알림',
        channelDescription: '새로운 5대 플랫폼 최신 이슈가 수집될 때 발송되는 알림입니다.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: '이슈 레이더 업데이트',
        icon: '@mipmap/ic_launcher',
        showWhen: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '📡 이슈 레이더: 최신 이슈 $count건 도착!',
        '가장 핫한 토픽: $topHeadline',
        details,
      );
    } catch (e) {
      debugPrint('[NotificationService] 알림 발송 예외: $e');
    }
  }
}
