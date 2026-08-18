class Assignment {
  final int id;
  final int workerId;
  final int machineId;
  final DateTime assignedAt;
  final DateTime? returnedAt;
  final String status;
  final String location;
  
  // These are often joined in AssignmentDetailResponse
  final String? workerName;
  final String? machineName;
  final String? assignedByName;
  final String? returnedByName;

  Assignment({
    required this.id,
    required this.workerId,
    required this.machineId,
    required this.assignedAt,
    this.returnedAt,
    required this.status,
    required this.location,
    this.workerName,
    this.machineName,
    this.assignedByName,
    this.returnedByName,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    // Parse UTC datetime safely and convert to local
    DateTime parseDate(String dateStr) {
      // If the backend sends naive UTC without 'Z', append 'Z' to ensure correct parsing
      if (!dateStr.endsWith('Z')) {
        dateStr = '${dateStr}Z';
      }
      return DateTime.parse(dateStr).toLocal();
    }

    return Assignment(
      id: json['id'],
      workerId: json['worker_id'],
      machineId: json['machine_id'],
      assignedAt: parseDate(json['assigned_at']),
      returnedAt: json['returned_at'] != null ? parseDate(json['returned_at']) : null,
      status: json['status'],
      location: json['location'] ?? 'On Site',
      workerName: json['worker_name'],
      machineName: json['machine_name'],
      assignedByName: json['assigned_by_name'],
      returnedByName: json['returned_by_name'],
    );
  }
}
