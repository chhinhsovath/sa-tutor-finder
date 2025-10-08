class Counselor {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? specialization;
  final String status;
  final DateTime createdAt;

  Counselor({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.specialization,
    required this.status,
    required this.createdAt,
  });

  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      specialization: json['specialization'],
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'specialization': specialization,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
