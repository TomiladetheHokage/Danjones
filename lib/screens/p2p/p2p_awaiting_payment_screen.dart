import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'p2p_order_review_screen.dart';

class P2PAwaitingPaymentScreen extends StatefulWidget {
  final int tradeId;
  final double fiatAmount;
  final double cryptoAmount;
  final double pricePerUnit;
  final String currencySymbol;
  final String currencyImage;
  final String sellerName;
  final DateTime? createdAt;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;

    final String? sellerAvatar;

    const P2PAwaitingPaymentScreen({
    super.key,
    required this.tradeId,
    required this.fiatAmount,
    required this.cryptoAmount,
    required this.pricePerUnit,
    required this.currencySymbol,
    required this.currencyImage,
    required this.sellerName,
    this.createdAt,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.sellerAvatar,
  });

  @override
  State<P2PAwaitingPaymentScreen> createState() => _P2PAwaitingPaymentScreenState();
}

class _P2PAwaitingPaymentScreenState extends State<P2PAwaitingPaymentScreen> {
  late Timer _timer;
  int _secondsRemaining = 900; // 15 minutes
  bool _isLoading = false;
  dynamic _paymentProof; // XFile or File, depending on platform

  bool get _hasBankDetails =>
      widget.bankName != null && 
      widget.bankName!.isNotEmpty && 
      widget.bankAccountNumber != null && 
      widget.bankAccountNumber!.isNotEmpty;

  String get _statusDisplay => _hasBankDetails ? 'Online' : 'Pending';

  @override
  void initState() {
    super.initState();
    if (widget.createdAt != null) {
      final elapsed = DateTime.now().difference(widget.createdAt!).inSeconds;
      _secondsRemaining = (900 - elapsed).clamp(0, 900);
    }
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final reversedIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '${buffer.toString()}.${parts[1]}';
  }

