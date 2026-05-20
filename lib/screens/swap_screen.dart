import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/wallet.dart';
import '../services/data_store.dart';
import '../theme/app_theme.dart';

class SwapScreen extends StatefulWidget {
  final bool showBackButton;
  const SwapScreen({super.key, this.showBackButton = false});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final TextEditingController _payController = TextEditingController(text: '0.0');

  Wallet? _payWallet;
  Wallet? _receiveWallet;

  List<Wallet> get _cryptoWallets => (DataStore.instance.dashboard.value?.wallets ?? [])
      .where((w) => w.currency.symbol.toUpperCase() != 'NGN')
      .toList();

  @override
  void initState() {
    super.initState();
    final wallets = _cryptoWallets;
    if (wallets.isNotEmpty) _payWallet = wallets.first;
    if (wallets.length > 1) _receiveWallet = wallets[1];
  }

  @override
  void dispose() {
    _payController.dispose();
    super.dispose();
  }

  void _swapTokens() {
    setState(() {
      final tmp = _payWallet;
      _payWallet = _receiveWallet;
      _receiveWallet = tmp;
    });
  }

  Future<void> _pickToken({required bool isPay}) async {
    final wallets = _cryptoWallets;
    final picked = await showModalBottomSheet<Wallet>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TokenPickerSheet(
        wallets: wallets,
        exclude: isPay ? _receiveWallet : _payWallet,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isPay) {
        _payWallet = picked;
      } else {
        _receiveWallet = picked;
      }
    });
  }

  String _rateLabel() {
    if (_payWallet == null || _receiveWallet == null) return '';
    return '1 ${_payWallet!.currency.symbol.toUpperCase()} ≈ ? ${_receiveWallet!.currency.symbol.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: widget.showBackButton ? 56 : 100,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  'Swap',
                  style: AppTheme.inter(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
        title: Text(
          'Swap',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You Pay', style: AppTheme.inter(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 12),
            _buildAmountBox(
              controller: _payController,
              wallet: _payWallet,
              onTokenTap: () => _pickToken(isPay: true),
            ),
            const SizedBox(height: 8),
            Text(
              _payWallet != null
                  ? 'Balance: ${_payWallet!.balance} ${_payWallet!.currency.symbol.toUpperCase()}'
                  : 'Balance: —',
              style: AppTheme.inter(color: Colors.white60, fontSize: 11),
            ),

            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _swapTokens,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward_rounded, color: Color(0xFFE4B53E), size: 22),
                      Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('You Receive', style: AppTheme.inter(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 12),
            _buildAmountBox(
              controller: null,
              wallet: _receiveWallet,
              onTokenTap: () => _pickToken(isPay: false),
              readOnly: true,
            ),
            const SizedBox(height: 8),
            Text(
              _receiveWallet != null
                  ? 'Balance: ${_receiveWallet!.balance} ${_receiveWallet!.currency.symbol.toUpperCase()}'
                  : 'Balance: —',
              style: AppTheme.inter(color: Colors.white60, fontSize: 11),
            ),

            const SizedBox(height: 40),
            if (_payWallet != null && _receiveWallet != null)
              Center(
                child: Text(
                  _rateLabel(),
                  style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 40),
            _buildSwapButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBox({
    required TextEditingController? controller,
    required Wallet? wallet,
    required VoidCallback onTokenTap,
    bool readOnly = false,
  }) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: controller != null
                ? TextField(
                    controller: controller,
                    readOnly: readOnly,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTheme.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    '0.0',
                    style: AppTheme.inter(color: Colors.white38, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
          ),
          GestureDetector(
            onTap: onTokenTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (wallet != null)
                  _TokenIcon(imageUrl: wallet.currency.fullImageUrl, symbol: wallet.currency.symbol)
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.token, color: Colors.white24, size: 18),
                  ),
                const SizedBox(width: 6),
                Text(
                  wallet?.currency.symbol.toUpperCase() ?? 'Select',
                  style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE4B53E), size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          if (_payWallet == null || _receiveWallet == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Text(
                  'Please select both tokens before swapping.',
                  style: AppTheme.inter(color: Colors.white70, fontSize: 13),
                ),
              ),
            );
            return;
          }
          _showTransactionBottomSheet(context);
        },
        child: Text(
          'Swap',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  void _showTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SwapTransactionBottomSheet(
        payWallet: _payWallet,
        receiveWallet: _receiveWallet,
        payAmount: _payController.text,
      ),
    );
  }
}

