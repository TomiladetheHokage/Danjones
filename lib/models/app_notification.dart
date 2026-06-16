class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> metadata;
  final DateTime? readAt;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.metadata,
    this.readAt,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? const {}),
      readAt: json['read_at'] == null
          ? null
          : DateTime.tryParse(json['read_at'].toString()),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  bool get isUnread => readAt == null;

  int? get tradeId {
    final value = metadata['trade_id'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? get role {
    final value = metadata['role']?.toString();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}