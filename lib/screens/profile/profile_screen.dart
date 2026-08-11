import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'security_settings_screen.dart';
import 'customer_support_screen.dart';
import '../auth/login_screen.dart';
import '../p2p/trade_screen.dart';
import '../p2p/my_ads_screen.dart';
import '../kyc/verification_center_screen.dart';
import '../legal/about_legal_screen.dart';
import 'notifications_screen.dart';
import 'payment_methods_screen.dart';
import '../../services/api_service.dart';
import '../../services/data_store.dart';
import '../../services/crypto_service.dart';
import '../../models/auth/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;

  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> userFuture;
  UserProfile? _profile; // cached once loaded

  Future<void> _handleLogout() async {
    try {
      await ApiService.logout();
      await DataStore.instance.clear();
      CryptoService.invalidateCache(); // clear market price cache

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userFuture = ApiService.getUserProfile();
    // Pre-load profile into state so the KYC badge and other widgets
    // outside the FutureBuilder re-render correctly when data arrives.
    userFuture.then((profile) {
      if (mounted) setState(() => _profile = profile);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Profile',
          style: AppTheme.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset("assets/icons/Notification-icon.png", width: 24, height: 24, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              FutureBuilder<UserProfile>(
                future: userFuture,
                builder: (context, snapshot) {
                  String email = 'user***@email.com';

                  if (snapshot.hasData) {
                    email = snapshot.data!.email;
                  }

                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          UserAvatar(
                            name: snapshot.data?.name ?? email,
                            avatarUrl: snapshot.data?.avatar,
                            radius: 40,
                            backgroundColor: const Color(0xFF1C1D21),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF45E555),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF050505), width: 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        email,
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       'UID: $uid',
                      //       style: AppTheme.inter(color: Colors.white54, fontSize: 13),
                      //     ),
                      //     const SizedBox(width: 4),
                      //     const Icon(Icons.copy, color: Colors.white54, size: 14),
                      //     const SizedBox(width: 12),
                      //     Container(
                      //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      //       decoration: BoxDecoration(
                      //         color: Colors.white.withOpacity(0.1),
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       child: Text(
                      //         'VIP 0',
                      //         style: AppTheme.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  );
                },
              ),
     const SizedBox(height: 20),
Container(
  width: 140,
  height: 38,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(19),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE4B53E), Color(0xFFB88A2D)],
    ),
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
      ),
    ),
    onPressed: () async {
      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
      );
      if (updated == true && mounted) {
        final refreshed = ApiService.getUserProfile();
        setState(() {
          userFuture = refreshed;
        });
        refreshed.then((p) {
          if (mounted) setState(() => _profile = p);
        }).catchError((_) {});
      }
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.edit, size: 16),
        const SizedBox(width: 6),
        Text(
          'Edit Profile',
          style: AppTheme.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 30),
              
              // Menu Items
              _buildMenuGroup([
                _buildMenuItem(
                  imagePath: 'assets/icons/finger-print.png',
                  title: 'Identity Verification',
                  subtitle: _kycTierLabel(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VerificationCenterScreen()),
                    );
                  },
                  trailing: _buildKycBadge(),
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuGroup([
                _buildMenuItem(
                  imagePath: 'assets/icons/payment.png',
                  title: 'Payment Methods',
                  subtitle: 'Manage NGN Bank Accounts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  imagePath: 'assets/icons/security.png',
                  title: 'Security Center',
                  subtitle: '2FA, Password, Anti-Phishing',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  imagePath: 'assets/icons/history.png',
                  title: 'Transaction History',
                  subtitle: 'Spot, P2P, Withdrawals',
                  // trailing: _comingSoonBadge(),
                  onTap: () {
                    // _showComingSoon(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TradeScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.campaign_outlined,
                  title: 'My Ads',
                  subtitle: 'Manage your P2P buy/sell ads',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyAdsScreen()),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuGroup([
                _buildMenuItem(
                  imagePath: 'assets/icons/refferal.png',
                  title: 'Referral & Rewards',
                  subtitle: 'Invite friends, earn up to 40%',
                  trailing: _comingSoonBadge(),
                  onTap: () {
                    showComingSoon(context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const ReferralScreen()),
                    // );
                  },
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuGroup([
                _buildMenuItem(
                  imagePath: 'assets/icons/customer-support.png',
                  title: 'Customer Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  imagePath: 'assets/icons/settings.png',
                  title: 'Settings',
                  subtitle: 'Language, Theme',
                  // trailing: _comingSoonBadge(),
                  onTap: () {
                      // _showComingSoon(context);

                      // TODO: enable later
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                  },
                ),
                _buildMenuItem(
                  imagePath: 'assets/icons/about.png',
                  title: 'About & Legal',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutLegalScreen()),
                  ),
                ),
              ]),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE4B53E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _handleLogout,
                  child: Text(
                    'Log Out',
                    style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
 
  String _kycTierLabel() {
    if (_profile == null) return 'Not verified';
    final status = _profile!.kycStatus.toLowerCase();
    if (_profile!.kycVerified || status == 'approved') return 'Tier 2';
    if (status == 'pending') return 'Tier 1 · Pending';
    if (status == 'rejected') return 'Tier 1 · Rejected';
    return 'Tier 1';
  }

  Widget _buildKycBadge() {
    final bool verified = _profile?.kycVerified ?? false;
    final String status = _profile?.kycStatus.toLowerCase() ?? '';

    // Determine label + colours based on kyc_verified and kyc_status
    final String label;
    final Color bg;
    final Color fg;

    if (verified || status == 'approved') {
      label = 'Verified';
      bg = const Color(0xFF4CAF50).withOpacity(0.15);
      fg = const Color(0xFF4CAF50);
    } else if (status == 'pending') {
      label = 'Pending';
      bg = const Color(0xFFE4B53E).withOpacity(0.15);
      fg = const Color(0xFFE4B53E);
    } else if (status == 'rejected') {
      label = 'Rejected';
      bg = const Color(0xFFEF5350).withOpacity(0.15);
      fg = const Color(0xFFEF5350);
    } else {
      label = 'Unverified';
      bg = const Color(0xFFE4B53E).withOpacity(0.15);
      fg = const Color(0xFFE4B53E);
    }

    return SizedBox(
      height: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTheme.inter(
            color: fg,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              items[index],
              if (index < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    String? imagePath,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imagePath != null
                  ? Image.asset(
                      imagePath,
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) =>
                          Icon(icon ?? Icons.circle, color: Colors.white54, size: 20),
                    )
                  : Icon(icon ?? Icons.circle, color: Colors.white54, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.inter(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) ...[
                  trailing,
                  const SizedBox(width: 8),
                ],
                Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.3), size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

void showComingSoon(BuildContext context) {
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
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'This feature is still in development.',
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

Widget _comingSoonBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFE4B53E).withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Coming Soon',
      style: TextStyle(
        color: Color(0xFFE4B53E),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
