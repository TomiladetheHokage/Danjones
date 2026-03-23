import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_info_row.dart';
import '../../widgets/p2p/p2p_user_header.dart';
import '../../widgets/p2p/p2p_warning_box.dart';
import 'p2p_awaiting_payment_screen.dart';

class P2POrderConfirmationScreen extends StatelessWidget {
  const P2POrderConfirmationScreen({super.key});

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
        title: Text('Confirm Order', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFFE4B53E), size: 18),
                  const SizedBox(width: 8),
                  Text('Quote expires in', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text('00:59 s', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // You Pay / Receive
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You Pay', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Text('₦', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('NGN', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('125,000.00', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFE4B53E), size: 16),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Receive', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('USDT', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Image.asset('assets/icons/USDT.png', width: 32, height: 32, errorBuilder: (c,e,s) => const CircleAvatar(backgroundColor: Colors.green, radius: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('100.00', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // User Header
            const P2PUserHeader(
              name: 'CryptoKingNG',
              stats: '450 trades | 98.5%',
              showBackground: true,
            ),
            const SizedBox(height: 24),
            
            // Details
            const P2PInfoRow(label: 'Price per unit', value: '1,250.00 NGN'),
            const P2PInfoRow(label: 'Quantity', value: '100.00 USDT'),
            const P2PInfoRow(label: 'Payment Method', value: 'Bank Transfer'),
            const P2PInfoRow(label: 'Bank Name', value: 'Access Bank'),
            const SizedBox(height: 24),
            
            // Warning Box
            const P2PWarningBox(
              message: 'Do not include crypto-related terms (e.g., BTC, USDT, Crypto) in the bank transfer remarks to avoid transaction failure.',
            ),
            const SizedBox(height: 32),
            
            // Terms
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Secured by Escrow', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('Terms & Conditions', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Confirm Button
            _buildPrimaryButton(context),
            const SizedBox(height: 24),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const P2PAwaitingPaymentScreen()),
          );
        },
        child: Text(
          'Confirm',
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
