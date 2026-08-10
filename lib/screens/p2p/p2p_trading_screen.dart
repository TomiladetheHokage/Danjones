import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../models/p2p/p2p_ad.dart';
import '../../models/p2p/p2p_trade.dart';
import '../../services/api_service.dart';
import '../../services/data_store.dart';
import '../../widgets/shared/user_avatar.dart';
import 'create_ad_screen.dart';
import 'my_ads_screen.dart';
import 'p2p_order_confirmation_screen.dart';
import 'p2p_seller_release_screen.dart';
import 'p2p_profile_screen.dart';
import 'trade_details_screen.dart';

class P2PTradingScreen extends StatefulWidget {
  const P2PTradingScreen({super.key});

  @override
  State<P2PTradingScreen> createState() => _P2PTradingScreenState();
}

class _P2PTradingScreenState extends State<P2PTradingScreen> with WidgetsBindingObserver {
  int _p2pNavIndex = 0;

  // Full list of supported P2P currencies — always shown in the sort sheet
  static const List<String> _supportedTokens = ['BTC', 'ETH', 'USDT', 'DOGE', 'BSC'];
  bool _isBuySelected = true;
  String _selectedToken = '';        // empty = "All" until ads load
  List<String> _availableTokens = []; // derived from loaded ads
  late Future<List<P2PAd>> _adsFuture;

