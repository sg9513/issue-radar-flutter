import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/issue_item.dart';
import '../models/bookmark_folder.dart';
import '../models/trend_item.dart';
import 'notification_service.dart';

class IssueService extends ChangeNotifier {
  static const String liveDataUrl =
      'https://raw.githubusercontent.com/sg9513/issue-radar-flutter/main/data/latest_issues.json';

  List<IssueItem> _allIssues = [];
  bool _isLoading = false;
  String _searchQuery = '';
  IssueChannel _selectedChannel = IssueChannel.all;
  final Set<String> _bookmarkedIds = {};
  DateTime? _lastUpdatedAt;
  bool _notificationEnabled = true;
  String? _recentNotificationMsg;
  final Set<String> _knownIssueIds = {};
  Timer? _backgroundTimer;

  // Custom Bookmark Folders
  final List<BookmarkFolder> _folders = [];

  // Real-time Trends
  List<TrendItem> _trends = [];

  List<IssueItem> get allIssues => _allIssues;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  IssueChannel get selectedChannel => _selectedChannel;
  Set<String> get bookmarkedIds => _bookmarkedIds;
  List<BookmarkFolder> get folders => _folders;
  List<TrendItem> get trends => _trends;
  DateTime? get lastUpdatedAt => _lastUpdatedAt;
  bool get notificationEnabled => _notificationEnabled;
  String? get recentNotificationMsg => _recentNotificationMsg;

