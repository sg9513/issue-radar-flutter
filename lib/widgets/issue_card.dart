import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/issue_item.dart';
import '../services/issue_service.dart';
import '../theme/app_theme.dart';
import 'detail_sheet.dart';

class IssueCard extends StatefulWidget {
  final IssueItem item;
  final VoidCallback? onBookmarkToggle;
  final bool isBookmarked;
  final IssueService? issueService;

  const IssueCard({
    Key? key,
    required this.item,
    this.onBookmarkToggle,
    this.isBookmarked = false,
    this.issueService,
  }) : super(key: key);

  @override
  State<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
  Color _getChannelColor(IssueChannel channel) {
    switch (channel) {
      case IssueChannel.github:
        return AppColors.github;
      case IssueChannel.reddit:
        return AppColors.reddit;
      case IssueChannel.x:
        return AppColors.xTwitter;
      case IssueChannel.facebook:
        return AppColors.facebook;
      case IssueChannel.google:
        return AppColors.google;
      case IssueChannel.newUpdates:
        return const Color(0xFF06B6D4);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final channelColor = _getChannelColor(item.channel);
    final isUnreadNew = item.isNew && !item.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isUnreadNew ? const Color(0xFF151E32) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnreadNew
              ? const Color(0xFF06B6D4).withOpacity(0.6)
              : channelColor.withOpacity(0.3),
          width: isUnreadNew ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnreadNew
                ? const Color(0xFF06B6D4).withOpacity(0.12)
                : channelColor.withOpacity(0.08),
            blurRadius: isUnreadNew ? 18 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!item.isRead) {
              setState(() {
                item.isRead = true;
              });
            }

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => DetailSheet(
                item: item,
                issueService: widget.issueService,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Row
                Row(
                  children: [
                    if (isUnreadNew) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF06B6D4), width: 1),
                        ),
                        child: const Text(
                          '✨ NEW',
                          style: TextStyle(
                            color: Color(0xFF06B6D4),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: channelColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.channel.iconData, size: 14, color: channelColor),
                          const SizedBox(width: 4),
                          Text(
                            item.channelLabel,
                            style: TextStyle(
                              color: channelColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLighter,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.metric,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isUnreadNew ? FontWeight.w800 : FontWeight.w700,
                    color: item.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                    height: 1.35,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Summary
                Text(
                  item.summary,
                  style: TextStyle(
                    fontSize: 13,
                    color: item.isRead ? AppColors.textMuted : AppColors.textSecondary,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Tags Row
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLighter.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Quick Action Icons on Card
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: widget.isBookmarked ? AppColors.primary : AppColors.textMuted,
                        ),
                        tooltip: '보관함 바로 저장',
                        onPressed: () {
                          if (widget.onBookmarkToggle != null) {
                            widget.onBookmarkToggle!();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 19, color: AppColors.textMuted),
                        tooltip: '공유하기',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${item.title}\n${item.sourceUrl}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('제목과 원문 링크가 클립보드에 복사되었습니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
