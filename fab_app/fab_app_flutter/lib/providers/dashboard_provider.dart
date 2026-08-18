import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dashboard_service.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return await service.getStats();
});
