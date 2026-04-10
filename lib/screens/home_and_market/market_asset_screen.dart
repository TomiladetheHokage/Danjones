import 'package:flutter/material.dart';
import '../../widgets/interactive_chart/interactive_chart.dart';
import '../../widgets/interactive_chart/candle_data.dart';
import '../../widgets/interactive_chart/chart_style.dart';
import 'package:intl/intl.dart';
import '../../models/crypto_asset.dart';
import '../../theme/app_theme.dart';
import 'dart:math' as math;

class MarketAssetScreen extends StatefulWidget {
  final CryptoAsset asset;
  const MarketAssetScreen({super.key, required this.asset});

  @override
  State<MarketAssetScreen> createState() => _MarketAssetScreenState();
}

class _MarketAssetScreenState extends State<MarketAssetScreen> {
  String _selectedTimeframe = '1h';

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
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
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

  Widget _buildPriceHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.asset.formattedPrice,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              Text(
                widget.asset.changeText,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.asset.isPositive ? const Color(0xFF52D377) : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.star_outline,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final List<CandleData> chartData = List.generate(widget.asset.sparklineData.length, (index) {
      double price = widget.asset.sparklineData[index];
      double openPrice = index > 0 ? widget.asset.sparklineData[index - 1] : price;
      
      return CandleData(
        timestamp: DateTime.now().subtract(Duration(hours: widget.asset.sparklineData.length - index)).millisecondsSinceEpoch,
        open: openPrice,
        close: price,
        high: math.max(openPrice, price) * 1.001,
        low: math.min(openPrice, price) * 0.999,
        volume: 0,
      );
    });

    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InteractiveChart(
            candles: chartData.isNotEmpty ? chartData : [CandleData(timestamp: 0, open: 0, close: 0, high: 0, low: 0, volume: 0)],
            initialVisibleCandleCount: 25,
            timeLabel: (timestamp, visibleDataCount) => "",
            style: ChartStyle(
              timeLabelHeight: 0,
              volumeHeightFactor: 0.0,
              priceGridLineColor: Colors.white.withOpacity(0.04),
              priceLabelStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 10,
              ),
              timeLabelStyle: const TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildTimeAndTimeframeControls(),
      ],
    );
  }

  Widget _buildTimeAndTimeframeControls() {
    final tfs = ['1m', '5m', '15m', '1h', '1d', 'More'];
    final times = ['18:00', '19:00', '20:00', '21:00', '21:00', 'icon'];

    return Column(
      children: [
        Divider(color: Colors.white.withOpacity(0.04), height: 1),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: times.map((time) {
              return SizedBox(
                width: 38,
                child: Center(
                  child: time == 'icon'
                      ? Icon(
                          Icons.crop_free,
                          color: Colors.white.withOpacity(0.4),
                          size: 16,
                        )
                      : Text(
                          time,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.white.withOpacity(0.04), height: 1),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tfs.map((tf) {
                bool isSelected = _selectedTimeframe == tf;
                return GestureDetector(
                  onTap: () {
                    if (tf != 'More') {
                      setState(() => _selectedTimeframe = tf);
                    }
                  },
                  child: Container(
                    width: 38,
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
                            : Colors.white.withOpacity(0.4),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingSection() {
    const Color fafaColor = Color(0xFFFAFAFA);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. AVAILABLE BALANCE HEADER
          const Text(
            "Available Balance",
            style: TextStyle(
              color: fafaColor,
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),

          // MAIN AMOUNT TEXT
          const Text(
            "0.19873 BTC",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          // 3. THE MAIN ROW (Icon, Name, Fiat Value)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT SIDE: Image Icon
              Image.asset(
                'assets/icons/${widget.asset.symbol}.png',
                width: 44, // Increased size, removed bg
                height: 44,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.monetization_on,
                  color: Colors.white24,
                  size: 44,
                ),
              ),
              const SizedBox(width: 14),
              // SYMBOL AND SUBTITLE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.asset.symbol,
                    style: const TextStyle(
                      color: fafaColor,
                      fontSize: 18, // Slightly larger
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.asset.name, // Subtitle e.g. "Bitcoin"
                    style: TextStyle(
                      color: fafaColor.withOpacity(0.6),
                      fontSize: 14, // Slightly larger
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // RIGHT SIDE: Fiat Amount and Change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.asset.formattedPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "(${widget.asset.changeText})",
                    style: TextStyle(
                      color: widget.asset.isPositive ? const Color(0xFF52D377) : const Color(0xFFEF4444),
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

  // 4. THE INFO SECTION (Labels in #FAFAFA)
  Widget _buildInfoSection() {
    const Color fafaColor = Color(0xFFFAFAFA);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "Info",
            style: TextStyle(
              color: fafaColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow("Market Cap", "\$250M", fafaColor),
          _infoRow("Circulating Supply", "10M", fafaColor),
          _infoRow("Max Supply", "21M", fafaColor),
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
            "Trade",
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
}
