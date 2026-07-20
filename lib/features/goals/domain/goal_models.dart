import 'package:equatable/equatable.dart';

class InvestmentGoal extends Equatable {
  const InvestmentGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.colorHex,
    required this.categoryIds,
  });

  factory InvestmentGoal.fromJson(Map<String, dynamic> json) {
    return InvestmentGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconData: json['icon_data'] as String,
      colorHex: json['color_hex'] as String,
      categoryIds: List<String>.from(json['category_ids'] as List),
    );
  }

  final String id;
  final String title;
  final String description;
  final String iconData; // Can be icon name or code point
  final String colorHex;
  final List<String> categoryIds;

  @override
  List<Object?> get props => [id, title, description, iconData, colorHex, categoryIds];
}
