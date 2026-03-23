import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_info_row.dart';
import '../../widgets/p2p/p2p_status_timeline.dart';
import '../../widgets/p2p/p2p_big_timer.dart';
import 'p2p_order_completed_screen.dart';
import 'p2p_chat_screen.dart';
import 'p2p_appeal_screen.dart';

class P2POrderReviewScreen extends StatelessWidget {
  const P2POrderReviewScreen({super.key});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Text('Seller is releasing crypto...', style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Please pay the seller within', style: AppTheme.inter(color: Colors.white54, fontSize: 13)), // Utilizing specific Figma text blueprint
            const SizedBox(height: 24),
            
            const P2PBigTimer(minutes: 14, seconds: 59),
            const SizedBox(height: 24),
            
            Text('Escrow Protected', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('95% of orders are completed within 15 minutes.', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 24),
            
            const P2PStatusTimeline(currentStep: 2),
            const SizedBox(height: 32),
            
            const P2PInfoRow(label: 'Fiat Amount', value: '125,000.00 NGN'), 
            const P2PInfoRow(label: 'Price', value: '1,250.00 NGN'),
            const P2PInfoRow(label: 'Receive Quantity', value: '100 USDT'),
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                        Text('Do not cancel the order', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12, fontWeight: FontWeight.bold)),
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const P2PAppealScreen(isBuyer: true)));
                  },
                  child: Text('Appeal', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const P2PChatScreen()));
                  },
                  icon: Image.asset('assets/icons/message.png', width: 22, height: 22, errorBuilder: (c,e,s) => const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFE4B53E), size: 18)),
                  label: Text('Open Chat', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const P2POrderCompletedScreen())),
                child: Text('Simulate Seller Release (Test Button)', style: AppTheme.inter(color: Colors.white38, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
