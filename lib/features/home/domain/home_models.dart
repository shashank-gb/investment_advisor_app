import 'package:equatable/equatable.dart';

class FundCategory extends Equatable {
  const FundCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory FundCategory.fromJson(Map<String, dynamic> json) {
    return FundCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  final String id;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [id, name, description];
}

class MutualFund extends Equatable {
  const MutualFund({
    required this.id,
    required this.name,
    required this.amc,
    required this.category,
    required this.nav,
    required this.returns1Y,
    this.returns3Y,
    this.riskLevel,
    this.minInvestment,
    this.isin,
  });

  factory MutualFund.fromJson(Map<String, dynamic> json) {
    return MutualFund(
      id: json['id'] as String,
      name: json['name'] as String,
      amc: json['amc'] as String,
      category: json['category'] as String,
      nav: (json['nav'] as num).toDouble(),
      returns1Y: (json['returns_1y'] as num).toDouble(),
      returns3Y: (json['returns_3y'] as num?)?.toDouble(),
      riskLevel: json['risk_level'] as String?,
      minInvestment: (json['min_investment'] as num?)?.toDouble(),
      isin: json['isin'] as String?,
    );
  }

  final String id;
  final String name;
  final String amc;
  final String category;
  final double nav;
  final double returns1Y;
  final double? returns3Y;
  final String? riskLevel;
  final double? minInvestment;
  final String? isin;

  @override
  List<Object?> get props => [
        id,
        name,
        amc,
        category,
        nav,
        returns1Y,
        returns3Y,
        riskLevel,
        minInvestment,
        isin,
      ];
}

class MarketIndex extends Equatable {
  const MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
  });

  factory MarketIndex.fromJson(Map<String, dynamic> json) {
    return MarketIndex(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['change_percent'] as num).toDouble(),
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
