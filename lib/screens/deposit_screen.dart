import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/data_store.dart';
import 'receive_screen.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  bool _isCryptoTab = true;
  String _searchQuery = '';
  
  // Fiat Form State
  String _selectedMethod = 'Bank Transfer';
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _txRef;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _initiateDeposit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText.replaceAll(',', ''));
    if (amount == null || amount < 1000) {
      _showError('Minimum deposit is ₦1,000');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = DataStore.instance.dashboard.value?.user;
      if (user == null) throw Exception('User data not found. Please login again.');

      final txRef = 'fund_${DateTime.now().millisecondsSinceEpoch}';
      
      final Customer customer = Customer(
        name: user.name,
        email: user.email,
        phoneNumber: user.phone ?? "0000000000",
      );

      final Flutterwave flutterwave = Flutterwave(
        publicKey: ApiService.flutterwavePublicKey,
        currency: "NGN",
        redirectUrl: 'https://api.danjones.ng',
        txRef: txRef,
        amount: amount.toString(),
        customer: customer,
        paymentOptions: "card, banktransfer, ussd",
        customization: Customization(
          title: "Wallet Deposit",
          description: "Wallet deposit for ${user.email}",
          logo: "https://api.danjones.ng/assets/images/Danjones-Logo.png",
        ),
        isTestMode: ApiService.flutterwavePublicKey.contains("TEST"),
      );

      final ChargeResponse? response = await flutterwave.charge(context);
      
      setState(() => _isLoading = false);

      if (response != null) {
        if (response.success == true) {
          _txRef = response.txRef;
          _verifyDeposit();
        } else {
          _showError(response.status ?? "Transaction failed");
        }
      } else {
        // response is null when user cancels
        _showError("Transaction cancelled");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _verifyDeposit() async {
    if (_txRef == null) return;

    setState(() => _isVerifying = true);

    try {
      final response = await ApiService.verifyFlutterwaveDeposit(reference: _txRef!);
      
      setState(() => _isVerifying = false);

      if (response['success'] == true) {
        _showSuccess(response['message'] ?? 'Deposit verified successfully!');
      } else {
        _showError(response['message'] ?? 'Verification failed');
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    _showErrorDialog(message);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Deposit Error',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTheme.inter(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Okay',
                      style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4B53E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFFE4B53E),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Success',
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4B53E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: AppTheme.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Deposit',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSegmentedControl(),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isCryptoTab ? _buildCryptoView() : _buildFiatView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        color: const Color(0xFF151515),
      ),
      child: Row(
        children: [
          _buildSegmentTab('Crypto', _isCryptoTab, () => setState(() => _isCryptoTab = true)),
          _buildSegmentTab('Fiat', !_isCryptoTab, () => setState(() => _isCryptoTab = false)),
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
            gradient: isActive ? const LinearGradient(colors: [Color(0xFFE4B53E), Color(0xFFB88A2D)]) : null,
          ),
          child: Text(
            label,
            style: AppTheme.inter(
              color: isActive ? Colors.black : Colors.white.withOpacity(0.5),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CRYPTO TAB — reads from DataStore wallets (no extra API call)
  // ==========================================
  Widget _buildCryptoView() {
    final wallets = DataStore.instance.dashboard.value?.wallets ?? [];
    final cryptoWallets = wallets
        .where((w) => w.currency.symbol.toUpperCase() != 'NGN')
        .where((w) =>
            w.currency.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            w.currency.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (wallets.isEmpty) {
      return Center(
        child: Text(
          'No wallets found',
          style: AppTheme.inter(color: Colors.white38, fontSize: 14),
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: cryptoWallets.length,
            itemBuilder: (context, index) {
              final wallet = cryptoWallets[index];
              return _buildWalletListItem(wallet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWalletListItem(Wallet wallet) {
    final imageUrl = wallet.currency.fullImageUrl;
    final symbol = wallet.currency.symbol.toUpperCase();
    final name = wallet.currency.name;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReceiveScreen(wallet: wallet)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
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
                        placeholder: (context, url) => Container(
                          color: Colors.white.withValues(alpha: 0.05),
                          child: const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFE4B53E),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.token,
                          color: Colors.white24,
                          size: 24,
                        ),
                      )
                    : const Icon(Icons.token, color: Colors.white24, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: AppTheme.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: AppTheme.inter(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 20,
            ),
          ],
        ),
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
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search Token',
                  hintStyle: AppTheme.inter(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.2),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FIAT TAB
  // ==========================================
  Widget _buildFiatView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Amount', style: AppTheme.inter(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text('₦', style: AppTheme.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '50,000',
                      hintStyle: AppTheme.inter(color: Colors.white24, fontSize: 24, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Min: ₦1,000', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
          
          const SizedBox(height: 32),
          
          if (_isLoading || _isVerifying)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFE4B53E)),
                    const SizedBox(height: 16),
                    Text(
                      _isVerifying ? 'Verifying Transaction...' : 'Preparing Payment...',
                      style: AppTheme.inter(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: _buildInitiateButton(),
            ),
          
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.security, color: Color(0xFFE4B53E), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Secure Payment',
                      style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your payment is processed securely via Flutterwave. We do not store your card details.',
                  style: AppTheme.inter(color: Colors.white54, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInitiateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _initiateDeposit,
        child: Text(
          'Proceed to Payment',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSimpleDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13)),
        Text(value, style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _isVerifying ? null : _verifyDeposit,
        child: _isVerifying
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Text(
                'I Have Made The Payment',
                style: AppTheme.inter(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
              ),
      ),
    );
  }
}