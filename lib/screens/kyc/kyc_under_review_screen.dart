import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../main_shell.dart';

class KycUnderReviewScreen extends StatelessWidget {
  const KycUnderReviewScreen({super.key});

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
        title: Text('KYC Verification', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Icon Background
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(color: const Color(0xFF1C1D21), borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Container(
                  width: 60, height: 60,
                  // decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)])),
                  child: Center(child: Image.asset('assets/icons/cloud-icon (1).png', width: 48)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Under Review Badge - Centered
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999), 
                  border: Border.all(color: const Color(0xFFE4B53E), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/timer-icon.png', width: 34, height: 24),
                    const SizedBox(width: 8),
                    Text('Under Review', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Verification Text - Left Aligned
            Text('Verification in Progress', style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              'We are currently reviewing your documents. This usually takes less than 5 minutes, but manual reviews may take up to 24 hours.', 
              textAlign: TextAlign.left, 
              style: AppTheme.inter(color: Colors.white38, fontSize: 13, height: 1.6)
            ),
            const SizedBox(height: 36),

            _buildTimeline(),
            const SizedBox(height: 20),

            // Why wait box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  // Image.asset('assets/icons/dislike.png', width: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Why wait?', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('You can explore the market and add coins to your watchlist while we verify your account.', 
                          style: AppTheme.inter(color: Colors.white38, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildOutlinedButton(label: 'Explore Markets', asset: 'assets/icons/market-icon.png', onTap: () {
              mainShellKey.currentState?.setTab(1);
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
            const SizedBox(height: 14),
            _buildPrimaryButton(label: 'Back to Home', onTap: () {
              mainShellKey.currentState?.setTab(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          _rowItem('Documents Submitted', 'assets/icons/tick-circle.png', true),
          const SizedBox(height: 16),
          _rowItem('Under Review', 'assets/icons/timer-icon.png', true),
          const SizedBox(height: 16),
          _rowItem('Final Approval', null, false),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String? icon, bool isIcon) {
    return Row(
      children: [
        SizedBox(width: 24, child: isIcon ? Image.asset(icon!, width: 20) : Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24))),
        const SizedBox(width: 14),
        Text(label, style: AppTheme.inter(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 54,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)])),
        alignment: Alignment.center,
        child: Text(label, style: AppTheme.inter(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOutlinedButton({required String label, required String asset, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 54,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFE4B53E))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(asset, width: 18),
          const SizedBox(width: 8),
          Text(label, style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}