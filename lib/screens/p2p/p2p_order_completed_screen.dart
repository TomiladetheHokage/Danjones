import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_info_row.dart';

class P2POrderCompletedScreen extends StatelessWidget {
  const P2POrderCompletedScreen({super.key});

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
        title: Text('Order Details', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE4B53E).withOpacity(0.2),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE4B53E),
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 36),
              ),
            ),
            const SizedBox(height: 24),
            
            Text('Order Completed', style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Assets have been released to your Funding Wallet', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 48),
            
            Text('100 USDT', style: AppTheme.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Transaction Successful', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 48),
            
            const P2PInfoRow(label: 'Total Payment', value: '125,000.00 NGN'),
            const P2PInfoRow(label: 'Price', value: '₦1,250.00 / USDT'),
            const P2PInfoRow(label: 'Seller', value: 'CryptoKing_NG'),
            const P2PInfoRow(label: 'Order No', value: '#29384920'),
            const SizedBox(height: 48),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How was your trading\nexperience?', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
                      const SizedBox(height: 4),
                      Text('Your feedback helps us improve', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.white54, size: 24),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_down_alt_outlined, color: Colors.white54, size: 24),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 64),
            
            _buildPrimaryButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
          // Navigate to root stack or home
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Text(
          'Back Home',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
