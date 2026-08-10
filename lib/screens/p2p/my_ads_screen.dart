import 'package:flutter/material.dart';
import '../../models/p2p/p2p_ad.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'create_ad_screen.dart';

class MyAdsScreen extends StatefulWidget {
  final bool embedded;
  const MyAdsScreen({super.key, this.embedded = false});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  late Future<List<P2PAd>> _adsFuture;
  final Set<int> _closingIds = {};
  String _activeTab = 'all'; // all | buy | sell | inactive

  @override
  void initState() {
    super.initState();
    _adsFuture = ApiService.getMyP2pAds();
  }

  void _refresh() => setState(() => _adsFuture = ApiService.getMyP2pAds());

  List<P2PAd> _filter(List<P2PAd> ads) {
    switch (_activeTab) {
      case 'buy':
        return ads.where((a) => a.type.toLowerCase() == 'buy' && a.isActive).toList();
      case 'sell':
        return ads.where((a) => a.type.toLowerCase() == 'sell' && a.isActive).toList();
      case 'inactive':
        return ads.where((a) => !a.isActive).toList();
      default:
        return ads;
    }
  }

  Future<void> _closeAd(P2PAd ad) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1E),
        title: Text('Close Ad?',
            style: AppTheme.inter(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'This will close your ${ad.type.toUpperCase()} ad for ${ad.currencySymbol}.',
          style: AppTheme.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep',
                style: AppTheme.inter(
                    color: Colors.white54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Close',
                style: AppTheme.inter(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _closingIds.add(ad.id));
    try {
      await ApiService.closeP2pAd(adId: ad.id);
      if (!mounted) return;
      _showToast(
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF33D17A),
        title: 'Ad Closed',
        message: 'Your ad has been closed successfully.',
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _showToast(
        icon: Icons.error_outline_rounded,
        iconColor: Colors.redAccent,
        title: 'Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _closingIds.remove(ad.id));
    }
  }

  void _showToast({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1D21),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: AppTheme.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(message,
                        style: AppTheme.inter(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white54, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtMoney(double v) {
    final s = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
    return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  String _fmtCrypto(double v, String sym) {
    final f = v
        .toStringAsFixed(7)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return '$f $sym';
  }

  // ── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
        automaticallyImplyLeading: false,
        title: Text('My Ads',
            style: AppTheme.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const CreateAdScreen()),
              );
              if (created == true) _refresh();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE4B53E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<P2PAd>>(
        future: _adsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFE4B53E), strokeWidth: 2),
            );
          }
          if (snap.hasError) return _buildError(snap.error.toString());

          final all = snap.data ?? [];
          final filtered = _filter(all);

          // Count badges
          final buyCt = all
              .where((a) => a.type.toLowerCase() == 'buy' && a.isActive)
              .length;
          final sellCt = all
              .where((a) => a.type.toLowerCase() == 'sell' && a.isActive)
              .length;
          final inactiveCt = all.where((a) => !a.isActive).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tab bar ──────────────────────────────
              _buildTabBar(buyCt, sellCt, inactiveCt),

              // ── List ────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        color: const Color(0xFFE4B53E),
                        backgroundColor: const Color(0xFF1D1E22),
                        onRefresh: () async => _refresh(),
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _buildAdCard(filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────
  Widget _buildTabBar(int buyCt, int sellCt, int inactiveCt) {
    final tabs = [
      ('All Ads', 'all', 0),
      ('Buy Ads', 'buy', buyCt),
      ('Sell Ads', 'sell', sellCt),
      ('Inactive', 'inactive', inactiveCt),
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: tabs.map((tab) {
              final label = tab.$1;
              final key = tab.$2;
              final count = tab.$3;
              final active = _activeTab == key;

              return GestureDetector(
                onTap: () => setState(() => _activeTab = key),
                child: Container(
                  margin: const EdgeInsets.only(right: 28),
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active
                            ? const Color(0xFFE4B53E)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTheme.inter(
                          fontSize: 15,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color:
                              active ? Colors.white : Colors.white54,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE4B53E),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: AppTheme.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
            indent: 0,
            endIndent: 0),
      ],
    );
  }

  // ── Ad card ────────────────────────────────────────────
  Widget _buildAdCard(P2PAd ad) {
    final isBuy = ad.type.toLowerCase() == 'buy';
    final typeColor =
        isBuy ? const Color(0xFF33D17A) : const Color(0xFFFF6B6B);
    final isClosing = _closingIds.contains(ad.id);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: type badge + active dot ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${ad.type[0].toUpperCase()}${ad.type.substring(1)} ${ad.currencySymbol}',
                  style: AppTheme.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ad.isActive
                          ? const Color(0xFF33D17A)
                          : Colors.white38,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ad.isActive ? 'Active' : 'Inactive',
                    style: AppTheme.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ad.isActive
                          ? const Color(0xFF33D17A)
                          : Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Row 2: Price | Available ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price',
                        style: AppTheme.inter(
                            fontSize: 13, color: Colors.white60)),
                    const SizedBox(height: 4),
                    Text(
                      '₦${_fmtMoney(ad.price)}',
                      style: AppTheme.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE4B53E)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available',
                        style: AppTheme.inter(
                            fontSize: 13, color: Colors.white60)),
                    const SizedBox(height: 4),
                    Text(
                      _fmtCrypto(
                          ad.availableAmount, ad.currencySymbol),
                      style: AppTheme.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Row 3: Min | Max ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Min Order',
                        style: AppTheme.inter(
                            fontSize: 13, color: Colors.white60)),
                    const SizedBox(height: 4),
                    Text(
                      '₦${_fmtMoney(ad.minLimit)}',
                      style: AppTheme.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Max Order',
                        style: AppTheme.inter(
                            fontSize: 13, color: Colors.white60)),
                    const SizedBox(height: 4),
                    Text(
                      '₦${_fmtMoney(ad.maxLimit)}',
                      style: AppTheme.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Payment method ──
          if (ad.bankName != null) ...[
            const SizedBox(height: 16),
            Text('Payment Method',
                style: AppTheme.inter(
                    fontSize: 13, color: Colors.white60)),
            const SizedBox(height: 8),
            _bankChip(ad.bankName!, ad.bankAccountNumber),
          ],

          // ── Terms ──
          if (ad.terms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              ad.terms,
              style: AppTheme.inter(
                  fontSize: 12, color: Colors.white38, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (ad.isActive) ...[
            const SizedBox(height: 18),
            Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.07)),
            const SizedBox(height: 14),

            // ── Buttons ──
            Row(
              children: [
                // Close Order — outlined gold
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed:
                          isClosing ? null : () => _closeAd(ad),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFE4B53E), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isClosing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE4B53E)),
                            )
                          : Text('Close Order',
                              style: AppTheme.inter(
                                  color: const Color(0xFFE4B53E),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Cancel Order — filled gold
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed:
                          isClosing ? null : () => _closeAd(ad),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4B53E),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel Order',
                          style: AppTheme.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _bankChip(String bankName, String? accountNumber) {
    const accentColors = [
      Color(0xFF33D17A),
      Color(0xFF8B5CF6),
      Color(0xFFE4B53E),
      Color(0xFF60A5FA),
      Color(0xFFFF6B6B),
    ];
    final accent =
        accentColors[bankName.hashCode.abs() % accentColors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
                color: accent, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bankName,
                  style: AppTheme.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              if (accountNumber != null)
                Text(
                  accountNumber.length > 4
                      ? '•••• ${accountNumber.substring(accountNumber.length - 4)}'
                      : accountNumber,
                  style: AppTheme.inter(
                      fontSize: 11, color: Colors.white54),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_tethering_error_rounded,
                color: Colors.white24, size: 54),
            const SizedBox(height: 10),
            Text('Could not load ads',
                style: AppTheme.inter(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(error.replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                    color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4B53E),
                foregroundColor: Colors.black,
              ),
              child: Text('Retry',
                  style: AppTheme.inter(fontWeight: FontWeight.w700)),
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
            const Icon(Icons.post_add_rounded,
                color: Colors.white24, size: 60),
            const SizedBox(height: 12),
            Text('No ads yet',
                style: AppTheme.inter(
                    color: Colors.white70,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Your posted buy/sell ads will appear here.',
              textAlign: TextAlign.center,
              style:
                  AppTheme.inter(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
