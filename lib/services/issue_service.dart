import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/issue_item.dart';

class IssueService extends ChangeNotifier {
  List<IssueItem> _allIssues = [];
  bool _isLoading = false;
  String _searchQuery = '';
  IssueChannel _selectedChannel = IssueChannel.all;
  final Set<String> _bookmarkedIds = {};

  List<IssueItem> get allIssues => _allIssues;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  IssueChannel get selectedChannel => _selectedChannel;
  Set<String> get bookmarkedIds => _bookmarkedIds;

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
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    // 5대 플랫폼 초기 데이터 로드 (고화질 실전 데이터)
    await Future.delayed(const Duration(milliseconds: 300));
    _allIssues = _getMockSeedIssues();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshIssues() async {
    _isLoading = true;
    notifyListeners();

    // 백그라운드 수집 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 600));
    _allIssues = _getMockSeedIssues();
    _isLoading = false;
    notifyListeners();
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
    } else {
      _bookmarkedIds.add(id);
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
      IssueItem(
        id: 'fb-1',
        channel: IssueChannel.facebook,
        channelLabel: 'Facebook IT 개발자 그룹',
        title: '국내 테크 스타트업 500팀 대상 \"2026 하반기 실무 AI 도구 만족도 서베이\"',
        summary: '국내 500개 테크 스타트업 서베이 결과, 사내 저장소 컨텍스트 연동 에이전트가 최우수 평가를 받았습니다.',
        metric: '👍 1.8k likes · 💬 420 comments',
        tags: ['#Survey', '#DevTools', '#Startup'],
        background: '국내 개발자 그룹에서 실시한 업무 생산성 설문조사 인포그래픽이 높은 공유 수를 기록했습니다.',
        reactions: '보안 규정과 사내 소스코드 유출 방지 가이드라인을 충족하는 온프레미스/엔터프라이즈 솔루션에 관심이 높습니다.',
        insight: '도구 도입을 넘어 사내 보안 거버넌스 구축이 엔지니어링 리더들의 최대 관심사입니다.',
        sourceUrl: 'https://facebook.com/groups/devkorea',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
      IssueItem(
        id: 'gg-1',
        channel: IssueChannel.google,
        channelLabel: 'Google Trends 급상승',
        title: '구글 급상승 검색어: \"자율형 AI 에이전트 프레임워크\"',
        summary: '단순 챗봇을 넘어 스스로 환경을 탐색하고 작업을 완수하는 에이전틱 AI 관련 검색량 폭증.',
        metric: '🔥 500% 급상승 · 트렌드 1위',
        tags: ['#GoogleTrends', '#AgenticAI', '#Trending'],
        background: '주요 글로벌 빅테크 기업들의 자율 에이전트 출시 발표 이후 일반 대중 및 개발자들의 검색 유입이 급증했습니다.',
        reactions: '개인용 자동화 도구부터 엔터프라이즈 업무 자동화까지 적용 가능성에 대한 관심이 쏟아지고 있습니다.',
        insight: 'AI 패러다임이 대화형 어시스턴트에서 자율 실행 에이전트로 이동하고 있음을 보여주는 대중적 지표입니다.',
        sourceUrl: 'https://trends.google.com/trending',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
