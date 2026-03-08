import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import 'sparkline_chart.dart';
import '../theme/app_theme.dart';

/// Single row for token/asset list: icon, name, sparkline, price and change.
class TokenListItem extends StatelessWidget {
  final CryptoAsset asset;
  final VoidCallback? onTap;

  const TokenListItem({super.key, required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE4B53E).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                asset.symbol.length >= 2 ? asset.symbol.substring(0, 2) : asset.symbol,
                style: AppTheme.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE4B53E),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: AppTheme.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${asset.price.toStringAsFixed(5)} (${asset.formattedPrice})',
                    style: AppTheme.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            SparklineChart(
              data: asset.sparklineData,
              isPositive: asset.isPositive,
              width: 64,
              height: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  asset.formattedPrice,
                  style: AppTheme.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '(${asset.changeText})',
                  style: AppTheme.inter(
                    fontSize: 12,
                    color: asset.isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
