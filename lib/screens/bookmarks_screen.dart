import 'package:flutter/material.dart';
import '../models/bookmark_folder.dart';
import '../models/issue_item.dart';
import '../services/issue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/issue_card.dart';

class BookmarksScreen extends StatefulWidget {
  final IssueService issueService;

  const BookmarksScreen({Key? key, required this.issueService}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  BookmarkFolder? _selectedFolder;

  @override
  void initState() {
    super.initState();
    widget.issueService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.issueService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedFolder != null) {
      return _buildFolderDetailView(_selectedFolder!);
    }

    final folders = widget.issueService.folders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('내 보관함', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(
                  '${folders.length}개 보관함 · ${widget.issueService.bookmarkedIds.length}개 스크랩',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, color: AppColors.primary),
            tooltip: '새 보관함 추가',
            onPressed: () => _showCreateFolderDialog(context),
          ),
        ],
      ),
      body: folders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    '생성된 보관함이 없습니다.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('첫 보관함 만들기'),
                    onPressed: () => _showCreateFolderDialog(context),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return _buildFolderTile(folder);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('보관함 추가'),
        onPressed: () => _showCreateFolderDialog(context),
      ),
    );
  }

  Widget _buildFolderTile(BookmarkFolder folder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: folder.color.withOpacity(0.3), width: 1.2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: folder.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(folder.icon, color: folder.color, size: 24),
        ),
        title: Text(
          folder.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '저장된 이슈 ${folder.count}개',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
              onPressed: () => _showRenameFolderDialog(context, folder),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
              onPressed: () => _showDeleteFolderDialog(context, folder),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
        onTap: () {
          setState(() => _selectedFolder = folder);
        },
      ),
    );
  }

  Widget _buildFolderDetailView(BookmarkFolder folder) {
    final issues = widget.issueService.getIssuesForFolder(folder.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => setState(() => _selectedFolder = null),
        ),
        title: Row(
          children: [
            Icon(folder.icon, size: 18, color: folder.color),
            const SizedBox(width: 8),
            Text(
              folder.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: issues.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inbox_outlined, size: 56, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    '이 보관함에 저장된 이슈가 없습니다.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '메인 레이더 피드에서 이슈 카드를 저장해 보세요.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final it = issues[index];
                final isSaved = widget.issueService.isBookmarked(it.id);
                return IssueCard(
                  item: it,
                  isBookmarked: isSaved,
                  issueService: widget.issueService,
                  onBookmarkToggle: () {
                    widget.issueService.toggleBookmark(it.id);
                  },
                );
              },
            ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    Color selectedColor = const Color(0xFF6366F1);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                '새 보관함 만들기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '보관함 이름 (예: AI 신기술, 사이드 프로젝트)',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surfaceLighter,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('테마 컬러 선택', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      const Color(0xFF6366F1),
                      const Color(0xFF10B981),
                      const Color(0xFFF59E0B),
                      const Color(0xFFEF4444),
                      const Color(0xFF06B6D4),
                      const Color(0xFF8B5CF6),
                    ].map((c) {
                      final isPicked = selectedColor == c;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isPicked ? Border.all(color: Colors.white, width: 2.5) : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      widget.issueService.createFolder(
                        controller.text.trim(),
                        color: selectedColor,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('생성'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRenameFolderDialog(BuildContext context, BookmarkFolder folder) {
    final controller = TextEditingController(text: folder.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('보관함 이름 변경', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '새로운 이름',
              filled: true,
              fillColor: AppColors.surfaceLighter,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  widget.issueService.renameFolder(folder.id, controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('변경'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteFolderDialog(BuildContext context, BookmarkFolder folder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('보관함 삭제', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          content: Text('\'${folder.name}\' 보관함을 정말 삭제할까요? (원문 이슈는 삭제되지 않습니다)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                widget.issueService.deleteFolder(folder.id);
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
