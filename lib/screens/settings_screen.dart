import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
                _buildListTile(
                  icon: Icons.language,
                  title: 'Language',
                  trailingText: 'English',
                  showArrow: true,
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.monetization_on_outlined,
                  title: 'Display Currency',
                  trailingText: 'NGN',
                  showArrow: true,
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.brightness_6_outlined,
                  title: 'Appearance',
                  showArrow: true,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Notifications'),
            _buildContainer(
              children: [
                _buildSwitchTile(
                   title: 'Price Alerts',
                   value: priceAlerts,
                   onChanged: (v) => setState(() => priceAlerts = v),
                ),
                _buildDivider(),
                _buildSwitchTile(
                   title: 'Order Updates',
                   value: orderUpdates,
                   onChanged: (v) => setState(() => orderUpdates = v),
                ),
                _buildDivider(),
                _buildSwitchTile(
                   title: 'P2P Messages',
                   value: p2pMessages,
                   onChanged: (v) => setState(() => p2pMessages = v),
                ),
                _buildDivider(),
                _buildSwitchTile(
                   title: 'Promotions',
                   value: promotions,
                   onChanged: (v) => setState(() => promotions = v),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Privacy & Data'),
            _buildContainer(
              children: [
                _buildListTile(
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
                _buildDivider(),
                _buildListTile(
                  icon: Icons.shield_outlined,
                  title: 'Data Usage Policy',
                  showArrow: true,
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
                _buildListTile(
                  title: 'Terms of Service',
                  showArrow: true,
                ),
                _buildDivider(),
                _buildListTile(
                  title: 'Privacy Policy',
                  showArrow: true,
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.star,
                  iconColor: const Color(0xFFE4B53E),
                  title: 'Rate Us',
                  titleColor: const Color(0xFFE4B53E),
                  trailingIcon: Icons.open_in_new,
                  trailingIconColor: const Color(0xFFE4B53E),
                ),
              ],
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16);
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
            Text(
              trailingText,
              style: AppTheme.inter(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(width: 8),
          ],
          if (trailingContainer != null) ...[
            trailingContainer,
            const SizedBox(width: 8),
          ],
          if (showArrow)
            Icon(trailingIcon ?? Icons.arrow_forward_ios, color: trailingIconColor ?? Colors.white.withOpacity(0.2), size: 14)
          else if (trailingIcon != null)
            Icon(trailingIcon, color: trailingIconColor ?? Colors.white.withOpacity(0.2), size: 14),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
            activeTrackColor: const Color(0xFFE4B53E),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            inactiveThumbColor: Colors.white54,
          ),
        ],
      ),
    );
  }
}
