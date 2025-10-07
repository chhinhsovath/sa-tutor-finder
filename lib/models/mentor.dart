class Mentor {
  final String id;
  final String name;
  final String email;
  final String english_level;
  final String? contact;
  final String timezone;
  final String status;
  final String? userType; // User role: student, mentor, counselor, admin
  final DateTime created_at;
  final DateTime updated_at;
  final List<AvailabilitySlot>? availability_slots;

  Mentor({
    required this.id,
    required this.name,
    required this.email,
    required this.english_level,
    this.contact,
    required this.timezone,
    required this.status,
    this.userType,
    required this.created_at,
    required this.updated_at,
    this.availability_slots,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      english_level: json['english_level'] ?? 'A1', // Default for non-mentors
      contact: json['contact'],
      timezone: json['timezone'],
      status: json['status'],
      userType: json['user_type'], // Parse user_type from API
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
      availability_slots: json['availability_slots'] != null
          ? (json['availability_slots'] as List)
              .map((slot) => AvailabilitySlot.fromJson(slot))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'english_level': english_level,
      'contact': contact,
      'timezone': timezone,
      'status': status,
      if (userType != null) 'user_type': userType,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      if (availability_slots != null)
        'availability_slots': availability_slots!.map((s) => s.toJson()).toList(),
    };
  }
}

class AvailabilitySlot {
  final String id;
  final int day_of_week;
  final String start_time;
  final String end_time;

  AvailabilitySlot({
    required this.id,
    required this.day_of_week,
    required this.start_time,
    required this.end_time,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'],
      day_of_week: json['day_of_week'],
      start_time: json['start_time'],
      end_time: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': day_of_week,
      'start_time': start_time,
      'end_time': end_time,
    };
  }

  String get dayName {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day_of_week];
  }
}
