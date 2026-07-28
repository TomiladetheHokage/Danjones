import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/market/currency.dart';
import '../../models/wallet/wallet.dart';
import '../../services/api_service.dart';
import '../../services/data_store.dart';
import '../../theme/app_theme.dart';
import 'receive_screen.dart';

/// Shows ALL active crypto currencies. Tapping one creates a wallet (if needed)
/// then navigates to the deposit/receive screen.
class DepositSelectCoinScreen extends StatefulWidget {
  const DepositSelectCoinScreen({super.key});

  @override
  State<DepositSelectCoinScreen> createState() => _DepositSelectCoinScreenState();
}

class _DepositSelectCoinScreenState extends State<DepositSelectCoinScreen> {
  List<Currency> _currencies = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';

  // Track which currency is currently being processed so we can show a
  // per-row spinner without blocking the whole screen.
  int? _processingId;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final all = await ApiService.getCurrencies();
      if (!mounted) return;
      setState(() {
        // Only show active crypto currencies
        _currencies = all.where((c) => c.isCrypto && c.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Currency> get _filtered {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _currencies;
    return _currencies
        .where((c) =>
            c.symbol.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _onCurrencyTap(Currency currency) async {
    if (_processingId != null) return;
    setState(() => _processingId = currency.id);

    try {
      // Check if user already has a wallet for this currency
      final existing = DataStore.instance.dashboard.value?.wallets
          .where((w) => w.currencyId == currency.id)
          .firstOrNull;

      Wallet wallet;
      if (existing != null) {
        wallet = existing;
      } else {
        // Create wallet on the backend
        wallet = await ApiService.createWallet(currencyId: currency.id);

        // Refresh dashboard so the new wallet appears in the store
        try {
          final updated = await ApiService.getDashboardData();
          await DataStore.instance.updateDashboard(updated);
        } catch (_) {
          // Non-fatal — the receive screen will still work with the returned wallet
        }
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReceiveScreen(wallet: wallet)),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Error',
                  style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: AppTheme.inter(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text('Okay',
                      style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Coin to Deposit',
          style: AppTheme.inter(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildSearchBar(),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                cursorColor: Colors.white24,
                style: AppTheme.inter(color: Colors.white, fontSize: 14),
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search coin',
                  hintStyle: AppTheme.inter(
                      color: Colors.white.withOpacity(0.2), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Icon(Icons.search,
                color: Colors.white.withOpacity(0.2), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE4B53E)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                textAlign: TextAlign.center,
                style: AppTheme.inter(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadCurrencies();
              },
              child: Text('Retry',
                  style: AppTheme.inter(
                      color: const Color(0xFFE4B53E), fontSize: 14)),
            ),
          ],
        ),
      );
    }

    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Text('No coins found',
            style: AppTheme.inter(color: Colors.white38, fontSize: 14)),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildCurrencyRow(list[index]),
    );
  }

  Widget _buildCurrencyRow(Currency currency) {
    final imageUrl = currency.fullImageUrl;
    final isProcessing = _processingId == currency.id;

    return InkWell(
      onTap: isProcessing ? null : () => _onCurrencyTap(currency),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Coin icon
            SizedBox(
              width: 40,
              height: 40,
              child: ClipOval(
                child: imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(
                          color: Colors.white.withOpacity(0.05),
                          child: const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE4B53E)),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                            Icons.token,
                            color: Colors.white24,
                            size: 24),
                      )
                    : const Icon(Icons.token, color: Colors.white24, size: 24),
              ),
            ),
            const SizedBox(width: 14),

            // Name + symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.symbol.toUpperCase(),
                    style: AppTheme.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currency.name,
                    style:
                        AppTheme.inter(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),

            // Trailing: spinner while processing, chevron otherwise
            if (isProcessing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFE4B53E)),
              )
            else
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.2), size: 20),
          ],
        ),
      ),
    );
  }
}
