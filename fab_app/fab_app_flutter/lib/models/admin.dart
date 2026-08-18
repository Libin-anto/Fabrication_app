class Admin {
  final int id;
  final String username;
  final String? name;
  final String? role;

  Admin({
    required this.id,
    required this.username,
    this.name,
    this.role,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
    };
  }
}
