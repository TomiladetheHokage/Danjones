import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../theme/app_theme.dart';
import '../widgets/token_list_item.dart';
import 'asset_details_screen.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  bool _hideBalance = false;
  String _search = '';

  List<CryptoAsset> get _filteredAssets {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return MockCrypto.marketList;
    return MockCrypto.marketList
        .where((asset) =>
            asset.symbol.toLowerCase().contains(query) ||
            asset.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Assets',
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildEquityCard(),
            const SizedBox(height: 18),
            _buildDistributionBar(),
            const SizedBox(height: 18),
            _buildSearchField(),
            const SizedBox(height: 12),
            Expanded(child: _buildAssetsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildEquityCard() {
    return Center(
      child: Container(
        width: 351,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.07),
              Colors.white.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Total Equity (NGN)',
                  style: AppTheme.inter(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _hideBalance = !_hideBalance),
                  child: Icon(
                    _hideBalance
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _hideBalance ? '••••••••' : '₦ ${MockCrypto.totalEquityNgn.toStringAsFixed(2)}',
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF45E555).withOpacity(0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '+ ₦${MockCrypto.equityChangeNgn.toStringAsFixed(0)} (${MockCrypto.equityChangePercent}%)',
                style: AppTheme.inter(
                  color: const Color(0xFF45E555),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildDistributionBar() {
    const colors = [Color(0xFF5ED5A8), Color(0xFFB25EFF), Color(0xFFFFC107), Color(0xFF4C4C4C)];
    const labels = ['NGN 55%', 'BTC 20%', 'ETH 10%', 'Others 15%'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ADDED THIS HEADER ---
          Text(
            'Asset Distribution',
            style: AppTheme.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16), // Space between text and bar
          // -------------------------
          
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Row(
              children: colors
                  .map((color) => Expanded(
                        child: Container(
                          height: 10,
                          color: color,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(labels.length, (index) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    labels[index],
                    style: AppTheme.inter(color: Colors.white54, fontSize: 12),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                cursorColor: Colors.white24,
                style: AppTheme.inter(color: Colors.white, fontSize: 14),
                onChanged: (value) => setState(() => _search = value),
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
            Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.2),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsList() {
    final assets = _filteredAssets;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: assets.length,
      separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.08), height: 1),
      itemBuilder: (context, index) {
        final asset = assets[index];
        return TokenListItem(
          asset: asset,
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => AssetDetailsScreen(asset: asset),
              ),
            );
          },
        );
      },
    );
  }
}
