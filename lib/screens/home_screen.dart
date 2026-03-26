import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/sparkline_chart.dart';
import '../theme/app_theme.dart';
import 'top_movers_screen.dart';
import 'deposit_screen.dart';
import 'swap_screen.dart';
import 'main_shell.dart';
import 'p2p_trading_screen.dart';
import 'profile_screen.dart';

class CryptoDashboard extends StatefulWidget {
  const CryptoDashboard({super.key});

  @override
  State<CryptoDashboard> createState() => _CryptoDashboardState();
}

class _CryptoDashboardState extends State<CryptoDashboard> {
  bool _isMoversSelected = true;
  bool _hideBalance = false;

  // FIX: Initialize immediately to prevent LateInitializationError
  final List<double> _btcData = List.generate(20, (i) => 50.0 + Random().nextDouble() * 50);
  final List<double> _ethData = List.generate(20, (i) => 40.0 + Random().nextDouble() * 60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      extendBody: true,
      body: Stack(
        children: [
          /// LAYER 1 & 2: BASE RADIAL GRADIENT (Atmospheric Dark Green)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.7),
                  radius: 1.5,
                  colors: [
                    Color(0xFF0D1F1E), // Glow core
                    Color(0xFF070707), // Transition
                    Color(0xFF050505), // Edge
                  ],
                  stops: [0.0, 0.26, 1.0],
                ),
              ),
            ),
          ),

          /// LAYER 3: GIANT GLOW ORB (Soft Green Halo)
          Positioned(
            top: -220,
            left: -150,
            right: -150,
            child: Container(
              height: 650,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5ED5A8).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          /// LAYER 5: RADAR RINGS (Subtle Texture)
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 450),
              painter: RadarBackgroundPainter(),
            ),
          ),

          /// MAIN CONTENT (Your original 700-line layout logic)
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                _buildBalanceSection(),
                _buildActionGrid(),
                _buildMoversToggle(),
                _buildHorizontalMovers(),
                _buildTokenHeader(),
                _buildTokenList(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// --- DETAILED UI BUILDERS (Your original styles restored) ---

  SliverToBoxAdapter _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage("assets/images/profile_picture.png"),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.white),
                const SizedBox(width: 8),
                Text('Wallet (0xbhc...cdjds)', 
                  style: AppTheme.inter(color: Colors.white, fontSize: 14)),
              ],
            ),
            Image.asset("assets/icons/Notification-icon.png", 
              width: 28, height: 28, color: const Color(0xFFE4B53E)),
          ],
        ),
      ),
    );
  }

SliverToBoxAdapter _buildBalanceSection() {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          width: 351,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.07), 
                Colors.white.withOpacity(0.02)
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Total Equity (NGN)',
                    style: AppTheme.inter(
                      color: Colors.white54, 
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _hideBalance = !_hideBalance),
                    child: Icon(
                      _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _hideBalance ? '••••••••' : '₦ 12,450,200.50',
                style: AppTheme.inter(
                  color: Colors.white, 
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF45E555).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '+ ₦25,000 (2.4%)',
                  style: AppTheme.inter(
                    color: const Color(0xFF45E555), 
                    fontSize: 13, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildActionGrid() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionItem('Deposit', 'assets/icons/deposit.png', true, onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const DepositScreen()),
              );
            }),
            _actionItem('Buy', 'assets/icons/buy.png', false),
            _actionItem('Swap', 'assets/icons/swap.png', false, onTap: () {
              mainShellKey.currentState?.setTab(2);
            }),
            _actionItem('P2P', 'assets/icons/p2p.png', false, onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const P2PTradingScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _actionItem(String label, String iconPath, bool isGold, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(iconPath, width: 65, height: 65),
          const SizedBox(height: 8),
          Text(label, style: AppTheme.inter(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildMoversToggle() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 62,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            _toggleBtn('Top Movers', _isMoversSelected, () {
              setState(() => _isMoversSelected = true);
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const TopMoversScreen()),
              );
            }),
            _toggleBtn('Top Losers', !_isMoversSelected, () => setState(() => _isMoversSelected = false)),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: active ? const LinearGradient(colors: [Color(0xFFE4B53E), Color(0xFFB88A2D)]) : null,
          ),
child: Text(
  label,
  style: AppTheme.inter(
    color: active ? Colors.black : Colors.white.withOpacity(0.5),
    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
    fontSize: 13,
  ),
),        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHorizontalMovers() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) => const TopMoversScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Movers',
                    style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),               
                  Text(
                    'View all',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
             child: Row(
  children: [
    // Add this SizedBox here to push the BTC card to the right
    const SizedBox(width: 8), 
    _moverCard(context, 'BTC', 'Bitcoin', '₦12,450,200', '+4.5%', _btcData, 'assets/icons/BTC.png'),
    const SizedBox(width: 1),
    _moverCard(context, 'ETH', 'Ethereum', '₦1,250,000', '+2.1%', _ethData, 'assets/icons/ETH.png'),
  ],
),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _moverCard(BuildContext context, String sym, String name, String price, String change, List<double> data, String img) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => const TopMoversScreen()),
      );
    },
    child: Container(
      width: 180, // Balanced width
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111), // Dark charcoal
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP ROW: Large Icon + (Symbol/Name) + Pill on far right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bigger Image as requested
            Image.asset(
              img, 
              width: 44, 
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sym, 
                        style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                      // Percentage Pill (Oval Stuff)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF45E555).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          change, 
                          style: AppTheme.inter(color: const Color(0xFF52D377), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    name, 
                    style: AppTheme.inter(color: Colors.white38, fontSize: 11)
                  ),
                ],
              ),
            ),
          ],
        ),

        const Spacer(),

        // MIDDLE: Sparkline
        SizedBox(
          height: 35, 
          width: double.infinity,
          child: SparklineChart(data: data, isPositive: true),
        ),

        const Spacer(),

        // BOTTOM: Amount (Right Aligned)
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            price, 
            style: AppTheme.inter(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            )
          ),
        ),
      ],
    ),
  ));
}

  SliverToBoxAdapter _buildTokenHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
Text(
  'Tokens',
  style: AppTheme.inter(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  ),
),            
            Text('View all', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  SliverList _buildTokenList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: CircleAvatar(backgroundColor: Color(0xFF1A1A1A)),
          title: Text('Token $index', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text('Crypto Asset', style: TextStyle(color: Colors.white38)),
          trailing: Text('₦1,200.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        childCount: 5,
      ),
    );
  }
}

class RadarBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5ED5A8).withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width / 2, size.height * 0.1);
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, i * 65.0, paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}