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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
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
                color: Colors.white54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            
            // QR Code Placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.qr_code_2, size: 180, color: Colors.black),
            ),
            
            const SizedBox(height: 40),
            
            // Manual Setup Key
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manual Setup Key',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D21),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XJ92 4K1L 8M2P Q5R7',
                    style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Icon(Icons.copy, color: Color(0xFFE4B53E), size: 18),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Save this key Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D21),
                borderRadius: BorderRadius.circular(12),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Store this setup key on paper. If you lose\nyour phone, this key is the only way to\nrecover your Google Authenticator.',
                    style: AppTheme.inter(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.android, color: Colors.white54, size: 18),
                      const SizedBox(width: 6),
                      Text('Android', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
                      const SizedBox(width: 16),
                      Container(width: 1, height: 12, color: Colors.white24),
                      const SizedBox(width: 16),
                      const Icon(Icons.apple, color: Colors.white54, size: 18),
                      const SizedBox(width: 6),
                      Text('iOS', style: AppTheme.inter(color: Colors.white54, fontSize: 13)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Next Step Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE4B53E), Color(0xFFA7711E)],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Temporarily navigating to Two Factor Auth Screen for demo
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TwoFactorAuthScreen()),
                    );
                  },
                  child: Text(
                    'Next Step',
                    style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.bold),
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
