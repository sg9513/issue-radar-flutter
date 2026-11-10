import 'package:flutter/material.dart';
import '../models/issue_item.dart';
import '../services/issue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/issue_card.dart';
import 'bookmarks_screen.dart';
import 'trends_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final IssueService issueService;

  const HomeScreen({Key? key, required this.issueService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomNavIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.issueService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.issueService.removeListener(_onServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentBottomNavIndex,
        children: [
          _buildRadarFeedScreen(),
          BookmarksScreen(issueService: widget.issueService),
          TrendsScreen(issueService: widget.issueService),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
            if (index == 0) _isSearching = false;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: '레이더'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: '보관함'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department_outlined), label: '트렌드'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: '설정'),
        ],
      ),
    );
  }

  Widget _buildRadarFeedScreen() {
    final issues = widget.issueService.filteredIssues;
    final notice = widget.issueService.recentNotificationMsg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '이슈 키워드 검색...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      widget.issueService.setSearchQuery('');
                      setState(() => _isSearching = false);
                    },
                  ),
                ),
                onChanged: (val) => widget.issueService.setSearchQuery(val),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.radar, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이슈 레이더',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '실시간 동기화 활성',
                            style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textSecondary),
              onPressed: () => setState(() => _isSearching = true),
            ),
        ],
      ),
      body: Column(
        children: [
          // New Update Alert Banner
          if (notice != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF06B6D4), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notice,
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.issueService.clearRecentNotification(),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF06B6D4)),
                  ),
                ],
              ),
            ),

          // Filter Chips Row
          _buildFilterChipsRow(),

          // Issues List
          Expanded(
            child: widget.issueService.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : issues.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              '검색된 이슈가 없습니다.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onRefresh: () => widget.issueService.refreshIssues(),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: issues.length,
                          itemBuilder: (context, index) {
                            return IssueCard(item: issues[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: IssueChannel.values.length,
        itemBuilder: (context, index) {
          final channel = IssueChannel.values[index];
          final isSelected = widget.issueService.selectedChannel == channel;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                channel.iconData,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              label: Text(
                channel.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              selectedColor: channel == IssueChannel.newUpdates
                  ? const Color(0xFF06B6D4)
                  : AppColors.primary,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              onSelected: (selected) {
                if (selected) widget.issueService.setChannel(channel);
              },
            ),
          );
        },
      ),
    );
  }
}
