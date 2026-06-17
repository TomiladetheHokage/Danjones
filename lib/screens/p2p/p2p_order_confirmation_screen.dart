import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/p2p_ad.dart';
import '../../services/api_service.dart';
import '../../services/data_store.dart';
import '../../widgets/p2p/p2p_info_row.dart';
import '../../widgets/p2p/p2p_user_header.dart';
import '../../widgets/p2p/p2p_warning_box.dart';
import '../legal/terms_screen.dart';
import 'p2p_payment_method_screen.dart';
import 'p2p_awaiting_payment_screen.dart';
import 'p2p_seller_release_screen.dart';

class P2POrderConfirmationScreen extends StatefulWidget {
  final P2PAd ad;
  final double fiatAmount;
  final bool isSell;
  final int? sellTradeId;
  final double? sellCryptoAmount;
  final String? sellBuyerName;
  final String? sellBuyerAvatar;
  final DateTime? sellCreatedAt;
  final String? sellBankName;

  const P2POrderConfirmationScreen({
    super.key,
    required this.ad,
    this.fiatAmount = 0.0,
    this.isSell = false,
    this.sellTradeId,
    this.sellCryptoAmount,
    this.sellBuyerName,
    this.sellBuyerAvatar,
    this.sellCreatedAt,
    this.sellBankName,
  });

  @override
  State<P2POrderConfirmationScreen> createState() => _P2POrderConfirmationScreenState();
}

class _P2POrderConfirmationScreenState extends State<P2POrderConfirmationScreen> {
  late double _cryptoAmount;
  bool _isLoading = false;
  bool _isLoadingBankAccounts = false;
  List<Map<String, dynamic>> _bankAccounts = [];
  int _selectedBankIndex = 0;

