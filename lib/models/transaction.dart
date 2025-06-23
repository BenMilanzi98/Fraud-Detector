enum TransactionType { incoming, outgoing }
enum PaymentMethod { airtelMoney, tnmMpamba }
enum TransactionStatus { pending, completed, failed, suspicious }

class Transaction {
  final int? id;
  final int systemId;
  final String transactionId;
  final double amount;
  final String fromNumber;
  final String toNumber;
  final TransactionType type;
  final PaymentMethod method;
  final TransactionStatus status;
  final bool isSuspicious;
  final String? suspiciousReason;
  final DateTime timestamp;
  final DateTime createdAt;
  final String? description;

  Transaction({
    this.id,
    required this.systemId,
    required this.transactionId,
    required this.amount,
    required this.fromNumber,
    required this.toNumber,
    required this.type,
    required this.method,
    this.status = TransactionStatus.completed,
    this.isSuspicious = false,
    this.suspiciousReason,
    required this.timestamp,
    required this.createdAt,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'system_id': systemId,
      'transaction_id': transactionId,
      'amount': amount,
      'from_number': fromNumber,
      'to_number': toNumber,
      'type': type.name,
      'method': method.name,
      'status': status.name,
      'is_suspicious': isSuspicious ? 1 : 0,
      'suspicious_reason': suspiciousReason,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      systemId: map['system_id'],
      transactionId: map['transaction_id'],
      amount: map['amount'],
      fromNumber: map['from_number'],
      toNumber: map['to_number'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == map['method'],
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      isSuspicious: map['is_suspicious'] == 1,
      suspiciousReason: map['suspicious_reason'],
      timestamp: DateTime.parse(map['timestamp']),
      createdAt: DateTime.parse(map['created_at']),
      description: map['description'],
    );
  }

  Transaction copyWith({
    int? id,
    int? systemId,
    String? transactionId,
    double? amount,
    String? fromNumber,
    String? toNumber,
    TransactionType? type,
    PaymentMethod? method,
    TransactionStatus? status,
    bool? isSuspicious,
    String? suspiciousReason,
    DateTime? timestamp,
    DateTime? createdAt,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      systemId: systemId ?? this.systemId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      fromNumber: fromNumber ?? this.fromNumber,
      toNumber: toNumber ?? this.toNumber,
      type: type ?? this.type,
      method: method ?? this.method,
      status: status ?? this.status,
      isSuspicious: isSuspicious ?? this.isSuspicious,
      suspiciousReason: suspiciousReason ?? this.suspiciousReason,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  String get formattedAmount => 'MK ${amount.toStringAsFixed(2)}';
  
  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.airtelMoney:
        return 'Airtel Money';
      case PaymentMethod.tnmMpamba:
        return 'TNM Mpamba';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.incoming:
        return 'Incoming';
      case TransactionType.outgoing:
        return 'Outgoing';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.suspicious:
        return 'Suspicious';
    }
  }
} 