import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/funds_repository.dart';
import '../domain/funds_models.dart';

final fundDetailProvider = FutureProvider.family<FundDetail, String>((ref, fundId) {
  return ref.watch(fundsRepositoryProvider).getFundDetail(fundId);
});
