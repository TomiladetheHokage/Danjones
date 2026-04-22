import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/crypto_asset.dart';
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
              child: _buildTokenImage(asset.imagePath, asset.symbol),
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

  Widget _buildTokenImage(String? imagePath, String symbol) {
    if (imagePath != null && imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE4B53E)),
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.token, color: Colors.white24, size: 32),
      );
    }

    return Image.asset(
      'assets/icons/${symbol.toUpperCase()}.png',
      width: 32,
      height: 32,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.token, color: Colors.white24, size: 32),
    );
  }
}