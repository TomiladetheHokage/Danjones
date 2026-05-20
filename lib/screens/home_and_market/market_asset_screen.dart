import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/crypto_asset.dart';
import '../../models/wallet.dart';
import '../../services/crypto_service.dart';
import '../../services/data_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/interactive_chart/candle_data.dart';
import '../../widgets/interactive_chart/chart_style.dart';
import '../../widgets/interactive_chart/interactive_chart.dart';

class MarketAssetScreen extends StatefulWidget {
  final CryptoAsset asset;
  const MarketAssetScreen({super.key, required this.asset});

  @override
  State<MarketAssetScreen> createState() => _MarketAssetScreenState();
}

class _MarketAssetScreenState extends State<MarketAssetScreen> {
  // ── Timeframe config ──────────────────────────────────────────────────────
  static const List<String> _timeframes = ['1m', '5m', '15m', '1h', '1d'];

  /// Maps each UI timeframe label to the CoinGecko `days` parameter.
  /// CoinGecko OHLC granularity: days=1 → 30-min, days=7/30 → 4-hour candles.
  static const Map<String, int> _tfToDays = {
    '1m': 1,
    '5m': 1,
    '15m': 1,
    '1h': 7,
    '1d': 30,
  };

  String _selectedTimeframe = '1h';

  // ── Chart state ───────────────────────────────────────────────────────────
  List<CandleData>? _candles;
  bool _chartLoading = false;
  String? _chartError;

  // ── Market info state ─────────────────────────────────────────────────────
  double _marketCap = 0;
  double _circulatingSupply = 0;
  double _maxSupply = 0;
  double _livePrice = 0;
  double _livePriceChange = 0;
  bool _infoLoading = false;

  // ── Wallet balance ────────────────────────────────────────────────────────
  Wallet? _wallet;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Seed from the passed asset so the screen isn't blank while loading
    _marketCap = widget.asset.marketCap;
    _circulatingSupply = widget.asset.circulatingSupply;
    _maxSupply = widget.asset.maxSupply;
    _livePrice = widget.asset.price;
    _livePriceChange = widget.asset.priceChangePercent;

