import 'package:flutter/material.dart';
import '../models/crypto_asset.dart'; // Ensure this path is correct
import 'sparkline_chart.dart';
import '../theme/app_theme.dart';

class TokenListItem extends StatelessWidget {
  final CryptoAsset asset;
  final VoidCallback? onTap;

  const TokenListItem({super.key, required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.8)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            // 1. IMAGE: Clean, no circle background
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset('assets/icons/${asset.symbol.toUpperCase()}.png', 
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.token, color: Colors.white24)),
            ),
            const SizedBox(width: 12),

            // 2. NAME & SYMBOL
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(asset.symbol.toUpperCase(), style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(asset.name, style: AppTheme.inter(fontSize: 12, color: Colors.white38)),
              ],
            ),

            // 3. THE CHART: Placed in Expanded + Center to fill the gap properly
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 70, // Fixed width prevents the "hill" look
                  height: 35,
                  child: SparklineChart(data: asset.sparklineData, isPositive: asset.isPositive),
                ),
              ),
            ),

            // 4. PRICE & BALANCE
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(asset.formattedPrice, style: AppTheme.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '(${asset.changeText})',
                  style: AppTheme.inter(fontSize: 11, fontWeight: FontWeight.bold, 
                    color: asset.isPositive ? const Color(0xFF5ED5A8) : const Color(0xFFEF4444)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}