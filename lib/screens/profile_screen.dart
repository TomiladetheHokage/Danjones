import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'referral_screen.dart';
import 'settings_screen.dart';
import 'customer_support_screen.dart';
import 'enable_2fa_scan_screen.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> userFuture;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
            onPressed: () {},
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
                  ImageProvider avatarImage = const AssetImage("assets/images/profile_picture.png");
                  String email = 'user***@email.com';
                  String uid = '8839201';

                  if (snapshot.hasData) {
                    if (snapshot.data!.avatar != null && snapshot.data!.avatar!.isNotEmpty) {
                      avatarImage = NetworkImage('https://api.danjones.ng${snapshot.data!.avatar}');
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
                            backgroundImage: avatarImage,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'UID: $uid',
                            style: AppTheme.inter(color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy, color: Colors.white54, size: 14),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'VIP 0',
                              style: AppTheme.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, size: 16),
                      const SizedBox(width: 6),
                      Text('Edit Profile', style: AppTheme.inter(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Menu Items
              _buildMenuGroup([
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Identity Verification',
                  subtitle: 'Level 1 Limits: 50k NGN/Day',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4B53E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Unverified',
                      style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuGroup([
                _buildMenuItem(
                  icon: Icons.account_balance_outlined,
                  title: 'Payment Methods',
                  subtitle: 'Manage NGN Bank Accounts',
                ),
                _buildMenuItem(
                  icon: Icons.security_outlined,
                  title: 'Security Center',
                  subtitle: '2FA, Password, Anti-Phishing',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Enable2faScanScreen()),
                    );
                  },
                  trailing: Row(
                    children: [
                      Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFFE4B53E), borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 2),
                      Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFFE4B53E), borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 2),
                      Container(width: 6, height: 16, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(3))),
                    ],
                  ),
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Transaction History',
                  subtitle: 'Spot, P2P, Withdrawals',
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuGroup([
                _buildMenuItem(
                  icon: Icons.card_giftcard,
                  title: 'Referral & Rewards',
                  subtitle: 'Invite friends, earn up to 40%',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReferralScreen()),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuGroup([
                _buildMenuItem(
                  icon: Icons.headset_mic_outlined,
                  title: 'Customer Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerSupportScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Language, Theme',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About & Legal',
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
                  onPressed: () {},
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
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.transparent, // Expand tap area
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF45E555).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF45E555), size: 20),
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
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 12),
            ],
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 14),
          ],
        ),
      ),
    );
  }
}
