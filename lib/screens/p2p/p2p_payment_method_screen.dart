import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_dialog.dart';
import 'p2p_add_payment_method_screen.dart';

class P2PPaymentMethodScreen extends StatefulWidget {
  const P2PPaymentMethodScreen({super.key});

  @override
  State<P2PPaymentMethodScreen> createState() => _P2PPaymentMethodScreenState();
}

class _P2PPaymentMethodScreenState extends State<P2PPaymentMethodScreen> {
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  // Track which account is selected (by index)
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await ApiService.getBankAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoading = false;
          if (_accounts.isNotEmpty) _selectedIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomDialog.showError(
          context,
          title: 'Error',
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const P2PAddPaymentMethodScreen()),
    );
    // If a new account was saved, refresh the list
    if (result == true) {
      _loadAccounts();
    }
  }

  String _maskAccountNumber(String number) {
    if (number.length <= 4) return number;
    return '•••• ${number.substring(number.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
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
          'Payment Method',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE4B53E), strokeWidth: 2))
          : RefreshIndicator(
              color: const Color(0xFFE4B53E),
              backgroundColor: const Color(0xFF1A1A1E),
              onRefresh: _loadAccounts,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Saved accounts
                  ..._accounts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final account = entry.value;
                    final bankName = account['bank_name']?.toString() ??
                        account['bank']?['name']?.toString() ??
                        'Bank Transfer';
                    final accountNumber = account['account_number']?.toString() ?? '';
                    final accountName = account['account_name']?.toString() ?? '';
                    final isSelected = _selectedIndex == index;

                    // Accent colour per card
                    final accentColors = [
                      Colors.greenAccent,
                      Colors.purpleAccent,
                      const Color(0xFFE4B53E),
                      Colors.blueAccent,
                      Colors.redAccent,
                    ];
                    final accent = accentColors[index % accentColors.length];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF151515),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: const Color(0xFFE4B53E).withOpacity(0.4))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bankName,
                                      style: AppTheme.inter(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      accountName.isNotEmpty
                                          ? '$accountName  ${_maskAccountNumber(accountNumber)}'
                                          : _maskAccountNumber(accountNumber),
                                      style: AppTheme.inter(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              // Checkbox
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFE4B53E)
                                        : Colors.white24,
                                    width: 1.5,
                                  ),
                                  color: isSelected
                                      ? const Color(0xFFE4B53E)
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.black, size: 14)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Add New button
                  GestureDetector(
                    onTap: _navigateToAdd,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline, color: Color(0xFFE4B53E), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Add New',
                          style: AppTheme.inter(
                            color: const Color(0xFFE4B53E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
