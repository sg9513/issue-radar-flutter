import 'package:flutter/material.dart';
import '../models/issue_item.dart';
import '../theme/app_theme.dart';
import 'detail_sheet.dart';

class IssueCard extends StatelessWidget {
  final IssueItem item;
  final VoidCallback? onBookmarkToggle;
  final bool isBookmarked;

  const IssueCard({
    Key? key,
    required this.item,
    this.onBookmarkToggle,
    this.isBookmarked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channelColor = _getChannelColor(item.channel);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: channelColor.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: channelColor.withOpacity(0.08),
            blurRadius: 16,
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => DetailSheet(item: item),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.35,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Summary
                Text(
                  item.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      default:
        return AppColors.primary;
    }
  }
}
