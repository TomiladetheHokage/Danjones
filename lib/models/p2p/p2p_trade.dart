class P2PTrade {
  final int id;
  final int advertisementId;
  final int sellerId;
  final int buyerId;
  final int currencyId;
  final int? bankAccountId;
  final double cryptoAmount;
  final double fiatAmount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String adType;
  final double adPrice;
  final String adTerms;

  final String sellerName;
  final String? sellerAvatar;
  final String buyerName;
  final String? buyerAvatar;
  final String currencyName;
  final String currencySymbol;
  final String currencyImage;

  // Bank account details (from advertisement.bank_account or trade.bank_account)
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;

  P2PTrade({
    required this.id,
    required this.advertisementId,
    required this.sellerId,
    required this.buyerId,
    required this.currencyId,
    this.bankAccountId,
    required this.cryptoAmount,
    required this.fiatAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.adType,
    required this.adPrice,
    required this.adTerms,
    required this.sellerName,
    this.sellerAvatar,
    required this.buyerName,
    this.buyerAvatar,
    required this.currencyName,
    required this.currencySymbol,
    required this.currencyImage,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
  });

  factory P2PTrade.fromJson(Map<String, dynamic> json) {
    final advertisement = json['advertisement'] as Map<String, dynamic>? ?? {};
    final seller = json['seller'] as Map<String, dynamic>? ?? {};
    final buyer = json['buyer'] as Map<String, dynamic>? ?? {};
    final currency = json['currency'] as Map<String, dynamic>? ?? {};

    // Bank account can be at trade level or inside advertisement
    final bankAccount = (json['bank_account'] as Map<String, dynamic>?) ??
        (advertisement['bank_account'] as Map<String, dynamic>?);
    final bankData = bankAccount?['bank'] as Map<String, dynamic>?;

    return P2PTrade(
      id: (json['id'] as num?)?.toInt() ?? 0,
      advertisementId: (json['advertisement_id'] as num?)?.toInt() ?? 0,
      sellerId: (json['seller_id'] as num?)?.toInt() ?? 0,
      buyerId: (json['buyer_id'] as num?)?.toInt() ?? 0,
      currencyId: (json['currency_id'] as num?)?.toInt() ?? 0,
      bankAccountId: (json['bank_account_id'] as num?)?.toInt(),
      cryptoAmount: (json['crypto_amount'] as num?)?.toDouble() ?? 0,
      fiatAmount: (json['fiat_amount'] as num?)?.toDouble() ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      adType: (advertisement['type'] ?? '').toString(),
      adPrice: (advertisement['price'] as num?)?.toDouble() ?? 0,
      adTerms: (advertisement['terms'] ?? '').toString(),
      sellerName: (seller['name'] ?? 'Unknown Seller').toString(),
      sellerAvatar: seller['avatar'] as String?,
      buyerName: (buyer['name'] ?? 'Unknown Buyer').toString(),
      buyerAvatar: buyer['avatar'] as String?,
      currencyName: (currency['name'] ?? '').toString(),
      currencySymbol: (currency['symbol'] ?? '').toString(),
      currencyImage: (currency['image'] ?? '').toString(),
      bankName: bankData?['name']?.toString() ?? bankAccount?['bank_name']?.toString(),
      bankAccountNumber: bankAccount?['account_number']?.toString(),
      bankAccountName: bankAccount?['account_name']?.toString(),
    );
  }

  bool get isPending => !['completed', 'cancelled', 'disputed'].contains(status.toLowerCase());
}
