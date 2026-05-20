import '../services/api_service.dart';

class P2PAd {
  final int id;
  final int userId;
  final String type; // "buy" or "sell"
  final double price;
  final double totalAmount;
  final double availableAmount;
  final double minLimit;
  final double maxLimit;
  final String terms;
  final bool isActive;

  // Nested user fields
  final String userName;
  final String? userAvatar;

  // Nested currency fields
  final String currencyName;
  final String currencySymbol;
  final String currencyImage;

  P2PAd({
    required this.id,
    required this.userId,
    required this.type,
    required this.price,
    required this.totalAmount,
    required this.availableAmount,
    required this.minLimit,
    required this.maxLimit,
    required this.terms,
    required this.isActive,
    required this.userName,
    this.userAvatar,
    required this.currencyName,
    required this.currencySymbol,
    required this.currencyImage,
  });

  factory P2PAd.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final currency = json['currency'] as Map<String, dynamic>? ?? {};

    return P2PAd(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? 'sell',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      availableAmount: (json['available_amount'] as num?)?.toDouble() ?? 0.0,
      minLimit: (json['min_limit'] as num?)?.toDouble() ?? 0.0,
      maxLimit: (json['max_limit'] as num?)?.toDouble() ?? 0.0,
      terms: json['terms'] ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      userName: user['name'] ?? 'Unknown',
      userAvatar: user['avatar'] as String?,
      currencyName: currency['name'] ?? '',
      currencySymbol: currency['symbol'] ?? '',
      currencyImage: currency['image'] ?? '',
    );
  }

  /// Full URL for the currency image
  String get currencyImageUrl {
    if (currencyImage.startsWith('http')) return currencyImage;
    final clean = currencyImage.startsWith('/') ? currencyImage.substring(1) : currencyImage;
    return '${ApiService.rootUrl}/$clean';
  }
}
