import 'currency.dart';

class Wallet {
  final int id;
  final String address;
  final String balance;
  final num balanceUsd;
  final String status;
  final int currencyId;
  final Currency currency;

  Wallet({
    required this.id,
    required this.address,
    required this.balance,
    required this.balanceUsd,
    required this.status,
    required this.currencyId,
    required this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? 0,
      address: json['address'] ?? '',
      balance: json['balance']?.toString() ?? '0.00',
      balanceUsd: json['balance_usd'] ?? 0,
      status: json['status'] ?? '',
      currencyId: json['currency_id'] ?? 0,
      currency: Currency.fromJson(json['currency'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'balance': balance,
      'balance_usd': balanceUsd,
      'status': status,
      'currency_id': currencyId,
      'currency': {
        'id': currency.id,
        'name': currency.name,
        'symbol': currency.symbol,
        'image': currency.imagePath,
        'decimal_places': currency.decimalPlaces,
        'is_crypto': currency.isCrypto ? 1 : 0,
        'is_active': currency.isActive ? 1 : 0,
      },
    };
  }
}
