import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/auth/user_profile.dart';
import '../../services/api_service.dart';
import 'kyc_tier2_screen.dart';

class VerificationCenterScreen extends StatefulWidget {
  const VerificationCenterScreen({super.key});

  @override
  State<VerificationCenterScreen> createState() => _VerificationCenterScreenState();
}

class _VerificationCenterScreenState extends State<VerificationCenterScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile();
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
          'Verification Center',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final bool verified = snapshot.data?.kycVerified ?? false;
          final String status = snapshot.data?.kycStatus.toLowerCase() ?? '';
          final bool isPending = status == 'pending';
          final bool isRejected = status == 'rejected';
          final bool isApproved = verified || status == 'approved';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Status icon
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SizedBox(
                    height: 72,
                    width: 72,
                    child: CircularProgressIndicator(color: Color(0xFFE4B53E), strokeWidth: 2),
                  )
                else if (isApproved)
                  Image.asset('assets/icons/tick-circle.png', width: 72, height: 72, fit: BoxFit.contain)
                else if (isPending)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE4B53E).withOpacity(0.12),
                    ),
                    child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFE4B53E), size: 36),
                  )
                else if (isRejected)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEF5350).withOpacity(0.12),
                    ),
                    child: const Icon(Icons.cancel_outlined, color: Color(0xFFEF5350), size: 36),
                  )
                else
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                    child: const Icon(Icons.verified_user_outlined, color: Colors.white38, size: 36),
                  ),

                const SizedBox(height: 16),

                // Title
                Text(
                  isApproved
                    ? 'Tier 2 Verified'
                      : isPending
                          ? 'Verification Pending'
                          : isRejected
                              ? 'Verification Rejected'
                              : 'Not Verified',
                  style: AppTheme.inter(
                    color: isApproved
                        ? Colors.white
                        : isPending
                            ? const Color(0xFFE4B53E)
                            : isRejected
                                ? const Color(0xFFEF5350)
                                : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isApproved
                    ? 'Your identity verification is complete.\nYou now have Tier 2 access.'
                      : isPending
                          ? 'Your documents are under review.\nWe\'ll notify you once complete.'
                          : isRejected
                              ? 'Your verification was not successful.\nPlease resubmit your documents.'
                              : 'Complete identity verification\nto unlock full platform features.',
                  textAlign: TextAlign.center,
                  style: AppTheme.inter(color: Colors.white38, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 28),

                // Show privileges only when verified
                if (isApproved) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Current Privileges',
                      style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _privilegeRow(
                    label: 'Deposit Limit',
                    valueWidget: Text(
                      'Unlimited NGN',
                      style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _privilegeRow(
                    label: 'P2P Trading',
                    valueWidget: Text(
                      'Active',
                      style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action button — only show upgrade when verified; show verify when not
                if (isApproved)
                  _buildOutlinedButton(
                    label: 'Upgrade to Tier 3  →',
                    onTap: _showComingSoon,
                  )
                else if (!isPending)
                  _buildPrimaryButton(
                    label: isRejected ? 'Resubmit Verification' : 'Start Verification',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KycTier2Screen()),
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon() {
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
                    children: const [
                      Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tier 3 verification will be available soon.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
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

Widget _privilegeRow({
  required String label,
  required Widget valueWidget,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFF151515),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.05),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
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
            border: Border.all(
              color: const Color(0xFFE4B53E),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.check,
            color: Color(0xFFE4B53E),
            size: 16,
          ),
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
