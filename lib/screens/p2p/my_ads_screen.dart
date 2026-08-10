import 'package:flutter/material.dart';
import '../../models/p2p/p2p_ad.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class MyAdsScreen extends StatefulWidget {
  final bool embedded;

  const MyAdsScreen({super.key, this.embedded = false});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  late Future<List<P2PAd>> _adsFuture;
  final Set<int> _closingIds = {};

  @override
  void initState() {
    super.initState();
    _adsFuture = _fetchMyAds();
  }

  // Calls the dedicated /p2p/my-ads endpoint scoped to the authenticated user.
  Future<List<P2PAd>> _fetchMyAds() async {
    return ApiService.getMyP2pAds();
  }

  void _refresh() => setState(() {
        _adsFuture = _fetchMyAds();
      });

  Future<void> _closeAd(P2PAd ad) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1E),
        title: Text(
          'Close Ad?',
          style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will close your ${ad.type.toUpperCase()} ad for ${ad.currencySymbol}. It will no longer be visible to buyers.',
          style: AppTheme.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep', style: AppTheme.inter(color: Colors.white54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Close Ad', style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _closingIds.add(ad.id));
    try {
      await ApiService.closeP2pAd(adId: ad.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Ad closed successfully',
            style: AppTheme.inter(color: Colors.white, fontSize: 13),
          ),
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: AppTheme.inter(color: Colors.redAccent, fontSize: 13),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _closingIds.remove(ad.id));
    }
  }

  String _formatMoney(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first;
    final buf = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final left = whole.length - i;
      buf.write(whole[i]);
      if (left > 1 && left % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}.${parts.last}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'My Ads',
          style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<P2PAd>>(
        future: _adsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE4B53E), strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final ads = snapshot.data ?? [];
          if (ads.isEmpty) return _buildEmpty();

          return RefreshIndicator(
            color: const Color(0xFFE4B53E),
            backgroundColor: const Color(0xFF1D1E22),
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: ads.length,
              separatorBuilder: (_, _i) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildAdCard(ads[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdCard(P2PAd ad) {
    final isBuy = ad.type.toLowerCase() == 'buy';
    final typeColor = isBuy ? const Color(0xFFE4B53E) : const Color(0xFFFF6B6B);
    final isClosing = _closingIds.contains(ad.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1B1F), Color(0xFF141518)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ad.type.toUpperCase(),
                  style: AppTheme.inter(color: typeColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ad.isActive
                      ? const Color(0xFFE4B53E).withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ad.isActive ? 'Active' : 'Closed',
                  style: AppTheme.inter(
                    color: ad.isActive ? const Color(0xFFE4B53E) : Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${ad.id}',
                style: AppTheme.inter(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Coin + price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.currencySymbol,
                      style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ad.currencyName,
                      style: AppTheme.inter(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${_formatMoney(ad.price)}',
                    style: AppTheme.inter(
                      color: const Color(0xFFE4B53E),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'per unit',
                    style: AppTheme.inter(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem('Available', '${ad.availableAmount.toStringAsFixed(8)} ${ad.currencySymbol}'),
                _statItem('Min', '₦${_formatMoney(ad.minLimit)}'),
                _statItem('Max', '₦${_formatMoney(ad.maxLimit)}'),
              ],
            ),
          ),

          if (ad.terms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Terms: ${ad.terms}',
              style: AppTheme.inter(color: Colors.white38, fontSize: 11, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Close button — only for active ads
          if (ad.isActive) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: isClosing ? null : () => _closeAd(ad),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: isClosing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                      )
                    : Text(
                        'Close Ad',
                        style: AppTheme.inter(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.inter(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: AppTheme.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_tethering_error_rounded, color: Colors.white24, size: 54),
            const SizedBox(height: 10),
            Text('Could not load ads', style: AppTheme.inter(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4B53E),
                foregroundColor: Colors.black,
              ),
              child: Text('Retry', style: AppTheme.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.post_add_rounded, color: Colors.white24, size: 60),
            const SizedBox(height: 12),
            Text('No ads yet', style: AppTheme.inter(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Your posted buy/sell ads will appear here.',
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
