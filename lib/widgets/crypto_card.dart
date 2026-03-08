import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import 'sparkline_chart.dart';
import '../theme/app_theme.dart';

/// Horizontal card for Top Movers / New sections - matches _moverCard design.
class CryptoCard extends StatelessWidget {
  final CryptoAsset asset;
  final VoidCallback? onTap;

  const CryptoCard({super.key, required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: _getAvatarColor(asset.symbol),
                  child: Text(
                    asset.symbol.substring(0, 1),
                    style: TextStyle(
                      color: _getAvatarTextColor(asset.symbol),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        asset.name,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (asset.isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    asset.changeText,
                    style: TextStyle(
                      color: asset.isPositive ? const Color(0xFF34D399) : Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SparklineChart(
              data: asset.sparklineData,
              isPositive: asset.isPositive,
              width: 128,
              height: 40,
            ),
            const Spacer(),
            Text(
              asset.formattedPrice,
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String symbol) {
    if (symbol == 'BTC') return Colors.orange.withOpacity(0.3);
    if (symbol == 'ETH') return Colors.purple.withOpacity(0.3);
    if (symbol == 'SOL') return Colors.cyan.withOpacity(0.3);
    if (symbol == 'FTT') return Colors.pink.withOpacity(0.3);
    return Colors.blue.withOpacity(0.3);
  }

  Color _getAvatarTextColor(String symbol) {
    if (symbol == 'BTC') return Colors.orange;
    if (symbol == 'ETH') return Colors.purple;
    if (symbol == 'SOL') return Colors.cyan;
    if (symbol == 'FTT') return Colors.pink;
    return Colors.blue;
  }
}
