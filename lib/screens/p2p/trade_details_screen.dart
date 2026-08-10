import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/p2p/p2p_trade.dart';
import '../../services/api_service.dart';
import '../../services/data_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/user_avatar.dart';

class TradeDetailsScreen extends StatefulWidget {
  final P2PTrade trade;

  const TradeDetailsScreen({super.key, required this.trade});

  @override
  State<TradeDetailsScreen> createState() => _TradeDetailsScreenState();
}

class _TradeDetailsScreenState extends State<TradeDetailsScreen> {
  bool _isCanceling = false;

  Timer? _timer;
  late Duration _timeLeft;

  bool get _isSeller {
    final currentUserId = DataStore.instance.dashboard.value?.user.id;
    return currentUserId != null && currentUserId == widget.trade.sellerId;
  }

  bool get _isPending =>
      widget.trade.status.toLowerCase() == 'pending';

  @override
  void initState() {
    super.initState();
    _timeLeft = _calcTimeLeft();
    if (_isPending) _startTimer();
  }

  Duration _calcTimeLeft() {
    if (widget.trade.createdAt == null) return Duration.zero;
    const window = Duration(minutes: 15);
    final elapsed = DateTime.now().difference(widget.trade.createdAt!);
    final remaining = window - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final cur = _timeLeft;
      if (cur.inSeconds <= 0) {
        _timer?.cancel();
      } else {
        setState(() => _timeLeft = cur - const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────
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

  String _formatCrypto(double v, String sym) {
    final f = v
        .toStringAsFixed(7)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return '$f $sym';
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} $h:$m $ampm';
  }

  String _countdown(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return const Color(0xFF33D17A);
      case 'cancelled':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFFE4B53E);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending Payment';
      case 'paid': return 'Paid';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  // ── Actions ────────────────────────────────────────────
  Future<void> _cancelTrade() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1E),
        title: Text('Cancel Trade?',
            style: AppTheme.inter(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'This will cancel order #${widget.trade.id}.',
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
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            child: Text('Cancel',
                style: AppTheme.inter(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    setState(() => _isCanceling = true);
    try {
      await ApiService.cancelP2pTrade(tradeId: widget.trade.id);
      if (!mounted) return;
      await _showToast(
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF33D17A),
        title: 'Order Cancelled',
        message: 'Your order has been cancelled successfully.',
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showToast(
        icon: Icons.error_outline_rounded,
        iconColor: Colors.redAccent,
        title: 'Cancel Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isCanceling = false);
    }
  }

  Future<void> _showToast({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return showModalBottomSheet(
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
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
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
                child: const Icon(Icons.close,
                    color: Colors.white54, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final trade = widget.trade;
    final sc = _statusColor(trade.status);

    // Side label: if the ad is a sell ad, the buyer is buying
    final currentUserId = DataStore.instance.dashboard.value?.user.id;
    final isBuyer = trade.buyerId == currentUserId;
    final adIsSell = trade.adType.toLowerCase() == 'sell';
    final isMyBuy = (isBuyer && adIsSell) || (!isBuyer && !adIsSell);
    final sideLabel = isMyBuy ? 'Buy' : 'Sell';
    final sideColor =
        isMyBuy ? const Color(0xFF33D17A) : const Color(0xFFFF6B6B);

    final counterpartyName =
        _isSeller ? trade.buyerName : trade.sellerName;
    final counterpartyRole = _isSeller ? 'Buyer' : 'Seller';
    final counterpartyInitials = counterpartyName.isNotEmpty
        ? counterpartyName
            .trim()
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    final counterpartyAvatar =
        _isSeller ? trade.buyerAvatar : trade.sellerAvatar;

    final orderId = 'DJ${trade.id.toString().padLeft(8, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: AppTheme.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined,
                color: Colors.white, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Main card ────────────────────────────
                  _mainCard(trade, sc, sideLabel, sideColor, orderId),

                  const SizedBox(height: 12),

                  // ── Payment Method card ───────────────────
                  _paymentCard(trade),

                  const SizedBox(height: 12),

                  // ── Counterparty card ─────────────────────
                  _counterpartyCard(
                    counterpartyRole,
                    counterpartyName,
                    counterpartyInitials,
                    counterpartyAvatar,
                    trade,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom action bar ──────────────────────────
          if (trade.isPending)
            _bottomActions(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Main card
  // ─────────────────────────────────────────────────────
  Widget _mainCard(
    P2PTrade trade,
    Color sc,
    String sideLabel,
    Color sideColor,
    String orderId,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge + side label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sc.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel(trade.status),
                  style: AppTheme.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sc),
                ),
              ),
              Text(
                '$sideLabel ${trade.currencySymbol}',
                style: AppTheme.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: sideColor),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Amount (centered)
          Center(
            child: Column(
              children: [
                Text(
                  'Amount',
                  style: AppTheme.inter(
                      fontSize: 13, color: Colors.white60),
                ),
                const SizedBox(height: 6),
                Text(
                  '₦${_formatMoney(trade.fiatAmount)}',
                  style: AppTheme.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCrypto(trade.cryptoAmount, trade.currencySymbol),
                  style:
                      AppTheme.inter(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Divider(
              color: Colors.white.withValues(alpha: 0.07), height: 1),
          const SizedBox(height: 16),

          // Info rows
          _detailRow('Price',
              '₦${_formatMoney(trade.adPrice)}'),
          const SizedBox(height: 12),
          _detailRow(
            'Order ID',
            orderId,
            trailing: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: orderId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin:
                        const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text('Order ID copied',
                        style: AppTheme.inter(
                            color: Colors.white, fontSize: 13)),
                  ),
                );
              },
              child: const Icon(Icons.copy_rounded,
                  color: Colors.white54, size: 16),
            ),
          ),
          if (_isPending) ...[
            const SizedBox(height: 12),
            _detailRow(
              'Time Left To Pay',
              _countdown(_timeLeft),
              valueColor: _timeLeft.inSeconds > 0
                  ? const Color(0xFFFF4444)
                  : Colors.white38,
              valueFontSize: 16,
              valueFontWeight: FontWeight.bold,
            ),
          ],
          const SizedBox(height: 12),
          _detailRow(
            'Created Time',
            _formatDateTime(trade.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Widget? trailing,
    Color? valueColor,
    double valueFontSize = 13,
    FontWeight valueFontWeight = FontWeight.w600,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTheme.inter(fontSize: 13, color: Colors.white60),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTheme.inter(
                fontSize: valueFontSize,
                fontWeight: valueFontWeight,
                color: valueColor ?? Colors.white,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing,
            ],
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // Payment Method card
  // ─────────────────────────────────────────────────────
  Widget _paymentCard(P2PTrade trade) {
    final bankName = trade.bankName;
    final accountNumber = trade.bankAccountNumber;
    final accountName = trade.bankAccountName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: AppTheme.inter(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 14),
          if (bankName == null)
            Text('—', style: AppTheme.inter(color: Colors.white38, fontSize: 13))
          else
            _bankMethodTile(
              bankName: bankName,
              accountNumber: accountNumber,
              accountName: accountName,
            ),
        ],
      ),
    );
  }

  Widget _bankMethodTile({
    required String bankName,
    String? accountNumber,
    String? accountName,
  }) {
    // Deterministic accent colour from bank name — mirrors create_ad_screen
    const accentColors = [
      Color(0xFF33D17A),
      Color(0xFF8B5CF6),
      Color(0xFFE4B53E),
      Color(0xFF60A5FA),
      Color(0xFFFF6B6B),
    ];
    final accent = accentColors[bankName.hashCode.abs() % accentColors.length];

    final masked = (accountNumber != null && accountNumber.length > 4)
        ? '${bankName}  •••• ${accountNumber.substring(accountNumber.length - 4)}'
        : bankName;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Coloured left bar
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: AppTheme.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  accountName != null && accountName.isNotEmpty
                      ? '$accountName  ·  $masked'
                      : masked,
                  style: AppTheme.inter(
                      fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
          // Account number badge
          if (accountNumber != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Text(
                accountNumber,
                style: AppTheme.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Counterparty card
  // ─────────────────────────────────────────────────────
  Widget _counterpartyCard(
    String role,
    String name,
    String initials,
    String? avatarUrl,
    P2PTrade trade,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: AppTheme.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              UserAvatar(name: name, avatarUrl: avatarUrl, radius: 23),
              const SizedBox(width: 12),
              // Name + verified
              Expanded(
                child: Row(
                  children: [
                    Text(
                      name,
                      style: AppTheme.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified_rounded,
                        color: Color(0xFFE4B53E), size: 16),
                  ],
                ),
              ),
              // Chat + chevron
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      color: Color(0xFFE4B53E), size: 22),
                  const SizedBox(width: 12),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white54, size: 22),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Bottom action bar
  // ─────────────────────────────────────────────────────
  Widget _bottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: _isCanceling ? null : _cancelTrade,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE4B53E), width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _isCanceling
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFE4B53E)),
                )
              : Text(
                  'Cancel Order',
                  style: AppTheme.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE4B53E),
                  ),
                ),
        ),
      ),
    );
  }
}
