import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SwapScreen extends StatefulWidget {
  final bool showBackButton;
  const SwapScreen({super.key, this.showBackButton = false});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: widget.showBackButton ? 56 : 100,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  'Swap',
                  style: AppTheme.inter(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
        title: Text(
          'Swap',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You Pay', style: AppTheme.inter(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 12),
            _buildAmountBox(
              value: '0.0',
              tokenSymbol: 'BTC',
              tokenIcon: 'assets/icons/BTC.png',
              backgroundColor: const Color(0xFF1E1E1F),
            ),
            const SizedBox(height: 8),
            Text('Balance: 100 BTC', style: AppTheme.inter(color: Colors.white60, fontSize: 11)),
            
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: Color(0xFFE4B53E), size: 22),
                    Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text('You Receive', style: AppTheme.inter(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 12),
            _buildAmountBox(
              value: '0.0',
              tokenSymbol: 'ETH',
              tokenIcon: 'assets/icons/ETH.png',
              backgroundColor: const Color(0xFF1E1E1F),
            ),
            const SizedBox(height: 8),
            Text('Balance: 100 BTC', style: AppTheme.inter(color: Colors.white60, fontSize: 11)),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                '1 BTC ~= 1000 ETH',
                style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 40),
            _buildSwapButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBox({
    required String value,
    required String tokenSymbol,
    required String tokenIcon,
    required Color backgroundColor,
  }) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              style: AppTheme.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, 5),
                child: Image.asset(tokenIcon, width: 44, height: 44),
              ),
              const SizedBox(width: 2),
              Text(
                tokenSymbol,
                style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE4B53E), size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
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
        onPressed: () {
          _showTransactionBottomSheet(context);
        },
        child: Text(
          'Swap',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  void _showTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SwapTransactionBottomSheet(),
    );
  }
}

class SwapTransactionBottomSheet extends StatelessWidget {
  const SwapTransactionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Swap Transaction',
              style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            
            // Tokens visual
            _buildTokensVisualRow(),
            const SizedBox(height: 40),
            
            _buildAddressRow('From:', '0x8dfu8dfj8ja8289d93dj9d3...00kdiwjd'),
            const SizedBox(height: 20),
            _buildAddressRow('To:', '0x8dfu8dfj8ja8289d93dj9d3...00kdiwjd'),
            
            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 24),
            
            _buildSummaryRow('Network fees', '0.004BTC', isWhite: true),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 24),
            
            _buildSummaryRow('Total', '0.1320BTC', isBold: true, isWhite: true),
            const SizedBox(height: 32),
            
            // Warning box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE4B53E), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please double check recipient address',
                      style: AppTheme.inter(color: Colors.white60, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _buildConfirmButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTokensVisualRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTokenInfo('assets/icons/BTC.png', '0.1298 BTC', '\$3.00912'),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Icon(Icons.compare_arrows_rounded, color: Color(0xFFE4B53E), size: 24),
        ),
        _buildTokenInfo('assets/icons/ETH.png', '0.1642 ETH', '\$3.00', isRightAlign: true),
      ],
    );
  }

  Widget _buildTokenInfo(String iconPath, String amount, String fiatValue, {bool isRightAlign = false}) {
    return Column(
      crossAxisAlignment: isRightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1A1A),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          alignment: Alignment.center,
          child: Image.asset(iconPath, width: 22, height: 22),
        ),
        const SizedBox(height: 16),
        Text(amount, style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(fiatValue, style: AppTheme.inter(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildAddressRow(String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  address,
                  style: AppTheme.inter(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.copy_rounded, color: Color(0xFFE4B53E), size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isWhite = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.inter(
            color: isWhite ? Colors.white60 : Colors.white54,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTheme.inter(
            color: isWhite ? Colors.white : Colors.white,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
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
        onPressed: () => _showSuccessDialog(context),
        child: Text(
          'Confirm',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF151515),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Transaction Confirmed', style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 48),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE4B53E), width: 3),
                  ),
                  child: const Icon(Icons.check, color: const Color(0xFFE4B53E), size: 40),
                ),
                const SizedBox(height: 48),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In vitae id amet ut sit duis',
                  style: AppTheme.inter(color: Colors.white70, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
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
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close bottom sheet
                    },
                    child: Text('Done', style: AppTheme.inter(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
