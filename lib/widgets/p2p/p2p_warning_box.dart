import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class P2PWarningBox extends StatelessWidget {
  final String message;
  final String? highlightedPrefix;

  const P2PWarningBox({super.key, required this.message, this.highlightedPrefix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.5), // Subtle dark tint
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE4B53E), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: highlightedPrefix != null && message.startsWith(highlightedPrefix!)
              ? RichText(
                  text: TextSpan(
                    style: AppTheme.inter(color: Colors.white60, fontSize: 12, height: 1.5),
                    children: [
                      TextSpan(
                        text: highlightedPrefix,
                        style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12, height: 1.5),
                      ),
                      TextSpan(
                        text: message.substring(highlightedPrefix!.length),
                      ),
                    ],
                  ),
                )
              : Text(
                  message,
                  style: AppTheme.inter(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
