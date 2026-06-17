import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_user_header.dart';
import '../../widgets/p2p/p2p_warning_box.dart';
import '../../widgets/p2p/p2p_big_timer.dart';
import 'p2p_appeal_screen.dart';
import 'p2p_chat_screen.dart';

class P2PSellerReleaseScreen extends StatefulWidget {
  final int tradeId;
  final double fiatAmount;
  final double cryptoAmount;
  final String currencySymbol;
  final String buyerName;
  final DateTime? createdAt;
  final String? bankName;

    final String? buyerAvatar;

    const P2PSellerReleaseScreen({
    super.key,
    required this.tradeId,
    required this.fiatAmount,
    required this.cryptoAmount,
    required this.currencySymbol,
    required this.buyerName,
    this.createdAt,
    this.bankName,
    this.buyerAvatar,
  });

  @override
  State<P2PSellerReleaseScreen> createState() => _P2PSellerReleaseScreenState();
}

class _P2PSellerReleaseScreenState extends State<P2PSellerReleaseScreen> {
  bool _isReleasing = false;
  bool _bankConfirmed = false;

  Future<void> _confirmRelease() async {
    setState(() => _isReleasing = true);
    try {
      await ApiService.completeP2pTrade(tradeId: widget.tradeId);
      if (!mounted) return;
      await _showComingSoonPopup('Crypto released successfully');
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showErrorPopup(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isReleasing = false);
    }
  }

  void _showErrorPopup(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1D21),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4B53E).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFE4B53E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Release Failed',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTheme.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showComingSoonPopup(String message) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1D21),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4B53E).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    color: Color(0xFFE4B53E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Coming Soon',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTheme.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          style: AppTheme.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Text(
              'Confirm Payment Receipt',
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please verify the exact amount has been\ncredited to your bank account.',
              style: AppTheme.inter(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            const P2PBigTimer(minutes: 14, seconds: 59),
            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Text(
                    'You are receiving',
                    style: AppTheme.inter(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₦${widget.fiatAmount.toStringAsFixed(2)}',
                    style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Crypto to Release ${widget.cryptoAmount.toStringAsFixed(8)} ${widget.currencySymbol}',
                    style: AppTheme.inter(
                      color: const Color(0xFFE4B53E),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buyer Information',
                    style: AppTheme.inter(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  P2PUserHeader(
                    name: widget.buyerName,
                     avatarUrl: widget.buyerAvatar,
                    isOnline: true,
                    onChatTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => P2PChatScreen(
                            tradeId: widget.tradeId,
                            fiatAmount: widget.fiatAmount,
                            cryptoAmount: widget.cryptoAmount,
                            currencySymbol: widget.currencySymbol,
                            counterpartyName: widget.buyerName,
                            counterpartyAvatar: widget.buyerAvatar,
                            isBuyer: false,
                            createdAt: widget.createdAt,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank Transfer',
                            style: AppTheme.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.bankName ?? 'Bank Transfer',
                            style: AppTheme.inter(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Instant',
                        style: AppTheme.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const P2PWarningBox(
              highlightedPrefix: 'Do not release crypto ',
              message:
                  'Do not release crypto until you have logged into your bank account and confirmed the money has arrived. SMS alerts can be fake.',
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => setState(() => _bankConfirmed = !_bankConfirmed),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _bankConfirmed ? const Color(0xFFE4B53E) : Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFFE4B53E),
                        width: 1.5,
                      ),
                    ),
                    child: _bankConfirmed
                        ? const Icon(Icons.check, color: Colors.black, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I have logged into my bank app and confirmed the payment of ₦${widget.fiatAmount.toStringAsFixed(2)} is available in my balance.',
                      style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildPrimaryButton(
              context,
              _isReleasing ? 'Releasing...' : 'Confirm Release',
              (_isReleasing || !_bankConfirmed) ? null : _confirmRelease,
              hasArrow: !_isReleasing,
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _showPaymentNotReceivedModal(context),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE4B53E), width: 1),
                  color: Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  "I haven't received payment",
                  style: AppTheme.inter(
                    color: const Color(0xFFE4B53E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text,
    VoidCallback? onPressed, {
    bool hasArrow = false,
  }) {
    final isEnabled = onPressed != null;
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: isEnabled
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.2),
                  ],
                ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: AppTheme.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isEnabled ? Colors.black : Colors.grey,
              ),
            ),
            if (hasArrow && isEnabled) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.black,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPaymentNotReceivedModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Confirm Payment Receipt',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please verify the exact amount has been\ncredited to your bank account.',
                  style: AppTheme.inter(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildModalButton('Open Chat', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => P2PChatScreen(
                        tradeId: widget.tradeId,
                        fiatAmount: widget.fiatAmount,
                        cryptoAmount: widget.cryptoAmount,
                        currencySymbol: widget.currencySymbol,
                        counterpartyName: widget.buyerName,
                        counterpartyAvatar: widget.buyerAvatar,
                        isBuyer: false,
                        createdAt: widget.createdAt,
                      ),
                    ),
                  );
                }, true),
                const SizedBox(height: 16),
                _buildModalButton('File a Dispute', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                           P2PAppealScreen(
                           isBuyer: false,
                           tradeId: widget.tradeId,
                           fiatAmount: widget.fiatAmount,
                           counterpartyName: widget.buyerName,
                             counterpartyAvatar: widget.buyerAvatar,
                           currencySymbol: widget.currencySymbol,
                         ),
                    ),
                  );
                }, false),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Wait a Moment',
                    style: AppTheme.inter(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalButton(String text, VoidCallback onPressed, bool isFilled) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isFilled ? const Color(0xFFE4B53E) : Colors.transparent,
        border: isFilled ? null : Border.all(color: const Color(0xFFE4B53E)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTheme.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isFilled ? Colors.black : const Color(0xFFE4B53E),
          ),
        ),
      ),
    );
  }
}
