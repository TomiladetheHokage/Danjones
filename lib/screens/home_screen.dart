import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/sparkline_chart.dart';
import '../theme/app_theme.dart';

class CryptoDashboard extends StatefulWidget {
  const CryptoDashboard({super.key});

  @override
  State<CryptoDashboard> createState() => _CryptoDashboardState();
}

class _CryptoDashboardState extends State<CryptoDashboard> {
  bool _isMoversSelected = true;
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      extendBody: true,
      body: Stack(
        children: [

          /// BASE RADIAL BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.6),
                  radius: 1.3,
                  colors: [
                    Color(0xFF0F2A1E),
                    Color(0xFF0A0A0A),
                    Color(0xFF050505),
                  ],
                  stops: [0.0, 0.55, 1],
                ),
              ),
            ),
          ),

          /// SOFT GREEN GLOW
          Positioned(
            top: -140,
            left: -120,
            right: -120,
            child: Container(
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF22C55E).withOpacity(.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          /// RADAR LINES
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 400),
              painter: RadarBackgroundPainter(),
            ),
          ),

          /// MAIN CONTENT
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

  /// APP BAR
SliverToBoxAdapter _buildAppBar() {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [

          /// LEFT + RIGHT ITEMS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// Profile Image
              const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(
                  "assets/images/profile_picture.png", // your asset image
                ),
              ),

              /// Notification Icon
              Image.asset(
                "assets/icons/Notification-icon.png",
                width: 28,
                height: 28,
                color: const Color(0xFFE4B53E),
              ),
            ],
          ),

          /// CENTER WALLET TEXT
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Wallet (0xbhc...cdjds)',
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  /// BALANCE CARD
 SliverToBoxAdapter _buildBalanceSection() {
  return SliverToBoxAdapter(
    child: Center(
      child: Container(
        width: 351,
        height: 160,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE ROW
            Row(
              children: [
                Text(
                  'Total Equity (NGN)',
                  style: AppTheme.inter(
                    color: Colors.white.withOpacity(.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
GestureDetector(
  onTap: () {
    setState(() {
      _hideBalance = !_hideBalance; // optional: toggle balance visibility
    });
  },
  child: Image.asset(
    "assets/icons/eye-vector-icon.png",
    width: 18,      // match the original icon size
    height: 18,
    color: Colors.white.withOpacity(0.6), // optional tint
  ),
),
              ],
            ),

            const SizedBox(height: 6),

            /// BALANCE
            RichText(
              text: TextSpan(
                style: AppTheme.inter(color: Colors.white),
                children: [
                  TextSpan(
                    text: '₦ ',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white.withOpacity(.9),
                    ),
                  ),
                   TextSpan(
text: _hideBalance ? '••••••••' : '12,450,200',                 
   style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '.50',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            /// CHANGE BADGE
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '+₦25,000 (2.4%)',
                style: AppTheme.inter(
                  color: const Color(0xFF34D399),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  /// ACTION BUTTONS
  SliverToBoxAdapter _buildActionGrid() {
   final actions = [
    ('Deposit', 'assets/icons/deposit.png', true),
    ('Buy', 'assets/icons/buy.png', false),
    ('Swap', 'assets/icons/swap.png', false),
    ('P2P', 'assets/icons/p2p.png', false),
  ];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((a) => _actionItem(a.$1, imagePath: a.$2, isGold: a.$3)).toList(),
        ),
      ),
    );
  }
Widget _actionItem(String label, {IconData? icon, String? imagePath, bool isGold = false}) {
  return Column(
    children: [
      Container(
        width: 65,
        height: 65,
        // REMOVED: BoxDecoration with colors/gradients
        // ADDED: Simple transparent container or very subtle splash effect
        decoration: const BoxDecoration(
          color: Colors.transparent, 
        ),
        child: Center(
          child: imagePath != null
              ? Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      color: isGold ? const Color(0xFFE4B53E) : Colors.white24,
                      size: 50,
                    );
                  },
                )
              : Icon(
                  icon,
                  color: isGold ? const Color(0xFFE4B53E) : Colors.white,
                  size: 50,
                ),
        ),
      ),
      const SizedBox(height: 8), // Adjusted spacing
      Text(
        label, 
        style: AppTheme.inter(
          color: Colors.white.withOpacity(0.7), 
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}

  /// MOVERS TOGGLE
SliverToBoxAdapter _buildMoversToggle() {
  return SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: 54, // Fixed height for a tighter look
      padding: const EdgeInsets.all(6), // This creates the "smaller" bar effect
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _toggleBtn('Top Movers', _isMoversSelected, () => setState(() => _isMoversSelected = true)),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // Only show the gold gradient if active
          gradient: active 
              ? const LinearGradient(colors: [Color(0xFFE4B53E), Color(0xFFB88A2D)]) 
              : null,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.inter(
              color: active ? Colors.black : Colors.white38,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
  );
}

  /// HORIZONTAL MOVERS
  SliverToBoxAdapter _buildHorizontalMovers() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _moverCard('BTC', 'Bitcoin', '\$16,000', '+4.5%',
                [10, 12, 9, 14, 15, 13, 16]),
            _moverCard('ETH', 'Ethereum', '\$16,000', '+4.5%',
                [8, 10, 7, 12, 14, 11, 13]),
          ],
        ),
      ),
    );
  }

Widget _moverCard(String symbol, String name, String price, String change, List<double> chartData) {
  return Container(
    width: 160,
    margin: const EdgeInsets.only(right: 15),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: symbol == 'BTC'
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.purple.withOpacity(0.3),
              child: Text(
                symbol.substring(0, 1),
                style: TextStyle(
                  color: symbol == 'BTC' ? Colors.orange : Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                change,
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        SparklineChart(
          data: chartData,
          isPositive: true,
          width: 128,
          height: 40,
        ),
        
        const Spacer(),
        
        Text(price, style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

  /// TOKEN HEADER
  SliverToBoxAdapter _buildTokenHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tokens',
                style: AppTheme.heading3),
            Text('View all',
                style: AppTheme.inter(
                  color: const Color(0xFFE4B53E),
                )),
          ],
        ),
      ),
    );
  }

  /// TOKEN LIST
  SliverList _buildTokenList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20),
          leading: const CircleAvatar(
              backgroundColor: Color(0xFF1A1A1A)),
          title: const Text('BTC',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          subtitle: const Text('Bitcoin',
              style: TextStyle(color: Colors.white38)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('\$20,380',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text('+2.5%',
                  style: TextStyle(
                      color: Colors.green, fontSize: 12)),
            ],
          ),
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
      ..color = const Color(0xFF22C55E).withOpacity(.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height * 0.2);

    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, i * 60.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}