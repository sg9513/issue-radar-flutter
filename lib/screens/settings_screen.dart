import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _liveFetchPushEnabled = true;
  bool _morningPushEnabled = true;
  bool _breakingPushEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('앱 설정 및 알림'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('실시간 알림 설정'),
          _buildSwitchTile(
            title: '📡 최신 정보 수집 시 즉시 알림',
            subtitle: '새로운 이슈 데이터가 수집되어 앱에 갱신될 때 스마트폰 상단바로 알림',
            value: _liveFetchPushEnabled,
            onChanged: (val) => setState(() => _liveFetchPushEnabled = val),
          ),
          _buildSwitchTile(
            title: '🌅 아침 7시 데일리 모닝 브리핑',
            subtitle: '매일 아침 밤사이 누적된 5대 플랫폼 핵심 이슈 3선 요약',
            value: _morningPushEnabled,
            onChanged: (val) => setState(() => _morningPushEnabled = val),
          ),
          _buildSwitchTile(
            title: '🔥 긴급 속보 / 하이 임팩트 알림',
            subtitle: '깃허브 급상승 1위나 검색량 500% 급증 시 즉시 알림',
            value: _breakingPushEnabled,
            onChanged: (val) => setState(() => _breakingPushEnabled = val),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('앱 정보'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '이슈 레이더 (Issue Radar Native)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '버전 1.2.0 (실시간 알림 & 보관함 & 트렌드 탑재)',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                SizedBox(height: 8),
                Text(
                  '개발자: 승규 x 두기\n깃허브, 레딧, X, 페이스북, 구글 실시간 지능형 분석 시스템',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        activeColor: AppColors.primary,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