// ── Token icon helper ─────────────────────────────────────────────────────────
class _TokenIcon extends StatelessWidget {
  final String imageUrl;
  final String symbol;
  final double size;

  const _TokenIcon({required this.imageUrl, required this.symbol, this.size = 32});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFE4B53E)),
        ),
        errorWidget: (context, url, error) => _fallback(),
      );
    }
    return Image.asset(
      'assets/icons/${symbol.toUpperCase()}.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback() => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E1E1E)),
        child: const Icon(Icons.token, color: Colors.white24, size: 18),
      );
}

// ── Token picker bottom sheet ─────────────────────────────────────────────────
class _TokenPickerSheet extends StatelessWidget {
  final List<Wallet> wallets;
  final Wallet? exclude;

  const _TokenPickerSheet({required this.wallets, this.exclude});

  @override
  Widget build(BuildContext context) {
    final available = wallets.where((w) => w.id != exclude?.id).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Token',
              style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (available.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No tokens available',
                  style: AppTheme.inter(color: Colors.white38, fontSize: 14),
                ),
              )
            else
              ...available.map((w) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: _TokenIcon(
                      imageUrl: w.currency.fullImageUrl,
                      symbol: w.currency.symbol,
                      size: 40,
                    ),
                    title: Text(
                      w.currency.symbol.toUpperCase(),
                      style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      w.currency.name,
                      style: AppTheme.inter(color: Colors.white38, fontSize: 12),
                    ),
                    trailing: Text(
                      w.balance,
                      style: AppTheme.inter(color: Colors.white60, fontSize: 13),
                    ),
                    onTap: () => Navigator.pop(context, w),
                  )),
          ],
        ),
      ),
    );
  }
}

// ── Swap confirmation bottom sheet ────────────────────────────────────────────
class SwapTransactionBottomSheet extends StatelessWidget {
  final Wallet? payWallet;
  final Wallet? receiveWallet;
  final String payAmount;

  const SwapTransactionBottomSheet({
    super.key,
    required this.payWallet,
    required this.receiveWallet,
    required this.payAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Swap Transaction',
              style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            _buildTokensVisualRow(),
            const SizedBox(height: 40),
            _buildAddressRow('From:', payWallet?.address ?? '—'),
            const SizedBox(height: 20),
            _buildAddressRow('To:', receiveWallet?.address ?? '—'),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            _buildSummaryRow('Network fees', '—'),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            _buildSummaryRow(
              'You Pay',
              '$payAmount ${payWallet?.currency.symbol.toUpperCase() ?? ''}',
              isBold: true,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE4B53E), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please double check recipient address',
                      style: AppTheme.inter(color: Colors.white60, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildConfirmButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTokensVisualRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTokenInfo(payWallet, payAmount),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: const Icon(Icons.compare_arrows_rounded, color: Color(0xFFE4B53E), size: 24),
        ),
        _buildTokenInfo(receiveWallet, '?', isRightAlign: true),
      ],
    );
  }

  Widget _buildTokenInfo(Wallet? wallet, String amount, {bool isRightAlign = false}) {
    return Column(
      crossAxisAlignment: isRightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1A1A),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          alignment: Alignment.center,
          child: wallet != null
              ? _TokenIcon(imageUrl: wallet.currency.fullImageUrl, symbol: wallet.currency.symbol, size: 24)
              : const Icon(Icons.token, color: Colors.white24, size: 22),
        ),
        const SizedBox(height: 16),
        Text(
          '$amount ${wallet?.currency.symbol.toUpperCase() ?? ''}',
          style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          wallet?.currency.name ?? '—',
          style: AppTheme.inter(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAddressRow(String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  address,
                  style: AppTheme.inter(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.copy_rounded, color: Color(0xFFE4B53E), size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.inter(color: Colors.white60, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          value,
          style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () => _showSuccessDialog(context),
        child: Text(
          'Confirm',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Transaction Confirmed',
                style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 48),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE4B53E), width: 3),
                ),
                child: const Icon(Icons.check, color: Color(0xFFE4B53E), size: 40),
              ),
              const SizedBox(height: 48),
              Text(
                'Your swap has been processed successfully. The tokens will reflect in your wallet shortly.',
                style: AppTheme.inter(color: Colors.white70, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(
                    'Done',
                    style: AppTheme.inter(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
