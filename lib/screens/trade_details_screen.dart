import 'package:flutter/material.dart';

import '../models/p2p_trade.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TradeDetailsScreen extends StatefulWidget {
  final P2PTrade trade;

  const TradeDetailsScreen({super.key, required this.trade});

  @override
  State<TradeDetailsScreen> createState() => _TradeDetailsScreenState();
}

class _TradeDetailsScreenState extends State<TradeDetailsScreen> {
  bool _isMarkingPaid = false;
  bool _isCanceling = false;

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
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} $hh:$mm';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return const Color(0xFF33D17A);
      case 'cancelled':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFFE4B53E);
    }
  }

  Future<void> _cancelTrade() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1E),
        title: Text('Cancel Trade?', style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'This will cancel order #${widget.trade.id}.',
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
            child: Text('Cancel', style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    setState(() => _isCanceling = true);
    try {
      await ApiService.cancelP2pTrade(tradeId: widget.trade.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trade cancelled successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isCanceling = false);
    }
  }

  Future<void> _markTradePaid() async {
    setState(() => _isMarkingPaid = true);
    try {
      await ApiService.markP2pTradePaid(tradeId: widget.trade.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trade marked as paid')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isMarkingPaid = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trade = widget.trade;
    final statusColor = _statusColor(trade.status);
    final side = trade.adType.toLowerCase() == 'sell' ? 'Buy' : 'Sell';

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
          'Trade #${trade.id}',
          style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B1C20), Color(0xFF141518)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      trade.status.toUpperCase(),
                      style: AppTheme.inter(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$side ${trade.currencySymbol}',
                    style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₦${_formatMoney(trade.fiatAmount)}',
                    style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trade.cryptoAmount.toStringAsFixed(8)} ${trade.currencySymbol}',
                    style: AppTheme.inter(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _infoTile('Price per unit', '₦${_formatMoney(trade.adPrice)}'),
            _infoTile('Seller', trade.sellerName),
            _infoTile('Buyer', trade.buyerName),
            _infoTile('Trade date', _formatDate(trade.createdAt)),
            _infoTile('Updated', _formatDate(trade.updatedAt)),
            _infoTile('Terms', trade.adTerms.isEmpty ? 'No specific terms' : trade.adTerms),
            const SizedBox(height: 18),
            if (trade.isPending) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isMarkingPaid || _isCanceling ? null : _markTradePaid,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFE4B53E),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isMarkingPaid
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          'Mark as Paid',
                          style: AppTheme.inter(color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isMarkingPaid || _isCanceling ? null : _cancelTrade,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isCanceling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
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

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF18191C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.inter(color: Colors.white38, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
