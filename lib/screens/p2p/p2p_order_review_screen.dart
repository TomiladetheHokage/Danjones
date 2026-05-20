import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/p2p/p2p_info_row.dart';
import '../../widgets/p2p/p2p_status_timeline.dart';
import '../../widgets/p2p/p2p_big_timer.dart';
import 'p2p_order_completed_screen.dart';
import 'p2p_chat_screen.dart';
import 'p2p_appeal_screen.dart';

class P2POrderReviewScreen extends StatefulWidget {
  final int tradeId;
  final double fiatAmount;
  final double cryptoAmount;
  final double pricePerUnit;
  final String currencySymbol;
  final String sellerName;

  const P2POrderReviewScreen({
    super.key,
    required this.tradeId,
    required this.fiatAmount,
    required this.cryptoAmount,
    required this.pricePerUnit,
    required this.currencySymbol,
    required this.sellerName,
  });

  @override
  State<P2POrderReviewScreen> createState() => _P2POrderReviewScreenState();
}

class _P2POrderReviewScreenState extends State<P2POrderReviewScreen> {
  Timer? _pollTimer;
  bool _navigating = false;

  // Poll every 5 seconds — industry standard for P2P order status
  static const Duration _pollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Check immediately on load, then every 5s
    _checkStatus();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_navigating || !mounted) return;

    try {
      final trades = await ApiService.getMyP2pTrades();
      if (!mounted) return;

      final match = trades.cast<dynamic>().firstWhere(
        (t) => t.id == widget.tradeId,
        orElse: () => null,
      );

      if (match == null) return;

      final status = (match.status as String? ?? '').toLowerCase();

      if (status == 'completed' || status == 'released') {
        _navigating = true;
        _pollTimer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => P2POrderCompletedScreen(
              tradeId: widget.tradeId,
              fiatAmount: widget.fiatAmount,
              cryptoAmount: widget.cryptoAmount,
              pricePerUnit: widget.pricePerUnit,
              currencySymbol: widget.currencySymbol,
              sellerName: widget.sellerName,
            ),
          ),
        );
      }
    } catch (_) {
      // Silently ignore poll errors — will retry on next tick
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
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order #${widget.tradeId}',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Text(
              'Seller is releasing crypto...',
              style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please pay the seller within',
              style: AppTheme.inter(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),

            const P2PBigTimer(minutes: 14, seconds: 59),
            const SizedBox(height: 24),

            Text(
              'Escrow Protected',
              style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '95% of orders are completed within 15 minutes.',
              style: AppTheme.inter(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 24),

            const P2PStatusTimeline(currentStep: 2),
            const SizedBox(height: 32),

            P2PInfoRow(label: 'Fiat Amount', value: '${_formatMoney(widget.fiatAmount)} NGN'),
            P2PInfoRow(label: 'Price', value: '₦${_formatMoney(widget.pricePerUnit)} / ${widget.currencySymbol}'),
            P2PInfoRow(label: 'Receive Quantity', value: '${widget.cryptoAmount.toStringAsFixed(8)} ${widget.currencySymbol}'),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFE4B53E), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Do not cancel the order',
                          style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Since you have already made the payment, cancelling now may result in loss of funds. Wait for the seller to release.',
                          style: AppTheme.inter(color: Colors.white60, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const P2PAppealScreen(isBuyer: true)),
                  ),
                  child: Text(
                    'Appeal',
                    style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const P2PChatScreen()),
                  ),
                  icon: Image.asset(
                    'assets/icons/message.png',
                    width: 22,
                    height: 22,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFFE4B53E),
                      size: 18,
                    ),
                  ),
                  label: Text(
                    'Open Chat',
                    style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            // Polling indicator
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Waiting for seller to release...',
                  style: AppTheme.inter(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
