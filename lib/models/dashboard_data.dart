import 'user_profile.dart';
import 'wallet.dart';

class DashboardData {
  final UserProfile user;
  final List<Wallet> wallets;
  final num totalBalanceUsd;
  final num totalBalanceNgn;

  DashboardData({
    required this.user,
    required this.wallets,
    required this.totalBalanceUsd,
    required this.totalBalanceNgn,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    var data = json['data'] ?? json;
    
    return DashboardData(
      user: UserProfile.fromJson(data['user'] ?? {}),
      wallets: (data['wallets'] as List? ?? [])
          .map((w) => Wallet.fromJson(w))
          .toList(),
      totalBalanceUsd: data['total_balance_usd'] ?? 0,
      totalBalanceNgn: data['total_balance_ngn'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'username': user.username,
        'phone': user.phone,
        'avatar': user.avatar,
        'has_pin': user.hasPin,
        'email_verified_at': user.emailVerifiedAt,
        'phone_verified_at': user.phoneVerifiedAt,
        'created_at': user.createdAt,
      },
      'wallets': wallets.map((w) => w.toJson()).toList(),
      'total_balance_usd': totalBalanceUsd,
      'total_balance_ngn': totalBalanceNgn,
    };
  }
}
