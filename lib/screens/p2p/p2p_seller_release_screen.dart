import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_user_header.dart';
import '../../widgets/p2p/p2p_warning_box.dart';
import '../../widgets/p2p/p2p_big_timer.dart';
import 'p2p_appeal_screen.dart';
import 'p2p_chat_screen.dart';
import 'p2p_order_completed_screen.dart';

class P2PSellerReleaseScreen extends StatelessWidget {
  const P2PSellerReleaseScreen({super.key});

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
            Text('Confirm Payment Receipt', style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Please verify the exact amount has been\ncredited to your bank account.', style: AppTheme.inter(color: Colors.white54, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
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
                  Text('You are receiving', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 12),
                  Text('₦125,000.00', style: AppTheme.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Crypto to Release 100.00 USDT', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12)),
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
                  Text('Buyer Information', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 16),
                  P2PUserHeader(
                    name: 'Chinedu_Crypto',
                    isOnline: true,
                    onChatTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const P2PChatScreen()));
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bank Transfer', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Kuda Microfinance Bank', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      Text('Instant', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const P2PWarningBox(
              highlightedPrefix: 'Do not release crypto ',
              message: 'Do not release crypto until you have logged into your bank account and confirmed the money has arrived. SMS alerts can be fake.',
            ),
            const SizedBox(height: 24),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE4B53E), width: 1.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'I have logged into my bank app and confirmed the payment of ₦125,000.00 is available in my balance.',
                    style: AppTheme.inter(color: Colors.white, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildPrimaryButton(context, 'Confirm Release', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const P2POrderCompletedScreen()));
            }, hasArrow: true),
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
                child: Text("I haven't received payment", style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String text, VoidCallback onPressed, {bool hasArrow = false}) {
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
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
            ),
            if (hasArrow) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
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
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                Text('Confirm Payment Receipt', style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Please verify the exact amount has been\ncredited to your bank account.', style: AppTheme.inter(color: Colors.white54, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                
                _buildModalButton('Open Chat', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const P2PChatScreen()));
                }, true),
                const SizedBox(height: 16),
                _buildModalButton('File a Dispute', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const P2PAppealScreen(isBuyer: false)));
                }, false),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Wait a Moment', style: AppTheme.inter(color: Colors.white54, fontSize: 14)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: isFilled ? Colors.black : const Color(0xFFE4B53E)),
        ),
      ),
    );
  }
}
