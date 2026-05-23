import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/wallet.dart';
import '../../services/data_store.dart';
import '../../theme/app_theme.dart';
import 'withdraw_form_screen.dart';

class WithdrawSelectCoinScreen extends StatefulWidget {
  /// If provided, this wallet is highlighted / pre-selected.
  final Wallet? preselected;

  const WithdrawSelectCoinScreen({super.key, this.preselected});

  @override
  State<WithdrawSelectCoinScreen> createState() =>
      _WithdrawSelectCoinScreenState();
}

class _WithdrawSelectCoinScreenState extends State<WithdrawSelectCoinScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<Wallet> get _allWallets =>
      (DataStore.instance.dashboard.value?.wallets ?? [])
          .where((w) => w.currency.symbol.toUpperCase() != 'NGN')
          .toList();

  List<Wallet> get _filtered {
    if (_query.isEmpty) return _allWallets;
    final q = _query.toLowerCase();
    return _allWallets
        .where((w) =>
            w.currency.symbol.toLowerCase().contains(q) ||
            w.currency.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCoinTap(Wallet wallet) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WithdrawTypeSheet(wallet: wallet),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Coin',
          style: AppTheme.inter(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF161618),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.3), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTheme.inter(
                          color: Colors.white, fontSize: 14),
                      cursorColor: const Color(0xFFE4B53E),
                      decoration: InputDecoration(
                        hintText: 'Search coin name or ticker',
                        hintStyle: AppTheme.inter(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: Icon(Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 18),
                    ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: wallets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            color: Colors.white.withValues(alpha: 0.15),
                            size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No coins found',
                          style: AppTheme.inter(
                              color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: wallets.length,
                    itemBuilder: (context, i) =>
                        _CoinTile(
                          wallet: wallets[i],
                          isPreselected:
                              wallets[i].id == widget.preselected?.id,
                          onTap: () => _onCoinTap(wallets[i]),
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Coin list tile ────────────────────────────────────────────────────────────
class _CoinTile extends StatelessWidget {
  final Wallet wallet;
  final bool isPreselected;
  final VoidCallback onTap;

  const _CoinTile({
    required this.wallet,
    required this.isPreselected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = wallet.currency.fullImageUrl;
    final symbol = wallet.currency.symbol.toUpperCase();

    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFFE4B53E).withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.03),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: 44,
              height: 44,
              child: ClipOval(
                child: imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(
                          color: Colors.white.withValues(alpha: 0.05),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE4B53E)),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                            Icons.token,
                            color: Colors.white24,
                            size: 28),
                      )
                    : const Icon(Icons.token,
                        color: Colors.white24, size: 28),
              ),
            ),
            const SizedBox(width: 14),

            // Name + symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    wallet.currency.name,
                    style: AppTheme.inter(
                        color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Balance + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  wallet.balance,
                  style: AppTheme.inter(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  symbol,
                  style: AppTheme.inter(
                      color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Withdrawal type bottom sheet ──────────────────────────────────────────────
class _WithdrawTypeSheet extends StatelessWidget {
  final Wallet wallet;
  const _WithdrawTypeSheet({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF111113),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: ClipOval(
                    child: wallet.currency.fullImageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: wallet.currency.fullImageUrl,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.token,
                                color: Colors.white24,
                                size: 22),
                          )
                        : const Icon(Icons.token,
                            color: Colors.white24, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Withdraw ${wallet.currency.symbol.toUpperCase()}',
                  style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select withdrawal method',
              style: AppTheme.inter(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // On-chain option
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WithdrawFormScreen(wallet: wallet),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4B53E)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.link_rounded,
                          color: Color(0xFFE4B53E), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'On-chain Withdrawal',
                            style: AppTheme.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Send to any external wallet address',
                            style: AppTheme.inter(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Color(0xFFE4B53E), size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Coming soon — internal transfer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141416),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.swap_horiz_rounded,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Internal Transfer',
                          style: AppTheme.inter(
                              color: Colors.white38,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transfer between Danjones accounts',
                          style: AppTheme.inter(
                              color: Colors.white24, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Soon',
                      style: AppTheme.inter(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
