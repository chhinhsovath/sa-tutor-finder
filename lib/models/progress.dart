class StudentProgress {
  final String studentId;
  final String studentName;
  final String currentLevel;
  final int totalSessions;
  final int completedSessions;
  final double averageRating;
  final int totalHours;
  final List<String> recentTopics;
  final Map<String, dynamic>? levelProgress;

  StudentProgress({
    required this.studentId,
    required this.studentName,
    required this.currentLevel,
    required this.totalSessions,
    required this.completedSessions,
    required this.averageRating,
    required this.totalHours,
    required this.recentTopics,
    this.levelProgress,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    return StudentProgress(
      studentId: json['student_id'],
      studentName: json['student_name'],
      currentLevel: json['current_level'] ?? 'A1',
      totalSessions: json['total_sessions'] ?? 0,
      completedSessions: json['completed_sessions'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalHours: json['total_hours'] ?? 0,
      recentTopics: (json['recent_topics'] as List?)?.map((e) => e.toString()).toList() ?? [],
      levelProgress: json['level_progress'],
    );
  }

  double get completionPercentage {
    if (totalSessions == 0) return 0.0;
    return (completedSessions / totalSessions).clamp(0.0, 1.0);
  }
}
