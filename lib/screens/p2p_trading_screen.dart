import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/p2p_ad.dart';
import '../services/api_service.dart';
import 'create_ad_screen.dart';
import 'p2p/p2p_order_confirmation_screen.dart';
import 'p2p/p2p_seller_release_screen.dart';

class P2PTradingScreen extends StatefulWidget {
  const P2PTradingScreen({super.key});

  @override
  State<P2PTradingScreen> createState() => _P2PTradingScreenState();
}

class _P2PTradingScreenState extends State<P2PTradingScreen> {
  bool _isBuySelected = true;
  // BTC is first/default because the API currently only has BTC ads
  String _selectedToken = 'BTC';

  late Future<List<P2PAd>> _adsFuture;

  @override
  void initState() {
    super.initState();
    _adsFuture = ApiService.getP2pAds();
  }

  void _refresh() {
    setState(() {
      _adsFuture = ApiService.getP2pAds();
    });
  }

  /// Filter ads by selected token and active status only.
  /// Both Buy and Sell tabs currently show the same active ad pool.
  List<P2PAd> _filterAds(List<P2PAd> all) {
    return all.where((ad) {
      return ad.currencySymbol.toUpperCase() == _selectedToken.toUpperCase() &&
          ad.isActive;
    }).toList();
  }

  void _showBuyAmountDialog(P2PAd ad) {
    final amountController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Amount',
                  style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'How much ${ad.currencySymbol} do you want to buy?',
                  style: AppTheme.inter(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTheme.inter(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter NGN amount',
                    hintStyle: AppTheme.inter(color: Colors.white30, fontSize: 14),
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
                    suffixText: 'NGN',
                    suffixStyle: AppTheme.inter(color: Colors.white54, fontSize: 14),
                    errorText: errorText,
                  ),
                  onChanged: (val) {
                    setDialogState(() => errorText = null);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Limits: ₦${ad.minLimit.toStringAsFixed(2)} – ₦${ad.maxLimit.toStringAsFixed(2)}',
                  style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE4B53E)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTheme.inter(color: const Color(0xFFE4B53E), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (amount == null) {
                            setDialogState(() => errorText = 'Enter a valid amount');
                            return;
                          }
                          if (amount < ad.minLimit) {
                            setDialogState(() => errorText = 'Amount below minimum (₦${ad.minLimit})');
                            return;
                          }
                          if (amount > ad.maxLimit) {
                            setDialogState(() => errorText = 'Amount exceeds maximum (₦${ad.maxLimit})');
                            return;
                          }

                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => P2POrderConfirmationScreen(
                                ad: ad,
                                fiatAmount: amount,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4B53E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Continue',
                          style: AppTheme.inter(color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'P2P Trading',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSegmentedControl(),
              _buildFiltersRow(),
              Expanded(
                child: FutureBuilder<List<P2PAd>>(
                  future: _adsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE4B53E),
                          strokeWidth: 2,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    final filtered = _filterAds(snapshot.data ?? []);

                    if (filtered.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => _buildAdCard(filtered[index]),
                    );
                  },
                ),
              ),
            ],
          ),

          // Post Ad Floating Button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => const CreateAdScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFE4B53E), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '+ Post Ad',
                    style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Segmented control ───────────────────────────────────────────────────

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFF151515),
        ),
        child: Row(
          children: [
            _buildSegmentTab('Buy', _isBuySelected, () => setState(() => _isBuySelected = true)),
            _buildSegmentTab('Sell', !_isBuySelected, () => setState(() => _isBuySelected = false)),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: isActive ? const LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)]) : null,
          ),
          child: Text(
            label,
            style: AppTheme.inter(
              color: isActive ? Colors.black : Colors.white54,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Token chip row ──────────────────────────────────────────────────────

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // BTC is first to match current API data
          _buildTokenChip('BTC'),
          const SizedBox(width: 8),
          _buildTokenChip('USDT'),
          const SizedBox(width: 8),
          _buildTokenChip('ETH'),
          const Spacer(),
          Text('Sort', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE4B53E), size: 18),
        ],
      ),
    );
  }

  Widget _buildTokenChip(String token) {
    final bool isSelected = _selectedToken == token;
    return GestureDetector(
      onTap: () => setState(() => _selectedToken = token),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE4B53E) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          token,
          style: AppTheme.inter(
            color: isSelected ? Colors.black : Colors.white60,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─── Ad card ─────────────────────────────────────────────────────────────

  Widget _buildAdCard(P2PAd ad) {
    // Dummy data for fields not yet in the API response
    const tradeStats = '450 trades | 98.5%';
    final methods = ['Palmpay', 'Bank Transfer'];

    final initials = ad.userName.length >= 2
        ? ad.userName.substring(0, 2).toUpperCase()
        : ad.userName.toUpperCase();

    final formattedPrice = _formatNumber(ad.price);
    final formattedAvailable = _formatCrypto(ad.availableAmount, ad.currencySymbol);
    final formattedMin = _formatNumber(ad.minLimit);
    final formattedMax = _formatNumber(ad.maxLimit);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar / initials
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E1E1E),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTheme.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ad.userName,
                          style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.green, size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tradeStats,
                      style: AppTheme.inter(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Price column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Price', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedPrice,
                        style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text('NGN', style: AppTheme.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Details row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    formattedAvailable,
                    style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Limits', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    '₦$formattedMin – ₦$formattedMax',
                    style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Action row ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: methods.map((m) => _buildMethodIndicator(m)).toList(),
              ),
              GestureDetector(
                onTap: () {
                  if (_isBuySelected) {
                    _showBuyAmountDialog(ad);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const P2PSellerReleaseScreen()),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isBuySelected ? 'Buy ${ad.currencySymbol}' : 'Sell ${ad.currencySymbol}',
                    style: AppTheme.inter(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodIndicator(String label) {
    Color dotColor = label == 'Palmpay'
        ? Colors.purpleAccent
        : label == 'Bank Transfer'
            ? Colors.blueAccent
            : Colors.greenAccent;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTheme.inter(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  // ─── Empty / Error states ────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.white24, size: 56),
          const SizedBox(height: 12),
          Text(
            'No ads available',
            style: AppTheme.inter(color: Colors.white38, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different token or check back later.',
            style: AppTheme.inter(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 56),
            const SizedBox(height: 12),
            Text(
              'Failed to load ads',
              style: AppTheme.inter(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white30, fontSize: 12),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _refresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE4B53E)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Retry',
                  style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (m) => ',',
          );
    }
    return value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        );
  }

  String _formatCrypto(double value, String symbol) {
    // Show up to 7 significant decimal places, strip trailing zeros
    final formatted = value.toStringAsFixed(7).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return '$formatted $symbol';
  }
}
