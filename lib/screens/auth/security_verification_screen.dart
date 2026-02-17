import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityVerificationScreen extends StatefulWidget {
  const SecurityVerificationScreen({super.key});

  @override
  State<SecurityVerificationScreen> createState() => _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState extends State<SecurityVerificationScreen> {
  // Simulating 6 OTP digits
  final List<String> _otpDigits = List.filled(6, '');
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-focus the hidden text field to bring up keyboard
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
      // Auto-submit or enable button
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
          // Hidden TextField to handle input
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
                  'Security Verification',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                    children: [
                      const TextSpan(text: 'Enter the 6-digit code sent to '),
                      TextSpan(
                        text: '+234 80*** **85',
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Display Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    final isActive = _controller.text.length == index;
                    final isFilled = _otpDigits[index].isNotEmpty;
                    
                    return Container(
                      width: 45,
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive 
                              ? const Color(0xFFE4B53E) 
                              : (isFilled ? Colors.white30 : Colors.white10),
                          width: isActive ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        _otpDigits[index].isEmpty ? (isActive ? '|' : '*') : _otpDigits[index],
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isActive ? const Color(0xFFE4B53E) : Colors.white,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),
                Text(
                  "Didn't receive the code?",
                  style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                    children: [
                      const TextSpan(text: 'Resend code in '),
                      TextSpan(
                        text: '00:59',
                        style: GoogleFonts.outfit(color: const Color(0xFFE4B53E)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to dashboard or success screen (not yet created)
                      // For now, maybe pop back to login
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification Successful!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4B53E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Confirm',
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
          
          // Simulated Keypad at bottom if needed, but system keyboard is better.
          // The design shows a custom keypad, but for functionality, system keyboard is standard.
          // I'll stick to system keyboard for better accessibility and implementation speed.
        ],
      ),
    );
  }
}
