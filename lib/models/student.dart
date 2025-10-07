class Student {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String englishLevel;
  final String? learningGoals;
  final String timezone;
  final String status;
  final int totalSessions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.englishLevel,
    this.learningGoals,
    required this.timezone,
    required this.status,
    required this.totalSessions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      englishLevel: json['english_level'] ?? 'A1',
      learningGoals: json['learning_goals'],
      timezone: json['timezone'] ?? 'Asia/Phnom_Penh',
      status: json['status'] ?? 'active',
      totalSessions: json['total_sessions'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      'english_level': englishLevel,
      if (learningGoals != null) 'learning_goals': learningGoals,
      'timezone': timezone,
      'status': status,
      'total_sessions': totalSessions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
