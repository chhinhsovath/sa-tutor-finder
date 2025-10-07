class Session {
  final String id;
  final String studentId;
  final String mentorId;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String status;
  final String? notes;
  final String? cancellationReason;
  final String? mentorFeedback;
  final String? studentFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional populated fields
  final String? mentorName;
  final String? studentName;

  Session({
    required this.id,
    required this.studentId,
    required this.mentorId,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.notes,
    this.cancellationReason,
    this.mentorFeedback,
    this.studentFeedback,
    required this.createdAt,
    required this.updatedAt,
    this.mentorName,
    this.studentName,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      studentId: json['student_id'],
      mentorId: json['mentor_id'],
      sessionDate: DateTime.parse(json['session_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      durationMinutes: json['duration_minutes'],
      status: json['status'],
      notes: json['notes'],
      cancellationReason: json['cancellation_reason'],
      mentorFeedback: json['mentor_feedback'],
      studentFeedback: json['student_feedback'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      mentorName: json['mentor_name'],
      studentName: json['student_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'mentor_id': mentorId,
      'session_date': sessionDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'duration_minutes': durationMinutes,
      'status': status,
      if (notes != null) 'notes': notes,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      if (mentorFeedback != null) 'mentor_feedback': mentorFeedback,
      if (studentFeedback != null) 'student_feedback': studentFeedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      default:
        return status;
    }
  }
}
