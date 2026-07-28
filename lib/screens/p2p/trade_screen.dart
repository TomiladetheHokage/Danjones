import 'package:flutter/material.dart';

import '../../models/p2p/p2p_trade.dart';
import 'trade_details_screen.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/custom_dialog.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  late Future<List<P2PTrade>> _tradesFuture;
  String _activeFilter = 'all';
  bool _isCanceling = false;

  @override
  void initState() {
    super.initState();
    _tradesFuture = ApiService.getMyP2pTrades();
  }

  void _refreshTrades() {
    setState(() {
      _tradesFuture = ApiService.getMyP2pTrades();
    });
  }

  Future<void> _onRefresh() async {
    _refreshTrades();
    await _tradesFuture;
  }

  Future<void> _confirmCancelTrade(P2PTrade trade) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B1E),
          title: Text('Cancel Trade?', style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          content: Text(
            'This will cancel order #${trade.id}. You can still create a new trade afterward.',
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
              child: Text('Cancel Trade', style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    setState(() => _isCanceling = true);
    try {
      await ApiService.cancelP2pTrade(tradeId: trade.id);
      if (!mounted) return;
      CustomDialog.showSuccess(
        context,
        title: 'Trade Cancelled',
        message: 'Order #${trade.id} has been cancelled successfully.',
        buttonText: 'Done',
      );
      _refreshTrades();
    } catch (e) {
      if (!mounted) return;
      CustomDialog.showError(
        context,
        title: 'Cancel Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isCanceling = false);
    }
  }

  List<P2PTrade> _applyFilter(List<P2PTrade> trades) {
    if (_activeFilter == 'all') return trades;
    return trades.where((trade) => trade.status.toLowerCase() == _activeFilter).toList();
  }

  String _formatMoney(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first;
    final dec = parts.last;
    final buf = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final left = whole.length - i;
      buf.write(whole[i]);
      if (left > 1 && left % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}.$dec';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return const Color(0xFF33D17A);
      case 'cancelled':
        return const Color(0xFFFF6B6B);
      case 'pending':
      default:
        return const Color(0xFFE4B53E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Trades',
          style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF18191C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Pending', 'pending'),
                _buildFilterChip('Paid', 'paid'),
                _buildFilterChip('Completed', 'completed'),
                _buildFilterChip('Cancelled', 'cancelled'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<P2PTrade>>(
              future: _tradesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE4B53E)));
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final filtered = _applyFilter(snapshot.data ?? []);
                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: const Color(0xFFE4B53E),
                  backgroundColor: const Color(0xFF1D1E22),
                  onRefresh: _onRefresh,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildTradeCard(filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _activeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: selected
              ? const LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)])
              : null,
          color: selected ? null : const Color(0xFF121316),
          border: Border.all(color: selected ? Colors.transparent : Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          label,
          style: AppTheme.inter(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTradeCard(P2PTrade trade) {
    final statusColor = _statusColor(trade.status);
    final side = trade.adType.toLowerCase() == 'sell' ? 'Buy' : 'Sell';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final updated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => TradeDetailsScreen(trade: trade)),
        );
        if (updated == true) {
          _refreshTrades();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1B1F), Color(0xFF141518)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trade.status.toUpperCase(),
                  style: AppTheme.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Text(
                '#${trade.id}',
                style: AppTheme.inter(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$side ${trade.currencySymbol}',
                      style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦${_formatMoney(trade.fiatAmount)}',
                      style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trade.cryptoAmount.toStringAsFixed(8)} ${trade.currencySymbol}',
                      style: AppTheme.inter(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Price', style: AppTheme.inter(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '₦${_formatMoney(trade.adPrice)}',
                    style: AppTheme.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.white54, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Seller: ${trade.sellerName}',
                    style: AppTheme.inter(color: Colors.white60, fontSize: 12),
                  ),
                ),
                Text(
                  _formatDate(trade.createdAt),
                  style: AppTheme.inter(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          if (trade.isPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: _isCanceling ? null : () => _confirmCancelTrade(trade),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: _isCanceling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                      )
                    : Text(
                        'Cancel Trade',
                        style: AppTheme.inter(color: Colors.redAccent, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_tethering_error_rounded, color: Colors.white24, size: 54),
            const SizedBox(height: 10),
            Text(
              'Could not load trades',
              style: AppTheme.inter(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _refreshTrades,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 60),
            const SizedBox(height: 12),
            Text(
              'No trades yet',
              style: AppTheme.inter(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Your P2P order history will appear here once you place trades.',
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
