import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'two_factor_auth_screen.dart';

class Enable2faManualScreen extends StatefulWidget {
  const Enable2faManualScreen({super.key});

  @override
  State<Enable2faManualScreen> createState() => _Enable2faManualScreenState();
}

class _Enable2faManualScreenState extends State<Enable2faManualScreen> {
  bool _isBackedUp = false;

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
          'Manual Entry',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Can't scan the QR code? Enter the key below\nmanually into your authenticator app.",
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              'Secret Key',
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
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
                    'JBSWY3DPEHPK3PXP',
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
            
            const SizedBox(height: 32),
            
            _buildInstructionStep(
              number: '1',
              title: 'Copy Code',
              body: 'Tap the copy icon above to grab your unique\nkey.',
            ),
            const SizedBox(height: 20),
            _buildInstructionStep(
              number: '2',
              title: 'Open App',
              body: 'Switch to Google Authenticator or Authy on\nyour device.',
            ),
            const SizedBox(height: 20),
            _buildInstructionStep(
              number: '3',
              title: 'Add Key',
              body: "Select 'Enter setup key' in the app and paste\nthe code.",
            ),
            
            const SizedBox(height: 32),
            
            // Security Note Container
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
                        'Security Note',
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
                    'Save this key in a secure place (offline). It\nallows you to restore your 2FA if you lose\nyour phone.',
                    style: AppTheme.inter(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'I have backed up this key',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: _isBackedUp,
                  onChanged: (v) {
                    setState(() {
                      _isBackedUp = v;
                    });
                  },
                  activeColor: Colors.black,
                  activeTrackColor: const Color(0xFFE4B53E),
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  inactiveThumbColor: Colors.white54,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
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
                    colors: [Color(0xFFE4B53E), Color(0xFFB88A2D)],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: _isBackedUp ? Colors.black : Colors.black54,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isBackedUp ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TwoFactorAuthScreen()),
                    );
                  } : null,
                 child: Text(
  'Next Step',
  style: AppTheme.inter(
    fontSize: 16, 
    fontWeight: FontWeight.bold, // Switched to bold to match Figma
    color: Colors.black,         // Added the black color
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

  Widget _buildInstructionStep({required String number, required String title, required String body}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE4B53E)),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTheme.inter(
                color: const Color(0xFFE4B53E),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
