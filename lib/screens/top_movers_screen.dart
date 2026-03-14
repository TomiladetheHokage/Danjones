import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../widgets/sparkline_chart.dart';
import '../theme/app_theme.dart';

class TopMoversScreen extends StatelessWidget {
  const TopMoversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CryptoAsset> moreMovers = [
      ...MockCrypto.topMovers,
      ...MockCrypto.topMovers,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: moreMovers.length,
                // FIXED DIVIDER: LinearGradient shows better than Radial
                separatorBuilder: (context, index) => Center(
                  child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.12), // Bright center
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context, index) => _buildMoverItem(moreMovers[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            // Changed from Icons.arrow_back_ios_new to Icons.arrow_back
            child: const Icon(
              Icons.arrow_back, 
              color: Colors.white, 
              size: 24, // Standard arrow size for clear navigation
            ),
          ),
        ),
        Text(
          'Top movers',
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

  

Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20), // More horizontal padding
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          // 1. TEXT ON THE LEFT
          Expanded(
            child: TextField(
              cursorColor: Colors.white24,
              style: AppTheme.inter(
                color: Colors.white, 
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Search Token',
                hintStyle: AppTheme.inter(
                  color: Colors.white.withOpacity(0.2), 
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          
          // 2. ICON ON THE RIGHT
          Icon(
            Icons.search, 
            color: Colors.white.withOpacity(0.2), 
            size: 26, // Slightly larger for the right-side placement
          ),
        ],
      ),
    ),
  );
}

Widget _buildMoverItem(CryptoAsset asset) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        // 1. MASSIVE ICON
        Padding(
          padding: const EdgeInsets.only(top: 4), // Nudging image down to align with slim text
          child: SizedBox(
            width: 56,
            height: 56,
            child: Image.asset(
              'assets/icons/${asset.symbol.toUpperCase()}.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.token, color: Colors.white24, size: 56),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 2. SLIM TEXT COLUMN
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asset.symbol.toUpperCase(),
              style: AppTheme.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400, // Slim
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4), 
            Text(
              asset.name,
              style: AppTheme.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400, // Slim
                color: const Color(0xFFFAFAFA), // THE UPDATED COLOR
              ),
            ),
          ],
        ),

        const Spacer(),

        // 3. SPARKLINE CHART
        Padding(
          padding: const EdgeInsets.only(top: 14), // Centering chart vertically
          child: SizedBox(
            width: 70,
            height: 32,
            child: SparklineChart(
              data: asset.sparklineData,
              isPositive: asset.isPositive,
            ),
          ),
        ),

        const Spacer(),

        // 4. PRICE SECTION
        Padding(
          padding: const EdgeInsets.only(top: 6), // Aligning price row with top of symbol
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '3.00912',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '(\$12.09)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFAFAFA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '(${asset.changeText})',
                style: AppTheme.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: asset.isPositive
                      ? const Color(0xFF52D377)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}