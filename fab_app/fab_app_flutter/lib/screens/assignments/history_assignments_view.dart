import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/assignment.dart';
import '../../providers/assignment_provider.dart';

class HistoryAssignmentsView extends ConsumerStatefulWidget {
  const HistoryAssignmentsView({super.key});

  @override
  ConsumerState<HistoryAssignmentsView> createState() => _HistoryAssignmentsViewState();
}

class _HistoryAssignmentsViewState extends ConsumerState<HistoryAssignmentsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(assignmentHistoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search history...',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(assignmentHistoryProvider);
            },
            child: historyAsync.when(
              data: (assignments) {
                final filtered = assignments.where((a) {
                  return (a.workerName?.toLowerCase() ?? '').contains(_searchQuery) ||
                         (a.machineName?.toLowerCase() ?? '').contains(_searchQuery) ||
                         a.location.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('No assignment history.', style: TextStyle(fontSize: 16))),
                    ],
                  );
                }

                final grouped = <String, List<Assignment>>{};
                for (final a in filtered) {
                  final workerName = a.workerName ?? 'Unknown Worker';
                  grouped.putIfAbsent(workerName, () => []).add(a);
                }
                
                final groupKeys = grouped.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
                  itemCount: groupKeys.length,
                  itemBuilder: (context, index) {
                    final workerName = groupKeys[index];
                    final workerAssignments = grouped[workerName]!;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const Divider(),
                            ...workerAssignments.map((assignment) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          assignment.machineName ?? 'Unknown Machine',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey),
                                        ),
                                        child: Text(
                                          assignment.status,
                                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward, size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text(DateFormat('MMM dd, yyyy - hh:mm a').format(assignment.assignedAt), style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  if (assignment.returnedAt != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Text(DateFormat('MMM dd, yyyy - hh:mm a').format(assignment.returnedAt!), style: const TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(assignment.location, style: const TextStyle(fontSize: 13))),
                                    ],
                                  ),
                                  if (assignment.assignedByName != null && assignment.assignedByName!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text('Assigned by: ${assignment.assignedByName}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                  if (assignment.returnedByName != null && assignment.returnedByName!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text('Returned by: ${assignment.returnedByName}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                  if (assignment != workerAssignments.last)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: Divider(height: 1),
                                    ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(err.toString().replaceAll('Exception: ', ''), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(assignmentHistoryProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
