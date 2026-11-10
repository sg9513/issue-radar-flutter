import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/issue_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상단 상태바 및 하단 네비게이션 바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 로컬 알림 서비스 초기화
  await NotificationService.initialize();

  final issueService = IssueService();

  runApp(IssueRadarApp(issueService: issueService));
}

class IssueRadarApp extends StatelessWidget {
  final IssueService issueService;

  const IssueRadarApp({Key? key, required this.issueService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이슈 레이더',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(issueService: issueService),
    );
  }
}
