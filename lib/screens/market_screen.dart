import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../widgets/crypto_card.dart';
import '../widgets/token_list_item.dart';
import '../theme/app_theme.dart';
import 'market_asset_screen.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildMarketHeader()),
            SliverToBoxAdapter(child: _buildSectionHeader('Top Movers', onViewAll: () {})),
            SliverToBoxAdapter(child: _buildTopMoversRow(context)),
            SliverToBoxAdapter(child: _buildSectionHeader('New', onViewAll: () {})),
            SliverToBoxAdapter(child: _buildNewRow(context)),
            
            SliverToBoxAdapter(child: _buildSectionHeader('Top Assets', onViewAll: () {})),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TokenListItem(
                  asset: MockCrypto.topAssets[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketAssetScreen(
                          asset: MockCrypto.topAssets[index],
                        ),
                      ),
                    );
                  },
                ),
                childCount: MockCrypto.topAssets.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  /// Market Header with proper spacing
 Widget _buildMarketHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Center(
      child: Text(
        'Market',
        style: AppTheme.heading2,
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title, {required VoidCallback onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         Text(
  title,
  style: AppTheme.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  ),
),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View all',
              style: AppTheme.inter(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTopMoversRow() {
  //   return SizedBox(
  //     height: 180,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 20),
  //       itemCount: MockCrypto.topMovers.length,
  //       itemBuilder: (context, index) {
  //         return Padding(
  //           padding: const EdgeInsets.only(right: 12),
  //           child: CryptoCard(asset: MockCrypto.topMovers[index], onTap: () {}),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildTopMoversRow(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 8),
              for (int index = 0; index < MockCrypto.topMovers.length; index++) ...[
                CryptoCard(
                  asset: MockCrypto.topMovers[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketAssetScreen(
                          asset: MockCrypto.topMovers[index],
                        ),
                      ),
                    );
                  },
                  imagePath: _getImagePath(MockCrypto.topMovers[index].symbol),
                ),
                if (index < MockCrypto.topMovers.length - 1) const SizedBox(width: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewRow(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 8),
              for (int index = 0; index < MockCrypto.newList.length; index++) ...[
                CryptoCard(
                  asset: MockCrypto.newList[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketAssetScreen(
                          asset: MockCrypto.newList[index],
                        ),
                      ),
                    );
                  },
                  imagePath: _getImagePath(MockCrypto.newList[index].symbol),
                ),
                if (index < MockCrypto.newList.length - 1) const SizedBox(width: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getImagePath(String symbol) {
    switch (symbol) {
      case 'BTC':
        return 'assets/icons/BTC.png';
      case 'ETH':
        return 'assets/icons/ETH.png';
      case 'FTT':
        return 'assets/icons/FTT.png';
      case 'MATIC':
        return 'assets/icons/MATIC.png';
      case 'XRP':
        return 'assets/icons/XRP.png';
      case 'UNI':
        return 'assets/icons/UNI.png';
      default:
        return 'assets/icons/BTC.png';
    }
  }
}