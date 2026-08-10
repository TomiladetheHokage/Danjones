import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// A consistent, cached circular avatar used throughout the P2P and profile
/// sections. Falls back to an initials badge when no URL is available or the
/// image fails to load.
///
/// Usage:
///   UserAvatar(name: 'Tunde01', avatarUrl: trade.sellerAvatar, radius: 23)
class UserAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double radius;
  final Color backgroundColor;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 23,
    this.backgroundColor = const Color(0xFF2E2E2E),
    this.fontSize = 0, // 0 = auto (radius * 0.45)
  });

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  double get _fontSize => fontSize > 0 ? fontSize : radius * 0.62;

  String? get _resolvedUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    return ApiService.resolveUrl(avatarUrl) ?? avatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final diameter = radius * 2;

    Widget fallback = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTheme.inter(
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    if (url == null) return fallback;

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: _fontSize,
          height: _fontSize,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => fallback,
      // Cache for 7 days — avatars rarely change
      maxWidthDiskCache: (diameter * 2).toInt(),
      maxHeightDiskCache: (diameter * 2).toInt(),
    );
  }
}
