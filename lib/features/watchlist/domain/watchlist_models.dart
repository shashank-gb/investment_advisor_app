import 'package:equatable/equatable.dart';
import 'package:mf_app/features/funds/domain/funds_models.dart';

class WatchlistGroup extends Equatable {
  const WatchlistGroup({
    required this.id,
    required this.name,
    required this.fundCount,
  });

  factory WatchlistGroup.fromJson(Map<String, dynamic> json) {
    return WatchlistGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      fundCount: json['fund_count'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final int fundCount;

  @override
  List<Object?> get props => [id, name, fundCount];
}

class WatchlistFund extends Equatable {
  const WatchlistFund({
    required this.groupId,
    required this.fund,
  });

  factory WatchlistFund.fromJson(Map<String, dynamic> json) {
    return WatchlistFund(
      groupId: json['group_id'] as String,
      fund: MutualFund.fromJson(json['fund'] as Map<String, dynamic>),
    );
  }

  final String groupId;
  final MutualFund fund;

  @override
  List<Object?> get props => [groupId, fund];
}
