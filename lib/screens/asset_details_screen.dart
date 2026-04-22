import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';
import '../widgets/sparkline_chart.dart';
import '../services/crypto_service.dart';
import '../models/crypto_asset.dart';
import 'deposit_screen.dart';
import 'main_shell.dart';

class AssetDetailsScreen extends StatefulWidget {
  final Wallet wallet;

  const AssetDetailsScreen({super.key, required this.wallet});

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  bool _showHistory = true;
  CryptoAsset? _liveMarketData;

  @override
  void initState() {
    super.initState();
    _fetchLiveMarketData();
  }

  Future<void> _fetchLiveMarketData() async {
    try {
      final list = await CryptoService.fetchDashboardCurrencies();
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
        _buildActionButton('assets/icons/deposit.png', 'Deposit', onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (context) => const DepositScreen()),
          );
        }),
        const SizedBox(width: 24),
        _buildActionButton('assets/icons/buy.png', 'Buy'),
        const SizedBox(width: 24),
        _buildActionButton('assets/icons/swap.png', 'Swap', onTap: () {
          Navigator.of(context, rootNavigator: true).pop();
          mainShellKey.currentState?.setTab(2);
        }),
      ],
    );
  }

  Widget _buildActionButton(String iconPath, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(iconPath, width: 65, height: 65),
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
        child: Text(
          'History',
          style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      ...List.generate(3, (index) => _buildHistoryItem()),
    ];
  }

  Widget _buildHistoryItem() {
    final symbol = widget.wallet.currency.symbol.toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('From: 0x6f...a98', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
              Text('07 Oct 2021 at 02:32 AM', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receive', style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
              Text('0.0636 $symbol', style: AppTheme.inter(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check, color: Colors.white54, size: 14),
                  const SizedBox(width: 4),
                  Text('Confirmed', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                ],
              ),
              Text('~ \$107.17', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
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
          onPressed: () => Navigator.pushNamed(context, '/market'),
          child: Text('Go to market', style: AppTheme.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ),
    );
  }
}