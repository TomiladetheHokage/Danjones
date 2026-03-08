/// Model for a crypto asset (token) with price and chart data.
class CryptoAsset {
  final String symbol;
  final String name;
  final double price;
  final double priceChangePercent;
  final List<double> sparklineData;
  final bool isPositive;

  const CryptoAsset({
    required this.symbol,
    required this.name,
    required this.price,
    required this.priceChangePercent,
    required this.sparklineData,
  }) : isPositive = priceChangePercent >= 0;

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
}

/// Mock data for Home and Market screens.
class MockCrypto {
  static const totalEquityNgn = 12450200.50;
  static const equityChangeNgn = 25000.0;
  static const equityChangePercent = 2.4;

  static const List<double> _upTrend = [0.2, 0.5, 0.3, 0.7, 0.4, 0.9, 0.6, 1.0];
  static const List<double> _downTrend = [1.0, 0.7, 0.8, 0.5, 0.6, 0.3, 0.4, 0.2];

  static List<CryptoAsset> get topMovers => [
        CryptoAsset(
          symbol: 'BTC',
          name: 'Bitcoin',
          price: 160000,
          priceChangePercent: 4.5,
          sparklineData: _upTrend,
        ),
        CryptoAsset(
          symbol: 'ETH',
          name: 'Ethereum',
          price: 160000,
          priceChangePercent: 4.5,
          sparklineData: _upTrend,
        ),
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
        CryptoAsset(symbol: 'USDT', name: 'Tether', price: 1.0, priceChangePercent: 0.0, sparklineData: List.filled(8, 0.5)),
        CryptoAsset(symbol: 'UNI', name: 'Uniswap', price: 6.2, priceChangePercent: 0.5, sparklineData: _upTrend),
        CryptoAsset(symbol: 'ADA', name: 'Cardano', price: 0.48, priceChangePercent: -0.8, sparklineData: _downTrend),
      ];

  static List<CryptoAsset> get newList => [
        CryptoAsset(symbol: 'BTC', name: 'Bitcoin', price: 160000, priceChangePercent: 4.5, sparklineData: _upTrend),
        CryptoAsset(symbol: 'FTT', name: 'FTX', price: 160000, priceChangePercent: -4.5, sparklineData: _downTrend),
      ];

  static List<CryptoAsset> get topAssets => [
        CryptoAsset(symbol: 'BTC', name: 'Bitcoin', price: 12.09, priceChangePercent: 0.68, sparklineData: _upTrend),
        CryptoAsset(symbol: 'ETH', name: 'Ethereum', price: 3200.5, priceChangePercent: 1.2, sparklineData: _upTrend),
      ];
}
