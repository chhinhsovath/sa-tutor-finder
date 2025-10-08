class AdminAnalytics {
  final MentorStats mentors;
  final StudentStats students;
  final SessionStats sessions;
  final ReviewStats reviews;

  AdminAnalytics({
    required this.mentors,
    required this.students,
    required this.sessions,
    required this.reviews,
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    final data = json['analytics'];
    return AdminAnalytics(
      mentors: MentorStats.fromJson(data['mentors']),
      students: StudentStats.fromJson(data['students']),
      sessions: SessionStats.fromJson(data['sessions']),
      reviews: ReviewStats.fromJson(data['reviews']),
    );
  }

  int get totalUsers => mentors.total + students.total;
  int get activeUsers => mentors.active + students.active;
}

class MentorStats {
  final int total;
  final int active;

  MentorStats({required this.total, required this.active});

  factory MentorStats.fromJson(Map<String, dynamic> json) {
    return MentorStats(
      total: json['total'],
      active: json['active'],
    );
  }
}

class StudentStats {
  final int total;
  final int active;

  StudentStats({required this.total, required this.active});

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    return StudentStats(
      total: json['total'],
      active: json['active'],
    );
  }
}

class SessionStats {
  final int total;
  final int completed;
  final int pending;

  SessionStats({
    required this.total,
    required this.completed,
    required this.pending,
  });

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      total: json['total'],
      completed: json['completed'],
      pending: json['pending'],
    );
  }

  double get completionRate {
    if (total == 0) return 0.0;
    return (completed / total * 100);
  }
}

class ReviewStats {
  final int total;
  final double averageRating;

  ReviewStats({required this.total, required this.averageRating});

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      total: json['total'],
      averageRating: (json['average_rating'] ?? 0).toDouble(),
    );
  }
}
