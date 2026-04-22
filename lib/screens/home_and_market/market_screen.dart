import 'package:flutter/material.dart';
import '../../models/crypto_asset.dart';
import '../../widgets/crypto_card.dart';
import '../../widgets/token_list_item.dart';
import '../../theme/app_theme.dart';
import '../../services/crypto_service.dart';
import 'market_asset_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late Future<List<CryptoAsset>> marketFuture;

  @override
  void initState() {
    super.initState();
    marketFuture = CryptoService.fetchTopMovers();
  }

  Future<void> _refresh() async {
    setState(() {
      marketFuture = CryptoService.fetchTopMovers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFFE4B53E),
          backgroundColor: const Color(0xFF1E1E1E),
          child: FutureBuilder<List<CryptoAsset>>(
            future: marketFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFE4B53E)));
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      const Text('Failed to load market data', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _refresh,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE4B53E)),
                        child: const Text('Retry', style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data found', style: TextStyle(color: Colors.white70)));
              }

              final allAssets = snapshot.data!;
              final topMovers = List<CryptoAsset>.from(allAssets)..sort((a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));
              final newAssets = List<CryptoAsset>.from(allAssets)..sort((a, b) => a.priceChangePercent.compareTo(b.priceChangePercent)); // using losers as "new" for now
              
              final topMoversList = topMovers.take(5).toList();
              final newAssetsList = newAssets.take(5).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: _buildMarketHeader()),
                  SliverToBoxAdapter(child: _buildSectionHeader('Top Movers', onViewAll: () {})),
                  SliverToBoxAdapter(child: _buildTopMoversRow(context, topMoversList)),
                  SliverToBoxAdapter(child: _buildSectionHeader('New', onViewAll: () {})),
                  SliverToBoxAdapter(child: _buildNewRow(context, newAssetsList)),
                  
                  SliverToBoxAdapter(child: _buildSectionHeader('Top Assets', onViewAll: () {})),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => TokenListItem(
                        asset: allAssets[index],
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => MarketAssetScreen(
                                asset: allAssets[index],
                              ),
                            ),
                          );
                        },
                      ),
                      childCount: allAssets.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          ),
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

  Widget _buildTopMoversRow(BuildContext context, List<CryptoAsset> assets) {
    return SizedBox(
      height: 200,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 8),
              for (int index = 0; index < assets.length; index++) ...[
                CryptoCard(
                  asset: assets[index],
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => MarketAssetScreen(
                          asset: assets[index],
                        ),
                      ),
                    );
                  },
                  imagePath: assets[index].imagePath,
                ),
                if (index < assets.length - 1) const SizedBox(width: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewRow(BuildContext context, List<CryptoAsset> assets) {
    return SizedBox(
      height: 200,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 8),
              for (int index = 0; index < assets.length; index++) ...[
                CryptoCard(
                  asset: assets[index],
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => MarketAssetScreen(
                          asset: assets[index],
                        ),
                      ),
                    );
                  },
                  imagePath: assets[index].imagePath,
                ),
                if (index < assets.length - 1) const SizedBox(width: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }

}