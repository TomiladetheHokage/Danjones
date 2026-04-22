import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallet.dart';
import '../models/dashboard_data.dart';
import '../services/data_store.dart';
import '../theme/app_theme.dart';
import 'asset_details_screen.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  bool _hideBalance = false;
  String _search = '';

  List<Wallet> _filteredWallets(List<Wallet> wallets) {
    final query = _search.trim().toLowerCase();
    final filtered = wallets.where((w) => w.currency.isCrypto).toList();
    if (query.isEmpty) return filtered;
    return filtered.where((w) =>
        w.currency.symbol.toLowerCase().contains(query) ||
        w.currency.name.toLowerCase().contains(query)).toList();
  }

  String _formatNgn(num value) {
    final s = value.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$intPart.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: ValueListenableBuilder<DashboardData?>(
        valueListenable: DataStore.instance.dashboard,
        builder: (context, dashboard, _) {
          final wallets = dashboard?.wallets ?? [];
          final totalNgn = dashboard?.totalBalanceNgn ?? 0;
          final filtered = _filteredWallets(wallets);

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text('Assets', style: AppTheme.heading2, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _buildEquityCard(totalNgn),
                const SizedBox(height: 18),
                _buildDistributionBar(wallets, dashboard),
                const SizedBox(height: 18),
                _buildSearchField(),
                const SizedBox(height: 12),
                Expanded(child: _buildAssetsList(filtered)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquityCard(num totalNgn) {
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
                  style: AppTheme.inter(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _hideBalance = !_hideBalance),
                  child: Icon(
                    _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _hideBalance ? '••••••••' : '₦ ${_formatNgn(totalNgn)}',
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
                // Note: using placeholder until backend provides PnL data
                '+ ₦25,000.00 (2.4%)',
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

  Widget _buildDistributionBar(List<Wallet> wallets, DashboardData? dashboard) {
    final double totalNgn = dashboard?.totalBalanceNgn.toDouble() ?? 0.0;
    final double totalUsd = dashboard?.totalBalanceUsd.toDouble() ?? 0.0;
    
    // Calculate exchange rate to convert crypto USD balances into NGN
    final double rate = totalUsd > 0 ? (totalNgn / totalUsd) : 1500.0;

    double getWalletValue(Wallet w) {
      if (!w.currency.isCrypto && w.currency.symbol.toUpperCase() == 'NGN') {
        return double.tryParse(w.balance) ?? 0.0;
      }
      return w.balanceUsd.toDouble() * rate;
    }

    final computedTotal = wallets.fold<double>(0, (sum, w) => sum + getWalletValue(w));

    final List<Color> colors = [
      const Color(0xFF5ED5A8),
      const Color(0xFFB25EFF),
      const Color(0xFFFFC107),
      const Color(0xFF4C6EFF),
      const Color(0xFF4C4C4C),
    ];

    final List<_DistSegment> segments = [];
    final significantWallets = [...wallets]
      ..sort((a, b) => getWalletValue(b).compareTo(getWalletValue(a)));

    if (computedTotal > 0) {
      for (int i = 0; i < significantWallets.length && i < 4; i++) {
        final w = significantWallets[i];
        final val = getWalletValue(w);
        final pct = (val / computedTotal * 100);
        if (pct >= 1) { // Only show chunks >= 1% to avoid clutter
          segments.add(_DistSegment(
            color: colors[i % colors.length],
            label: '${w.currency.symbol.toUpperCase()} ${pct.toStringAsFixed(0)}%',
            flex: (pct * 10).round().clamp(1, 10000),
          ));
        }
      }
      // "Others" segment
      if (significantWallets.length > 4) {
        final othersVal = significantWallets.skip(4).fold<double>(0, (s, w) => s + getWalletValue(w));
        final pct = othersVal / computedTotal * 100;
        if (pct >= 1) {
          segments.add(_DistSegment(
            color: colors[4],
            label: 'Others ${pct.toStringAsFixed(0)}%',
            flex: (pct * 10).round().clamp(1, 10000),
          ));
        }
      }
    }

    // Fallback if no data or very small balances
    if (segments.isEmpty) {
      segments.addAll([
        _DistSegment(color: colors[0], label: 'NGN 55%', flex: 55),
        _DistSegment(color: colors[1], label: 'BTC 20%', flex: 20),
        _DistSegment(color: colors[2], label: 'ETH 10%', flex: 10),
        _DistSegment(color: colors[4], label: 'Others 15%', flex: 15),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Distribution',
            style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Row(
              children: segments.map((seg) => Expanded(
                flex: seg.flex,
                child: Container(height: 10, color: seg.color),
              )).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: segments.map((seg) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: seg.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(seg.label, style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
              ],
            )).toList(),
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
                  hintStyle: AppTheme.inter(color: Colors.white.withOpacity(0.2), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Icon(Icons.search, color: Colors.white.withOpacity(0.2), size: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsList(List<Wallet> wallets) {
    if (wallets.isEmpty) {
      return Center(
        child: Text('No assets found', style: AppTheme.inter(color: Colors.white38, fontSize: 14)),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: wallets.length,
      separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.08), height: 1),
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return _buildWalletItem(wallet);
      },
    );
  }

  Widget _buildWalletItem(Wallet wallet) {
    final imageUrl = wallet.currency.fullImageUrl;
    final balance = double.tryParse(wallet.balance) ?? 0.0;
    final balanceUsd = wallet.balanceUsd.toDouble();

    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => AssetDetailsScreen(wallet: wallet),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            // Token image
            SizedBox(
              width: 40,
              height: 40,
              child: imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE4B53E)),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.token, color: Colors.white24, size: 40),
                    )
                  : const Icon(Icons.token, color: Colors.white24, size: 40),
            ),
            const SizedBox(width: 12),

            // Token name and symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.currency.symbol.toUpperCase(),
                    style: AppTheme.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    wallet.currency.name,
                    style: AppTheme.inter(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),

            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${balance.toStringAsFixed(wallet.currency.decimalPlaces)} ${wallet.currency.symbol.toUpperCase()}',
                  style: AppTheme.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${balanceUsd.toStringAsFixed(2)}',
                  style: AppTheme.inter(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DistSegment {
  final Color color;
  final String label;
  final int flex;
  _DistSegment({required this.color, required this.label, required this.flex});
}
