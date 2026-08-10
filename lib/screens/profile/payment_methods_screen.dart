import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late Future<List<Map<String, dynamic>>> _accountsFuture;
  Map<int, bool> _deletingAccounts = {}; // Track which account is being deleted

  @override
  void initState() {
    super.initState();
    _accountsFuture = ApiService.getBankAccounts();
  }

  void _refresh() => setState(() {
        _accountsFuture = ApiService.getBankAccounts();
      });

  void _openAddAccount() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const _AddBankAccountSheet()),
    );
    if (added == true) _refresh();
  }

  Future<void> _deleteAccount(Map<String, dynamic> account) async {
    final accountId = (account['id'] as num?)?.toInt();
    if (accountId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1C1D21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Delete Bank Account?',
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone. You won\'t be able to receive payments to this account.',
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE4B53E).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: AppTheme.inter(
                            color: const Color(0xFFE4B53E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.redAccent,
                        ),
                        child: Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: AppTheme.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;

    if (!confirmed) return;

    setState(() => _deletingAccounts[accountId] = true);

    try {
      await ApiService.deleteBankAccount(bankAccountId: accountId);
      if (mounted) {
        _refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFE4B53E), size: 20),
                const SizedBox(width: 10),
                Text(
                  'Bank account deleted',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E1E1E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color(0xFFE4B53E).withOpacity(0.3),
              ),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deletingAccounts[accountId] = false);
    }
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
                if (accounts.isEmpty)
                  _buildEmpty()
                else
                  ...accounts.map((account) => _buildAccountCard(account)),

                const SizedBox(height: 8),
                // Add new account button
                GestureDetector(
                  onTap: _openAddAccount,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFE4B53E).withOpacity(0.12),
                          const Color(0xFFE4B53E).withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFE4B53E).withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4B53E).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFFE4B53E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add New Bank Account',
                          style: AppTheme.inter(
                            color: const Color(0xFFE4B53E),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
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
    final accountId = (account['id'] as num?)?.toInt() ?? 0;
    final isDeleting = _deletingAccounts[accountId] ?? false;

    const accentColors = [
      Color(0xFF33D17A),
      Color(0xFF8B5CF6),
      Color(0xFFE4B53E),
      Color(0xFF60A5FA),
      Color(0xFFFF6B6B),
    ];
    final accent =
        accentColors[bankName.hashCode.abs() % accentColors.length];

    final masked = accountNumber.length > 4
        ? '•••• ${accountNumber.substring(accountNumber.length - 4)}'
        : accountNumber;

    return AnimatedOpacity(
      opacity: isDeleting ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            // Coloured left bar
            Container(
              width: 3,
              height: 44,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 14),
            // Bank info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
                    style: AppTheme.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accountName,
                    style: AppTheme.inter(
                        fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Account number badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Text(
                masked,
                style: AppTheme.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent),
              ),
            ),
            const SizedBox(width: 10),
            // Delete button
            GestureDetector(
              onTap: isDeleting ? null : () => _deleteAccount(account),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: isDeleting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.redAccent.withValues(alpha: 0.6)),
                        ),
                      )
                    : const Icon(Icons.delete_outline_rounded,
                        color: Colors.white38, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE4B53E).withOpacity(0.1),
            ),
            child: const Icon(
              Icons.account_balance_outlined,
              color: Color(0xFFE4B53E),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Bank Accounts Yet',
            style: AppTheme.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a bank account to start receiving payments from P2P trades.',
            textAlign: TextAlign.center,
            style: AppTheme.inter(
              color: Colors.white54,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Could Not Load Accounts',
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                color: Colors.white54,
                fontSize: 12,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _refresh,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE4B53E).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: AppTheme.inter(
                    color: const Color(0xFFE4B53E),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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

  void _openBankPicker() {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(_banks);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFF141416),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Select a bank',
                      style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Search',
                      style: AppTheme.inter(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: AppTheme.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search banks',
                          hintStyle: AppTheme.inter(color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                        ),
                        onChanged: (val) {
                          setSheetState(() {
                            filtered = _banks
                                .where((b) => (b['name'] as String)
                                    .toLowerCase()
                                    .contains(val.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final bank = filtered[index];
                        final name = bank['name'] as String? ?? '';
                        final accentColors = [
                          Colors.purpleAccent,
                          const Color(0xFFE4B53E),
                          const Color(0xFFE4B53E),
                          Colors.blueAccent,
                          Colors.redAccent,
                        ];
                        final accent = accentColors[index % accentColors.length];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Alphabet header when first letter changes
                            if (index == 0 ||
                                name[0].toUpperCase() !=
                                    (filtered[index - 1]['name'] as String)[0].toUpperCase())
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 4),
                                child: Text(
                                  name[0].toUpperCase(),
                                  style: AppTheme.inter(
                                    color: Colors.white54,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _selectedBank = bank;
                                  _verifiedAccountName = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: AppTheme.inter(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(color: Colors.white10, height: 1),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _verify() async {
    if (_selectedBank == null || _accountNumberCtrl.text.length < 10) return;
    setState(() { _isVerifying = true; _verifiedAccountName = null; });
    try {
      final bankId = (_selectedBank!['id'] as num?)?.toInt();
      if (bankId == null) {
        throw Exception('Selected bank is missing ID. Please choose another bank.');
      }
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
                  GestureDetector(
                    onTap: _openBankPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1D21),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedBank != null
                                ? _selectedBank!['name']?.toString() ?? 'Choose your bank'
                                : 'Choose your bank',
                            style: AppTheme.inter(
                                color: _selectedBank != null ? Colors.white : Colors.white38,
                                fontSize: 14),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white38),
                        ],
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
                        color: const Color(0xFFE4B53E).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE4B53E).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFFE4B53E), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Account Verified',
                                    style: AppTheme.inter(
                                        color: const Color(0xFFE4B53E),
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
