import '../services/api_service.dart';

class Currency {
  final int id;
  final String name;
  final String symbol;
  final String imagePath;
  final int decimalPlaces;
  final bool isCrypto;
  final bool isActive;

  Currency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.imagePath,
    required this.decimalPlaces,
    required this.isCrypto,
    required this.isActive,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      imagePath: json['image'] ?? '',
      decimalPlaces: json['decimal_places'] ?? 2,
      isCrypto: (json['is_crypto'] == 1 || json['is_crypto'] == true),
      isActive: (json['is_active'] == 1 || json['is_active'] == true),
    );
  }

  /// Returns the full URL for the currency image
  String get fullImageUrl {
    if (imagePath.startsWith('http')) return imagePath;
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    // Use the dynamic rootUrl which handles the local proxy during development
    return '${ApiService.rootUrl}/$cleanPath';
  }
}
