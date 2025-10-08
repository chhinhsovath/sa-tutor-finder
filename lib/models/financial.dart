class TransactionSummary {
  final int totalTransactions;
  final int completedTransactions;
  final int pendingTransactions;
  final double totalRevenue;
  final double pendingRevenue;
  final double netRevenue;
  final double averageTransactionAmount;

  TransactionSummary({
    required this.totalTransactions,
    required this.completedTransactions,
    required this.pendingTransactions,
    required this.totalRevenue,
    required this.pendingRevenue,
    required this.netRevenue,
    required this.averageTransactionAmount,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'];
    return TransactionSummary(
      totalTransactions: summary['total_transactions'] ?? 0,
      completedTransactions: summary['completed_transactions'] ?? 0,
      pendingTransactions: summary['pending_transactions'] ?? 0,
      totalRevenue: (summary['total_revenue'] ?? 0).toDouble(),
      pendingRevenue: (summary['pending_revenue'] ?? 0).toDouble(),
      netRevenue: (summary['net_revenue'] ?? 0).toDouble(),
      averageTransactionAmount: (summary['average_transaction_amount'] ?? 0).toDouble(),
    );
  }
}

class Transaction {
  final String id;
  final String studentId;
  final String sessionId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? studentName;
  final String? mentorName;

  Transaction({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.studentName,
    this.mentorName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      studentId: json['student_id'],
      sessionId: json['session_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      studentName: json['student']?['name'],
      mentorName: json['session']?['mentor']?['name'],
    );
  }

  String get displayTitle {
    if (mentorName != null) {
      return 'Session with $mentorName';
    }
    return 'Session #${sessionId.substring(0, 8)}';
  }
}
