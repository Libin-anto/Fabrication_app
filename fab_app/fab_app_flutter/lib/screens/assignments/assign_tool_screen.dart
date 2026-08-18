import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/machine_provider.dart';
import '../../providers/worker_provider.dart';
import '../../services/assignment_service.dart';
import '../../models/worker.dart';
import '../../models/machine.dart';

class AssignToolScreen extends ConsumerStatefulWidget {
  const AssignToolScreen({super.key});

  @override
  ConsumerState<AssignToolScreen> createState() => _AssignToolScreenState();
}

class _AssignToolScreenState extends ConsumerState<AssignToolScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Worker? _selectedWorker;
  Machine? _selectedMachine;
  final TextEditingController _locationController = TextEditingController(text: 'On Site');
  
  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorker == null || _selectedMachine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a worker and a machine.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assign this machine to this worker?'),
            const SizedBox(height: 16),
            Text('Worker:\n${_selectedWorker!.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Machine:\n${_selectedMachine!.machineNumber} - ${_selectedMachine!.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(assignmentServiceProvider).assignMachine(
        _selectedWorker!.id,
        _selectedMachine!.id,
        _locationController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Machine assigned successfully.')),
        );
      }
      
      // Refresh providers
      ref.invalidate(machinesProvider);
      ref.invalidate(currentAssignmentsProvider);
      ref.invalidate(assignmentHistoryProvider);
      
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        // Refresh machines in case it was already assigned by someone else
        ref.invalidate(machinesProvider);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workersProvider);
    final machinesAsync = ref.watch(machinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Tool'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Worker Selection
              const Text('Select Worker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              workersAsync.when(
                data: (workers) {
                  final activeWorkers = workers.where((w) => w.isActive).toList();
                  return DropdownButtonFormField<Worker>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    initialValue: _selectedWorker,
                    hint: const Text('Choose a worker'),
                    isExpanded: true,
                    items: activeWorkers.map((w) {
                      return DropdownMenuItem(
                        value: w,
                        child: Text('${w.name} (${w.workerId})'),
                      );
                    }).toList(),
                    onChanged: _isLoading ? null : (val) => setState(() => _selectedWorker = val),
                    validator: (val) => val == null ? 'Required field' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading workers', style: TextStyle(color: Colors.red)),
              ),
              
              const SizedBox(height: 24),
              
              // Machine Selection
              const Text('Select Machine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              machinesAsync.when(
                data: (machines) {
                  final availableMachines = machines.where((m) => m.status == 'Available' && m.isActive).toList();
                  return DropdownButtonFormField<Machine>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.precision_manufacturing),
                    ),
                    initialValue: _selectedMachine,
                    hint: const Text('Choose an available machine'),
                    isExpanded: true,
                    items: availableMachines.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text('${m.machineNumber} - ${m.name}'),
                      );
                    }).toList(),
                    onChanged: _isLoading ? null : (val) => setState(() => _selectedMachine = val),
                    validator: (val) => val == null ? 'Required field' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading machines', style: TextStyle(color: Colors.red)),
              ),
              
              const SizedBox(height: 24),
              
              // Location Input
              const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required field' : null,
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Review Assignment', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
