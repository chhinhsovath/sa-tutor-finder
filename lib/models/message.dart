class Message {
  final String id;
  final String senderId;
  final String senderType;
  final String recipientId;
  final String recipientType;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  // Optional populated fields
  final String? senderName;

  Message({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.recipientId,
    required this.recipientType,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      senderType: json['sender_type'],
      recipientId: json['recipient_id'],
      recipientType: json['recipient_type'],
      content: json['content'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_type': senderType,
      'recipient_id': recipientId,
      'recipient_type': recipientType,
      'content': content,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
