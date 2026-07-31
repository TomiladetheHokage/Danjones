import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth/user_profile.dart';
import '../models/wallet/dashboard_data.dart';

class DataStore {
  // Singleton pattern
  static final DataStore instance = DataStore._internal();
  DataStore._internal();

  final _storage = const FlutterSecureStorage();
  final String _dashboardKey = 'cached_dashboard_data';

  // State using ValueNotifier
  final ValueNotifier<DashboardData?> dashboard = ValueNotifier<DashboardData?>(null);

  /// Load cached data on app startup
  Future<void> init() async {
    try {
      final cachedString = await _storage.read(key: _dashboardKey);
      if (cachedString != null) {
        final Map<String, dynamic> json = jsonDecode(cachedString);
        dashboard.value = DashboardData.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading cached dashboard: $e');
    }
  }

  /// Update dashboard data and persist it
  Future<void> updateDashboard(DashboardData newData) async {
    dashboard.value = newData;
    try {
      final jsonString = jsonEncode(newData.toJson());
      await _storage.write(key: _dashboardKey, value: jsonString);
    } catch (e) {
      debugPrint('Error caching dashboard: $e');
    }
  }

  /// Patch the cached user object without waiting for a full dashboard refresh.
  Future<void> patchDashboardUser(Map<String, dynamic> incomingUser) async {
    final current = dashboard.value;
    if (current == null) return;

    final existing = current.user;
    final merged = <String, dynamic>{
      'id': existing.id,
      'name': existing.name,
      'email': existing.email,
      'username': existing.username,
      'phone': existing.phone,
      'avatar': existing.avatar,
      'has_pin': existing.hasPin,
      'email_verified_at': existing.emailVerifiedAt,
      'phone_verified_at': existing.phoneVerifiedAt,
      'created_at': existing.createdAt,
      'kyc_status': existing.kycStatus,
      'kyc_verified': existing.kycVerified,
    };

    incomingUser.forEach((key, value) {
      if (value != null) {
        merged[key] = value;
      }
    });

    final updated = DashboardData(
      user: UserProfile.fromJson(merged),
      wallets: current.wallets,
      totalBalanceUsd: current.totalBalanceUsd,
      totalBalanceNgn: current.totalBalanceNgn,
    );

    await updateDashboard(updated);
  }

  /// Clear store (e.g. on logout)
  Future<void> clear() async {
    dashboard.value = null;
    await _storage.delete(key: _dashboardKey);
  }
}
