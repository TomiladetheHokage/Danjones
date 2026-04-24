import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_and_market/home_screen.dart';
import 'home_and_market/market_screen.dart';
import 'assets_screen.dart';
import 'swap_screen.dart';
import 'profile_screen.dart';

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
    _NavItem(
      assetPath: 'assets/vectors/home.png',
      label: 'Home',
    ),
    _NavItem(
      assetPath: 'assets/vectors/market_asset_icon.png',
      label: 'Market',
    ),
    _NavItem(
      assetPath: '', // Center button handled separately
      label: 'Trade',
      isCenter: true,
    ),
    _NavItem(
      assetPath: 'assets/vectors/asset_nav_icon.png',
      label: 'Assets',
    ),
    _NavItem(
      icon: Icons.menu_rounded,
      label: 'Menu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildNavigator(0, const CryptoDashboard()),
          _buildNavigator(1, const MarketScreen()),
          _buildNavigator(2, const SwapScreen()),
          _buildNavigator(3, const AssetsScreen()),
          _buildNavigator(4, const ProfileScreen()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNavigator(int index, Widget home) {
    return Navigator(
      key: _navigatorKeys[index],
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => home,
        );
      },
    );
  }

  Widget _buildBottomNav() {
    const double navHeight = 85.0;
    return Container(
      height: navHeight,
      width: double.infinity,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Premium Background with ultra-smooth curve
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, navHeight),
            painter: NavPainter(),
          ),
          // Nav Items
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                if (item.isCenter) {
                  return _buildCenterButton();
                }
                
                final isSelected = _currentIndex == index;
                return _buildNavItem(
                  assetPath: item.assetPath,
                  icon: item.icon,
                  label: item.label,
                  selected: isSelected,
                  onTap: () => setState(() => _currentIndex = index),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    String? assetPath,
    IconData? icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    // Senior Designer: Refined colors for depth
    final Color color = selected ? const Color(0xFFF7BD3E) : const Color(0xFF666666);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 5.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (assetPath != null && assetPath.isNotEmpty)
              ColorFiltered(
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                child: Image.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 24,
                color: color,
              ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, -28), // Perfectly seated in the slick curve
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFAD058),
                      Color(0xFFE4B53E),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/vectors/arrows_icon.png',
                    width: 32,
                    height: 32,
                    color: const Color(0xFF151515),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String? assetPath;
  final IconData? icon;
  final String label;
  final bool isCenter;
  const _NavItem({this.assetPath, this.icon, required this.label, this.isCenter = false});
}

class NavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Senior Designer: Darker, more professional base color
    Paint paint = Paint()
      ..color = const Color(0xFF0F0F0F) 
      ..style = PaintingStyle.fill;

    // Extremely subtle highlight instead of "grey bar"
    Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double centerX = size.width / 2;
    double notchWidth = 110; 
    double notchHeight = 28;
    double curveSideWidth = 25; // Smooth "G2" transition length

    Path path = Path();
    path.moveTo(0, 0);
    
    // Smooth transition into the notch
    path.lineTo(centerX - notchWidth / 2 - curveSideWidth, 0);
    
    // Slicker Bezier curve (S-shape entrance)
    path.cubicTo(
      centerX - notchWidth / 2, 0,
      centerX - notchWidth / 2, -notchHeight,
      centerX, -notchHeight,
    );
    
    // Slicker Bezier curve (S-shape exit)
    path.cubicTo(
      centerX + notchWidth / 2, -notchHeight,
      centerX + notchWidth / 2, 0,
      centerX + notchWidth / 2 + curveSideWidth, 0,
    );
    
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    
    // Draw only the top subtle highlight
    Path highlightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(centerX - notchWidth / 2 - curveSideWidth, 0)
      ..cubicTo(
        centerX - notchWidth / 2, 0,
        centerX - notchWidth / 2, -notchHeight,
        centerX, -notchHeight,
      )
      ..cubicTo(
        centerX + notchWidth / 2, -notchHeight,
        centerX + notchWidth / 2, 0,
        centerX + notchWidth / 2 + curveSideWidth, 0,
      )
      ..lineTo(size.width, 0);
      
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
