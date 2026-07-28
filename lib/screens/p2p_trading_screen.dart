import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../models/p2p_ad.dart';
import '../models/p2p_trade.dart';
import '../services/api_service.dart';
import '../services/data_store.dart';
import 'create_ad_screen.dart';
import 'p2p/my_ads_screen.dart';
import 'p2p/p2p_order_confirmation_screen.dart';
import 'p2p/p2p_seller_release_screen.dart';
import 'profile_screen.dart';
import 'trade_details_screen.dart';

class P2PTradingScreen extends StatefulWidget {
  const P2PTradingScreen({super.key});

  @override
  State<P2PTradingScreen> createState() => _P2PTradingScreenState();
}

class _P2PTradingScreenState extends State<P2PTradingScreen> with WidgetsBindingObserver {
  int _p2pNavIndex = 0;

  // Marketplace tab state
  bool _isBuySelected = true;
  String _selectedToken = 'BTC';
  late Future<List<P2PAd>> _adsFuture;

  // Orders tab state
  bool _isOrdersBuyTab = true;
  late Future<List<P2PTrade>> _tradesFuture;
  List<P2PTrade> _cachedTrades = []; // instant display while refreshing
  bool _tradesRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _adsFuture = ApiService.getP2pAds();
    _tradesFuture = ApiService.getMyP2pTrades().then((trades) {
      _cachedTrades = trades;
      return trades;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefreshTrades();
    }
  }

  void _refreshAds() => setState(() {
        _adsFuture = ApiService.getP2pAds();
      });
  void _refreshTrades() => setState(() {
        _tradesFuture = ApiService.getMyP2pTrades().then((trades) {
          _cachedTrades = trades;
          return trades;
        });
      });

  Future<void> _silentRefreshTrades() async {
    if (_tradesRefreshing) return;
    _tradesRefreshing = true;
    try {
      final trades = await ApiService.getMyP2pTrades();
      if (mounted) setState(() => _cachedTrades = trades);
    } finally {
      _tradesRefreshing = false;
    }
  }

  Future<void> _proceedToOrderConfirmation(P2PAd cachedAd, double fiatAmount, {bool isSell = false}) async {
    try {
      // Fetch fresh ad data to ensure latest seller bank details are shown
      final freshAds = await ApiService.getP2pAds();
      final freshAd = freshAds.firstWhere(
        (ad) => ad.id == cachedAd.id,
        orElse: () => cachedAd, // Fall back to cached if not found
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => P2POrderConfirmationScreen(
            ad: freshAd,
            fiatAmount: fiatAmount,
            isSell: isSell,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // If fresh fetch fails, use cached ad
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => P2POrderConfirmationScreen(
            ad: cachedAd,
            fiatAmount: fiatAmount,
            isSell: isSell,
          ),
        ),
      );
    }
  }

  Future<void> _callMyTradesEndpoint() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final primaryBase = (kIsWeb && kDebugMode)
        ? ApiService.liveUrl
        : ApiService.baseUrl;
    final fallbackBase = (kIsWeb && kDebugMode)
        ? ApiService.baseUrl
        : ApiService.liveUrl;
    final token = ApiService.authToken;

    Future<http.Response> fetch(String base) {
      return http.get(
        Uri.parse('$base/p2p/my-trades?t=$now'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );
    }

    try {
      await fetch(primaryBase);
    } catch (_) {
      await fetch(fallbackBase);
    }
  }

  void _switchOrdersTab(bool isBuyTab) {
    setState(() => _isOrdersBuyTab = isBuyTab);
    _silentRefreshTrades(); // fetch fresh data without showing a spinner
  }

  Future<void> _openSellConfirmOrder(P2PTrade trade) async {
    try {
      final ads = await ApiService.getP2pAds();
      final ad = ads.firstWhere(
        (a) => a.id == trade.advertisementId,
        orElse: () => ads.isNotEmpty ? ads.first : throw Exception('Ad not found'),
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => P2POrderConfirmationScreen(
            ad: ad,
            fiatAmount: trade.fiatAmount,
            isSell: true,
            sellTradeId: trade.id,
            sellCryptoAmount: trade.cryptoAmount,
            sellBuyerName: trade.buyerName,
            sellBuyerAvatar: trade.buyerAvatar,
            sellCreatedAt: trade.createdAt,
            sellBankName: trade.bankName,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      // Fallback: go directly to release screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => P2PSellerReleaseScreen(
            tradeId: trade.id,
            fiatAmount: trade.fiatAmount,
            cryptoAmount: trade.cryptoAmount,
            currencySymbol: trade.currencySymbol,
            buyerName: trade.buyerName,
            buyerAvatar: trade.buyerAvatar,
            createdAt: trade.createdAt,
            bankName: trade.bankName,
          ),
        ),
      );
    }
  }

