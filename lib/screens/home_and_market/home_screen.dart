import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/sparkline_chart.dart';
import '../../theme/app_theme.dart';
import 'top_movers_screen.dart';
import '../deposit_screen.dart';
import '../main_shell.dart';
import '../notifications_screen.dart';
import '../p2p_trading_screen.dart';
import '../profile_screen.dart';
import '../../services/crypto_service.dart';
import '../../models/crypto_asset.dart';
import '../../services/api_service.dart';
import '../../models/user_profile.dart';
import '../../models/dashboard_data.dart';
import '../../models/wallet.dart';
import '../../services/data_store.dart';
import 'market_asset_screen.dart';
import 'package:flutter/services.dart';

class CryptoDashboard extends StatefulWidget {
  const CryptoDashboard({super.key});

  @override
  State<CryptoDashboard> createState() => _CryptoDashboardState();
}

class _CryptoDashboardState extends State<CryptoDashboard> {
  bool _isMoversSelected = true;
  bool _hideBalance = false;
  late Future<List<CryptoAsset>> marketFuture;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    marketFuture = CryptoService.fetchMarketsOnce();
    // Fetch dashboard data and update store
    try {
      final dashboardData = await ApiService.getDashboardData();
      await DataStore.instance.updateDashboard(dashboardData);
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
    }
  }

  Future<void> _refresh() async {
    CryptoService.invalidateCache();
    setState(() {
      marketFuture = CryptoService.fetchMarketsOnce();
    });
    try {
      final dashboardData = await ApiService.getDashboardData();
      await DataStore.instance.updateDashboard(dashboardData);
    } catch (e) {
      debugPrint('Error refreshing dashboard: $e');
    }
  }

  String _formatNgn(num p) {
    final s = p.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$intPart.${parts[1]}';
  }

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

          /// MAIN CONTENT
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFFE4B53E),
              backgroundColor: const Color(0xFF1E1E1E),
              child: FutureBuilder<List<CryptoAsset>>(
                future: marketFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE4B53E)));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load market data', style: TextStyle(color: Colors.white70)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found', style: TextStyle(color: Colors.white70)));
                  }

                  final allAssets = snapshot.data!;
                  final topMovers = List<CryptoAsset>.from(allAssets)..sort((a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));
                  final topLosers = List<CryptoAsset>.from(allAssets)..sort((a, b) => a.priceChangePercent.compareTo(b.priceChangePercent));
                  final sectionAssets = _isMoversSelected ? topMovers : topLosers;

                  return ValueListenableBuilder<DashboardData?>(
                    valueListenable: DataStore.instance.dashboard,
                    builder: (context, dashboard, _) {
                      // Get symbols user owns
                      final ownedSymbols = dashboard?.wallets.map((w) => w.currency.symbol.toUpperCase()).toSet() ?? {};

                      // Prioritize owned assets, then sort by price
                      final assetsForList = List<CryptoAsset>.from(allAssets)..sort((a, b) {
                        final aOwned = ownedSymbols.contains(a.symbol.toUpperCase());
                        final bOwned = ownedSymbols.contains(b.symbol.toUpperCase());
                        if (aOwned && !bOwned) return -1;
                        if (!aOwned && bOwned) return 1;
                        return b.price.compareTo(a.price);
                      });

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        slivers: [
                          _buildAppBar(),
                      _buildBalanceSection(),
                      _buildActionGrid(),
                      _buildMoversToggle(),
                      _buildHorizontalMovers(sectionAssets, showLosers: !_isMoversSelected),
                      _buildTokenHeader(),
                      _buildTokenList(assetsForList),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                      );
                    },
                  );
                },
              ),
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
              child: ValueListenableBuilder<DashboardData?>(
                valueListenable: DataStore.instance.dashboard,
                builder: (context, data, _) {
                  String? avatarUrl;
                  final user = data?.user;
                  if (user != null && user.avatar != null && user.avatar!.isNotEmpty) {
                    avatarUrl = ApiService.resolveUrl(user.avatar);
                  }
                  return CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1C1D21),
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person_rounded, color: Colors.white54, size: 20)
                        : null,
                  );
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<DashboardData?>(
                valueListenable: DataStore.instance.dashboard,
                builder: (context, data, _) {
                  final btcWallets = data?.wallets
                          .where((w) => w.currency.symbol.toUpperCase() == 'BTC')
                          .toList() ??
                      [];

                  final btcWallet =
                      btcWallets.isNotEmpty ? btcWallets.first : null;

                  final address = btcWallet?.address ?? '';

                  final displayAddress = address.length > 13
                      ? '${address.substring(0, 7)}...${address.substring(address.length - 6)}'
                      : address;

                  return GestureDetector(
                    onTap: address.isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(
                              ClipboardData(text: address),
                            );
                            if (context.mounted) {
                              _showCopiedToast(context);
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Wallet ($displayAddress)',
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.inter(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
              child: Image.asset("assets/icons/Notification-icon.png",
                width: 28, height: 28, color: const Color(0xFFE4B53E)),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCopiedToast(BuildContext context) {
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
                    Icons.copy_rounded,
                    color: Color(0xFFE4B53E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Copied',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Wallet address copied to clipboard.',
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
              ValueListenableBuilder<DashboardData?>(
                valueListenable: DataStore.instance.dashboard,
                builder: (context, data, _) {
                  final balance = data?.totalBalanceNgn ?? 0.0;
                  final formatted = _formatNgn(balance);
                  return Text(
                    _hideBalance ? '••••••••' : '₦ $formatted',
                    style: AppTheme.inter(
                      color: Colors.white, 
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF45E555).withOpacity(0.15),
              //     borderRadius: BorderRadius.circular(100),
              //   ),
              //   child: Text(
              //     '+ ₦25,000 (2.4%)',
              //     style: AppTheme.inter(
              //       color: const Color(0xFF45E555), 
              //       fontSize: 13, 
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // )
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
          _actionItem(
            'Deposit',
            'assets/icons/deposit.png',
            true,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const DepositScreen()),
              );
            },
          ),

          _actionItem(
            'Buy',
            'assets/icons/buy.png',
            false,
            onTap: () => _showComingSoon(context),
          ),

          _actionItem(
            'Swap',
            'assets/icons/swap.png',
            false,
            onTap: () {
              _showComingSoon(context);
              // mainShellKey.currentState?.setTab(2);
            },
          ),

          _actionItem(
            'P2P',
            'assets/icons/p2p.png',
            false,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const P2PTradingScreen()),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  // Widget _actionItem(String label, String iconPath, bool isGold, {VoidCallback? onTap}) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       children: [
  //         Image.asset(iconPath, width: 65, height: 65),
  //         const SizedBox(height: 8),
  //         Text(label, style: AppTheme.inter(color: Colors.white70, fontSize: 13)),
  //       ],
  //     ),
  //   );
  // }

  Widget _actionItem(
  String label,
  String iconPath,
  bool isGold, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(iconPath, width: 65, height: 65),

if (label == 'Swap' || label == 'Buy')
              Positioned(
                top: -2,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4B53E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: AppTheme.inter(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: AppTheme.inter(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
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

  SliverToBoxAdapter _buildHorizontalMovers(List<CryptoAsset> assets, {required bool showLosers}) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showLosers ? 'Top Losers' : 'Top Movers',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) => TopMoversScreen(showLosers: showLosers)),
                    );
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
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
                    const SizedBox(width: 8),
                    for (int index = 0; index < min(assets.length, 5); index++) ...[
                      _moverCard(
                        context,
                        assets[index].symbol.toUpperCase(),
                        assets[index].name,
                        assets[index].formattedPrice,
                        assets[index].changeText,
                        assets[index].sparklineData,
                        assets[index].imagePath ?? 'assets/icons/${assets[index].symbol.toLowerCase()}.png',
                        assets[index].isPositive,
                        assets[index],
                      ),
                      if (index < 4) const SizedBox(width: 1),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _moverCard(BuildContext context, String sym, String name, String price, String change, List<double> data, String img, bool isPositive, CryptoAsset asset) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => MarketAssetScreen(asset: asset)),
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
            img.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: img,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE4B53E)),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.token, color: Colors.white24, size: 44),
                )
              : Image.asset(
                  img.startsWith('assets/') ? img : 'assets/$img',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.token, color: Colors.white24, size: 44)
                ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sym,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Percentage Pill (Oval Stuff)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF45E555).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          change, 
                          style: AppTheme.inter(color: isPositive ? const Color(0xFF52D377) : const Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.bold),
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
          child: SparklineChart(data: data, isPositive: isPositive),
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

  SliverList _buildTokenList(List<CryptoAsset> assets) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final asset = assets[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: asset.imagePath != null && asset.imagePath!.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: asset.imagePath!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE4B53E)),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.token, color: Colors.white24, size: 40),
                )
              : Image.asset(
                  'assets/icons/${asset.symbol.toLowerCase()}.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) => const Icon(Icons.token, color: Colors.white24, size: 40),
                ),
            title: Text(asset.symbol.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(asset.name, style: const TextStyle(color: Colors.white38)),
            trailing: Text(asset.formattedPrice, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => MarketAssetScreen(asset: asset)),
              );
            },
          );
        },
        childCount: min(assets.length, 10),
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