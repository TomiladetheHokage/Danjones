import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/wallet/wallet.dart';
import '../../theme/app_theme.dart';
import '../../services/crypto_service.dart';
import '../../services/api_service.dart';
import '../../models/market/crypto_asset.dart';
import 'deposit_select_coin_screen.dart';
import '../market/market_asset_screen.dart';
import '../withdraw/withdraw_select_coin_screen.dart';
import '../profile/profile_screen.dart';

class AssetDetailsScreen extends StatefulWidget {
  final Wallet wallet;

  const AssetDetailsScreen({super.key, required this.wallet});

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  bool _showHistory = true;
  CryptoAsset? _liveMarketData;

  List<Map<String, dynamic>> _transactions = [];
  bool _transactionsLoading = true;   // true from the start — avoids setState during first build
  String? _transactionsError;

  @override
  void initState() {
    super.initState();
    _fetchLiveMarketData();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    if (!_transactionsLoading) {
      // Only set loading state on manual refreshes — initial load starts as true
      setState(() {
        _transactionsLoading = true;
        _transactionsError = null;
      });
    }
    try {
      final txns = await ApiService.getWalletTransactions(widget.wallet.currencyId);
      if (mounted) {
        setState(() {
          _transactions = txns;
          _transactionsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _transactionsError = e.toString().replaceFirst('Exception: ', '');
          _transactionsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchLiveMarketData() async {
    try {
      final list = await CryptoService.fetchMarketsOnce();
      final symbol = widget.wallet.currency.symbol.toUpperCase();
      final match = list.where((c) => c.symbol.toUpperCase() == symbol).firstOrNull;
      if (match != null && mounted) {
        setState(() => _liveMarketData = match);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.wallet.currency.symbol.toUpperCase(),
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 10),
                _buildBalanceSection(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 32),
                _buildSegmentedControl(),
                const SizedBox(height: 24),
                if (_showHistory) ..._buildHistorySection() else ..._buildInfoSection(),
              ],
            ),
          ),
          _buildGoToMarketButton(),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    final balance = double.tryParse(widget.wallet.balance) ?? 0.0;
    final balanceUsd = widget.wallet.balanceUsd.toDouble();
    final symbol = widget.wallet.currency.symbol.toUpperCase();
    final imageUrl = widget.wallet.currency.fullImageUrl;

    return Column(
      children: [
        // Token icon
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
          child: ClipOval(
            child: imageUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE4B53E)),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.token, color: Color(0xFFD4A347), size: 32),
                  )
                : const Icon(Icons.currency_bitcoin, color: Color(0xFFD4A347), size: 32),
          ),
        ),
        const SizedBox(height: 16),
        // Token balance
        Text(
          '${balance.toStringAsFixed(widget.wallet.currency.decimalPlaces)} $symbol',
          style: AppTheme.inter(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        // USD value
        Text(
          '\$${balanceUsd.toStringAsFixed(2)}',
          style: AppTheme.inter(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          'assets/icons/deposit.png',
          'Deposit',
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => const DepositSelectCoinScreen(),
              ),
            );
          },
        ),

        const SizedBox(width: 24),

        _buildActionButton(
          'assets/icons/withdraw.png',
          'Withdraw',
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => WithdrawSelectCoinScreen(
                  preselected: widget.wallet,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 24),

        // Buy — coming soon, no routing
        _buildActionButton(
          'assets/icons/buy.png',
          'Buy',
          comingSoon: true,
        ),

        const SizedBox(width: 24),

        // Swap — coming soon, no routing
        _buildActionButton(
          'assets/icons/swap.png',
          'Swap',
          comingSoon: true,
        ),
      ],
    );
  }

  Widget _buildActionButton(String iconPath, String label, {VoidCallback? onTap, bool comingSoon = false}) {
    return GestureDetector(
      onTap: comingSoon ? () => showComingSoon(context) : onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(iconPath, width: 65, height: 65),
              if (comingSoon)
                Positioned(
                  top: -2,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          Text(label, style: AppTheme.inter(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  

  Widget _buildSegmentedControl() {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Row(
        children: [
          _buildSegmentTab('History', _showHistory, () => setState(() => _showHistory = true)),
          _buildSegmentTab('Info', !_showHistory, () => setState(() => _showHistory = false)),
        ],
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
            borderRadius: BorderRadius.circular(30),
            gradient: isActive
                ? const LinearGradient(colors: [Color(0xFFE4B53E), Color(0xFFB88A2D)])
                : null,
          ),
          child: Text(
            label,
            style: AppTheme.inter(
              color: isActive ? Colors.black : Colors.white.withOpacity(0.5),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHistorySection() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'History',
              style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            if (_transactionsLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE4B53E)),
              )
            else if (_transactions.isNotEmpty)
              GestureDetector(
                onTap: _fetchTransactions,
                child: Icon(Icons.refresh, color: Colors.white.withOpacity(0.4), size: 18),
              ),
          ],
        ),
      ),
      if (_transactionsLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFE4B53E)),
          ),
        )
      else if (_transactionsError != null)
        _buildErrorState()
      else if (_transactions.isEmpty)
        _buildEmptyHistoryState()
      else
        ..._transactions.map(_buildTransactionItem),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.white.withOpacity(0.3), size: 36),
          const SizedBox(height: 12),
          Text(
            _transactionsError ?? 'Failed to load transactions',
            textAlign: TextAlign.center,
            style: AppTheme.inter(fontSize: 13, color: Colors.white.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _fetchTransactions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE4B53E).withOpacity(0.4)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Retry',
                style: AppTheme.inter(fontSize: 13, color: const Color(0xFFE4B53E)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    // `action` = "deposit" / "withdrawal" — the display label
    // `type`   = "credit" / "debit"       — determines +/- direction
    final action = (tx['action'] ?? tx['type'] ?? '').toString().toLowerCase();
    final creditDebit = (tx['type'] ?? '').toString().toLowerCase();
    final isCredit = creditDebit == 'credit' ||
        action == 'deposit' ||
        action == 'credit' ||
        action == 'receive';
    final amount = tx['amount']?.toString() ?? '0';
    final usd = tx['usd'] != null ? double.tryParse(tx['usd'].toString()) : null;
    final status = (tx['status'] ?? '').toString().toLowerCase();
    final description = (tx['description'] ?? '').toString();
    final symbol = widget.wallet.currency.symbol.toUpperCase();
    final date = tx['created_at'] ?? tx['date'] ?? '';

    // Format amount — trim trailing zeros
    String displayAmount = amount;
    final parsed = double.tryParse(amount);
    if (parsed != null) {
      displayAmount = parsed.toStringAsFixed(widget.wallet.currency.decimalPlaces);
    }

    String formattedDate = '';
    if (date.toString().isNotEmpty) {
      try {
        final dt = DateTime.parse(date.toString()).toLocal();
        formattedDate =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        formattedDate = date.toString();
      }
    }

    Color statusColor;
    switch (status) {
      case 'completed':
      case 'success':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'pending':
        statusColor = const Color(0xFFE4B53E);
        break;
      case 'failed':
      case 'cancelled':
        statusColor = const Color(0xFFEF5350);
        break;
      default:
        statusColor = Colors.white54;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // Direction icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? const Color(0xFF4CAF50) : const Color(0xFFEF5350)).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Action label + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(action.isNotEmpty ? action : 'Transaction'),
                  style: AppTheme.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.inter(fontSize: 11, color: Colors.white.withOpacity(0.35)),
                  ),
                ],
                if (formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: AppTheme.inter(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount + USD + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}$displayAmount $symbol',
                style: AppTheme.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isCredit ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                ),
              ),
              if (usd != null) ...[
                const SizedBox(height: 2),
                Text(
                  '\$${usd.toStringAsFixed(2)}',
                  style: AppTheme.inter(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                ),
              ],
              if (status.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  _capitalize(status),
                  style: AppTheme.inter(fontSize: 11, color: statusColor),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _buildEmptyHistoryState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No transactions',
          style: AppTheme.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInfoSection() {
    final name = widget.wallet.currency.name;
    final symbol = widget.wallet.currency.symbol.toUpperCase();

    final mktCap = _liveMarketData != null && _liveMarketData!.marketCap > 0 
        ? _liveMarketData!.formattedMarketCap : '\$250M';
    final circ = _liveMarketData != null && _liveMarketData!.circulatingSupply > 0 
        ? _liveMarketData!.formattedCirculatingSupply : '\$10M';
    final max = _liveMarketData != null && _liveMarketData!.maxSupply > 0 
        ? _liveMarketData!.formattedMaxSupply : '5M';

    return [
      const SizedBox(height: 16),
      _buildInfoRow('Market Cap', mktCap),
      _buildInfoRow('Circulating Supply', circ),
      _buildInfoRow('Max Supply', max),
      _buildInfoRow('Total Supply', '9M'),
      _buildInfoRow('All Time High', '\$40'),
      _buildInfoRow('All Time Low', '\$4'),
      const SizedBox(height: 4),
      Center(
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFE4B53E),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
          onPressed: () {},
          child: Text(
            'View More',
            style: AppTheme.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE4B53E),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'About ${symbol == 'BTC' ? 'Bitcoin' : name}',
        style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
      ),
      const SizedBox(height: 12),
      Text(
        'Bitcoin is a decentralized digital currency, without a central bank or single administrator, that can be sent from user to user on the peer-to-peer bitcoin network without the need for intermediaries.',
        style: AppTheme.inter(color: Colors.white.withOpacity(0.3), fontSize: 13, height: 1.5),
      ),
      const SizedBox(height: 100),
    ];
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.inter(color: Colors.white70, fontSize: 13)),
          Text(value, style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGoToMarketButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A347),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _goToMarket,
          child: Text('Go to market', style: AppTheme.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ),
    );
  }

  void _goToMarket() {
    // Use live data if already fetched, otherwise build a minimal asset from wallet info
    final asset = _liveMarketData ?? CryptoAsset(
      symbol: widget.wallet.currency.symbol,
      name: widget.wallet.currency.name,
      price: widget.wallet.balanceUsd.toDouble(),
      priceChangePercent: 0.0,
      sparklineData: const [0.0, 0.0, 0.0],
      imagePath: widget.wallet.currency.fullImageUrl,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MarketAssetScreen(asset: asset)),
    );
  }
}