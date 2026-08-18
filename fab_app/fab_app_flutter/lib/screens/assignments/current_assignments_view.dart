import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/assignment.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/machine_provider.dart';
import '../../services/assignment_service.dart';

class CurrentAssignmentsView extends ConsumerStatefulWidget {
  const CurrentAssignmentsView({super.key});

  @override
  ConsumerState<CurrentAssignmentsView> createState() => _CurrentAssignmentsViewState();
}

class _CurrentAssignmentsViewState extends ConsumerState<CurrentAssignmentsView> {
  String _searchQuery = '';

  Future<void> _returnMachine(Assignment assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Machine'),
        content: Text('Return ${assignment.machineName} from ${assignment.workerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Returning machine...')),
    );

    try {
      await ref.read(assignmentServiceProvider).returnMachine(assignment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Machine returned successfully.')),
        );
      }
      ref.invalidate(currentAssignmentsProvider);
      ref.invalidate(assignmentHistoryProvider);
      ref.invalidate(machinesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _toggleLocation(Assignment assignment) async {
    final newLocation = assignment.location == 'On Site' ? 'With Worker' : 'On Site';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating location...')),
    );

    try {
      await ref.read(assignmentServiceProvider).updateLocation(assignment.id, newLocation);
      ref.invalidate(currentAssignmentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update location: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(currentAssignmentsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search current assignments...',
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
              ref.invalidate(currentAssignmentsProvider);
            },
            child: assignmentsAsync.when(
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
                      Center(child: Text('No current assignments.', style: TextStyle(fontSize: 16))),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, left: 8, right: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final assignment = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    assignment.machineName ?? 'Unknown Machine',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(assignment.workerName ?? 'Unknown Worker'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(DateFormat('MMM dd, yyyy - hh:mm a').format(assignment.assignedAt)),
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
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _toggleLocation(assignment),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: assignment.location == 'With Worker' ? Colors.pink.shade50 : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: assignment.location == 'With Worker' ? Colors.pink.shade200 : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      assignment.location.isEmpty ? 'ON SITE' : assignment.location.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: assignment.location == 'With Worker' ? Colors.pink.shade700 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _returnMachine(assignment),
                                icon: const Icon(Icons.keyboard_return),
                                label: const Text('Return Machine'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade50,
                                  foregroundColor: Colors.green.shade700,
                                ),
                              ),
                            ),
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
                        onPressed: () => ref.refresh(currentAssignmentsProvider),
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