List<P2PAd> _filterAds(List<P2PAd> all, {required bool isBuySide}) {
  final activeAds = all.where((ad) => ad.isActive).toList();

  // Buy tab  → user wants to BUY crypto, so show merchants with SELL ads
  // Sell tab → user wants to SELL crypto, so show merchants with BUY ads
  final targetType = isBuySide ? 'sell' : 'buy';

  final typeFiltered = activeAds
      .where((ad) => ad.type.toLowerCase() == targetType)
      .toList();

  final tokenFiltered = typeFiltered
      .where((ad) => ad.currencySymbol.toUpperCase() == _selectedToken.toUpperCase())
      .toList();

  // Return token-filtered list if available, otherwise all matching type ads
  return tokenFiltered.isNotEmpty ? tokenFiltered : typeFiltered;
}

  List<P2PTrade> _filterTrades(List<P2PTrade> all, {required bool isBuyTab}) {
    final currentUserId = DataStore.instance.dashboard.value?.user.id;
    if (currentUserId == null) return [];

    if (isBuyTab) {
      return all.where((t) {
        final adType = t.adType.toLowerCase();
        if (adType.isNotEmpty) return adType != 'sell';
        return t.buyerId == currentUserId;
      }).toList();
    }

    // Show paid sell-side trades where the logged-in user is the seller.
    return all.where((t) {
      return t.sellerId == currentUserId && t.status.toLowerCase() == 'paid';
    }).toList();
  }

  String _formatNumber(double v) {
    final s = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
    return s.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  String _formatCrypto(double v, String sym) {
    final f = v
        .toStringAsFixed(7)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return '$f $sym';
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed': return const Color(0xFF33D17A);
      case 'cancelled': return const Color(0xFFFF6B6B);
      case 'paid': return Colors.blueAccent;
      default: return const Color(0xFFE4B53E);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/'
      '${d.month.toString().padLeft(2,'0')}/${d.year}';

  void _showBuyAmountDialog(P2PAd ad) {
    final ctrl = TextEditingController();
    String? err;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter Amount',
                    style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('How much NGN do you want to spend?',
                    style: AppTheme.inter(
                        color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTheme.inter(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter NGN amount',
                    hintStyle: AppTheme.inter(
                        color: Colors.white30, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF151515),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    suffixText: 'NGN',
                    suffixStyle: AppTheme.inter(
                        color: Colors.white54, fontSize: 14),
                    errorText: err,
                  ),
                  onChanged: (_) => setD(() => err = null),
                ),
                const SizedBox(height: 12),
                Text(
                    'Limits: ₦${ad.minLimit.toStringAsFixed(2)} – '
                    '₦${ad.maxLimit.toStringAsFixed(2)}',
                    style: AppTheme.inter(
                        color: const Color(0xFFE4B53E), fontSize: 12)),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFE4B53E)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Text('Cancel',
                          style: AppTheme.inter(
                              color: const Color(0xFFE4B53E),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4B53E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        final amt = double.tryParse(ctrl.text);
                        if (amt == null) {
                          setD(() => err = 'Enter a valid amount');
                          return;
                        }
                        if (amt < ad.minLimit) {
                          setD(() => err =
                              'Min ₦${ad.minLimit.toStringAsFixed(0)}');
                          return;
                        }
                        if (amt > ad.maxLimit) {
                          setD(() => err =
                              'Max ₦${ad.maxLimit.toStringAsFixed(0)}');
                          return;
                        }
                        Navigator.pop(ctx);
                        _proceedToOrderConfirmation(ad, amt);
                      },
                      child: Text('Continue',
                          style: AppTheme.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool coreP2PTabs = _p2pNavIndex == 0 || _p2pNavIndex == 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: coreP2PTabs
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _p2pNavIndex == 0 ? 'P2P Trading' : 'My Orders',
                style: AppTheme.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: _buildP2PBody(),
      bottomNavigationBar: _buildP2PBottomNav(),
    );
  }

  Widget _buildP2PBody() {
    switch (_p2pNavIndex) {
      case 0:
        return _buildMarketplace();
      case 1:
        return _buildOrders();
      case 2:
        return const MyAdsScreen(embedded: true);
      case 3:
        return const ProfileScreen(embedded: true);
      default:
        return _buildMarketplace();
    }
  }

  Widget _buildP2PBottomNav() {
    Widget item({
      required int index,
      required String iconAsset,
      required String label,
    }) {
      final active = _p2pNavIndex == index;
      final color = active ? const Color(0xFFE4B53E) : const Color(0xFF7B7E86);

      return Expanded(
        child: InkWell(
          onTap: () {
            // Orders, My Ads, Profile are coming soon — only P2P (index 0) is live
            if (index != 0) {
              showComingSoon(context);
              return;
            }
            setState(() => _p2pNavIndex = index);
            if (index == 1) {
              _silentRefreshTrades();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  child: Image.asset(
                    iconAsset,
                    width: 30,
                    height: 30,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTheme.inter(
                    color: color,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 98,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.14))),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B1F21), Color(0xFF121416)],
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            item(index: 0, iconAsset: 'assets/icons/profile-2user.png', label: 'P2P'),
            item(index: 1, iconAsset: 'assets/icons/message-text.png', label: 'Orders'),
            item(index: 2, iconAsset: 'assets/icons/Ads.png', label: 'My Ads'),
            item(index: 3, iconAsset: 'assets/icons/Users.png', label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _showSellAmountDialog(P2PAd ad) {
    final ctrl = TextEditingController();
    String? err;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter Amount',
                    style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    'How much ${ad.currencySymbol} do you want to sell?',
                    style: AppTheme.inter(
                        color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTheme.inter(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter NGN amount',
                    hintStyle: AppTheme.inter(
                        color: Colors.white30, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF151515),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    suffixText: 'NGN',
                    suffixStyle: AppTheme.inter(
                        color: Colors.white54, fontSize: 14),
                    errorText: err,
                  ),
                  onChanged: (_) => setD(() => err = null),
                ),
                const SizedBox(height: 12),
                Text(
                    'Limits: ₦${ad.minLimit.toStringAsFixed(2)} – '
                    '₦${ad.maxLimit.toStringAsFixed(2)}',
                    style: AppTheme.inter(
                        color: const Color(0xFFE4B53E), fontSize: 12)),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFE4B53E)),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12))),
                      child: Text('Cancel',
                          style: AppTheme.inter(
                              color: const Color(0xFFE4B53E),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12))),
                      onPressed: () {
                        final amt = double.tryParse(ctrl.text);
                        if (amt == null) {
                          setD(() => err = 'Enter a valid amount');
                          return;
                        }
                        if (amt < ad.minLimit) {
                          setD(() => err =
                              'Min ₦${ad.minLimit.toStringAsFixed(0)}');
                          return;
                        }
                        if (amt > ad.maxLimit) {
                          setD(() => err =
                              'Max ₦${ad.maxLimit.toStringAsFixed(0)}');
                          return;
                        }
                        Navigator.pop(ctx);
                        _proceedToOrderConfirmation(ad, amt, isSell: true);
                      },
                      child: Text('Continue',
                          style: AppTheme.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // ════════════════════════════════════════════════
  //  MARKETPLACE TAB
  // ════════════════════════════════════════════════

  Widget _buildMarketplace() {
    return Stack(
      children: [
        Column(
          children: [
            _buildBuySellSegment(),
            _buildFiltersRow(),
            Expanded(
              child: FutureBuilder<List<P2PAd>>(
                future: _adsFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFE4B53E), strokeWidth: 2),
                    );
                  }
                  if (snap.hasError) {
                    return _buildAdsError(snap.error.toString());
                  }
                  final ads = _filterAds(
                    snap.data ?? [],
                    isBuySide: _isBuySelected,
                  );
                  if (ads.isEmpty) return _buildAdsEmpty();
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 100),
                    itemCount: ads.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                    itemBuilder: (_, i) => _buildAdCard(ads[i]),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 32, left: 0, right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(
                      builder: (_) => const CreateAdScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: const Color(0xFFE4B53E), width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Text('+ Post Ad',
                    style: AppTheme.inter(
                        color: const Color(0xFFE4B53E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBuySellSegment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFF151515),
        ),
        child: Row(children: [
          _buildSegTab('Buy', _isBuySelected,
              () => setState(() => _isBuySelected = true)),
          _buildSegTab('Sell', !_isBuySelected, () {
            setState(() {
              _isBuySelected = false;
            });
            _refreshAds();
          }),
        ]),
      ),
    );
  }

  Widget _buildSegTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFFF3C756), Color(0xFFB88A2D)])
                : null,
          ),
          child: Text(label,
              style: AppTheme.inter(
                  color: active ? Colors.black : Colors.white54,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        _buildTokenChip('BTC'),
        const SizedBox(width: 8),
        _buildTokenChip('USDT'),
        const SizedBox(width: 8),
        _buildTokenChip('ETH'),
        const Spacer(),
        Text('Sort',
            style: AppTheme.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFE4B53E), size: 18),
      ]),
    );
  }

  Widget _buildTokenChip(String token) {
    final sel = _selectedToken == token;
    return GestureDetector(
      onTap: () => setState(() => _selectedToken = token),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? const Color(0xFFE4B53E)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(token,
            style: AppTheme.inter(
                color: sel ? Colors.black : Colors.white60,
                fontSize: 12,
                fontWeight:
                    sel ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }

  Widget _buildAdCard(P2PAd ad) {
    final initials = ad.userName.length >= 2
        ? ad.userName.substring(0, 2).toUpperCase()
        : ad.userName.toUpperCase();
    final isBuy = _isBuySelected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: ad.userAvatar != null && ad.userAvatar!.isNotEmpty
                    ? Image.network(
                        ApiService.resolveUrl(ad.userAvatar!) ?? ad.userAvatar!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1E1E1E),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: AppTheme.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1E1E1E)),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: AppTheme.inter(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(ad.userName,
                          style: AppTheme.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified,
                          color: Colors.green, size: 14),
                    ]),
                    const SizedBox(height: 4),
                    // Text('450 trades | 98.5%',
                    //     style: AppTheme.inter(
                    //         color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Price',
                      style: AppTheme.inter(
                          color: const Color(0xFFE4B53E),
                          fontSize: 11)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatNumber(ad.price),
                          style: AppTheme.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('NGN',
                          style: AppTheme.inter(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity ${_formatCrypto(ad.availableAmount, ad.currencySymbol)}',
                style: AppTheme.inter(
                    color: Colors.white54, fontSize: 11)),
              Text(
                'Limits ₦${_formatNumber(ad.minLimit)} - ₦${_formatNumber(ad.maxLimit)}',
                style: AppTheme.inter(
                    color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ad.bankName ?? '',
                  style: AppTheme.inter(
                      color: Colors.white38,
                      fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => isBuy
                    ? _showBuyAmountDialog(ad)
                    : _showSellAmountDialog(ad),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isBuy
                        ? const Color(0xFF33D17A)
                        : Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isBuy
                        ? 'Buy ${ad.currencySymbol}'
                        : 'Sell ${ad.currencySymbol}',
                    style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdsEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.inbox_outlined,
          color: Colors.white24, size: 56),
      const SizedBox(height: 12),
      Text('No ads available',
          style: AppTheme.inter(
              color: Colors.white38,
              fontSize: 15,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text('Try a different token or check back later.',
          style: AppTheme.inter(
              color: Colors.white24, fontSize: 12)),
    ]),
  );

  Widget _buildAdsError(String error) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded,
            color: Colors.white24, size: 56),
        const SizedBox(height: 12),
        Text('Failed to load ads',
            style: AppTheme.inter(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(error.replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
            style: AppTheme.inter(
                color: Colors.white30, fontSize: 12)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _refreshAds,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE4B53E)),
                borderRadius: BorderRadius.circular(20)),
            child: Text('Retry',
                style: AppTheme.inter(
                    color: const Color(0xFFE4B53E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    ),
  );

  // ════════════════════════════════════════════════
  //  MY ORDERS TAB
  // ════════════════════════════════════════════════

  Widget _buildOrders() {
    return Column(children: [
      _buildOrdersSegment(),
      Expanded(
        child: FutureBuilder<List<P2PTrade>>(
          future: _tradesFuture,
          builder: (ctx, snap) {
            // Use cached data immediately — no spinner on subsequent loads
            final rawList = snap.data ?? _cachedTrades;
            final isFirstLoad = snap.connectionState == ConnectionState.waiting && _cachedTrades.isEmpty;

            if (isFirstLoad) {
              return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFE4B53E), strokeWidth: 2),
              );
            }
            if (snap.hasError && _cachedTrades.isEmpty) {
              return _buildTradesError(snap.error.toString());
            }
            final trades =
              _filterTrades(rawList, isBuyTab: _isOrdersBuyTab);
              final child = trades.isEmpty
                  ? _buildTradesEmpty()
                  : RefreshIndicator(
                      color: const Color(0xFFE4B53E),
                      backgroundColor: const Color(0xFF1A1A1E),
                      onRefresh: () async => _refreshTrades(),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 8, bottom: 32),
                        itemCount: trades.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (_, i) => _buildTradeCard(
                          trades[i],
                          isBuyTab: _isOrdersBuyTab,
                        ),
                      ),
                    );
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey(_isOrdersBuyTab),
                  child: child,
                ),
              );
          },
        ),
      ),
    ]);
  }

  Widget _buildOrdersSegment() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFF151515),
        ),
        child: Row(children: [
          _buildSegTab('Buy Orders', _isOrdersBuyTab,
              () => _switchOrdersTab(true)),
          _buildSegTab('Sell Orders', !_isOrdersBuyTab,
              () => _switchOrdersTab(false)),
        ]),
      ),
    );
  }

  Widget _buildTradeCard(
    P2PTrade trade, {
    bool showSellAction = false,
    bool? isBuyTab,
  }) {
    final buyTab = isBuyTab ?? _isOrdersBuyTab;
    final counterparty =
        buyTab ? trade.sellerName : trade.buyerName;
    final initials = counterparty.length >= 2
        ? counterparty.substring(0, 2).toUpperCase()
        : counterparty.toUpperCase();
    final sc = _statusColor(trade.status);

    return GestureDetector(
      onTap: () async {
        if (!buyTab) {
          _openSellConfirmOrder(trade);
          return;
        }
        final r = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => TradeDetailsScreen(trade: trade),
          ),
        );
        if (r == true || r == null) _silentRefreshTrades();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E1E1E)),
                  alignment: Alignment.center,
                  child: buyTab
                      ? Text(initials,
                          style: AppTheme.inter(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold))
                      : (trade.buyerAvatar != null && trade.buyerAvatar!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                          ApiService.resolveUrl(trade.buyerAvatar!) ??
                            trade.buyerAvatar!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(initials,
                                    style: AppTheme.inter(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ),
                            )
                          : Text(initials,
                              style: AppTheme.inter(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(counterparty,
                            style: AppTheme.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            color: Colors.green, size: 14),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                          buyTab ? 'Seller' : 'Buyer',
                          style: AppTheme.inter(
                              color: Colors.white54,
                              fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Price',
                        style: AppTheme.inter(
                            color: const Color(0xFFE4B53E),
                            fontSize: 11)),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(_formatNumber(trade.adPrice),
                            style: AppTheme.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Text('NGN',
                            style: AppTheme.inter(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (buyTab)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: sc.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(trade.status.toUpperCase(),
                          style: AppTheme.inter(
                              color: sc,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (buyTab) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (trade.bankName != null)
                    Text(
                      trade.bankName!,
                      style: AppTheme.inter(
                          color: Colors.white38, fontSize: 11),
                    )
                  else
                    Text(
                        'Fiat  ₦${_formatNumber(trade.fiatAmount)}',
                        style: AppTheme.inter(
                            color: Colors.white70, fontSize: 12)),
                  Text(
                      _formatCrypto(
                          trade.cryptoAmount,
                          trade.currencySymbol),
                      style: AppTheme.inter(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
            if (showSellAction) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (trade.bankName != null)
                    Expanded(
                      child: Text(
                        trade.bankName!,
                        style: AppTheme.inter(
                            color: Colors.white38,
                            fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  GestureDetector(
                    onTap: () => _openSellConfirmOrder(trade),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Sell',
                        textAlign: TextAlign.center,
                        style: AppTheme.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (!buyTab && (trade.bankName == null)) const SizedBox(height: 4),
            if (buyTab && (trade.bankName != null ||
                trade.bankAccountNumber != null)) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.account_balance_rounded,
                      color: Color(0xFFE4B53E), size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        if (trade.bankName != null)
                          Text(trade.bankName!,
                              style: AppTheme.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w600)),
                        if (trade.bankAccountNumber != null)
                          Text(trade.bankAccountNumber!,
                              style: AppTheme.inter(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w700)),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
            if (buyTab) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${trade.id}',
                      style: AppTheme.inter(
                          color: Colors.white38,
                          fontSize: 11)),
                  if (trade.createdAt != null)
                    Text(_fmtDate(trade.createdAt!),
                        style: AppTheme.inter(
                            color: Colors.white38,
                            fontSize: 11)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTradesEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.receipt_long_outlined,
          color: Colors.white24, size: 56),
      const SizedBox(height: 12),
      Text('No orders yet',
          style: AppTheme.inter(
              color: Colors.white38,
              fontSize: 15,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text('Your trades will appear here.',
          style: AppTheme.inter(
              color: Colors.white24, fontSize: 12)),
    ]),
  );

  Widget _buildTradesError(String error) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded,
            color: Colors.white24, size: 56),
        const SizedBox(height: 12),
        Text('Failed to load orders',
            style: AppTheme.inter(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(error.replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
            style: AppTheme.inter(
                color: Colors.white30, fontSize: 12)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _refreshTrades,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(0xFFE4B53E)),
                borderRadius: BorderRadius.circular(20)),
            child: Text('Retry',
                style: AppTheme.inter(
                    color: const Color(0xFFE4B53E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    ),
  );
}
