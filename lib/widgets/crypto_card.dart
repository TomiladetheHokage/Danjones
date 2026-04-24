import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/crypto_asset.dart';
import 'sparkline_chart.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Horizontal card for Top Movers / New sections - matches _moverCard design.
class CryptoCard extends StatelessWidget {
  final CryptoAsset asset;
  final VoidCallback? onTap;
  final String? imagePath;

  const CryptoCard({super.key, required this.asset, this.onTap, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW: Image + Symbol/Name + Change Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imagePath != null && imagePath!.isNotEmpty
                    ? _buildCryptoImage(imagePath!)
                    : Container(
                        width: 44,
                        height: 44,
                        color: Colors.red,
                        child: const Center(child: Text('NO IMG', style: TextStyle(color: Colors.white, fontSize: 8))),
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            asset.symbol,
                            style: AppTheme.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (asset.isPositive ? const Color(0xFF45E555) : const Color(0xFFEF4444))
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              asset.changeText,
                              style: AppTheme.inter(
                                color: asset.isPositive ? const Color(0xFF52D377) : Colors.redAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        asset.name,
                        style: AppTheme.inter(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // MIDDLE: Sparkline
            SizedBox(
              height: 35,
              width: double.infinity,
              child: SparklineChart(
                data: asset.sparklineData,
                isPositive: asset.isPositive,
              ),
            ),
            const Spacer(),
            // BOTTOM: Price
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                asset.formattedPrice,
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoImage(String imagePath) {
    final imageUrl = imagePath.startsWith('http') 
        ? imagePath 
        : '${ApiService.rootUrl}/${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 44,
      height: 44,
      fit: BoxFit.contain,
      placeholder: (context, url) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE4B53E)),
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.token, color: Colors.white24, size: 44),
    );

    if (imagePath.endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        width: 44,
        height: 44,
      );
    } else {
      return Image.asset(
        imagePath.startsWith('assets/') ? imagePath : 'assets/$imagePath',
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.token, color: Colors.white24, size: 44),
      );
    }
  }
}
