class Worker {
  final int id;
  final String name;
  final String workerId;
  final String role;
  final bool isActive;
  final int boxId;

  Worker({
    required this.id,
    required this.name,
    required this.workerId,
    required this.role,
    required this.isActive,
    required this.boxId,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      workerId: json['worker_id'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
      boxId: json['box_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'worker_id': workerId,
      'role': role,
      'is_active': isActive,
      'box_id': boxId,
    };
  }
}
