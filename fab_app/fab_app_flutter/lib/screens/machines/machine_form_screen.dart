import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/machine.dart';
import '../../providers/machine_provider.dart';
import '../../services/machine_service.dart';

class MachineFormScreen extends ConsumerStatefulWidget {
  final Machine? machine;

  const MachineFormScreen({super.key, this.machine});

  @override
  ConsumerState<MachineFormScreen> createState() => _MachineFormScreenState();
}

class _MachineFormScreenState extends ConsumerState<MachineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _machineNumberController;
  late final TextEditingController _categoryController;
  late final TextEditingController _remarksController;
  String _status = 'Available';
  bool _isActive = true;

  final List<String> _statusOptions = ['Available', 'Assigned', 'Under Repair'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.machine?.name ?? '');
    _machineNumberController = TextEditingController(text: widget.machine?.machineNumber ?? '');
    _categoryController = TextEditingController(text: widget.machine?.category ?? '');
    _remarksController = TextEditingController(text: widget.machine?.remarks ?? '');
    _status = widget.machine?.status ?? 'Available';
    _isActive = widget.machine?.isActive ?? true;

    // Ensure status is valid
    if (!_statusOptions.contains(_status)) {
      _status = 'Available';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _machineNumberController.dispose();
    _categoryController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'machine_number': _machineNumberController.text.trim(),
      'category': _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      'status': _status,
      'remarks': _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      'is_active': _isActive,
    };

    try {
      if (widget.machine == null) {
        await ref.read(machineServiceProvider).createMachine(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Machine added successfully.')),
          );
        }
      } else {
        await ref.read(machineServiceProvider).updateMachine(widget.machine!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Machine updated successfully.')),
          );
        }
      }
      
      ref.invalidate(machinesProvider);
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
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.machine != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Machine' : 'Add Machine'),
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
                  prefixIcon: Icon(Icons.build),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _machineNumberController,
                decoration: const InputDecoration(
                  labelText: 'Machine Number (e.g. M-001)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: _isLoading ? null : (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
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
                    : Text(isEdit ? 'Save Changes' : 'Add Machine', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
