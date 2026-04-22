import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../services/data_store.dart';
import '../services/api_service.dart';
import '../models/currency.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  bool _isBuyAd = true;
  bool _isFixedPrice = true;
  bool _isChipperSelected = false;
  bool _isBankSelected = true;

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _minLimitController = TextEditingController();
  final TextEditingController _maxLimitController = TextEditingController();
  final TextEditingController _termsController = TextEditingController();
  
  bool _isLoading = false;
  
  List<Currency> _currencies = [];
  Currency? _selectedAsset;
  bool _isLoadingCurrencies = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final list = await ApiService.getCurrencies();
      if (mounted) {
        setState(() {
          _currencies = list.where((c) => c.isCrypto).toList();
          if (_currencies.isNotEmpty) {
            _selectedAsset = _currencies.first;
          }
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingCurrencies = false);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _totalAmountController.dispose();
    _minLimitController.dispose();
    _maxLimitController.dispose();
    _termsController.dispose();
    super.dispose();
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
                  'Error',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
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
                      style: GoogleFonts.outfit(
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                    color: Colors.greenAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.greenAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Success',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Great',
                      style: GoogleFonts.outfit(
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
        );
      },
    );
  }

  Future<void> _submitAd() async {
    if (_selectedAsset == null) {
      _showErrorDialog("Please select an asset.");
      return;
    }
    
    final price = double.tryParse(_priceController.text);
    final totalAmount = double.tryParse(_totalAmountController.text);
    final minLimit = double.tryParse(_minLimitController.text);
    final maxLimit = double.tryParse(_maxLimitController.text);
    final terms = _termsController.text.trim();

    if (price == null || totalAmount == null || minLimit == null || maxLimit == null) {
      _showErrorDialog("Please fill in all values with valid numbers.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.createP2pAd(
        currencyId: _selectedAsset!.id,
        type: _isBuyAd ? "buy" : "sell",
        price: price,
        totalAmount: totalAmount,
        minLimit: minLimit,
        maxLimit: maxLimit,
        terms: terms,
      );
      if (mounted) {
        _showSuccessDialog("Your advertisement has been posted successfully.");
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'Create Ad',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSegmentedControl(),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(child: Text('Asset', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
                const SizedBox(width: 16),
                Expanded(child: Text('Fiat', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildAssetSelector()),
                const SizedBox(width: 16),
                Expanded(child: _buildCurrencySelector('NGN', 'Naira', 'assets/icons/Ngn.png', circleColor: Colors.transparent)),
              ],
            ),
            
            const SizedBox(height: 32),
            Text('Price Settings', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                _buildPriceTab('Fixed Price', _isFixedPrice, () => setState(() => _isFixedPrice = true)),
                _buildPriceTab('Floating Price', !_isFixedPrice, () => setState(() => _isFixedPrice = false)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Price (NGN)', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12)),
            const SizedBox(height: 8),
            _buildPriceInput(),
            const SizedBox(height: 8),
            Text('Highest Order Price: ₦--', style: AppTheme.inter(color: Colors.white60, fontSize: 11)),
            
            const SizedBox(height: 32),
            Text('Amount & Limits', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text('Total Amount', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12)),
            const SizedBox(height: 8),
            _buildAmountInput(),
            const SizedBox(height: 8),
            Text('Available Balance: N/A', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Min Limit (NGN)', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      _buildLimitInput(_minLimitController, 'e.g. 5,000'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max Limit (NGN)', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      _buildLimitInput(_maxLimitController, 'e.g. 50,000'),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Methods', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: Color(0xFFE4B53E), size: 16),
                    const SizedBox(width: 4),
                    Text('Add New', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard('Chipper Cash', '@MerchantUser', Colors.greenAccent, _isChipperSelected, (val) => setState(() => _isChipperSelected = val!)),
            const SizedBox(height: 12),
            _buildPaymentMethodCard('Bank Transfer', 'Kuda Bank •••• 8829', Colors.purpleAccent, _isBankSelected, (val) => setState(() => _isBankSelected = val!)),
            
            const SizedBox(height: 32),
            Text('Terms & Conditions (Optional)', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _termsController,
                maxLines: null,
                style: AppTheme.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration.collapsed(
                  hintText: 'Write your terms here. e.g No third-party\npayments allowed',
                  hintStyle: AppTheme.inter(color: Colors.white30, fontSize: 14),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE4B53E), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For your safety, do not share personal contact info (WhatsApp, Telegram) in the terms.',
                      style: AppTheme.inter(color: Colors.white54, fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimated Total', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
                Text('Fee', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₦ 0.00', style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('0.00 BTC', style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildPostAdButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBuyAd = true),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: _isBuyAd ? const LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)]) : null,
                  color: _isBuyAd ? null : Colors.transparent,
                ),
                child: Text(
                  'I Want to Buy',
                  style: AppTheme.inter(
                    color: _isBuyAd ? Colors.black : Colors.white54,
                    fontSize: 13,
                    fontWeight: _isBuyAd ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBuyAd = false),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: !_isBuyAd ? const LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)]) : null,
                  color: !_isBuyAd ? null : Colors.transparent,
                ),
                child: Text(
                  'I Want to Sell',
                  style: AppTheme.inter(
                    color: !_isBuyAd ? Colors.black : Colors.white54,
                    fontSize: 13,
                    fontWeight: !_isBuyAd ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(String symbol, String name, String? iconPath, {Color? circleColor, IconData? circleIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: circleColor ?? const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: iconPath != null 
                    ? Image.asset(iconPath, width: 32, height: 32)
                    : Icon(circleIcon, size: 20, color: const Color(0xFFE4B53E)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(name, style: AppTheme.inter(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ],
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE4B53E), size: 18),
        ],
      ),
    );
  }

  Widget _buildPriceTab(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              title,
              style: AppTheme.inter(
                color: isSelected ? const Color(0xFFE4B53E) : Colors.white54,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 2,
              color: isSelected ? const Color(0xFFE4B53E) : Colors.white10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAdjuster(String value) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          Row(
            children: [
              _buildIconButton(Icons.remove),
              const SizedBox(width: 8),
              _buildIconButton(Icons.add),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4B53E)),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: const Color(0xFFE4B53E), size: 18),
    );
  }

  Widget _buildInputWithSuffix(String hint, String suffix, {bool isMaxGolden = false}) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: AppTheme.inter(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w500)),
          if (isMaxGolden)
            RichText(
              text: TextSpan(
                text: 'BTC | ',
                style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                children: [
                  TextSpan(text: 'MAX', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold)),
                ]
              )
            )
          else
            Text(suffix, style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInputBox(String hint) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(hint, style: AppTheme.inter(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildPaymentMethodCard(String title, String subtitle, Color lineCol, bool isSelected, ValueChanged<bool?> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 3, height: 24, decoration: BoxDecoration(color: lineCol, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTheme.inter(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          Theme(
            data: ThemeData(
               unselectedWidgetColor: Colors.white24,
            ),
            child: Checkbox(
              value: isSelected,
              activeColor: const Color(0xFFE4B53E),
              checkColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: onChanged,
            ),
          )
        ],
      ),
    );
  }

  // --------- New Dynamic Builders --------- //

  Widget _buildAssetSelector() {
    if (_isLoadingCurrencies) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: const SizedBox(
           width: 20, height: 20,
           child: CircularProgressIndicator(color: Color(0xFFE4B53E), strokeWidth: 2),
        ),
      );
    }
    if (_currencies.isEmpty) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: Text('No Assets', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
      );
    }
    
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: _selectedAsset,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE4B53E), size: 18),
          isExpanded: true,
          items: _currencies.map((c) {
            return DropdownMenuItem<Currency>(
              value: c,
              child: Row(
                children: [
                   Container(
                     width: 24,
                     height: 24,
                     clipBehavior: Clip.antiAlias,
                     decoration: const BoxDecoration(shape: BoxShape.circle),
                     child: CachedNetworkImage(
                       imageUrl: c.fullImageUrl,
                       fit: BoxFit.cover,
                       placeholder: (context, url) => const Icon(Icons.blur_circular, size: 16, color: Colors.white24),
                       errorWidget: (context, url, error) => const Icon(Icons.currency_bitcoin, size: 16, color: Color(0xFFE4B53E)),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Text(c.symbol.toUpperCase(), style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() { _selectedAsset = val; });
          },
        ),
      ),
    );
  }

  Widget _buildPriceInput() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextFormField(
        controller: _priceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Enter fixed NGN price',
          hintStyle: AppTheme.inter(color: Colors.white30, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _totalAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Amount',
                hintStyle: AppTheme.inter(color: Colors.white30, fontSize: 14),
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              text: '${_selectedAsset?.symbol.toUpperCase() ?? 'BTC'} | ',
              style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              children: [
                TextSpan(text: 'MAX', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold)),
              ]
            )
          )
        ],
      ),
    );
  }

  Widget _buildLimitInput(TextEditingController controller, String hint) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: AppTheme.inter(color: Colors.white30, fontSize: 14),
        ),
      ),
    );
  }

  // ---------------------------------------- //

  Widget _buildPostAdButton() {
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
        onPressed: _isLoading ? null : _submitAd,
        child: _isLoading 
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
            )
          : Text(
              'Post Ad',
              style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
            ),
      ),
    );
  }
}
