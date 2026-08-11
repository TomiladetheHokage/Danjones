import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/p2p/p2p_profile.dart';
import '../../models/auth/user_profile.dart';
import '../../services/api_service.dart';
import '../../widgets/shared/user_avatar.dart';
import '../profile/notifications_screen.dart';
import '../profile/payment_methods_screen.dart';

class P2PProfileScreen extends StatefulWidget {
  const P2PProfileScreen({super.key});

  @override
  State<P2PProfileScreen> createState() => _P2PProfileScreenState();
}

class _P2PProfileScreenState extends State<P2PProfileScreen> {
  late Future<P2PTraderProfile> _profileFuture;
  late Future<UserProfile> _userFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getP2pProfile();
    _userFuture = ApiService.getUserProfile();
  }

  String _formatJoinDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Details',
          style: AppTheme.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<P2PTraderProfile>(
        future: _profileFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE4B53E),
                strokeWidth: 2,
              ),
            );
          }

          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white38, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load profile',
                    style: AppTheme.inter(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE4B53E)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => setState(() {
                      _profileFuture = ApiService.getP2pProfile();
                      _userFuture = ApiService.getUserProfile();
                    }),
                    child: Text('Retry',
                        style: AppTheme.inter(color: const Color(0xFFE4B53E))),
                  ),
                ],
              ),
            );
          }

          final profile = snap.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Header — also needs user avatar ──
                FutureBuilder<UserProfile>(
                  future: _userFuture,
                  builder: (context, userSnap) {
                    final avatarUrl = userSnap.data?.avatar;
                    return _buildHeader(profile, avatarUrl);
                  },
                ),

                const SizedBox(height: 24),

                // ── About Me ──
                // _buildAboutMe(profile),

                const SizedBox(height: 24),

                // ── Statistics label ──
                Text(
                  'Statistics',
                  style: AppTheme.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Stats grid ──
                _buildStats(profile),

                const SizedBox(height: 16),

                // ── Info rows ──
                _buildInfoCard(profile),

                const SizedBox(height: 32),

                // ── Payment Methods button ──
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4B53E),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Payment Methods',
                          style: AppTheme.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward,
                            size: 20, color: Colors.black),
                      ],
                    ),
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

  // ─────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader(P2PTraderProfile profile, String? avatarUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar — real user photo with initials fallback
        UserAvatar(
          name: profile.name,
          avatarUrl: avatarUrl ?? profile.avatar,
          radius: 38,
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                profile.name,
                style: AppTheme.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // KYC badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: profile.isVerified
                      ? const Color(0xFFE4B53E)
                      : const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: profile.isVerified ? Colors.black : Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.isVerified ? 'Verified' : 'Unverified',
                      style: AppTheme.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            profile.isVerified ? Colors.black : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // Stats grid
  // ─────────────────────────────────────────────────────────
  Widget _buildStats(P2PTraderProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _statCell(
                value: _fmtNumber(profile.totalTrades),
                label: 'Total Order',
              ),
              _verticalDivider(),
              _statCell(
                value: _fmtNumber(profile.totalCompleted),
                label: 'Total Completed',
              ),
            ],
          ),
          Divider(
            color: Colors.white.withValues(alpha: 0.07),
            height: 24,
            thickness: 1,
          ),
          Row(
            children: [
              _statCell(
                value: profile.avgTransactionTimeFormatted,
                label: 'Avg. Release Time',
              ),
              _verticalDivider(),
              _statCell(
                value: '${profile.completionRate.toStringAsFixed(2)}%',
                label: 'Completion Rate',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell({required String value, required String label}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTheme.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.inter(fontSize: 13, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
        width: 1,
        height: 50,
        color: Colors.white.withValues(alpha: 0.07),
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );

  // ─────────────────────────────────────────────────────────
  // Info card
  // ─────────────────────────────────────────────────────────
  Widget _buildInfoCard(P2PTraderProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Joined',
            value: _formatJoinDate(profile.joinedAt),
          ),
          _rowDivider(),
          _infoRow(
            icon: Icons.language_rounded,
            label: 'Language',
            value: 'English',
          ),
          _rowDivider(),
          _infoRow(
            icon: Icons.shield_outlined,
            label: 'Account Status',
            value: '*Active',
            valueColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.inter(fontSize: 14, color: Colors.white),
            ),
          ),
          Text(
            value,
            style: AppTheme.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDivider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.07),
        ),
      );

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────
  String _fmtNumber(int n) {
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
