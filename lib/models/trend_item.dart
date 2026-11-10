class TrendItem {
  final int rank;
  final String keyword;
  final String category;
  final String searchVolume;
  final String surgeRate;
  final String platform;
  final String description;

  const TrendItem({
    required this.rank,
    required this.keyword,
    required this.category,
    required this.searchVolume,
    required this.surgeRate,
    required this.platform,
    required this.description,
  });

  factory TrendItem.fromJson(Map<String, dynamic> json) {
    return TrendItem(
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      keyword: json['keyword'] ?? '',
      category: json['category'] ?? '트렌드',
      searchVolume: json['searchVolume'] ?? '',
      surgeRate: json['surgeRate'] ?? '',
      platform: json['platform'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
