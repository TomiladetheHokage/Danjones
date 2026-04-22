import 'dart:math';

/// Model for a crypto asset (token) with price and chart data.
class CryptoAsset {
  final String symbol;
  final String name;
  final double price;
  final double priceChangePercent;
  final List<double> sparklineData;
  final bool isPositive;
  final String? imagePath;
  final double marketCap;
  final double circulatingSupply;
  final double maxSupply;

  const CryptoAsset({
    required this.symbol,
    required this.name,
    required this.price,
    required this.priceChangePercent,
    required this.sparklineData,
    this.imagePath,
    this.marketCap = 0.0,
    this.circulatingSupply = 0.0,
    this.maxSupply = 0.0,
  }) : isPositive = priceChangePercent >= 0;

  factory CryptoAsset.fromJson(Map<String, dynamic> json) {
    List<double> sparklineData = [];
    if (json['sparkline_in_7d'] != null && json['sparkline_in_7d']['price'] != null) {
      sparklineData = List<double>.from(json['sparkline_in_7d']['price'].map((e) => (e as num).toDouble()));
    }
    
    // In case sparkline is empty or missing, provide dummy data to prevent rendering issues
    if (sparklineData.isEmpty) {
      sparklineData = [0.0, 0.0];
    }
    
    final priceChange = (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0;
    
    return CryptoAsset(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      priceChangePercent: priceChange,
      sparklineData: sparklineData,
      imagePath: json['image'],
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply: (json['circulating_supply'] as num?)?.toDouble() ?? 0.0,
      maxSupply: (json['max_supply'] as num?)?.toDouble() ?? (json['total_supply'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String _formatPrice(double p) {
    final s = p.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '\$$intPart.${parts[1]}';
  }

  String get formattedPrice => _formatPrice(price);
  String get changeText => '${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(1)}%';

  String get formattedMarketCap => _formatCompactValue(marketCap);
  String get formattedCirculatingSupply => _formatCompactValue(circulatingSupply);
  String get formattedMaxSupply => maxSupply > 0 ? _formatCompactValue(maxSupply) : '∞';

  static String _formatCompactValue(double value) {
    if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '\$${(value / 1e3).toStringAsFixed(2)}K';
    return value.toStringAsFixed(2);
  }
}

/// Mock data for Home and Market screens.
class MockCrypto {
  static const totalEquityNgn = 12450200.50;
  static const equityChangeNgn = 25000.0;
  static const equityChangePercent = 2.4;

  // Generate realistic 20-point trend data with random values (like home screen)
  static List<double> _generateUpTrend() {
    final random = Random();
    return List.generate(20, (i) => 50.0 + random.nextDouble() * 50);
  }

  static List<double> _generateDownTrend() {
    final random = Random();
    return List.generate(20, (i) => 40.0 + random.nextDouble() * 60);
  }

  static final List<double> _upTrend = _generateUpTrend();
  static final List<double> _downTrend = _generateDownTrend();

  static List<CryptoAsset> get topMovers => [
        CryptoAsset(
          symbol: 'BTC',
          name: 'Bitcoin',
          price: 160000,
          priceChangePercent: 4.5,
          sparklineData: _upTrend,
          imagePath: 'icons/BTC.png',
          marketCap: 1200000000000,
          circulatingSupply: 19500000,
          maxSupply: 21000000,
        ),
        CryptoAsset(
          symbol: 'ETH',
          name: 'Ethereum',
          price: 160000,
          priceChangePercent: 4.5,
          sparklineData: _upTrend,
          imagePath: 'icons/ETH.png',
        ),
        CryptoAsset(symbol: 'MATIC', name: 'Polygon', price: 0.85, priceChangePercent: 2.1, sparklineData: _upTrend, imagePath: 'icons/MATIC.png'),
        CryptoAsset(symbol: 'XRP', name: 'Ripple', price: 0.52, priceChangePercent: -1.2, sparklineData: _downTrend, imagePath: 'icons/XRP.png'),
        CryptoAsset(symbol: 'UNI', name: 'Uniswap', price: 6.2, priceChangePercent: 0.5, sparklineData: _upTrend, imagePath: 'icons/UNI.png'),
      ];

  static List<CryptoAsset> get topLosers => [
        CryptoAsset(
          symbol: 'FTT',
          name: 'FTX',
          price: 160000,
          priceChangePercent: -4.5,
          sparklineData: _downTrend,
        ),
        CryptoAsset(
          symbol: 'SOL',
          name: 'Solana',
          price: 98000,
          priceChangePercent: -2.1,
          sparklineData: _downTrend,
        ),
      ];

  static List<CryptoAsset> get tokens => [
        CryptoAsset(
          symbol: 'BTC',
          name: 'Bitcoin',
          price: 12.09,
          priceChangePercent: 0.68,
          sparklineData: _upTrend,
        ),
        CryptoAsset(
          symbol: 'ETH',
          name: 'Ethereum',
          price: 3200.5,
          priceChangePercent: 1.2,
          sparklineData: _upTrend,
        ),
        CryptoAsset(
          symbol: 'BNB',
          name: 'Binance',
          price: 580.2,
          priceChangePercent: -0.3,
          sparklineData: _downTrend,
        ),
      ];

  static List<CryptoAsset> get marketList => [
        CryptoAsset(symbol: 'BTC', name: 'Bitcoin', price: 12.09, priceChangePercent: 0.68, sparklineData: _upTrend),
        CryptoAsset(symbol: 'ETH', name: 'Ethereum', price: 3200.5, priceChangePercent: 1.2, sparklineData: _upTrend),
        CryptoAsset(symbol: 'BNB', name: 'Binance', price: 580.2, priceChangePercent: -0.3, sparklineData: _downTrend),
        CryptoAsset(symbol: 'MATIC', name: 'Polygon', price: 0.85, priceChangePercent: 2.1, sparklineData: _upTrend),
        CryptoAsset(symbol: 'XRP', name: 'Ripple', price: 0.52, priceChangePercent: -1.2, sparklineData: _downTrend),
        CryptoAsset(symbol: 'USDT', name: 'Tether', price: 1.0, priceChangePercent: 0.0, sparklineData: _upTrend),
        CryptoAsset(symbol: 'UNI', name: 'Uniswap', price: 6.2, priceChangePercent: 0.5, sparklineData: _upTrend),
        CryptoAsset(symbol: 'ADA', name: 'Cardano', price: 0.48, priceChangePercent: -0.8, sparklineData: _downTrend),
      ];

  static List<CryptoAsset> get newList => [
        CryptoAsset(symbol: 'BTC', name: 'Bitcoin', price: 160000, priceChangePercent: 4.5, sparklineData: _upTrend),
        CryptoAsset(symbol: 'FTT', name: 'FTX', price: 160000, priceChangePercent: -4.5, sparklineData: _downTrend),
        CryptoAsset(symbol: 'MATIC', name: 'Polygon', price: 0.85, priceChangePercent: 2.1, sparklineData: _upTrend),
        CryptoAsset(symbol: 'XRP', name: 'Ripple', price: 0.52, priceChangePercent: -1.2, sparklineData: _downTrend),
        CryptoAsset(symbol: 'UNI', name: 'Uniswap', price: 6.2, priceChangePercent: 0.5, sparklineData: _upTrend),
      ];

  static List<CryptoAsset> get topAssets => [
        CryptoAsset(symbol: 'BTC', name: 'Bitcoin', price: 12.09, priceChangePercent: 0.68, sparklineData: _upTrend),
        CryptoAsset(symbol: 'ETH', name: 'Ethereum', price: 3200.5, priceChangePercent: 1.2, sparklineData: _upTrend),
        CryptoAsset(symbol: 'MATIC', name: 'Polygon', price: 0.85, priceChangePercent: 2.1, sparklineData: _upTrend),
        CryptoAsset(symbol: 'XRP', name: 'Ripple', price: 0.52, priceChangePercent: -1.2, sparklineData: _downTrend),
        CryptoAsset(symbol: 'UNI', name: 'Uniswap', price: 6.2, priceChangePercent: 0.5, sparklineData: _upTrend),
      ];
}
