import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_and_market/home_screen.dart';
import 'home_and_market/market_screen.dart';
import 'assets_screen.dart';
import 'swap_screen.dart';

final GlobalKey<MainShellState> mainShellKey = GlobalKey<MainShellState>();

class MainShell extends StatefulWidget {
  MainShell({Key? key}) : super(key: key ?? mainShellKey);

  @override
  State<MainShell> createState() => MainShellState();

  static MainShellState? of(BuildContext context) => context.findAncestorStateOfType<MainShellState>();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void setTab(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (index) => GlobalKey<NavigatorState>(),
  );

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.show_chart_rounded, label: 'Market'),
    _NavItem(icon: Icons.show_chart_rounded, label: 'Trade', isCenter: true),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Assets'),
    _NavItem(icon: Icons.menu_rounded, label: 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: IndexedStack(
        index: _currentIndex.clamp(0, _navItems.length - 1),
        children: [
          _buildNavigator(0, const CryptoDashboard()),
          _buildNavigator(1, const MarketScreen()),
          _buildNavigator(2, const SwapScreen()),
          _buildNavigator(3, const AssetsScreen()),
          _buildNavigator(4, _placeholderPage('Menu')),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNavigator(int index, Widget home) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => home);
      },
    );
  }

  Widget _placeholderPage(String title) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Center(
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;
              if (item.isCenter) {
                return _buildCenterButton();
              }
              return _buildNavItem(
                icon: item.icon,
                label: item.label,
                selected: isSelected,
                onTap: () => setState(() => _currentIndex = index),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: selected ? const Color(0xFFE4B53E) : Colors.white38,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? const Color(0xFFE4B53E) : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE4B53E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFE4B53E),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.swap_vert_rounded,
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trade',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final bool isCenter;
  const _NavItem({required this.icon, required this.label, this.isCenter = false});
}
