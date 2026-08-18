class Machine {
  final int id;
  final String machineId;
  final String machineNumber;
  final String name;
  final String? category;
  final String status;
  final String? remarks;
  final bool isActive;

  Machine({
    required this.id,
    required this.machineId,
    required this.machineNumber,
    required this.name,
    this.category,
    required this.status,
    this.remarks,
    required this.isActive,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      machineId: json['machine_id'],
      machineNumber: json['machine_number'],
      name: json['name'],
      category: json['category'],
      status: json['status'],
      remarks: json['remarks'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machine_id': machineId,
      'machine_number': machineNumber,
      'name': name,
      'category': category,
      'status': status,
      'remarks': remarks,
      'is_active': isActive,
    };
  }
}
