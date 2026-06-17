import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'referral_screen.dart';
import 'settings_screen.dart';
import 'security_settings_screen.dart';
import 'customer_support_screen.dart';
import 'enable_2fa_scan_screen.dart';
import 'auth/login_screen.dart';
import 'trade_screen.dart';
import 'p2p/my_ads_screen.dart';
import 'kyc/verification_center_screen.dart';
import 'legal/about_legal_screen.dart';
import 'notifications_screen.dart';
import 'payment_methods_screen.dart';
import '../services/api_service.dart';
import '../services/data_store.dart';
import '../services/crypto_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;

  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> userFuture;

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
                  String? avatarUrl;
                  String email = 'user***@email.com';
                  String uid = '8839201';

                  if (snapshot.hasData) {
                    if (snapshot.data!.avatar != null && snapshot.data!.avatar!.isNotEmpty) {
                      avatarUrl = ApiService.resolveUrl(snapshot.data!.avatar);
                    }
                    email = snapshot.data!.email;
                    uid = snapshot.data!.id.toString();
                  }

                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF1C1D21),
                            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl == null
                                ? const Icon(Icons.person_rounded, color: Colors.white54, size: 34)
                                : null,
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
        setState(() {
          userFuture = ApiService.getUserProfile();
        });
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
                  subtitle: 'Level 1',
                 onTap: () {
  // _showComingSoon(context);

  // TODO: enable when KYC is ready
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const VerificationCenterScreen()),
  );
},
       trailing: SizedBox(
  height: 20,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFE4B53E).withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      'Unverified',
      style: AppTheme.inter(
        color: const Color(0xFFE4B53E),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),
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
                    _showComingSoon(context);
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
void _showComingSoon(BuildContext context) {
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
                      "Coming Soon",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "This feature is still in development.",
                      style: TextStyle(
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
              )
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
}