    _resolveWallet();
    _loadChart();
    _loadMarketDetail();
  }

  // ── Balance ───────────────────────────────────────────────────────────────
  void _resolveWallet() {
    final wallets = DataStore.instance.dashboard.value?.wallets ?? [];
    final match = wallets.cast<Wallet?>().firstWhere(
      (w) =>
          w!.currency.symbol.toLowerCase() ==
          widget.asset.symbol.toLowerCase(),
      orElse: () => null,
    );
    setState(() => _wallet = match);
  }

  String get _balanceCrypto {
    if (_wallet == null) return '0.00 ${widget.asset.symbol.toUpperCase()}';
    return '${_wallet!.balance} ${widget.asset.symbol.toUpperCase()}';
  }

  String get _balanceUsd {
    if (_wallet == null) return '\$0.00';
    return '\$${_wallet!.balanceUsd.toDouble().toStringAsFixed(2)}';
  }

  // ── Chart loading ─────────────────────────────────────────────────────────
  Future<void> _loadChart() async {
    if (_chartLoading) return;
    setState(() {
      _chartLoading = true;
      _chartError = null;
    });

    try {
      final days = _tfToDays[_selectedTimeframe] ?? 7;
      final candles = await CryptoService.fetchOhlcCandles(
        symbol: widget.asset.symbol,
        days: days,
      );
      if (!mounted) return;
      setState(() => _candles = candles);
    } catch (e) {
      if (!mounted) return;
      setState(() =>
          _chartError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _chartLoading = false);
    }
  }

  // ── Market detail loading ─────────────────────────────────────────────────
  Future<void> _loadMarketDetail() async {
    setState(() => _infoLoading = true);
    try {
      final detail = await CryptoService.fetchCoinMarketDetail(
        symbol: widget.asset.symbol,
      );
      if (!mounted) return;
      setState(() {
        _marketCap = detail['market_cap'] ?? _marketCap;
        _circulatingSupply =
            detail['circulating_supply'] ?? _circulatingSupply;
        _maxSupply = detail['max_supply'] ?? _maxSupply;
        _livePrice = detail['current_price'] ?? _livePrice;
        _livePriceChange = detail['price_change_24h'] ?? _livePriceChange;
      });
    } catch (_) {
      // Silently fall back to values seeded from the asset
    } finally {
      if (mounted) setState(() => _infoLoading = false);
    }
  }

  // ── Timeframe tap ─────────────────────────────────────────────────────────
  void _onTimeframeTap(String tf) {
    if (tf == _selectedTimeframe) return;
    setState(() {
      _selectedTimeframe = tf;
      _candles = null;
    });
    _loadChart();
  }

  // ── Formatting helpers ────────────────────────────────────────────────────
  bool get _isPositive => _livePriceChange >= 0;

  String get _formattedPrice {
    final s = _livePrice.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '\$$intPart.${parts[1]}';
  }

  String get _changeText =>
      '${_isPositive ? '+' : ''}${_livePriceChange.toStringAsFixed(1)}%';

  static String _compact(double value) {
    if (value <= 0) return '--';
    if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '\$${(value / 1e3).toStringAsFixed(2)}K';
    return value.toStringAsFixed(2);
  }

  static String _compactNoSign(double value) {
    if (value <= 0) return '--';
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    return value.toStringAsFixed(2);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPriceHeaderRow(),
                  _buildChartSection(),
                  _buildHoldingSection(),
                  _buildInfoSection(),
                  _buildTradeButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          Text(
            widget.asset.symbol.toUpperCase(),
            style: AppTheme.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Price row ─────────────────────────────────────────────────────────────
  Widget _buildPriceHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formattedPrice,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              Text(
                _changeText,
                style: TextStyle(
                  fontSize: 14,
                  color: _isPositive
                      ? const Color(0xFF52D377)
                      : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.star_outline,
                color: Colors.white.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chart section ─────────────────────────────────────────────────────────
  Widget _buildChartSection() {
    return Column(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: _buildChartBody(),
        ),
        const SizedBox(height: 8),
        _buildTimeframeControls(),
      ],
    );
  }

  Widget _buildChartBody() {
    if (_chartLoading && (_candles == null || _candles!.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFE4B53E),
        ),
      );
    }

    if (_chartError != null && (_candles == null || _candles!.isEmpty)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 32),
              const SizedBox(height: 8),
              Text(
                _chartError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _loadChart,
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Color(0xFFE4B53E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final candles = _candles;
    if (candles == null || candles.length < 3) {
      return const Center(
        child: Text('No chart data', style: TextStyle(color: Colors.white24)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InteractiveChart(
        candles: candles,
        initialVisibleCandleCount: 30,
        timeLabel: (timestamp, visibleDataCount) => '',
        style: ChartStyle(
          timeLabelHeight: 0,
          volumeHeightFactor: 0.0,
          priceGridLineColor: Colors.white.withValues(alpha: 0.04),
          priceLabelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
          ),
          timeLabelStyle: const TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
        ),
      ),
    );
  }

  // ── Timeframe buttons ─────────────────────────────────────────────────────
  Widget _buildTimeframeControls() {
    return Column(
      children: [
        Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ..._timeframes.map((tf) {
                  final isSelected = _selectedTimeframe == tf;
                  return GestureDetector(
                    onTap: () => _onTimeframeTap(tf),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E1F25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tf,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
                // Spinner while fetching, icon otherwise
                SizedBox(
                  width: 44,
                  height: 28,
                  child: Center(
                    child: _chartLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFFE4B53E),
                            ),
                          )
                        : Icon(
                            Icons.crop_free,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 16,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Holding / balance section ─────────────────────────────────────────────
  Widget _buildHoldingSection() {
    const fafaColor = Color(0xFFFAFAFA);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              color: fafaColor,
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _balanceCrypto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _balanceUsd,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAssetIcon(widget.asset.imagePath, widget.asset.symbol),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.asset.symbol.toUpperCase(),
                    style: const TextStyle(
                      color: fafaColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.asset.name,
                    style: TextStyle(
                      color: fafaColor.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formattedPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '($_changeText)',
                    style: TextStyle(
                      color: _isPositive
                          ? const Color(0xFF52D377)
                          : const Color(0xFFEF4444),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info section ──────────────────────────────────────────────────────────
  Widget _buildInfoSection() {
    const fafaColor = Color(0xFFFAFAFA);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Info',
                style: TextStyle(
                  color: fafaColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_infoLoading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFFE4B53E),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _infoRow('Market Cap', _compact(_marketCap), fafaColor),
          _infoRow(
            'Circulating Supply',
            _circulatingSupply > 0
                ? '${_compactNoSign(_circulatingSupply)} ${widget.asset.symbol.toUpperCase()}'
                : '--',
            fafaColor,
          ),
          _infoRow(
            'Max Supply',
            _maxSupply > 0
                ? '${_compactNoSign(_maxSupply)} ${widget.asset.symbol.toUpperCase()}'
                : '∞',
            fafaColor,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Trade button ──────────────────────────────────────────────────────────
  Widget _buildTradeButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFE4B53E),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            'Trade',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // ── Asset icon ────────────────────────────────────────────────────────────
  Widget _buildAssetIcon(String? imagePath, String symbol) {
    if (imagePath != null && imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFE4B53E),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.monetization_on, color: Colors.white24, size: 44),
      );
    }
    return Image.asset(
      'assets/icons/${symbol.toUpperCase()}.png',
      width: 44,
      height: 44,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.monetization_on, color: Colors.white24, size: 44),
    );
  }
}
