import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/worker.dart';
import '../../providers/worker_provider.dart';
import '../../services/worker_service.dart';

class WorkerFormScreen extends ConsumerStatefulWidget {
  final Worker? worker;

  const WorkerFormScreen({super.key, this.worker});

  @override
  ConsumerState<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends ConsumerState<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _workerIdController;
  late final TextEditingController _roleController;
  late final TextEditingController _boxIdController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.worker?.name ?? '');
    _workerIdController = TextEditingController(text: widget.worker?.workerId ?? '');
    _roleController = TextEditingController(text: widget.worker?.role ?? '');
    _boxIdController = TextEditingController(text: widget.worker?.boxId.toString() ?? '');
    _isActive = widget.worker?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workerIdController.dispose();
    _roleController.dispose();
    _boxIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'worker_id': _workerIdController.text.trim(),
      'role': _roleController.text.trim(),
      'box_id': int.tryParse(_boxIdController.text.trim()) ?? 0,
      'is_active': _isActive,
    };

    try {
      if (widget.worker == null) {
        await ref.read(workerServiceProvider).createWorker(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Worker added successfully.')),
          );
        }
      } else {
        await ref.read(workerServiceProvider).updateWorker(widget.worker!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Worker updated successfully.')),
          );
        }
      }
      
      ref.invalidate(workersProvider);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.worker != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Worker' : 'Add Worker'),
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workerIdController,
                decoration: const InputDecoration(
                  labelText: 'Worker ID (e.g. W-001)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _boxIdController,
                decoration: const InputDecoration(
                  labelText: 'Box ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required field';
                  if (int.tryParse(val) == null) return 'Must be a valid integer';
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: _isLoading ? null : (val) => setState(() => _isActive = val),
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
                    : Text(isEdit ? 'Save Changes' : 'Add Worker', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
