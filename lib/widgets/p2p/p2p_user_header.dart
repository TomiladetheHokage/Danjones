import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class P2PUserHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? stats; // e.g. "450 trades | 98.5%"
  final bool isOnline;
  final VoidCallback? onChatTap;
  final bool showBackground;

  const P2PUserHeader({
    super.key,
    required this.name,
    this.avatarUrl,
    this.stats,
    this.isOnline = false,
    this.onChatTap,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/icons/Avatar.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E1E1E),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.substring(0, 2).toUpperCase(),
                  style: AppTheme.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (stats != null)
                Text(
                  stats!,
                  style: AppTheme.inter(color: Colors.white54, fontSize: 12),
                )
              else if (isOnline)
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Online', style: AppTheme.inter(color: Colors.green, fontSize: 12)),
                  ],
                ),
            ],
          ),
        ),
        if (onChatTap != null)
          GestureDetector(
            onTap: onChatTap,
            child: Image.asset(
              'assets/icons/message.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFE4B53E), size: 24),
            ),
          ),
      ],
    );

    if (showBackground) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: content,
      );
    }
    return content;
  }
}