  // Quote countdown
  static const int _quoteDuration = 59;
  int _quoteSeconds = _quoteDuration;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _cryptoAmount = widget.fiatAmount > 0 ? widget.fiatAmount / widget.ad.price : 0.0;
    _startQuoteTimer();
    if (widget.isSell) {
      _fetchBankAccounts();
    }
  }

  Future<void> _fetchBankAccounts() async {
    setState(() => _isLoadingBankAccounts = true);
    try {
      final accounts = await ApiService.getBankAccounts();
      if (!mounted) return;
      setState(() {
        _bankAccounts = accounts;
        if (_selectedBankIndex >= _bankAccounts.length) {
          _selectedBankIndex = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _bankAccounts = []);
    } finally {
      if (mounted) setState(() => _isLoadingBankAccounts = false);
    }
  }

  Future<void> _openAddBank() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const P2PPaymentMethodScreen()),
    );
    if (result == true || result == null) {
      _fetchBankAccounts();
    }
  }

  String _maskAccountNumber(String number) {
    if (number.length <= 4) return number;
    return '•••• ${number.substring(number.length - 4)}';
  }

  void _startQuoteTimer() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_quoteSeconds > 0) {
          _quoteSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  // Returns the user's real wallet balance for the traded coin.
  String _userBalance() {
    final wallets = DataStore.instance.dashboard.value?.wallets ?? [];
    final match = wallets.cast<dynamic>().firstWhere(
      (w) => w.currency.symbol.toLowerCase() == widget.ad.currencySymbol.toLowerCase(),
      orElse: () => null,
    );
    if (match == null) return '0.00 ${widget.ad.currencySymbol} available';
    return '${match.balance} ${widget.ad.currencySymbol} available';
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    if (widget.isSell) {
      if (widget.sellTradeId == null || widget.sellCryptoAmount == null || widget.sellBuyerName == null) {
        if (!mounted) return;
        _showErrorDialog('Trade details are missing. Please reopen this order.');
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => P2PSellerReleaseScreen(
            tradeId: widget.sellTradeId!,
            fiatAmount: widget.fiatAmount,
            cryptoAmount: widget.sellCryptoAmount!,
            currencySymbol: widget.ad.currencySymbol,
            buyerName: widget.sellBuyerName!,
            createdAt: widget.sellCreatedAt,
            bankName: widget.sellBankName ?? widget.ad.bankName,
            buyerAvatar: widget.sellBuyerAvatar,
          ),
        ),
      );
      return;
    }

    try {
      final response = await ApiService.initiateP2pTrade(
        advertisementId: widget.ad.id,
        amount: widget.fiatAmount,
      );

      final tradeData = (response['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final int tradeId = (tradeData['id'] as num?)?.toInt() ?? 0;
      final double fiatAmount = (tradeData['fiat_amount'] as num?)?.toDouble() ?? widget.fiatAmount;
      final double cryptoAmount = (tradeData['crypto_amount'] as num?)?.toDouble() ?? _cryptoAmount;

      DateTime? createdAt;
      final createdAtRaw = tradeData['created_at']?.toString();
      if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
        createdAt = DateTime.tryParse(createdAtRaw);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => P2PAwaitingPaymentScreen(
            tradeId: tradeId,
            fiatAmount: fiatAmount,
            cryptoAmount: cryptoAmount,
            pricePerUnit: widget.ad.price,
            currencySymbol: widget.ad.currencySymbol,
            currencyImage: widget.ad.currencyImage,
            sellerName: widget.ad.userName,
            createdAt: createdAt,
            bankName: widget.ad.bankName,
            bankAccountNumber: widget.ad.bankAccountNumber,
            bankAccountName: widget.ad.bankAccountName,
            sellerAvatar: widget.ad.userAvatar,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error',
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Okay',
                    style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        title: Text('Confirm Order', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: widget.isSell ? _buildSellOrderBody(context) : _buildBuyOrderBody(context),
      ),
    );
  }

  Widget _buildBuyOrderBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quote Timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFFE4B53E), size: 18),
              const SizedBox(width: 8),
              Text('Quote expires in', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('00:${_quoteSeconds.toString().padLeft(2, '0')} s', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // You Pay / Receive
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You Pay', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        'assets/icons/Ngn.png',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.green,
                          alignment: Alignment.center,
                          child: const Text('₦', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('NGN', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${widget.fiatAmount.toStringAsFixed(2)}', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFE4B53E), size: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Receive', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(widget.ad.currencySymbol, style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Image.network(
                      '${ApiService.rootUrl}${widget.ad.currencyImage}',
                      width: 32,
                      height: 32,
                      errorBuilder: (c, e, s) => Image.asset(
                        'assets/icons/${widget.ad.currencySymbol}.png',
                        width: 32,
                        height: 32,
                        errorBuilder: (c, e, s) => const CircleAvatar(backgroundColor: Colors.green, radius: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${_cryptoAmount.toStringAsFixed(8)}', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        P2PUserHeader(
          name: widget.ad.userName,
          avatarUrl: widget.ad.userAvatar,
          stats: _userBalance(),
          showBackground: true,
        ),
        const SizedBox(height: 24),

        P2PInfoRow(label: 'Price per unit', value: '${widget.ad.price.toStringAsFixed(2)} NGN'),
        P2PInfoRow(label: 'Quantity', value: '${_cryptoAmount.toStringAsFixed(8)} ${widget.ad.currencySymbol}'),
        P2PInfoRow(label: 'Terms', value: widget.ad.terms.isNotEmpty ? widget.ad.terms : 'No specific terms'),
        const SizedBox(height: 24),

        const P2PWarningBox(
          message: 'Do not include crypto-related terms (e.g., BTC, USDT, Crypto) in the bank transfer remarks to avoid transaction failure.',
        ),
        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Secured by Escrow', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              ),
              child: Text('Terms & Conditions', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildPrimaryButton(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSellOrderBody(BuildContext context) {
    final selectedBank = _bankAccounts.isNotEmpty ? _bankAccounts[_selectedBankIndex] : null;
    final bankName = selectedBank?['bank_name']?.toString() ??
        selectedBank?['bank']?['name']?.toString() ??
        'Bank Transfer';
    final accountNumber = selectedBank?['account_number']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFFE4B53E), size: 18),
              const SizedBox(width: 8),
              Text('Quote expires in', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('00:${_quoteSeconds.toString().padLeft(2, '0')} s', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('You will receive pay', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Text(
                _cryptoAmount.toStringAsFixed(8),
                style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(widget.ad.currencySymbol.toUpperCase(), style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'I will receive ${widget.fiatAmount.toStringAsFixed(2)} NGN',
          style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),

        P2PUserHeader(
          name: widget.ad.userName,
          avatarUrl: widget.ad.userAvatar,
          stats: _userBalance(),
          showBackground: true,
        ),
        const SizedBox(height: 22),

        Text('Payment Options', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2126),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('Bank Transfer', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 22),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bank Account', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: _openAddBank,
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Color(0xFFE4B53E), size: 16),
                  const SizedBox(width: 4),
                  Text('Add Bank', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isLoadingBankAccounts)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(color: Color(0xFFE4B53E), strokeWidth: 2),
            ),
          )
        else if (_bankAccounts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No bank account found yet. Add your bank details to continue.',
                  style: AppTheme.inter(color: Colors.white54, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _openAddBank,
                  child: Text(
                    'Add Bank',
                    style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedBankIndex,
                isExpanded: true,
                dropdownColor: const Color(0xFF151515),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                items: _bankAccounts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final account = entry.value;
                  final name = account['bank_name']?.toString() ??
                      account['bank']?['name']?.toString() ??
                      'Bank Transfer';
                  final number = account['account_number']?.toString() ?? '';
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      '$name ${_maskAccountNumber(number)}',
                      style: AppTheme.inter(color: Colors.white, fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedBankIndex = value);
                },
              ),
            ),
          ),

        if (!_isLoadingBankAccounts && _bankAccounts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '$bankName ${_maskAccountNumber(accountNumber)}',
            style: AppTheme.inter(color: Colors.white38, fontSize: 11),
          ),
        ],

        const SizedBox(height: 18),
        const P2PWarningBox(
          message: 'Do not include crypto-related terms (e.g., BTC, USDT, Crypto) in the bank transfer remarks to avoid transaction failure.',
        ),
        const SizedBox(height: 26),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Secured by Escrow', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              ),
              child: Text('Terms & Conditions', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildPrimaryButton(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    final isSellAndNoBank = widget.isSell && _bankAccounts.isEmpty;
    final canSubmit = !_isLoading && !isSellAndNoBank;

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
        onPressed: canSubmit ? _handleConfirm : null,
        child: Text(
          _isLoading
              ? 'Processing...'
              : (isSellAndNoBank ? 'Add Bank To Continue' : 'Confirm'),
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
