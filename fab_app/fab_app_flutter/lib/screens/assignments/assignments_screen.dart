import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'current_assignments_view.dart';
import 'history_assignments_view.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assignments'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Current'),
              Tab(text: 'History'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/assignments/new'),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            CurrentAssignmentsView(),
            HistoryAssignmentsView(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => context.push('/assignments/new'),
          icon: const Icon(Icons.add),
          label: const Text('Assign Tool'),
        ),
      ),
    );
  }
}
