import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late Future<List<Map<String, dynamic>>> _accountsFuture;

  @override
  void initState() {
    super.initState();
    _accountsFuture = ApiService.getBankAccounts();
  }

  void _refresh() =>
      setState(() => _accountsFuture = ApiService.getBankAccounts());

  void _openAddAccount() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const _AddBankAccountSheet()),
    );
    if (added == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Methods',
          style: AppTheme.inter(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFE4B53E), strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final accounts = snapshot.data ?? [];

          return RefreshIndicator(
            color: const Color(0xFFE4B53E),
            backgroundColor: const Color(0xFF1C1D21),
            onRefresh: () async => _refresh(),
            child: ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // Header info box
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1B1F), Color(0xFF111214)],
                    ),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE4B53E).withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_rounded,
                            color: Color(0xFFE4B53E), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${accounts.length} bank account${accounts.length == 1 ? '' : 's'} saved',
                              style: AppTheme.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'These accounts are used to receive NGN payments on P2P trades.',
                              style: AppTheme.inter(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (accounts.isEmpty)
                  _buildEmpty()
                else
                  ...accounts.map((account) => _buildAccountCard(account)),

                const SizedBox(height: 8),
                // Add new account button
                GestureDetector(
                  onTap: _openAddAccount,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFE4B53E).withOpacity(0.4),
                          width: 1.2),
                      color: const Color(0xFFE4B53E).withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: Color(0xFFE4B53E), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Add Bank Account',
                          style: AppTheme.inter(
                              color: const Color(0xFFE4B53E),
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final bankName = account['bank']?['name']?.toString() ??
        account['bank_name']?.toString() ??
        'Unknown Bank';
    final accountName = account['account_name']?.toString() ?? '';
    final accountNumber = account['account_number']?.toString() ?? '';
    final initials = bankName.isNotEmpty
        ? bankName.substring(0, bankName.length >= 2 ? 2 : 1).toUpperCase()
        : 'BK';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16171A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE4B53E).withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTheme.inter(
                  color: const Color(0xFFE4B53E),
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  accountName,
                  style: AppTheme.inter(
                      color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  accountNumber,
                  style: AppTheme.inter(
                      color: const Color(0xFFE4B53E),
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded,
              color: Color(0xFF33D17A), size: 20),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.account_balance_outlined,
              color: Colors.white24, size: 60),
          const SizedBox(height: 12),
          Text(
            'No bank accounts yet',
            style: AppTheme.inter(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Add a bank account to receive NGN payments from P2P trades.',
            textAlign: TextAlign.center,
            style: AppTheme.inter(
                color: Colors.white38, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white24, size: 56),
            const SizedBox(height: 12),
            Text(
              'Could not load payment methods',
              style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style:
                  AppTheme.inter(color: Colors.white38, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4B53E),
                foregroundColor: Colors.black,
              ),
              child:
                  Text('Retry', style: AppTheme.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Add Bank Account flow (full screen)
// ─────────────────────────────────────────────────────────────

class _AddBankAccountSheet extends StatefulWidget {
  const _AddBankAccountSheet();

  @override
  State<_AddBankAccountSheet> createState() => _AddBankAccountSheetState();
}

class _AddBankAccountSheetState extends State<_AddBankAccountSheet> {
  List<Map<String, dynamic>> _banks = [];
  Map<String, dynamic>? _selectedBank;
  final _accountNumberCtrl = TextEditingController();

  String? _verifiedAccountName;
  bool _isLoadingBanks = true;
  bool _isVerifying = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await ApiService.getBankList();
      if (mounted) setState(() { _banks = banks; _isLoadingBanks = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoadingBanks = false);
    }
  }

  Future<void> _verify() async {
    if (_selectedBank == null || _accountNumberCtrl.text.length < 10) return;
    setState(() { _isVerifying = true; _verifiedAccountName = null; });
    try {
      final bankId = (_selectedBank!['id'] as num).toInt();
      final res = await ApiService.verifyBankAccount(
        bankId: bankId,
        accountNumber: _accountNumberCtrl.text.trim(),
      );
      final name = res['account_name']?.toString() ??
          res['data']?['account_name']?.toString() ?? '';
      if (mounted) setState(() => _verifiedAccountName = name);
    } catch (e) {
      if (!mounted) return;
      _showStatusModal(
        title: 'Verification Failed',
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _save() async {
    if (_selectedBank == null || _verifiedAccountName == null) return;
    setState(() => _isSaving = true);
    try {
      final bankId = (_selectedBank!['id'] as num).toInt();
      await ApiService.storeBankAccount(
        bankId: bankId,
        accountName: _verifiedAccountName!,
        accountNumber: _accountNumberCtrl.text.trim(),
      );
      if (!mounted) return;
      await _showStatusModal(
        title: 'Account Added',
        message: 'Your bank account has been saved successfully.',
        icon: Icons.check_circle_rounded,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showStatusModal(
        title: 'Save Failed',
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showStatusModal({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Padding(
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
                child: Icon(icon, color: const Color(0xFFE4B53E), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: AppTheme.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(message,
                        style: AppTheme.inter(
                            color: Colors.white54, fontSize: 12)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canVerify = _selectedBank != null &&
        _accountNumberCtrl.text.length >= 10 &&
        !_isVerifying;
    final canSave = _verifiedAccountName != null && !_isSaving;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Bank Account',
            style: AppTheme.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoadingBanks
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFE4B53E), strokeWidth: 2))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Bank',
                      style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1D21),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1C1D21),
                        value: _selectedBank,
                        hint: Text('Choose your bank',
                            style: AppTheme.inter(
                                color: Colors.white38, fontSize: 14)),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white38),
                        items: _banks
                            .map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(
                                    b['name']?.toString() ?? '',
                                    style: AppTheme.inter(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() {
                          _selectedBank = val;
                          _verifiedAccountName = null;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Account Number',
                      style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _accountNumberCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    style: AppTheme.inter(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '0000000000',
                      hintStyle:
                          AppTheme.inter(color: Colors.white30, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF1C1D21),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE4B53E))),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    onChanged: (_) =>
                        setState(() => _verifiedAccountName = null),
                  ),
                  const SizedBox(height: 20),
                  if (_verifiedAccountName != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF33D17A).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF33D17A).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF33D17A), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Account Verified',
                                    style: AppTheme.inter(
                                        color: const Color(0xFF33D17A),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(_verifiedAccountName!,
                                    style: AppTheme.inter(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_verifiedAccountName == null)
                    _buildButton(
                      label: _isVerifying ? 'Verifying...' : 'Verify Account',
                      onPressed: canVerify ? _verify : null,
                      isLoading: _isVerifying,
                    )
                  else
                    _buildButton(
                      label: _isSaving ? 'Saving...' : 'Save Account',
                      onPressed: canSave ? _save : null,
                      isLoading: _isSaving,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildButton({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: onPressed != null
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
                )
              : null,
          color: onPressed == null
              ? const Color(0xFF2A2A2A)
              : null,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : Text(label,
                  style: AppTheme.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: onPressed != null ? Colors.black : Colors.white38)),
        ),
      ),
    );
  }
}
