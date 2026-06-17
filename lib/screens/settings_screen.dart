import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'legal/terms_screen.dart';
import 'legal/privacy_policy_screen.dart';
import 'legal/data_usage_policy_screen.dart';
import 'security_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool priceAlerts = true;
  bool orderUpdates = true;
  bool p2pMessages = true;
  bool promotions = false;
  bool _isDeletingAccount = false;

  void _showComingSoon() {
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
                        'Coming Soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'This feature is still in development.',
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    bool showPassword = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1D21),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Delete Account',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This action cannot be undone. All your data will be permanently deleted.',
                        style: AppTheme.inter(
                          color: Colors.white54,
                          fontSize: 13,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: passwordController,
                        onChanged: (_) => setState(() {}),
                        obscureText: !showPassword,
                        style: AppTheme.inter(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: AppTheme.inter(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF151515),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => showPassword = !showPassword),
                            child: Icon(
                              showPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (passwordController.text.isNotEmpty &&
                                  !_isDeletingAccount)
                              ? () => _performDeleteAccount(
                                    passwordController.text,
                                  )
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.red.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isDeletingAccount
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Delete Account Permanently',
                                  style: AppTheme.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTheme.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performDeleteAccount(String password) async {
    setState(() => _isDeletingAccount = true);
    try {
      await ApiService.deleteAccount(password: password);
      if (!mounted) return;
      Navigator.pop(context);
      _showSuccessPopup();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      _showErrorPopup(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showSuccessPopup() {
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
                    color: Colors.green.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Account Deleted',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your account has been permanently deleted.',
                        style: AppTheme.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorPopup(String message) {
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
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Deletion Failed',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTheme.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          'Settings',
          style: AppTheme.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('General'),
            _buildContainer(
              children: [
                // Language — display only, no arrow
                _buildListTile(
                  icon: Icons.language,
                  title: 'Language',
                  trailingText: 'English',
                  showArrow: false,
                ),
                _buildDivider(),
                // Display Currency — display only, no arrow
                _buildListTile(
                  icon: Icons.monetization_on_outlined,
                  title: 'Display Currency',
                  trailingText: 'NGN',
                  showArrow: false,
                ),
                _buildDivider(),
                // Appearance — display only, no arrow
                _buildListTile(
                  icon: Icons.brightness_6_outlined,
                  title: 'Appearance',
                  showArrow: false,
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Notifications'),
            _buildContainer(
              children: [
                // Notification toggles are disabled with coming soon badge
                _buildSwitchTile(
                  title: 'Price Alerts',
                  value: priceAlerts,
                  disabled: true,
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Order Updates',
                  value: orderUpdates,
                  disabled: true,
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'P2P Messages',
                  value: p2pMessages,
                  disabled: true,
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Promotions',
                  value: promotions,
                  disabled: true,
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Privacy & Data'),
            _buildContainer(
              children: [
                // Clear Cache — tappable, shows coming soon
                GestureDetector(
                  onTap: _showComingSoon,
                  child: _buildListTile(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clear Cache',
                    trailingContainer: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('45 MB', style: AppTheme.inter(color: Colors.white, fontSize: 12)),
                    ),
                    showArrow: false,
                  ),
                ),
                _buildDivider(),
                // Data Usage Policy — routes to screen
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DataUsagePolicyScreen()),
                  ),
                  child: _buildListTile(
                    icon: Icons.shield_outlined,
                    title: 'Data Usage Policy',
                    showArrow: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('About'),
            _buildContainer(
              children: [
                _buildListTile(
                  title: 'App Version',
                  trailingText: 'v2.4.1',
                  showArrow: false,
                ),
                _buildDivider(),
                // Terms of Service — routes to screen
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  ),
                  child: _buildListTile(
                    title: 'Terms of Service',
                    showArrow: true,
                  ),
                ),
                _buildDivider(),
                // Privacy Policy — routes to screen
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  ),
                  child: _buildListTile(
                    title: 'Privacy Policy',
                    showArrow: true,
                  ),
                ),
                _buildDivider(),
                // Rate Us — commented out
                // _buildListTile(
                //   icon: Icons.star,
                //   iconColor: const Color(0xFFE4B53E),
                //   title: 'Rate Us',
                //   titleColor: const Color(0xFFE4B53E),
                //   trailingIcon: Icons.open_in_new,
                //   trailingIconColor: const Color(0xFFE4B53E),
                // ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Security'),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1D21),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.security_outlined, color: const Color(0xFFE4B53E), size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Manage Security',
                          style: AppTheme.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.2),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Account'),
            GestureDetector(
              onTap: _showDeleteAccountDialog,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1D21),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.7), size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Delete Account',
                          style: AppTheme.inter(
                            color: Colors.red.withOpacity(0.7),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.red.withOpacity(0.3),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2024 TradeNaija Exchange.\nSecure Nigerian Crypto Trading.',
                textAlign: TextAlign.center,
                style: AppTheme.inter(color: Colors.white38, fontSize: 12, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTheme.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildListTile({
    IconData? icon,
    Color? iconColor,
    required String title,
    Color? titleColor,
    String? trailingText,
    Widget? trailingContainer,
    bool showArrow = false,
    IconData? trailingIcon,
    Color? trailingIconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? const Color(0xFFE4B53E), size: 18),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTheme.inter(
                color: titleColor ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailingText != null) ...[
            Text(trailingText, style: AppTheme.inter(color: Colors.white38, fontSize: 13)),
            const SizedBox(width: 8),
          ],
          if (trailingContainer != null) ...[
            trailingContainer,
            const SizedBox(width: 8),
          ],
          if (showArrow)
            Icon(
              trailingIcon ?? Icons.arrow_forward_ios,
              color: trailingIconColor ?? Colors.white.withOpacity(0.2),
              size: 14,
            )
          else if (trailingIcon != null)
            Icon(trailingIcon, color: trailingIconColor ?? Colors.white.withOpacity(0.2), size: 14),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    bool disabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.inter(
              color: disabled ? Colors.white38 : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Disabled switch (greyed out, non-interactive)
          Switch(
            value: false,
            onChanged: null,
            activeColor: Colors.black,
            activeTrackColor: const Color(0xFFE4B53E),
            inactiveTrackColor: Colors.white.withOpacity(0.08),
            inactiveThumbColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
