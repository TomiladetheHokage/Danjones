import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Haptics
import '../theme/app_theme.dart';
import 'enable_2fa_manual_screen.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final TextEditingController _codeController = TextEditingController();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Two-Factor Authentication',
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter the 6-digit code sent to your Google\nAuthenticator app',
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            
            Text(
              'Security Code',
              style: AppTheme.inter(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            
            // 6-digit Code Input - Pixel Perfect Figma Match
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D21),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                cursorColor: const Color(0xFFE4B53E),
                onChanged: (value) {
                  if (value.length <= 6) {
                    HapticFeedback.selectionClick();
                  }
                },
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 26,
                  letterSpacing: 12.0, // Spaced out digits
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  counterText: "", // Hide counter
                  hintText: '000000',
                  hintStyle: AppTheme.inter(
                    color: Colors.white24,
                    fontSize: 26,
                    letterSpacing: 12.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Verify Button with Gold Gradient
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
                    foregroundColor: Colors.black,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Logic to verify code
                  },
                  child: Text(
                    'Verify',
                    style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 120), // Spacing for the bottom section
            
            // Or Divider - Custom widths to match Figma
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white.withOpacity(0.05), 
                    indent: 40, 
                    endIndent: 10,
                  ),
                ),
                Text(
                  'Or',
                  style: AppTheme.inter(color: Colors.white38, fontSize: 13),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white.withOpacity(0.05), 
                    indent: 10, 
                    endIndent: 40,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Use Recovery Code Button
            Center(
              child: GestureDetector(
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Enable2faManualScreen()),
                  );
                },
                child: Text(
                  'Use Recovery Code',
                  style: AppTheme.inter(
                    color: const Color(0xFFE4B53E),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Footer text
            Text(
              'If you cannot access your authenticator app, please\ncontact support immediately.',
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                color: Colors.white30, 
                fontSize: 11, 
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}