import 'package:equatable/equatable.dart';

class MarketIndex extends Equatable {
  const MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
  });

  factory MarketIndex.fromJson(Map<String, dynamic> json) {
    return MarketIndex(
      name: json['indexName'] as String,
      value: (json['last'] as num).toDouble(),
      change: ((json['last'] as num) - (json['previousClose'] as num)).toDouble(),
      changePercent: (json['percChange'] as num).toDouble(),
    );
  }

  final String name;
  final double value;
  final double change;
  final double changePercent;

  bool get isPositive => change >= 0;

  @override
  List<Object?> get props => [name, value, change, changePercent];
}

class ContentItem extends Equatable {
  const ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.actionUrl,
    this.type = ContentType.blog,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String?,
      actionUrl: json['action_url'] as String?,
      type: ContentType.fromString(json['type'] as String?),
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? actionUrl;
  final ContentType type;

  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, actionUrl, type];
}

enum ContentType {
  blog('blog'),
  ad('ad');

  const ContentType(this.value);
  final String value;

  static ContentType fromString(String? value) {
    return ContentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContentType.blog,
    );
  }
}