  List<IssueItem> get filteredIssues {
    return _allIssues.where((item) {
      if (_selectedChannel == IssueChannel.newUpdates) {
        if (!item.isNew || item.isRead) return false;
      } else if (_selectedChannel != IssueChannel.all) {
        if (item.channel != _selectedChannel) return false;
      }

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.title.toLowerCase().contains(q) ||
          item.summary.toLowerCase().contains(q) ||
          item.insight.toLowerCase().contains(q) ||
          item.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  IssueService() {
    _initDefaultFolders();
    _initDefaultTrends();
    loadInitialData();
    _startBackgroundWatcher();
  }

  void _startBackgroundWatcher() {
    _backgroundTimer?.cancel();
    // 15분마다 조용히 백그라운드 확인하여 '진짜 새로운 이슈'가 있을 때만 알림
    _backgroundTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _fetchLiveDataFromNetwork(sendNotification: true);
    });
  }

  @override
  void dispose() {
    _backgroundTimer?.cancel();
    super.dispose();
  }

  void setNotificationEnabled(bool enabled) {
    _notificationEnabled = enabled;
    notifyListeners();
  }

  void clearRecentNotification() {
    _recentNotificationMsg = null;
    notifyListeners();
  }

  void _initDefaultFolders() {
    _folders.addAll([
      BookmarkFolder(
        id: 'default',
        name: '📌 중요 스크랩',
        color: const Color(0xFF6366F1),
        icon: Icons.push_pin_outlined,
        issueIds: ['gh-1', 'x-1'],
      ),
      BookmarkFolder(
        id: 'ai-trends',
        name: '💡 AI 기술 동향',
        color: const Color(0xFF10B981),
        icon: Icons.smart_toy_outlined,
        issueIds: ['gh-1', 'gg-1'],
      ),
      BookmarkFolder(
        id: 'dev-tips',
        name: '🛠️ 개발 꿀팁 & 도구',
        color: const Color(0xFFF59E0B),
        icon: Icons.build_outlined,
        issueIds: ['gh-2', 'rd-1'],
      ),
    ]);
  }

  void _initDefaultTrends() {
    _trends = [
      const TrendItem(
        rank: 1,
        keyword: 'DeepSeek R1 / DeepInfer',
        category: 'AI / 추론 인프라',
        searchVolume: '320K+ 검색',
        surgeRate: '+850%',
        platform: 'Google Trends 1위 · GitHub',
        description: '저비용 고성능 분산 추론 가속 프레임워크 공개 및 스타 폭증',
      ),
      const TrendItem(
        rank: 2,
        keyword: '자율형 AI 에이전트',
        category: '소프트웨어 엔지니어링',
        searchVolume: '210K+ 검색',
        surgeRate: '+520%',
        platform: 'Google Trends · X 실시간',
        description: '단순 질의응답을 넘어선 다중 파일 수정 및 자율 테스크 해결 화두',
      ),
      const TrendItem(
        rank: 3,
        keyword: 'Claude 3.5 Sonnet 하이브리드 파이프라인',
        category: 'LLM 오케스트레이션',
        searchVolume: '185K+ 검색',
        surgeRate: '+410%',
        platform: 'X (트위터) 엔지니어 스레드',
        description: '추론 모델과 코딩 특화 모델을 결합하는 멀티 LLM 실전 체인 바이럴',
      ),
      const TrendItem(
        rank: 4,
        keyword: 'AI 코딩 도입 후 PR 리뷰 병목',
        category: '개발자 문화 & 거버넌스',
        searchVolume: '140K+ 검색',
        surgeRate: '+340%',
        platform: 'Reddit r/technology 인기글',
        description: '코드 생성량 폭증에 따른 코드 리뷰 피로감 및 품질 검증 대책 논의',
      ),
      const TrendItem(
        rank: 5,
        keyword: '스마트TV 클린OS / 디블로트',
        category: '오픈소스 유틸리티',
        searchVolume: '95K+ 검색',
        surgeRate: '+290%',
        platform: 'GitHub Trending 1위',
        description: '무선 Wi-Fi로 TV 광고 및 기본 탑재 앱을 일괄 삭제하는 툴 화제',
      ),
    ];
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    if (_allIssues.isEmpty) {
      _allIssues = _getMockSeedIssues();
      _knownIssueIds.addAll(_allIssues.map((e) => e.id));
      notifyListeners();
    }

    await _fetchLiveDataFromNetwork(sendNotification: false);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshIssues() async {
    _isLoading = true;
    notifyListeners();

    // 사용자가 직접 화면을 당겨서 새로고침할 때는 상단바 알림 금지 (이미 화면을 보고 있으므로)
    await _fetchLiveDataFromNetwork(sendNotification: false);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchLiveDataFromNetwork({bool sendNotification = false}) async {
    try {
      final uri = Uri.parse('$liveDataUrl?t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          bool hasBrandNewIssue = false;
          IssueItem? brandNewTopItem;

          if (decoded['items'] != null && decoded['items'] is List) {
            final List<dynamic> list = decoded['items'];
            final newItems = list.map((item) => IssueItem.fromJson(item)).toList();
            if (newItems.isNotEmpty) {
              // 이전에 없던 '진짜 새로운 이슈'가 들어왔는지 검사
              if (_knownIssueIds.isNotEmpty) {
                for (final item in newItems) {
                  if (!_knownIssueIds.contains(item.id)) {
                    hasBrandNewIssue = true;
                    brandNewTopItem ??= item;
                  }
                }
              }
              _knownIssueIds.addAll(newItems.map((e) => e.id));
              _allIssues = newItems;
            }
          }

          if (decoded['trends'] != null && decoded['trends'] is List) {
            final List<dynamic> tList = decoded['trends'];
            _trends = tList.map((t) => TrendItem.fromJson(t)).toList();
          }

          if (decoded['updated_at'] != null) {
            _lastUpdatedAt = DateTime.tryParse(decoded['updated_at']);
          }

          // 사용자가 앱 화면을 보고 있을 때는 알림을 보내지 않고,
          // 백그라운드에서 '진짜 새로운 이슈'가 새로 유입되었을 때만 상단바 푸시 발송!
          if (sendNotification && hasBrandNewIssue && _notificationEnabled) {
            final topHeadline = brandNewTopItem?.title ?? (_allIssues.isNotEmpty ? _allIssues.first.title : '최신 핫이슈');
            _recentNotificationMsg = '새로운 이슈가 도착했습니다: $topHeadline';

            await NotificationService.showUpdateNotification(
              count: _allIssues.length,
              topHeadline: topHeadline,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[IssueService] 실시간 데이터 동기화 예외: $e');
      if (_allIssues.isEmpty) {
        _allIssues = _getMockSeedIssues();
      }
    }
  }

  // Folder Operations
  void createFolder(String name, {Color? color, IconData? icon}) {
    if (name.trim().isEmpty) return;
    _folders.add(BookmarkFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      color: color ?? const Color(0xFF6366F1),
      icon: icon ?? Icons.folder_outlined,
    ));
    notifyListeners();
  }

  void renameFolder(String folderId, String newName) {
    if (newName.trim().isEmpty) return;
    final folder = _folders.firstWhere((f) => f.id == folderId, orElse: () => _folders.first);
    folder.name = newName.trim();
    notifyListeners();
  }

  void deleteFolder(String folderId) {
    _folders.removeWhere((f) => f.id == folderId);
    notifyListeners();
  }

  void toggleSaveToFolder(String folderId, String issueId) {
    final folder = _folders.firstWhere((f) => f.id == folderId, orElse: () => _folders.first);
    if (folder.issueIds.contains(issueId)) {
      folder.removeIssue(issueId);
      if (!_folders.any((f) => f.issueIds.contains(issueId))) {
        _bookmarkedIds.remove(issueId);
      }
    } else {
      folder.addIssue(issueId);
      _bookmarkedIds.add(issueId);
    }
    notifyListeners();
  }

  bool isIssueInFolder(String folderId, String issueId) {
    final folder = _folders.firstWhere((f) => f.id == folderId, orElse: () => _folders.first);
    return folder.issueIds.contains(issueId);
  }

  List<IssueItem> getIssuesForFolder(String folderId) {
    final folder = _folders.firstWhere((f) => f.id == folderId, orElse: () => _folders.first);
    return _allIssues.where((item) => folder.issueIds.contains(item.id)).toList();
  }

  void setChannel(IssueChannel channel) {
    _selectedChannel = channel;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleBookmark(String id) {
    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
      for (final f in _folders) {
        f.removeIssue(id);
      }
    } else {
      _bookmarkedIds.add(id);
      if (_folders.isNotEmpty) {
        _folders.first.addIssue(id);
      }
    }
    notifyListeners();
  }

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  static List<IssueItem> _getMockSeedIssues() {
    final now = DateTime.now();
    return [
      IssueItem(
        id: 'gh-1',
        channel: IssueChannel.github,
        channelLabel: 'GitHub Trending',
        title: 'deepseek-ai/DeepInfer: 차세대 고속 분산 추론 엔진',
        summary: 'DeepSeek 모델 군을 프로덕션 환경에서 최소 GPU 자원으로 초고속 서빙하는 공식 프레임워크 공개.',
        metric: '⭐ 25.8k stars · 3.4k forks',
        tags: ['#DeepSeek', '#Inference', '#AIInfra'],
        background: '대형 언어 모델의 로컬 및 사내 프라이빗 클라우드 도입 비용을 획기적으로 낮추기 위해 개발된 공식 고성능 런타임입니다.',
        reactions: 'vLLM, TensorRT-LLM 대비 높은 토큰 처리량과 메모리 절감 수치 벤치마크가 화제를 모으며 깃허브 스타가 급증했습니다.',
        insight: '추론 비용 절감이 AI 프로덕션 배포의 최대 화두로 부상하면서 전용 최적화 프레임워크 경쟁이 본격화되고 있습니다.',
        sourceUrl: 'https://github.com/deepseek-ai/DeepInfer',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      IssueItem(
        id: 'gh-2',
        channel: IssueChannel.github,
        channelLabel: 'GitHub Trending',
        title: 'Gathin23/cleanyourtv: 스마트TV 광고/블로트웨어 완벽 제거 툴',
        summary: 'Wi-Fi 무선 연결로 안드로이드 TV 및 구글 TV의 군더더기 앱을 삭제하고 Apple TV 스타일의 깔끔한 홈 제공.',
        metric: '⭐ 55.7k stars · Python',
        tags: ['#AndroidTV', '#OpenSource', '#CleanOS'],
        background: '스마트 TV 내 기본 탑재 광고와 성능 저하에 피로감을 느낀 글로벌 유저들을 위해 개발된 오픈소스 자동화 스크립트입니다.',
        reactions: '복잡한 adb 지식 없이 원클릭으로 쾌적한 런처를 구성할 수 있어 레딧과 해외 커뮤니티에서 폭발적 호응을 얻고 있습니다.',
        insight: '하드웨어 제조사의 무분별한 광고 탑재에 맞서 오픈소스 디블로트 생태계가 점차 대중화되고 있습니다.',
        sourceUrl: 'https://github.com/Gathin23/cleanyourtv',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      IssueItem(
        id: 'gh-3',
        channel: IssueChannel.github,
        channelLabel: 'GitHub Trending',
        title: 'storytold/craft-anything: 모든 소프트웨어 구조 리버스 엔지니어링',
        summary: 'Rust 기반으로 작성되어 임의의 소프트웨어 아키텍처를 분석하고 직관적 다이어그램으로 시각화.',
        metric: '⭐ 25.4k stars · Rust',
        tags: ['#Rust', '#Architecture', '#DevTools'],
        background: '거대한 레거시 코드베이스나 오픈소스의 동작 원리를 단시간에 파악하기 위해 제작된 정적/동적 아키텍처 분석기입니다.',
        reactions: '신규 프로젝트 온보딩 시간을 절반 이상 줄여준다는 평가와 함께 기업 내 테크 리드들의 관심이 집중되고 있습니다.',
        insight: '복잡해지는 마이크로서비스 및 분산 아키텍처를 자동으로 이해하고 문서화하는 툴의 실무 가치가 입증되고 있습니다.',
        sourceUrl: 'https://github.com/storytold/craft-anything',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }
}
