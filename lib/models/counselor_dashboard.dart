class CounselorDashboard {
  final CounselorInfo counselor;
  final DashboardStatistics statistics;
  final List<RecentSession> recentSessions;
  final List<SupportTicket> recentTickets;
  final List<StudentNeedingAttention> studentsNeedingAttention;

  CounselorDashboard({
    required this.counselor,
    required this.statistics,
    required this.recentSessions,
    required this.recentTickets,
    required this.studentsNeedingAttention,
  });

  factory CounselorDashboard.fromJson(Map<String, dynamic> json) {
    final data = json['dashboard'];
    return CounselorDashboard(
      counselor: CounselorInfo.fromJson(data['counselor']),
      statistics: DashboardStatistics.fromJson(data['statistics']),
      recentSessions: (data['recent_sessions'] as List)
          .map((e) => RecentSession.fromJson(e))
          .toList(),
      recentTickets: (data['recent_tickets'] as List)
          .map((e) => SupportTicket.fromJson(e))
          .toList(),
      studentsNeedingAttention: (data['students_needing_attention'] as List)
          .map((e) => StudentNeedingAttention.fromJson(e))
          .toList(),
    );
  }
}

class CounselorInfo {
  final String name;
  final String? specialization;

  CounselorInfo({required this.name, this.specialization});

  factory CounselorInfo.fromJson(Map<String, dynamic> json) {
    return CounselorInfo(
      name: json['name'],
      specialization: json['specialization'],
    );
  }
}

class DashboardStatistics {
  final int totalStudents;
  final int totalMentors;
  final int totalSessions;
  final int activeSessions;
  final int completedSessions;
  final int pendingTickets;
  final int totalReviews;
  final double averageRating;

  DashboardStatistics({
    required this.totalStudents,
    required this.totalMentors,
    required this.totalSessions,
    required this.activeSessions,
    required this.completedSessions,
    required this.pendingTickets,
    required this.totalReviews,
    required this.averageRating,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      totalStudents: json['total_students'],
      totalMentors: json['total_mentors'],
      totalSessions: json['total_sessions'],
      activeSessions: json['active_sessions'],
      completedSessions: json['completed_sessions'],
      pendingTickets: json['pending_tickets'],
      totalReviews: json['total_reviews'],
      averageRating: (json['average_rating'] ?? 0).toDouble(),
    );
  }
}

class RecentSession {
  final String id;
  final String studentName;
  final String mentorName;
  final String sessionDate;
  final String status;
  final DateTime createdAt;

  RecentSession({
    required this.id,
    required this.studentName,
    required this.mentorName,
    required this.sessionDate,
    required this.status,
    required this.createdAt,
  });

  factory RecentSession.fromJson(Map<String, dynamic> json) {
    return RecentSession(
      id: json['id'],
      studentName: json['student_name'],
      mentorName: json['mentor_name'],
      sessionDate: json['session_date'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class SupportTicket {
  final String id;
  final String subject;
  final String status;
  final String priority;
  final String? category;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.priority,
    this.category,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      subject: json['subject'],
      status: json['status'],
      priority: json['priority'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class StudentNeedingAttention {
  final String id;
  final String name;
  final String email;
  final String englishLevel;
  final int totalSessions;
  final DateTime createdAt;

  StudentNeedingAttention({
    required this.id,
    required this.name,
    required this.email,
    required this.englishLevel,
    required this.totalSessions,
    required this.createdAt,
  });

  factory StudentNeedingAttention.fromJson(Map<String, dynamic> json) {
    return StudentNeedingAttention(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      englishLevel: json['english_level'],
      totalSessions: json['total_sessions'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
