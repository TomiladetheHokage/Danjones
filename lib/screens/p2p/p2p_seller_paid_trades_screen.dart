import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/p2p_ad.dart';
import '../../models/p2p_trade.dart';
import '../../services/api_service.dart';
import '../../services/data_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_dialog.dart';

class P2PSellerPaidTradesScreen extends StatefulWidget {
  final P2PAd ad;

  const P2PSellerPaidTradesScreen({super.key, required this.ad});

  @override
  State<P2PSellerPaidTradesScreen> createState() => _P2PSellerPaidTradesScreenState();
}

class _P2PSellerPaidTradesScreenState extends State<P2PSellerPaidTradesScreen> {
  late Future<List<P2PTrade>> _tradesFuture;
  final Set<int> _releasing = {};

  @override
  void initState() {
    super.initState();
    _tradesFuture = _loadPaidTrades();
  }

  Future<List<P2PTrade>> _loadPaidTrades() async {
    final all = await ApiService.getMyP2pTrades();
    final currentUserId = DataStore.instance.dashboard.value?.user.id;
    return all.where((t) =>
      t.advertisementId == widget.ad.id &&
      t.sellerId == currentUserId &&
      t.status.toLowerCase() == 'paid',
    ).toList();
  }

  void _refresh() {
    setState(() => _tradesFuture = _loadPaidTrades());
  }

  Future<void> _confirmRelease(P2PTrade trade) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Release',
          style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are releasing:',
              style: AppTheme.inter(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '${trade.cryptoAmount.toStringAsFixed(8)} ${trade.currencySymbol}',
              style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'to ${trade.buyerName}',
              style: AppTheme.inter(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action is irreversible. Only confirm if you have received ₦${_fmt(trade.fiatAmount)}.',
                      style: AppTheme.inter(color: Colors.redAccent, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Back', style: AppTheme.inter(color: Colors.white54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF33D17A),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Release Crypto', style: AppTheme.inter(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _releasing.add(trade.id));
    try {
      await ApiService.completeP2pTrade(tradeId: trade.id);
      if (!mounted) return;
      CustomDialog.showSuccess(
        context,
        title: 'Released',
        message: '${trade.cryptoAmount.toStringAsFixed(8)} ${trade.currencySymbol} has been released to ${trade.buyerName}.',
        buttonText: 'Done',
        onButtonPressed: () {
          Navigator.pop(context); // close dialog
          _refresh();
        },
      );
    } catch (e) {
      if (!mounted) return;
      CustomDialog.showError(
        context,
        title: 'Release Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _releasing.remove(trade.id));
    }
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final buf = StringBuffer();
    for (int i = 0; i < parts[0].length; i++) {
      final left = parts[0].length - i;
      buf.write(parts[0][i]);
      if (left > 1 && left % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}.${parts[1]}';
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pending Releases',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Ad summary bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.ad.currencyImageUrl,
                  width: 32,
                  height: 32,
                  errorWidget: (_, __, ___) => const Icon(Icons.token, color: Colors.white24, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sell ${widget.ad.currencySymbol} @ ₦${_fmt(widget.ad.price)}',
                        style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Buyers who have marked payment as sent',
                        style: AppTheme.inter(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Trade list
          Expanded(
            child: FutureBuilder<List<P2PTrade>>(
              future: _tradesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE4B53E)));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            snapshot.error.toString().replaceAll('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: AppTheme.inter(color: Colors.white38, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _refresh,
                            child: Text('Retry', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final trades = snapshot.data ?? [];
                if (trades.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hourglass_empty_rounded, color: Colors.white24, size: 56),
                          const SizedBox(height: 16),
                          Text(
                            'No pending releases',
                            style: AppTheme.inter(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Buyers will appear here once they mark their payment as sent.',
                            textAlign: TextAlign.center,
                            style: AppTheme.inter(color: Colors.white38, fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFFE4B53E),
                  backgroundColor: const Color(0xFF1D1E22),
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: trades.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildTradeCard(trades[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeCard(P2PTrade trade) {
    final initials = trade.buyerName.length >= 2
        ? trade.buyerName.substring(0, 2).toUpperCase()
        : trade.buyerName.toUpperCase();
    final isReleasing = _releasing.contains(trade.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buyer info row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E1E1E),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTheme.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.buyerName,
                      style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Order #${trade.id} • ${_fmtDate(trade.updatedAt ?? trade.createdAt)}',
                      style: AppTheme.inter(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Paid badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF33D17A).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PAID',
                  style: AppTheme.inter(color: const Color(0xFF33D17A), fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Amount details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('They Paid', style: AppTheme.inter(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        '₦${_fmt(trade.fiatAmount)}',
                        style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('You Release', style: AppTheme.inter(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        '${trade.cryptoAmount.toStringAsFixed(8)} ${trade.currencySymbol}',
                        style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Confirm Release button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: isReleasing ? null : () => _confirmRelease(trade),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF33D17A),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isReleasing
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text(
                      'Confirm Release',
                      style: AppTheme.inter(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