  Future<void> _copyValue(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFE4B53E), size: 20),
            const SizedBox(width: 10),
            Text(
              '$label copied',
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: const Color(0xFFE4B53E).withOpacity(0.3)),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 2),
        elevation: 6,
      ),
    );
  }

  Future<void> _pickPaymentProof() async {
    // Let the user choose between camera and gallery via a bottom sheet
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Upload Payment Proof',
              style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4B53E).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFFE4B53E), size: 20),
              ),
              title: Text('Choose from Gallery', style: AppTheme.inter(color: Colors.white, fontSize: 14)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4B53E).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFE4B53E), size: 20),
              ),
              title: Text('Take a Photo', style: AppTheme.inter(color: Colors.white, fontSize: 14)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() => _paymentProof = picked);
    }
  }

  Future<void> _handleMarkPaid() async {
    if (_paymentProof == null) {
      _showErrorDialog('Please upload your payment proof before proceeding.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fileBytes = await _paymentProof.readAsBytes();
      await ApiService.markP2pTradePaid(
        tradeId: widget.tradeId,
        paymentProofBytes: fileBytes,
        fileName: _paymentProof.name,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => P2POrderReviewScreen(
            tradeId: widget.tradeId,
            fiatAmount: widget.fiatAmount,
            cryptoAmount: widget.cryptoAmount,
            pricePerUnit: widget.pricePerUnit,
            currencySymbol: widget.currencySymbol,
            sellerName: widget.sellerName,
            sellerAvatar: widget.sellerAvatar,
            createdAt: widget.createdAt,
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

  Future<void> _handleCancel() async {
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
                  color: Colors.orangeAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orangeAccent,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cancel Order?',
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to cancel this order? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE4B53E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Keep Order',
                        style: AppTheme.inter(
                          color: const Color(0xFFE4B53E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performCancel();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performCancel() async {
    setState(() => _isLoading = true);

    try {
      await ApiService.cancelP2pTrade(tradeId: widget.tradeId);

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
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

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final amountText = _formatCurrency(widget.fiatAmount);
    final priceText = _formatCurrency(widget.pricePerUnit);
    final avatarText = widget.sellerName.isEmpty
        ? 'DJ'
        : widget.sellerName.substring(0, widget.sellerName.length >= 2 ? 2 : 1).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isLoading ? null : _handleCancel,
        ),
        title: Text(
          'Order #${widget.tradeId}',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Awaiting Payment',
              style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Please pay the seller within',
              style: AppTheme.inter(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimerBox(value: minutes, label: 'Min'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    ':',
                    style: AppTheme.inter(color: Colors.white38, fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
                _buildTimerBox(value: seconds, label: 'Sec'),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B1B1D), Color(0xFF141416)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: AppTheme.inter(color: Colors.white38, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '₦$amountText',
                    style: AppTheme.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Buy ${widget.cryptoAmount.toStringAsFixed(8)} ${widget.currencySymbol} @ ₦$priceText',
                    textAlign: TextAlign.center,
                    style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                        ClipOval(
                          child: widget.sellerAvatar != null && widget.sellerAvatar!.isNotEmpty
                            ? Image.network(
                                ApiService.resolveUrl(widget.sellerAvatar!) ?? widget.sellerAvatar!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Color(0xFFB88A2D), Color(0xFFE4B53E)],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      avatarText,
                                      style: AppTheme.inter(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  );
                                },
                              )
                            : Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFB88A2D), Color(0xFFE4B53E)],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          avatarText,
                          style: AppTheme.inter(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                            ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sellerName,
                              style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _statusDisplay,
                              style: AppTheme.inter(
                                color: _hasBankDetails ? const Color(0xFF28C76F) : Colors.orangeAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyValue(widget.sellerName, 'Seller name'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE4B53E).withOpacity(0.4)),
                          ),
                          child: const Icon(Icons.copy_rounded, color: Color(0xFFE4B53E), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_hasBankDetails) ...[
                    _buildBankRow(
                      label: 'Bank Name',
                      value: widget.bankName ?? '',
                      onTap: () => _copyValue(widget.bankName ?? '', 'Bank name'),
                    ),
                    const SizedBox(height: 14),
                    _buildBankRow(
                      label: 'Account Number',
                      value: widget.bankAccountNumber ?? '',
                      onTap: () => _copyValue(widget.bankAccountNumber ?? '', 'Account number'),
                    ),
                    if (widget.bankAccountName != null && widget.bankAccountName!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildBankRow(
                        label: 'Account Name',
                        value: widget.bankAccountName ?? '',
                        onTap: () => _copyValue(widget.bankAccountName ?? '', 'Account name'),
                      ),
                    ],
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1D1B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE4B53E).withOpacity(0.14)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE4B53E).withOpacity(0.8)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '!',
                                style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Seller has not provided bank details yet. Please contact them or wait for them to update their account.',
                                style: AppTheme.inter(color: Colors.white60, fontSize: 12, height: 1.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE4B53E).withOpacity(0.14)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE4B53E).withOpacity(0.8)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '!',
                      style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Do not include crypto-related terms (e.g., BTC, USDT, Crypto) in the bank transfer remarks to avoid transaction failure.',
                      style: AppTheme.inter(color: Colors.white60, fontSize: 12, height: 1.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // Payment proof upload
            GestureDetector(
              onTap: _isLoading ? null : _pickPaymentProof,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _paymentProof != null
                        ? const Color(0xFFE4B53E).withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: _paymentProof == null
                    ? Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4B53E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.upload_rounded, color: Color(0xFFE4B53E), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload Payment Proof',
                                  style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Tap to attach your transfer screenshot',
                                  style: AppTheme.inter(color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
                        ],
                      )
                    : Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? FutureBuilder<List<int>>(
                                    future: _paymentProof.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          Uint8List.fromList(snapshot.data!),
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey[800],
                                      );
                                    },
                                  )
                                : Image.file(
                                    File(_paymentProof.path),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Proof attached',
                                  style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Tap to change',
                                  style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: Color(0xFFE4B53E), size: 22),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: _isLoading ? null : _handleCancel,
              child: Text(
                'Cancel',
                style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleMarkPaid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4B53E),
                  disabledBackgroundColor: const Color(0xFFE4B53E).withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'I Have Paid',
                        style: AppTheme.inter(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerBox({required String value, required String label}) {
    final isCritical = _secondsRemaining < 300;
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.inter(
              color: isCritical ? Colors.redAccent : const Color(0xFFE4B53E),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.inter(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBankRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.inter(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4B53E).withOpacity(0.35)),
            ),
            child: const Icon(Icons.copy_rounded, color: Color(0xFFE4B53E), size: 16),
          ),
        ),
      ],
    );
  }
}
