import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worker.dart';
import '../services/worker_service.dart';

final workersProvider = FutureProvider.autoDispose<List<Worker>>((ref) async {
  final service = ref.watch(workerServiceProvider);
  return await service.getWorkers();
});
