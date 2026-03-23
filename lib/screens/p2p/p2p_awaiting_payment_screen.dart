import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_user_header.dart';
import '../../widgets/p2p/p2p_warning_box.dart';
import '../../widgets/p2p/p2p_big_timer.dart';
import 'p2p_order_review_screen.dart';
import 'p2p_chat_screen.dart';

class P2PAwaitingPaymentScreen extends StatelessWidget {
  const P2PAwaitingPaymentScreen({super.key});

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
        title: Text('Order #29384920', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Text('Awaiting Payment', style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Please pay the seller within', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
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
                  Text('Total Amount', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 12),
                  Text('₦125,000.00', style: AppTheme.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Buy 100.00 USDT @ ₦1,250.00', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12)),
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
                  P2PUserHeader(
                    name: 'CryptoKingNG',
                    isOnline: true,
                    onChatTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const P2PChatScreen()));
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildCopyRow('Bank Name', 'Kuda Microfinance Bank'),
                  const SizedBox(height: 16),
                  _buildCopyRow('Account Number', '2039 485 722', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const P2PWarningBox(
              highlightedPrefix: 'Do not include crypto-related terms ',
              message: 'Do not include crypto-related terms (e.g., BTC, USDT, Crypto) in the bank transfer remarks to avoid transaction failure.',
            ),
            const SizedBox(height: 32),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel Order', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            
            _buildPrimaryButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
          ],
        ),
        const Icon(Icons.copy_rounded, color: Color(0xFFE4B53E), size: 18),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const P2POrderReviewScreen()),
          );
        },
        child: Text(
          'I have Paid',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
