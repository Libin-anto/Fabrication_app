import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assignment.dart';
import '../services/assignment_service.dart';

final currentAssignmentsProvider = FutureProvider.autoDispose<List<Assignment>>((ref) async {
  final service = ref.watch(assignmentServiceProvider);
  return await service.getCurrentAssignments();
});

final assignmentHistoryProvider = FutureProvider.autoDispose<List<Assignment>>((ref) async {
  final service = ref.watch(assignmentServiceProvider);
  return await service.getHistory();
});
