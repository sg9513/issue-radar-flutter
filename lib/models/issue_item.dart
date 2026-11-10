import 'package:flutter/material.dart';

enum IssueChannel {
  all,
  github,
  reddit,
  x,
  facebook,
  google;

  String get label {
    switch (this) {
      case IssueChannel.all:
        return '전체 피드';
      case IssueChannel.github:
        return 'GitHub';
      case IssueChannel.reddit:
        return 'Reddit';
      case IssueChannel.x:
        return 'X (트위터)';
      case IssueChannel.facebook:
        return 'Facebook';
      case IssueChannel.google:
        return 'Google Trends';
    }
  }

  Color get brandColor {
    switch (this) {
      case IssueChannel.all:
        return const Color(0xFF6366F1); // Indigo
      case IssueChannel.github:
        return const Color(0xFF24292E); // GitHub dark
      case IssueChannel.reddit:
        return const Color(0xFFFF4500); // Reddit orange
      case IssueChannel.x:
        return const Color(0xFF1DA1F2); // X / Twitter blue
      case IssueChannel.facebook:
        return const Color(0xFF1877F2); // Facebook blue
      case IssueChannel.google:
        return const Color(0xFFEA4335); // Google red
    }
  }

  IconData get iconData {
    switch (this) {
      case IssueChannel.all:
        return Icons.auto_awesome;
      case IssueChannel.github:
        return Icons.code;
      case IssueChannel.reddit:
        return Icons.forum;
      case IssueChannel.x:
        return Icons.tag;
      case IssueChannel.facebook:
        return Icons.groups;
      case IssueChannel.google:
        return Icons.trending_up;
    }
  }
}

class IssueItem {
  final String id;
  final IssueChannel channel;
  final String channelLabel;
  final String title;
  final String summary;
  final String metric;
  final List<String> tags;
  final String background;
  final String reactions;
  final String insight;
  final String sourceUrl;
  final DateTime timestamp;

  const IssueItem({
    required this.id,
    required this.channel,
    required this.channelLabel,
    required this.title,
    required this.summary,
    required this.metric,
    required this.tags,
    required this.background,
    required this.reactions,
    required this.insight,
    required this.sourceUrl,
    required this.timestamp,
  });

  factory IssueItem.fromJson(Map<String, dynamic> json) {
    IssueChannel parseChannel(String val) {
      switch (val.toLowerCase()) {
        case 'github':
          return IssueChannel.github;
        case 'reddit':
          return IssueChannel.reddit;
        case 'x':
        case 'twitter':
          return IssueChannel.x;
        case 'facebook':
          return IssueChannel.facebook;
        case 'google':
          return IssueChannel.google;
        default:
          return IssueChannel.all;
      }
    }

    return IssueItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      channel: parseChannel(json['channel'] ?? ''),
      channelLabel: json['channelLabel'] ?? '실시간 이슈',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      metric: json['metric'] ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      background: json['background'] ?? '',
      reactions: json['reactions'] ?? '',
      insight: json['insight'] ?? '',
      sourceUrl: json['sourceUrl'] ?? json['source'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel': channel.name,
      'channelLabel': channelLabel,
      'title': title,
      'summary': summary,
      'metric': metric,
      'tags': tags,
      'background': background,
      'reactions': reactions,
      'insight': insight,
      'sourceUrl': sourceUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
