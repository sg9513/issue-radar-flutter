import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/issue_item.dart';
import '../models/bookmark_folder.dart';
import '../models/trend_item.dart';

class IssueService extends ChangeNotifier {
  static const String liveDataUrl =
      'https://raw.githubusercontent.com/sg9513/issue-radar-flutter/main/data/latest_issues.json';

  List<IssueItem> _allIssues = [];
  bool _isLoading = false;
  String _searchQuery = '';
  IssueChannel _selectedChannel = IssueChannel.all;
  final Set<String> _bookmarkedIds = {};
  DateTime? _lastUpdatedAt;

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

  List<IssueItem> get filteredIssues {
    return _allIssues.where((item) {
      final matchesChannel =
          _selectedChannel == IssueChannel.all || item.channel == _selectedChannel;
      if (!matchesChannel) return false;

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

    // 1단계: 캐시/시드 데이터 즉시 표시 (지연 없는 쾌속 렌더링)
    if (_allIssues.isEmpty) {
      _allIssues = _getMockSeedIssues();
      notifyListeners();
    }

    // 2단계: 실시간 원격 최신 데이터 백그라운드 동기화
    await _fetchLiveDataFromNetwork();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshIssues() async {
    _isLoading = true;
    notifyListeners();

    await _fetchLiveDataFromNetwork();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchLiveDataFromNetwork() async {
    try {
      // 캐시 방지 타임스탬프 쿼리
      final uri = Uri.parse('$liveDataUrl?t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          if (decoded['items'] != null && decoded['items'] is List) {
            final List<dynamic> list = decoded['items'];
            _allIssues = list.map((item) => IssueItem.fromJson(item)).toList();
          }

          if (decoded['trends'] != null && decoded['trends'] is List) {
            final List<dynamic> tList = decoded['trends'];
            _trends = tList.map((t) => TrendItem.fromJson(t)).toList();
          }

          if (decoded['updated_at'] != null) {
            _lastUpdatedAt = DateTime.tryParse(decoded['updated_at']);
          }
        }
      }
    } catch (e) {
      debugPrint('[IssueService] 실시간 데이터 동기화 예외 (오프라인 모드 유지): $e');
      if (_allIssues.isEmpty) {
        _allIssues = _getMockSeedIssues();
      }
    }
  }

  // Folder Management Operations
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
      IssueItem(
        id: 'rd-1',
        channel: IssueChannel.reddit,
        channelLabel: 'Reddit r/technology',
        title: '\"AI 코딩 에이전트 도입 후 시니어 엔지니어의 일상 변화와 딜레마\"',
        summary: '코드 생성 속도는 빨라졌으나 PR 리뷰 및 시스템 안정성 검증 병목이 심화되었다는 레딧 인기 포스트.',
        metric: '⬆️ 4.8k upvotes · 💬 1.2k comments',
        tags: ['#AICoding', '#DevLife', '#CodeReview'],
        background: '개발 생산성 도구 도입 6개월 차 현업 엔지니어의 솔직한 분석 글이 대규모 공감을 얻었습니다.',
        reactions: '코드 생성량 증가에 비례해 유지보수 부채가 늘어난다는 우려와 리뷰 자동화 툴의 필요성에 공감대가 형성되었습니다.',
        insight: '단순 코딩 자동화를 넘어 팀 단위의 코드 리뷰 거버넌스가 핵심 과제로 부상했습니다.',
        sourceUrl: 'https://reddit.com/r/technology',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      IssueItem(
        id: 'x-1',
        channel: IssueChannel.x,
        channelLabel: 'X (트위터)',
        title: '실리콘밸리 엔지니어들의 \"멀티 LLM 하이브리드 파이프라인\" 실전 팁 화제',
        summary: '복잡한 아키텍처 설계와 빠른 파일 수정을 서로 다른 특화 모델에 분담시키는 체인이 대세로 정착 중입니다.',
        metric: '🔁 18.5k reposts · ❤️ 42k likes',
        tags: ['#AIWorkflow', '#LLMPipeline', '#Prompting'],
        background: '단일 모델의 한계를 극복하기 위해 추론 모델과 코딩 특화 모델을 결합하는 방법론이 X에서 바이럴을 탔습니다.',
        reactions: '현업 개발자들이 각자의 커스텀 프롬프트와 에이전트 설정 노하우를 공유하며 스레드가 확산되었습니다.',
        insight: '다양한 모델의 장단점을 파악하고 조합하는 오케스트레이션 능력이 개발자의 필수 역량이 되고 있습니다.',
        sourceUrl: 'https://x.com/tech_trends',
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
