import 'package:flutter/material.dart';
import '../../models/p2p/p2p_profile.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/user_avatar.dart';

class P2PUserProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String? userAvatar;

  const P2PUserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  State<P2PUserProfileScreen> createState() => _P2PUserProfileScreenState();
}

class _P2PUserProfileScreenState extends State<P2PUserProfileScreen> {
  late Future<P2PTraderProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getP2pUserProfile(widget.userId);
  }

  String _formatJoinDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _fmtNumber(int n) => n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

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
          'Trader Profile',
          style: AppTheme.inter(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<P2PTraderProfile>(
        future: _profileFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFE4B53E), strokeWidth: 2),
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
                  Text('Failed to load profile',
                      style:
                          AppTheme.inter(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE4B53E)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => setState(() => _profileFuture =
                        ApiService.getP2pUserProfile(widget.userId)),
                    child: Text('Retry',
                        style:
                            AppTheme.inter(color: const Color(0xFFE4B53E))),
                  ),
                ],
              ),
            );
          }

          final profile = snap.data!;
          // Prefer the avatar passed from the ad card (already loaded/cached),
          // fall back to whatever the profile endpoint returns.
          final avatarUrl = widget.userAvatar ?? profile.avatar;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Header ──────────────────────────────────
                _buildHeader(profile, avatarUrl),

                const SizedBox(height: 28),

                // ── Statistics ──────────────────────────────
                Text('Statistics',
                    style: AppTheme.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 12),
                _buildStats(profile),

                const SizedBox(height: 16),

                // ── Info card ────────────────────────────────
                _buildInfoCard(profile),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader(P2PTraderProfile profile, String? avatarUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(
          name: profile.name,
          avatarUrl: avatarUrl,
          radius: 38,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: AppTheme.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
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
                    Icon(Icons.check_circle_rounded,
                        size: 14,
                        color: profile.isVerified
                            ? Colors.black
                            : Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      profile.isVerified ? 'Verified' : 'Unverified',
                      style: AppTheme.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: profile.isVerified
                              ? Colors.black
                              : Colors.white54),
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

  // ── Stats grid ──────────────────────────────────────────
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
              _statCell(_fmtNumber(profile.totalTrades), 'Total Orders'),
              _vDivider(),
              _statCell(_fmtNumber(profile.totalCompleted), 'Completed'),
            ],
          ),
          Divider(
              color: Colors.white.withValues(alpha: 0.07),
              height: 24,
              thickness: 1),
          Row(
            children: [
              _statCell(profile.avgTransactionTimeFormatted, 'Avg. Release Time'),
              _vDivider(),
              _statCell(
                  '${profile.completionRate.toStringAsFixed(2)}%',
                  'Completion Rate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(String value, String label) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTheme.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTheme.inter(fontSize: 13, color: Colors.white54)),
          ],
        ),
      );

  Widget _vDivider() => Container(
        width: 1,
        height: 50,
        color: Colors.white.withValues(alpha: 0.07),
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );

  // ── Info card ────────────────────────────────────────────
  Widget _buildInfoCard(P2PTraderProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          _infoRow(Icons.calendar_today_outlined, 'Joined',
              _formatJoinDate(profile.joinedAt)),
          _rowDivider(),
          _infoRow(Icons.language_rounded, 'Language', 'English'),
          _rowDivider(),
          _infoRow(
            Icons.shield_outlined,
            'Account Status',
            '*Active',
            valueColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color valueColor = Colors.white,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white54),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style:
                        AppTheme.inter(fontSize: 14, color: Colors.white))),
            Text(value,
                style: AppTheme.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor)),
          ],
        ),
      );

  Widget _rowDivider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(
            height: 1, color: Colors.white.withValues(alpha: 0.07)),
      );
}
