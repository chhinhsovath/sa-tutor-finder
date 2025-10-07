class AppNotification {
  final String id;
  final String userId;
  final String userType;
  final String type;
  final String title;
  final String content;
  final bool isRead;
  final String? relatedEntityId;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.userType,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    this.relatedEntityId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      userType: json['user_type'],
      type: json['type'],
      title: json['title'],
      content: json['content'],
      isRead: json['is_read'] ?? false,
      relatedEntityId: json['related_entity_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_type': userType,
      'type': type,
      'title': title,
      'content': content,
      'is_read': isRead,
      if (relatedEntityId != null) 'related_entity_id': relatedEntityId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
