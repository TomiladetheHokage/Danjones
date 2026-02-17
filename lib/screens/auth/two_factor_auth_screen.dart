import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  // Simulating 6 OTP digits
  final List<String> _otpDigits = List.filled(6, '');
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    setState(() {
      for (int i = 0; i < 6; i++) {
        if (i < value.length) {
          _otpDigits[i] = value[i];
        } else {
          _otpDigits[i] = '';
        }
      }
    });

    if (value.length == 6) {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: _onCodeChanged,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Two-Factor Authentication',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to your Google Authenticator app',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 48),

                Text(
                  'Security Code',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                
                // OTP Display Boxes
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   decoration: BoxDecoration(
                     color: const Color(0xFF1E1E1E),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.white10),
                   ),
                   child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return Text(
                        _otpDigits[index].isEmpty ? '0' : _otpDigits[index],
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _otpDigits[index].isNotEmpty ? Colors.white : Colors.white24,
                          letterSpacing: 8,
                        ),
                      );
                    }),
                   ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Login successful
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login Successful!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4B53E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Verify',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                Row(
                  children: [
                     Expanded(child: Container(height: 1, color: Colors.white10)),
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                       child: Text('Or', style: GoogleFonts.outfit(color: Colors.white30)),
                     ),
                     Expanded(child: Container(height: 1, color: Colors.white10)),
                  ],
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Use Recovery Code',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFE4B53E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'If you cannot access your authenticator app, please contact support immediately.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
