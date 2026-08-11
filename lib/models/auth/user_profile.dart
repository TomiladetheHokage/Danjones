class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? avatar;
  final bool hasPin;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;
  final String createdAt;
  final String kycStatus;   // "approved" | "pending" | "rejected" | ""
  final bool kycVerified;
  final int kycLevel;       // 0, 1, 2, etc.

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.avatar,
    required this.hasPin,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.createdAt,
    this.kycStatus = '',
    this.kycVerified = false,
    this.kycLevel = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      phone: json['phone'],
      avatar: json['avatar'],
      hasPin: json['has_pin'] == true || json['has_pin'] == 1,
      emailVerifiedAt: json['email_verified_at'],
      phoneVerifiedAt: json['phone_verified_at'],
      createdAt: json['created_at'] ?? '',
      kycStatus: json['kyc_status']?.toString() ?? '',
      kycVerified: json['kyc_verified'] == true || json['kyc_verified'] == 1,
      kycLevel: (json['kyc_level'] as num?)?.toInt() ?? 0,
    );
  }
}
