import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'enable_2fa_manual_screen.dart';
import 'two_factor_auth_screen.dart';

class Enable2faScanScreen extends StatelessWidget {
  const Enable2faScanScreen({super.key});

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
          'Enable 2FA',
          style: AppTheme.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Scan QR Code',
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Open your authenticator app and scan\nthe QR code below to connect your\naccount.',
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                color: Colors.white38,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // QR Code Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.qr_code_2, size: 200, color: Colors.white),
            ),
            
            const SizedBox(height: 32),
            
            // Manual Setup Key Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manual Setup Key',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Enable2faManualScreen()),
                    );
                  },
                  child: Text(
                    'How to use?',
                    style: AppTheme.inter(
                      color: const Color(0xFFE4B53E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Setup Key Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D21),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'XJ92 4K1L 8M2P Q5R7',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Setup Key',
                        style: AppTheme.inter(
                          color: const Color(0xFFE4B53E),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.copy_all_rounded, color: Color(0xFFE4B53E), size: 20),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D21),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFE4B53E), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Save this key',
                        style: AppTheme.inter(
                          color: const Color(0xFFE4B53E),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Store the setup key on paper. If you lose your phone, this key is the only way to recover your Google Authenticator.',
                    style: AppTheme.inter(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Device Icons (Outside the box)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.android, color: Colors.white30, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Android',
                  style: AppTheme.inter(color: Colors.white30, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('|', style: TextStyle(color: Colors.white10, fontSize: 16)),
                ),
                const Icon(Icons.phone_iphone, color: Colors.white30, size: 18),
                const SizedBox(width: 8),
                Text(
                  'iOS',
                  style: AppTheme.inter(color: Colors.white30, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Next Step Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE4B53E), Color(0xFFB88A2D)],
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
                      MaterialPageRoute(builder: (context) => const TwoFactorAuthScreen()),
                    );
                  },
                  child: Text(
                    'Next Step',
                    style: AppTheme.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}