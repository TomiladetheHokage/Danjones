import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> _notificationsFuture;
  final Set<String> _markingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _notificationsFuture = ApiService.getNotifications();
  }

  void _refresh() {
    setState(() {
      _notificationsFuture = ApiService.getNotifications();
    });
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (!notification.isUnread || _markingIds.contains(notification.id)) return;

    setState(() => _markingIds.add(notification.id));
    try {
      await ApiService.markNotificationRead(id: notification.id);
      if (!mounted) return;
      _refresh();
    } finally {
      if (mounted) {
        setState(() => _markingIds.remove(notification.id));
      }
    }
  }

  String _formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown time';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'p2p_trade_initiated':
        return Icons.play_circle_outline_rounded;
      case 'p2p_trade_cancelled':
        return Icons.cancel_outlined;
      case 'p2p_trade_paid':
        return Icons.payments_outlined;
      case 'p2p_trade_completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _accentForType(String type) {
    switch (type) {
      case 'p2p_trade_cancelled':
        return const Color(0xFFFF6B6B);
      case 'p2p_trade_completed':
        return const Color(0xFF33D17A);
      default:
        return const Color(0xFFE4B53E);
    }
  }

  String _labelizeRole(String? role) {
    if (role == null || role.isEmpty) return 'Unknown';
    return role[0].toUpperCase() + role.substring(1);
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
          'Notifications',
          style: AppTheme.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE4B53E), strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final notifications = snapshot.data ?? [];
          final unreadCount = notifications.where((item) => item.isUnread).length;

          if (notifications.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: const Color(0xFFE4B53E),
            backgroundColor: const Color(0xFF1C1D21),
            onRefresh: () async => _refresh(),
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1B1F), Color(0xFF111214)],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4B53E).withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active_outlined, color: Color(0xFFE4B53E), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                              style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track P2P trade activity, status updates, and important account alerts here.',
                              style: AppTheme.inter(color: Colors.white54, fontSize: 12, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...notifications.map(_buildNotificationCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final accent = _accentForType(notification.type);
    final role = notification.role;
    final tradeId = notification.tradeId;
    final isMarking = _markingIds.contains(notification.id);

    return GestureDetector(
      onTap: () => _markAsRead(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF16171A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notification.isUnread ? accent.withOpacity(0.35) : Colors.white.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_iconForType(notification.type), color: accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (isMarking)
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: accent,
                                ),
                              )
                            else if (notification.isUnread)
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRelativeTime(notification.createdAt),
                          style: AppTheme.inter(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                notification.message,
                style: AppTheme.inter(color: Colors.white70, fontSize: 13, height: 1.55),
              ),
              if (tradeId != null || role != null) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (tradeId != null)
                      _buildMetaChip('Trade #$tradeId', Icons.receipt_long_rounded),
                    if (role != null)
                      _buildMetaChip(_labelizeRole(role), Icons.person_outline_rounded),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE4B53E)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 56),
            const SizedBox(height: 12),
            Text(
              'Could not load notifications',
              style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white38, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4B53E),
                foregroundColor: Colors.black,
              ),
              child: Text('Retry', style: AppTheme.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_read_outlined, color: Colors.white24, size: 60),
            const SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: AppTheme.inter(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Trade updates and account alerts will appear here as they happen.',
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white38, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}