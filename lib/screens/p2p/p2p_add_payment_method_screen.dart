import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_dialog.dart';

class P2PAddPaymentMethodScreen extends StatefulWidget {
  const P2PAddPaymentMethodScreen({super.key});

  @override
  State<P2PAddPaymentMethodScreen> createState() => _P2PAddPaymentMethodScreenState();
}

class _P2PAddPaymentMethodScreenState extends State<P2PAddPaymentMethodScreen> {
  final TextEditingController _accountNumberController = TextEditingController();

  // Bank list state
  List<Map<String, dynamic>> _banks = [];
  bool _isLoadingBanks = true;

  // Selected bank
  Map<String, dynamic>? _selectedBank;

  // Verification state
  bool _isVerifying = false;
  bool _isVerified = false;
  String _verifiedAccountName = '';

  // Save state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await ApiService.getBankList();
      if (mounted) {
        setState(() {
          _banks = banks;
          _isLoadingBanks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBanks = false);
        CustomDialog.showError(
          context,
          title: 'Error',
          message: 'Could not load banks. Please try again.',
        );
      }
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
                      'Select a payment method',
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
                          hintText: 'Please enter a payment method',
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
                        // Accent colour cycles through a few colours like in the mockup
                        final accentColors = [
                          Colors.purpleAccent,
                          const Color(0xFFE4B53E),
                          Colors.greenAccent,
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
                                  // Reset verification whenever bank changes
                                  _isVerified = false;
                                  _verifiedAccountName = '';
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

  Future<void> _handleVerify() async {
    final accountNumber = _accountNumberController.text.trim();
    if (_selectedBank == null) {
      CustomDialog.showError(context, title: 'Missing Bank', message: 'Please select a bank first.');
      return;
    }
    if (accountNumber.length < 10) {
      CustomDialog.showError(context, title: 'Invalid Account', message: 'Please enter a valid 10-digit account number.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await ApiService.verifyBankAccount(
        bankId: _selectedBank!['id'] as int,
        accountNumber: accountNumber,
      );
      if (!mounted) return;
      // The API returns the account name in various keys — handle both
      final accountName = (result['account_name'] ??
              result['data']?['account_name'] ??
              result['name'] ??
              '')
          .toString();

      if (accountName.isEmpty) {
        throw Exception('Account not found. Please check the number and try again.');
      }

      setState(() {
        _isVerified = true;
        _verifiedAccountName = accountName;
      });
    } catch (e) {
      if (!mounted) return;
      CustomDialog.showError(
        context,
        title: 'Verification Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      await ApiService.storeBankAccount(
        bankId: _selectedBank!['id'] as int,
        accountName: _verifiedAccountName,
        accountNumber: _accountNumberController.text.trim(),
      );
      if (!mounted) return;
      CustomDialog.showSuccess(
        context,
        title: 'Account Saved',
        message: 'Your bank account has been added successfully.',
        onButtonPressed: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(true); // pop screen with refresh signal
        },
      );
    } catch (e) {
      if (!mounted) return;
      CustomDialog.showError(
        context,
        title: 'Save Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canVerify = _selectedBank != null &&
        _accountNumberController.text.trim().length >= 10 &&
        !_isVerified;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method (fixed: Bank Transfer)
            _buildFieldLabel('Payment Method', required: true),
            const SizedBox(height: 8),
            _buildReadOnlyField('Bank Transfer'),
            const SizedBox(height: 8),
            Text(
              'Please note that cross-border transfers may be delayed; in addition, we kindly suggest you choosing an accurate bank to facilitate the transaction.',
              style: AppTheme.inter(color: Colors.white38, fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 24),

            // Name (auto-filled after verify)
            _buildFieldLabel('Name', required: true),
            const SizedBox(height: 8),
            _buildReadOnlyField(
              _isVerified ? _verifiedAccountName : '',
              hint: _isVerified ? null : 'Will be filled after verification',
            ),
            const SizedBox(height: 24),

            // Bank Name
            _buildFieldLabel('Bank Name', required: true),
            const SizedBox(height: 8),
            _buildBankSelector(),
            const SizedBox(height: 24),

            // Account Number
            _buildFieldLabel('Account Number', required: true),
            const SizedBox(height: 8),
            _buildAccountNumberInput(),

            const SizedBox(height: 40),

            // Primary action button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isVerifying || _isSaving)
                    ? null
                    : _isVerified
                        ? _handleSave
                        : (canVerify ? _handleVerify : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4B53E),
                  disabledBackgroundColor: const Color(0xFFE4B53E).withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: (_isVerifying || _isSaving)
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Text(
                        _isVerified ? 'Save Account' : 'Verify Account',
                        style: AppTheme.inter(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        children: [
          if (required)
            TextSpan(
              text: '* ',
              style: AppTheme.inter(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          TextSpan(
            text: label,
            style: AppTheme.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String value, {String? hint}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value.isNotEmpty ? value : (hint ?? ''),
        style: AppTheme.inter(
          color: value.isNotEmpty ? Colors.white : Colors.white30,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBankSelector() {
    return GestureDetector(
      onTap: _isLoadingBanks ? null : _openBankPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _isLoadingBanks
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(color: Color(0xFFE4B53E), strokeWidth: 2),
                  )
                : Text(
                    _selectedBank?['name'] as String? ?? 'Select Bank',
                    style: AppTheme.inter(
                      color: _selectedBank != null ? Colors.white : Colors.white30,
                      fontSize: 14,
                    ),
                  ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE4B53E), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountNumberInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _accountNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
        style: AppTheme.inter(color: Colors.white, fontSize: 14),
        onChanged: (_) {
          // Reset verification if account number changes
          if (_isVerified) {
            setState(() {
              _isVerified = false;
              _verifiedAccountName = '';
            });
          } else {
            setState(() {});
          }
        },
        decoration: InputDecoration(
          hintText: 'Please Enter Your Account Number',
          hintStyle: AppTheme.inter(color: Colors.white30, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
