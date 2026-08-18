import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/machine.dart';
import '../services/machine_service.dart';

final machinesProvider = FutureProvider.autoDispose<List<Machine>>((ref) async {
  final service = ref.watch(machineServiceProvider);
  return await service.getMachines();
});
