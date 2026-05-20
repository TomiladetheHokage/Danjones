import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'kyc_tier2_screen.dart';

class VerificationCenterScreen extends StatelessWidget {
  const VerificationCenterScreen({super.key});

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
          'Verification Center',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Gold circle with tick-circle image
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE4B53E).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/tick-circle.png',
                  width: 36,
                  height: 36,
                  color: Colors.white,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.check, color: Colors.white, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Tier 1 Verified',
              style: AppTheme.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Identity verified automatically via your\nsecure sign-up credentials.',
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white38, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),

            // Section label — white bold, left aligned
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Current Privileges',
                style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            _privilegeRow(
              iconAsset: 'assets/icons/bank.png',
              label: 'Deposit Limit',
              valueWidget: Text(
                'Unlimited NGN',
                style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            _privilegeRow(
              iconAsset: 'assets/icons/bank.png',
              label: 'Withdrawal Limit',
              valueWidget: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '500,000 NGN',
                      style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' / Daily',
                      style: AppTheme.inter(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _privilegeRow(
              iconAsset: 'assets/icons/bank.png',
              label: 'P2P Trading',
              valueWidget: Text(
                'Active',
                style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            _privilegeRow(
              iconAsset: 'assets/icons/bank.png',
              label: 'Spot Trading',
              valueWidget: Text(
                'Active',
                style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // Increase limits banner with thumbs
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Increase your limits',
                          style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: AppTheme.inter(color: Colors.white54, fontSize: 12, height: 1.5),
                            children: [
                              const TextSpan(text: 'Verify your Government ID (BVN/NIN) to unlock Tier 2 withdrawal limits up to '),
                              TextSpan(
                                text: '50M NGN.',
                                style: AppTheme.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Icon(Icons.thumb_up_outlined, color: Colors.white38, size: 22),
                      const SizedBox(height: 8),
                      Icon(Icons.thumb_down_outlined, color: Colors.white38, size: 22),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade button — outlined gold
            _buildOutlinedButton(
              label: 'Upgrade to Tier 2  →',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KycTier2Screen()),
              ),
            ),
            const SizedBox(height: 14),

            // Start Trading — filled gold
            _buildPrimaryButton(
              label: 'Start Trading',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _privilegeRow({
    required String iconAsset,
    required String label,
    required Widget valueWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Green square icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(
                iconAsset,
                width: 22,
                height: 22,
                color: Colors.white,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Label + value stacked
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                valueWidget,
              ],
            ),
          ),
          // Gold outlined checkmark
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE4B53E), width: 1.5),
            ),
            child: const Icon(Icons.check, color: Color(0xFFE4B53E), size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE4B53E), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.inter(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