  // Orders tab state
  String _ordersFilter = 'all';
  late Future<List<P2PTrade>> _tradesFuture;
  List<P2PTrade> _cachedTrades = []; // instant display while refreshing
  bool _tradesRefreshing = false;
  final Map<int, Timer> _orderTimers = {};
  final Map<int, Duration> _orderTimeLeft = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final adsFuture = ApiService.getP2pAds();
    adsFuture.then(_updateAvailableTokens).catchError((_) {});
    _adsFuture = adsFuture;
    _tradesFuture = ApiService.getMyP2pTrades().then((trades) {
      _cachedTrades = trades;
      return trades;
    });
  }

  /// Derives unique sorted tokens from loaded ads and updates state once —
  /// called after the future resolves, never during a build/layout pass.
  void _updateAvailableTokens(List<P2PAd> ads) {
    if (!mounted) return;
    final tokens = ads
        .where((ad) => ad.isActive)
        .map((ad) => ad.currencySymbol.toUpperCase())
        .toSet()
        .toList()
      ..sort();
    if (tokens.isEmpty) return;
    setState(() {
      _availableTokens = tokens;
      if (_selectedToken.isEmpty || !tokens.contains(_selectedToken)) {
        _selectedToken = tokens.first;
      }
    });
  }

  @override
  void dispose() {
    for (final t in _orderTimers.values) t.cancel();
    _orderTimers.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefreshTrades();
    }
  }

  void _refreshAds() {
    final future = ApiService.getP2pAds();
    future.then(_updateAvailableTokens).catchError((_) {});
    setState(() => _adsFuture = future);
  }
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

  void _switchOrdersFilter(String filter) {
    setState(() => _ordersFilter = filter);
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

    // Buy tab  → show ads with type "buy"
    // Sell tab → show ads with type "sell"
    final targetType = isBuySide ? 'buy' : 'sell';
    final typeFiltered = activeAds
        .where((ad) => ad.type.toLowerCase() == targetType)
        .toList();

    // Apply token filter — skip if nothing selected yet
    if (_selectedToken.isEmpty) return typeFiltered;
    return typeFiltered
        .where((ad) => ad.currencySymbol.toUpperCase() == _selectedToken)
        .toList();
  }

  List<P2PTrade> _filterTrades(List<P2PTrade> all, {String? filter}) {
    final f = filter ?? _ordersFilter;
    if (f == 'all') return all;
    return all.where((t) => t.status.toLowerCase() == f).toList();
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
        return const P2PProfileScreen();
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
    // Derive crypto limits from the fiat limits and ad price
    final minCrypto = ad.minLimit / ad.price;
    final maxCrypto = ad.maxLimit / ad.price;

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
                    hintText: 'Enter ${ad.currencySymbol} amount',
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
                    suffixText: ad.currencySymbol,
                    suffixStyle: AppTheme.inter(
                        color: Colors.white54, fontSize: 14),
                    errorText: err,
                  ),
                  onChanged: (_) => setD(() => err = null),
                ),
                const SizedBox(height: 12),
                Text(
                    'Limits: ${minCrypto.toStringAsFixed(6)} – '
                    '${maxCrypto.toStringAsFixed(6)} ${ad.currencySymbol}',
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
                        final cryptoAmt = double.tryParse(ctrl.text);
                        if (cryptoAmt == null || cryptoAmt <= 0) {
                          setD(() => err = 'Enter a valid amount');
                          return;
                        }
                        if (cryptoAmt < minCrypto) {
                          setD(() => err =
                              'Min ${minCrypto.toStringAsFixed(6)} ${ad.currencySymbol}');
                          return;
                        }
                        if (cryptoAmt > maxCrypto) {
                          setD(() => err =
                              'Max ${maxCrypto.toStringAsFixed(6)} ${ad.currencySymbol}');
                          return;
                        }
                        // Convert crypto → fiat to pass as fiatAmount
                        final fiatAmt = cryptoAmt * ad.price;
                        Navigator.pop(ctx);
                        _proceedToOrderConfirmation(ad, fiatAmt, isSell: true);
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
      child: Row(
        children: [
          // Dynamic token chips — scroll horizontally if many tokens
          Expanded(
            child: _availableTokens.isEmpty
                ? const SizedBox.shrink()
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _availableTokens.map((token) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildTokenChip(token),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          // Sort button
          GestureDetector(
            onTap: _showSortSheet,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort',
                  style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFE4B53E), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1D21),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Currency',
                style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ..._supportedTokens.map((token) {
                final isSelected = _selectedToken == token;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedToken = token);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE4B53E).withOpacity(0.12)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE4B53E)
                            : Colors.white.withOpacity(0.07),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          token,
                          style: AppTheme.inter(
                              color: isSelected
                                  ? const Color(0xFFE4B53E)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_rounded,
                              color: Color(0xFFE4B53E), size: 18),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTokenChip(String token) {
    final sel = _selectedToken == token;
    return GestureDetector(
      onTap: () => setState(() => _selectedToken = token),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFE4B53E) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          token,
          style: AppTheme.inter(
              color: sel ? Colors.black : Colors.white60,
              fontSize: 12,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildAdCard(P2PAd ad) {
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
              UserAvatar(
                name: ad.userName,
                avatarUrl: ad.userAvatar,
                radius: 18,
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
    return FutureBuilder<List<P2PTrade>>(
      future: _tradesFuture,
      builder: (ctx, snap) {
        final rawList = snap.data ?? _cachedTrades;
        final isFirstLoad =
            snap.connectionState == ConnectionState.waiting &&
                _cachedTrades.isEmpty;

        if (isFirstLoad) {
          return const Center(
            child: CircularProgressIndicator(
                color: Color(0xFFE4B53E), strokeWidth: 2),
          );
        }
        if (snap.hasError && _cachedTrades.isEmpty) {
          return _buildTradesError(snap.error.toString());
        }

        // Count badges per status
        final counts = <String, int>{
          'all': rawList.length,
          'pending': rawList.where((t) => t.status.toLowerCase() == 'pending').length,
          'paid': rawList.where((t) => t.status.toLowerCase() == 'paid').length,
          'completed': rawList.where((t) => t.status.toLowerCase() == 'completed').length,
          'cancelled': rawList.where((t) => t.status.toLowerCase() == 'cancelled').length,
        };

        final filtered = _filterTrades(rawList);

        // Start countdown timers for pending trades
        for (final trade in rawList) {
          if (trade.status.toLowerCase() == 'pending' &&
              trade.createdAt != null &&
              !_orderTimers.containsKey(trade.id)) {
            _startTradeTimer(trade);
          }
        }

        return Column(
          children: [
            // ── Tab bar ──
            _buildOrdersTabBar(counts),
            // ── List ──
            Expanded(
              child: filtered.isEmpty
                  ? _buildTradesEmpty()
                  : RefreshIndicator(
                      color: const Color(0xFFE4B53E),
                      backgroundColor: const Color(0xFF1A1A1E),
                      onRefresh: () async => _refreshTrades(),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildOrderCard(filtered[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _startTradeTimer(P2PTrade trade) {
    // Pending orders expire 15 minutes after creation
    const window = Duration(minutes: 15);
    final elapsed = DateTime.now().difference(trade.createdAt!);
    final remaining = window - elapsed;
    _orderTimeLeft[trade.id] =
        remaining.isNegative ? Duration.zero : remaining;

    _orderTimers[trade.id] = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final cur = _orderTimeLeft[trade.id] ?? Duration.zero;
      if (cur.inSeconds <= 0) {
        _orderTimers[trade.id]?.cancel();
        _orderTimers.remove(trade.id);
        _orderTimeLeft.remove(trade.id);
      } else {
        setState(() {
          _orderTimeLeft[trade.id] = cur - const Duration(seconds: 1);
        });
      }
    });
  }

  Widget _buildOrdersTabBar(Map<String, int> counts) {
    const tabs = [
      ('All', 'all'),
      ('Pending', 'pending'),
      ('Paid', 'paid'),
      ('Completed', 'completed'),
      ('Cancelled', 'cancelled'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: tabs.map((tab) {
              final label = tab.$1;
              final key = tab.$2;
              final count = counts[key] ?? 0;
              final active = _ordersFilter == key;

              return GestureDetector(
                onTap: () => _switchOrdersFilter(key),
                child: Container(
                  margin: const EdgeInsets.only(right: 24),
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active
                            ? const Color(0xFFE4B53E)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTheme.inter(
                          fontSize: 15,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: active ? Colors.white : Colors.white54,
                        ),
                      ),
                      if (count > 0 && key != 'all') ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE4B53E),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: AppTheme.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
            indent: 0,
            endIndent: 0),
      ],
    );
  }

  Widget _buildOrderCard(P2PTrade trade) {
    // Determine side from the perspective of the logged-in user
    final currentUserId = DataStore.instance.dashboard.value?.user.id;
    final isBuyer = trade.buyerId == currentUserId;
    final adIsSell = trade.adType.toLowerCase() == 'sell';
    // If I'm buying from a sell ad, I'm buying. If I'm selling to a buy ad, I'm selling.
    final isMyBuy = isBuyer && adIsSell || (!isBuyer && !adIsSell);
    final sideLabel = isMyBuy ? 'Buy' : 'Sell';
    final sideColor = isMyBuy
        ? const Color(0xFF33D17A)
        : const Color(0xFFFF6B6B);

    final counterparty = isBuyer ? trade.sellerName : trade.buyerName;

    final sc = _statusColor(trade.status);
    final statusLabel = _statusDisplayLabel(trade.status);
    final isPending = trade.status.toLowerCase() == 'pending';
    final timeLeft = _orderTimeLeft[trade.id];

    return GestureDetector(
      onTap: () async {
        final r = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => TradeDetailsScreen(trade: trade),
          ),
        );
        if (r == true || r == null) _silentRefreshTrades();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161618),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: status badge + side label ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTheme.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sc,
                    ),
                  ),
                ),
                Text(
                  '$sideLabel ${trade.currencySymbol}',
                  style: AppTheme.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: sideColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Row 2: avatar + name + amounts ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                UserAvatar(
                  name: counterparty,
                  avatarUrl: isBuyer ? trade.sellerAvatar : trade.buyerAvatar,
                  radius: 23,
                ),
                const SizedBox(width: 12),

                // Name + verified
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          counterparty,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.verified_rounded,
                          color: Color(0xFFE4B53E), size: 16),
                    ],
                  ),
                ),

                // Fiat amount + crypto
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₦${_formatNumber(trade.fiatAmount)}',
                      style: AppTheme.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCrypto(trade.cryptoAmount, trade.currencySymbol),
                      style: AppTheme.inter(
                          fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Row 3: Order ID + Price ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ID',
                        style: AppTheme.inter(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'DJ${trade.id.toString().padLeft(8, '0')}',
                          style: AppTheme.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.copy_rounded,
                            color: Colors.white38, size: 14),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Price',
                        style: AppTheme.inter(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '₦${_formatNumber(trade.adPrice)}',
                      style: AppTheme.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Row 4: Time Left + Chat button ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isPending)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time Left',
                          style: AppTheme.inter(
                              color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        timeLeft != null
                            ? _formatCountdown(timeLeft)
                            : '—',
                        style: AppTheme.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: (timeLeft != null &&
                                  timeLeft.inSeconds > 0)
                              ? const Color(0xFFFF4444)
                              : Colors.white38,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    trade.createdAt != null
                        ? _fmtDate(trade.createdAt!)
                        : '',
                    style: AppTheme.inter(
                        color: Colors.white38, fontSize: 12),
                  ),

                // Chat button
                GestureDetector(
                  onTap: () async {
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
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFE4B53E), width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            color: Color(0xFFE4B53E), size: 15),
                        const SizedBox(width: 6),
                        Text(
                          'chat',
                          style: AppTheme.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE4B53E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusDisplayLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending Payment';
      case 'paid': return 'Paid';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'disputed': return 'Disputed';
      default: return status;
    }
  }

  String _formatCountdown(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
