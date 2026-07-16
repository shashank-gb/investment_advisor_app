import 'package:equatable/equatable.dart';

class PortfolioSummary extends Equatable {
  const PortfolioSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalReturns,
    required this.returnsPercent,
    this.xirr,
  });

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      totalInvested: (json['total_invested'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      totalReturns: (json['total_returns'] as num).toDouble(),
      returnsPercent: (json['returns_percent'] as num).toDouble(),
      xirr: (json['xirr'] as num?)?.toDouble(),
    );
  }

  final double totalInvested;
  final double currentValue;
  final double totalReturns;
  final double returnsPercent;
  final double? xirr;

  @override
  List<Object?> get props =>
      [totalInvested, currentValue, totalReturns, returnsPercent, xirr];
}

class PortfolioHolding extends Equatable {
  const PortfolioHolding({
    required this.fundId,
    required this.fundName,
    required this.amc,
    required this.units,
    required this.investedAmount,
    required this.currentValue,
    required this.returns,
    required this.returnsPercent,
    this.folioNumber,
  });

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      fundId: json['fund_id'] as String,
      fundName: json['fund_name'] as String,
      amc: json['amc'] as String,
      units: (json['units'] as num).toDouble(),
      investedAmount: (json['invested_amount'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      returns: (json['returns'] as num).toDouble(),
      returnsPercent: (json['returns_percent'] as num).toDouble(),
      folioNumber: json['folio_number'] as String?,
    );
  }

  final String fundId;
  final String fundName;
  final String amc;
  final double units;
  final double investedAmount;
  final double currentValue;
  final double returns;
  final double returnsPercent;
  final String? folioNumber;

  @override
  List<Object?> get props => [
        fundId,
        fundName,
        amc,
        units,
        investedAmount,
        currentValue,
        returns,
        returnsPercent,
        folioNumber,
      ];
}
