import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import '../../models/wallet.dart';
import '../../services/api_service.dart';
import '../../services/data_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_dialog.dart';

class WithdrawFormScreen extends StatefulWidget {
  final Wallet wallet;
  const WithdrawFormScreen({super.key, required this.wallet});

  @override
  State<WithdrawFormScreen> createState() => _WithdrawFormScreenState();
}

class _WithdrawFormScreenState extends State<WithdrawFormScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  bool _isSubmitting = false;

  // Daily limit — static for now, replace with API when available
  static const double _dailyLimit = 5000000;

  // Used today — derived from wallet's current USD balance as a proxy.
  // Replace with a real /wallets/withdrawals/today endpoint when available.
  double get _usedToday {
    final wallets = DataStore.instance.dashboard.value?.wallets ?? [];
    // Sum all crypto wallet USD balances as a rough proxy for activity
    final total = wallets.fold<double>(
      0,
      (sum, w) => sum + w.balanceUsd.toDouble(),
    );
    // Cap at daily limit so the bar never overflows
    return total.clamp(0, _dailyLimit);
  }

  double get _remainingLimit =>
      (_dailyLimit - _usedToday).clamp(0, _dailyLimit);

  double get _balance => double.tryParse(widget.wallet.balance) ?? 0.0;

  double get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

  // Fee is 0 until the API provides it
  double get _fee => 0.0;

  double get _youReceive => (_amount - _fee).clamp(0, double.infinity);

  bool get _canSubmit =>
      _addressController.text.trim().isNotEmpty &&
      _amount > 0 &&
      _amount <= _balance &&
      !_isSubmitting;

  String? get _amountError {
    if (_amountController.text.isEmpty) return null;
    if (_amount <= 0) return 'Enter a valid amount';
    if (_amount > _balance) return 'Insufficient balance';
    return null;
  }

  @override
  void initState() {
    super.initState();
    _addressFocus.addListener(() => setState(() {}));
    _amountFocus.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
    _addressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _addressFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _setMax() {
    _amountController.text =
        _balance.toStringAsFixed(widget.wallet.currency.decimalPlaces);
  }

  void _pasteAddress() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _addressController.text = data!.text!;
      setState(() {});
    }
  }

  String _formatMoney(double v) {
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
    return v.toStringAsFixed(2);
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/wallets/send'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.authToken}',
        },
        body: jsonEncode({
          'currency_id': widget.wallet.currencyId,
          'amount': _amount,
          'recipient_address': _addressController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final success = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] != false;

      if (success) {
        CustomDialog.showSuccess(
          context,
          title: 'Withdrawal Submitted',
          message:
              'Your withdrawal of ${_amountController.text} ${widget.wallet.currency.symbol.toUpperCase()} has been submitted and is being processed.',
          buttonText: 'Done',
          onButtonPressed: () {
            Navigator.of(context).pop(); // close dialog
            Navigator.of(context).pop(); // back to select coin
            Navigator.of(context).pop(); // back to asset details
          },
        );
      } else {
        final msg = data['message'] as String? ??
            'Withdrawal failed. Please try again.';
        CustomDialog.showError(context, title: 'Withdrawal Failed', message: msg);
      }
    } catch (e) {
      if (!mounted) return;
      CustomDialog.showError(
        context,
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = widget.wallet.currency.symbol.toUpperCase();
    final imageUrl = widget.wallet.currency.fullImageUrl;

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
          'Withdraw',
          style: AppTheme.inter(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoinHeader(imageUrl, symbol),
              const SizedBox(height: 24),

              _buildSectionLabel('Withdrawal Address'),
              const SizedBox(height: 8),
              _buildAddressField(),
              const SizedBox(height: 20),

              _buildSectionLabel('Amount'),
              const SizedBox(height: 8),
              _buildAmountField(symbol),
              if (_amountError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _amountError!,
                  style: AppTheme.inter(color: Colors.redAccent, fontSize: 12),
                ),
              ],
              const SizedBox(height: 20),

              _buildSummaryCard(symbol),
              const SizedBox(height: 20),

              _buildLimitsCard(),
              const SizedBox(height: 20),

              _buildSecurityNote(),
              const SizedBox(height: 32),

              _buildSubmitButton(symbol),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Coin header ──────────────────────────────────────────────────────────────
  Widget _buildCoinHeader(String imageUrl, String symbol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: ClipOval(
              child: imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.token, color: Colors.white24, size: 28),
                    )
                  : const Icon(Icons.token, color: Colors.white24, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symbol,
                    style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(widget.wallet.currency.name,
                    style: AppTheme.inter(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Available',
                  style: AppTheme.inter(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                '${widget.wallet.balance} $symbol',
                style: AppTheme.inter(
                    color: const Color(0xFFE4B53E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) => Text(
        text,
        style: AppTheme.inter(
            color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
      );

  // ── Address field ────────────────────────────────────────────────────────────
  Widget _buildAddressField() {
    final focused = _addressFocus.hasFocus;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused
              ? const Color(0xFFE4B53E)
              : Colors.white.withValues(alpha: 0.07),
          width: focused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addressController,
              focusNode: _addressFocus,
              style: AppTheme.inter(color: Colors.white, fontSize: 13),
              cursorColor: const Color(0xFFE4B53E),
              decoration: InputDecoration(
                hintText: 'Enter or paste wallet address',
                hintStyle: AppTheme.inter(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: _pasteAddress,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Paste',
                style: AppTheme.inter(
                    color: const Color(0xFFE4B53E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Amount field ─────────────────────────────────────────────────────────────
  Widget _buildAmountField(String symbol) {
    final focused = _amountFocus.hasFocus;
    final hasError = _amountError != null;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError
              ? Colors.redAccent.withValues(alpha: 0.6)
              : focused
                  ? const Color(0xFFE4B53E)
                  : Colors.white.withValues(alpha: 0.07),
          width: focused || hasError ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              focusNode: _amountFocus,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              cursorColor: const Color(0xFFE4B53E),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: AppTheme.inter(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixText: symbol,
                suffixStyle: AppTheme.inter(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: _setMax,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE4B53E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'MAX',
                style: AppTheme.inter(
                    color: const Color(0xFFE4B53E),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary card ─────────────────────────────────────────────────────────────
  Widget _buildSummaryCard(String symbol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          _summaryRow('Withdrawal Fee', _amount > 0 ? '0.00 $symbol' : '—'),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 12),
          _summaryRow(
            'You Receive',
            _amount > 0
                ? '${_youReceive.toStringAsFixed(widget.wallet.currency.decimalPlaces)} $symbol'
                : '—',
            valueColor: _amount > 0 ? const Color(0xFF33D17A) : Colors.white38,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
        Text(
          value,
          style: AppTheme.inter(
            color: valueColor ?? Colors.white,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Limits card ──────────────────────────────────────────────────────────────
  Widget _buildLimitsCard() {
    final used = _usedToday;
    final remaining = _remainingLimit;
    final progress = (used / _dailyLimit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          _summaryRow('Daily Limit', '₦${_formatMoney(_dailyLimit)}'),
          const SizedBox(height: 10),
          _summaryRow('Used Today', '₦${_formatMoney(used)}'),
          const SizedBox(height: 10),
          _summaryRow(
            'Remaining',
            '₦${_formatMoney(remaining)}',
            valueColor: const Color(0xFFE4B53E),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFE4B53E)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Security note ────────────────────────────────────────────────────────────
  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFE4B53E).withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined,
              color: Color(0xFFE4B53E), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Always double-check the recipient address. Crypto transactions are irreversible. Danjones cannot recover funds sent to the wrong address.',
              style: AppTheme.inter(
                  color: Colors.white54, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit button ────────────────────────────────────────────────────────────
  Widget _buildSubmitButton(String symbol) {
    return AnimatedOpacity(
      opacity: _canSubmit ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: _canSubmit ? _submit : null,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.center,
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.black)),
                )
              : Text(
                  'Withdraw $symbol',
                  style: AppTheme.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
