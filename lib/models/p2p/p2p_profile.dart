class P2PTraderProfile {
  final int id;
  final String name;
  final String initials;
  final String? avatar;
  final String kycStatus;
  final DateTime? joinedAt;

  // Statistics
  final int totalTrades;
  final int totalCompleted;
  final double completionRate;
  final double avgTransactionTimeSeconds;
  final String avgTransactionTimeFormatted;

  // Bank accounts
  final List<P2PBankAccount> bankAccounts;

  P2PTraderProfile({
    required this.id,
    required this.name,
    required this.initials,
    this.avatar,
    required this.kycStatus,
    this.joinedAt,
    required this.totalTrades,
    required this.totalCompleted,
    required this.completionRate,
    required this.avgTransactionTimeSeconds,
    required this.avgTransactionTimeFormatted,
    required this.bankAccounts,
  });

  bool get isVerified => kycStatus.toLowerCase() == 'approved';

  factory P2PTraderProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final stats = json['statistics'] as Map<String, dynamic>? ?? {};
    final accounts = (json['bank_accounts'] as List<dynamic>? ?? [])
        .map((e) => P2PBankAccount.fromJson(e as Map<String, dynamic>))
        .toList();

    return P2PTraderProfile(
      id: (user['id'] as num?)?.toInt() ?? 0,
      name: (user['name'] ?? '').toString(),
      initials: (user['initials'] ?? '').toString(),
      avatar: user['avatar'] as String?,
      kycStatus: (user['kyc_status'] ?? 'unverified').toString(),
      joinedAt: DateTime.tryParse((user['joined_at'] ?? '').toString()),
      totalTrades: (stats['total_trades'] as num?)?.toInt() ?? 0,
      totalCompleted: (stats['total_completed'] as num?)?.toInt() ?? 0,
      completionRate: (stats['completion_rate'] as num?)?.toDouble() ?? 0.0,
      avgTransactionTimeSeconds:
          (stats['avg_transaction_time_seconds'] as num?)?.toDouble() ?? 0.0,
      avgTransactionTimeFormatted:
          (stats['avg_transaction_time_formatted'] ?? '—').toString(),
      bankAccounts: accounts,
    );
  }
}

class P2PBankAccount {
  final int id;
  final String accountName;
  final String accountNumber;
  final bool isActive;
  final String bankName;
  final String bankCode;

  P2PBankAccount({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.isActive,
    required this.bankName,
    required this.bankCode,
  });

  factory P2PBankAccount.fromJson(Map<String, dynamic> json) {
    final bank = json['bank'] as Map<String, dynamic>? ?? {};
    return P2PBankAccount(
      id: (json['id'] as num?)?.toInt() ?? 0,
      accountName: (json['account_name'] ?? '').toString(),
      accountNumber: (json['account_number'] ?? '').toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      bankName: (bank['name'] ?? '').toString(),
      bankCode: (bank['code'] ?? '').toString(),
    );
  }
}
