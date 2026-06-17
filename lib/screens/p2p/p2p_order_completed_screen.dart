import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_info_row.dart';

class P2POrderCompletedScreen extends StatelessWidget {
  final int? tradeId;
  final double? fiatAmount;
  final double? cryptoAmount;
  final double? pricePerUnit;
  final String? currencySymbol;
  final String? sellerName;

  const P2POrderCompletedScreen({
    super.key,
    this.tradeId,
    this.fiatAmount,
    this.cryptoAmount,
    this.pricePerUnit,
    this.currencySymbol,
    this.sellerName,
  });

  String _formatMoney(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first;
    final dec = parts.last;
    final buf = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final left = whole.length - i;
      buf.write(whole[i]);
      if (left > 1 && left % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}.$dec';
  }

  @override
  Widget build(BuildContext context) {
    final symbol = (currencySymbol == null || currencySymbol!.isEmpty) ? 'USDT' : currencySymbol!;
    final tradeFiatAmount = fiatAmount ?? 125000;
    final tradeCryptoAmount = cryptoAmount ?? 100;
    final tradePrice = pricePerUnit ?? (tradeCryptoAmount > 0 ? tradeFiatAmount / tradeCryptoAmount : 0);
    final tradeSeller = (sellerName == null || sellerName!.isEmpty) ? 'CryptoKing_NG' : sellerName!;
    final orderNumber = tradeId?.toString() ?? '29384920';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order Details', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Image.asset(
              'assets/icons/tick-circle.png',
              width: 92,
              height: 92,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            
            Text('Order Completed', style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Assets have been released to your Funding Wallet', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 48),
            
            Text('${tradeCryptoAmount.toStringAsFixed(8)} $symbol', style: AppTheme.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Transaction Successful', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 48),
            
            P2PInfoRow(label: 'Total Payment', value: '${_formatMoney(tradeFiatAmount)} NGN'),
            P2PInfoRow(label: 'Price', value: '₦${_formatMoney(tradePrice)} / $symbol'),
            P2PInfoRow(label: 'Seller', value: tradeSeller),
            P2PInfoRow(label: 'Order No', value: '#$orderNumber'),
            const SizedBox(height: 48),
            
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFF151515),
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('How was your trading\nexperience?', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
            //           const SizedBox(height: 4),
            //           Text('Your feedback helps us improve', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           IconButton(
            //             icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.white54, size: 24),
            //             onPressed: () {},
            //           ),
            //           IconButton(
            //             icon: const Icon(Icons.thumb_down_alt_outlined, color: Colors.white54, size: 24),
            //             onPressed: () {},
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            
            const SizedBox(height: 64),
            
            _buildPrimaryButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
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
          // Navigate to root stack or home
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Text(
          'Back Home',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
