import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../widgets/crypto_card.dart';
import '../widgets/token_list_item.dart';
import '../theme/app_theme.dart';

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
            SliverToBoxAdapter(child: _buildTopMoversRow()),
            SliverToBoxAdapter(child: _buildSectionHeader('New', onViewAll: () {})),
            SliverToBoxAdapter(child: _buildNewRow()),
            SliverToBoxAdapter(child: _buildSectionHeader('Top Assets', onViewAll: () {})),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TokenListItem(
                  asset: MockCrypto.topAssets[index],
                  onTap: () {},
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
      child: Text(
        'Market',
        style: AppTheme.heading2,
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
            style: AppTheme.heading3,
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View all',
              style: AppTheme.inter(
                fontSize: 14,
                color: const Color(0xFFE4B53E),
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

  Widget _buildTopMoversRow() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockCrypto.topMovers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CryptoCard(asset: MockCrypto.topMovers[index], onTap: () {}),
          );
        },
      ),
    );
  }

  Widget _buildNewRow() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockCrypto.newList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CryptoCard(asset: MockCrypto.newList[index], onTap: () {}),
          );
        },
      ),
    );
  }
}