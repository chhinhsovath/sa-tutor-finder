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

  // Location fields for proximity search
  final String? homeAddress;
  final double? homeLatitude;
  final double? homeLongitude;
  final String? schoolAddress;
  final double? schoolLatitude;
  final double? schoolLongitude;

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
    this.homeAddress,
    this.homeLatitude,
    this.homeLongitude,
    this.schoolAddress,
    this.schoolLatitude,
    this.schoolLongitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      englishLevel: json['english_level'] ?? 'A1',
      learningGoals: json['learning_goals'],
      timezone: json['timezone'] ?? 'Asia/Phnom_Penh',
      status: json['status'] ?? 'active',
      totalSessions: json['total_sessions'] ?? 0,
      homeAddress: json['home_address'],
      homeLatitude: json['home_latitude'] != null
          ? double.tryParse(json['home_latitude'].toString())
          : null,
      homeLongitude: json['home_longitude'] != null
          ? double.tryParse(json['home_longitude'].toString())
          : null,
      schoolAddress: json['school_address'],
      schoolLatitude: json['school_latitude'] != null
          ? double.tryParse(json['school_latitude'].toString())
          : null,
      schoolLongitude: json['school_longitude'] != null
          ? double.tryParse(json['school_longitude'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
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
      if (homeAddress != null) 'home_address': homeAddress,
      if (homeLatitude != null) 'home_latitude': homeLatitude,
      if (homeLongitude != null) 'home_longitude': homeLongitude,
      if (schoolAddress != null) 'school_address': schoolAddress,
      if (schoolLatitude != null) 'school_latitude': schoolLatitude,
      if (schoolLongitude != null) 'school_longitude': schoolLongitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
