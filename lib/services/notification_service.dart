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

      // OS 레벨 주기 알림 등록
      await schedulePeriodicNotification();
    } catch (e) {
      debugPrint('[NotificationService] 초기화 실패: $e');
    }
  }

  static Future<void> schedulePeriodicNotification() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'issue_radar_periodic',
        '정기 이슈 브리핑 알림',
        channelDescription: '안드로이드 시스템에서 정기적으로 최신 이슈를 리마인드하는 알림입니다.',
        importance: Importance.high,
        priority: Priority.high,
        ticker: '이슈 레이더 브리핑',
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.periodicallyShow(
        1001,
        '📡 이슈 레이더 실시간 브리핑',
        '새로운 5대 플랫폼 최신 핫이슈가 업데이트되었습니다. 탭하여 확인해보세요!',
        RepeatInterval.hourly,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      debugPrint('[NotificationService] 주기 알림 예약 완료');
    } catch (e) {
      debugPrint('[NotificationService] 주기 알림 예약 실패: $e');
    }
  }

  static Future<void> testNotification() async {
    try {
      if (!_isInitialized) await initialize();

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'issue_radar_test',
        '알림 테스트 채널',
        channelDescription: '알림 수신 확인을 위한 즉시 테스트 채널입니다.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: '알림 테스트',
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        9999,
        '🔔 [테스트] 이슈 레이더 알림 정상 작동!',
        '스마트폰 상단바 알림 및 진동이 정상적으로 작동하고 있습니다.',
        details,
      );
      debugPrint('[NotificationService] 테스트 알림 발송 완료');
    } catch (e) {
      debugPrint('[NotificationService] 테스트 알림 발송 실패: $e');
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
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '📡 이슈 레이더: 새로운 핫이슈 도착!',
        topHeadline,
        details,
      );
    } catch (e) {
      debugPrint('[NotificationService] 알림 발송 예외: $e');
    }
  }
}
