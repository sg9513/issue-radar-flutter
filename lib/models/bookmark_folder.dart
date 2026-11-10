import 'package:flutter/material.dart';

class BookmarkFolder {
  final String id;
  String name;
  Color color;
  IconData icon;
  final List<String> issueIds;
  final DateTime createdAt;

  BookmarkFolder({
    required this.id,
    required this.name,
    this.color = const Color(0xFF6366F1),
    this.icon = Icons.folder_outlined,
    List<String>? issueIds,
    DateTime? createdAt,
  })  : issueIds = issueIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  int get count => issueIds.length;

  void addIssue(String issueId) {
    if (!issueIds.contains(issueId)) {
      issueIds.add(issueId);
    }
  }

  void removeIssue(String issueId) {
    issueIds.remove(issueId);
  }
}
