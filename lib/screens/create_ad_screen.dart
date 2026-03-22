import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
                Expanded(child: _buildCurrencySelector('BTC', 'Bitcoin', 'assets/icons/BTC.png')),
                const SizedBox(width: 16),
                Expanded(child: _buildCurrencySelector('NGN', 'Naira', null, circleColor: const Color(0xFF333333), circleIcon: Icons.attach_money)),
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
            _buildPriceAdjuster('11250000.00'),
            const SizedBox(height: 8),
            Text('Highest Order Price: ₦11,255,000', style: AppTheme.inter(color: Colors.white60, fontSize: 11)),
            
            const SizedBox(height: 32),
            Text('Amount & Limits', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text('Total Amount', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 12)),
            const SizedBox(height: 8),
            _buildInputWithSuffix('0.00', 'BTC | MAX', isMaxGolden: true),
            const SizedBox(height: 8),
            Text('Available Balance: 0.45 BTC', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Min Limit (NGN)', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      _buildInputBox('5,000'),
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
                      _buildInputBox('50,000,000'),
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
                    ? Image.asset(iconPath, width: 20, height: 20)
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
        onPressed: () {},
        child: Text(
          'Post Ad',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
