import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dialog.dart';
import '../../services/api_service.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_policy_screen.dart';
import 'login_screen.dart';
import 'security_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _refCodeController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _showRefCode = false;
  bool _hasInteractedWithPassword = false;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TermsScreen()),
        );
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
        );
      };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _refCodeController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Please fill all required fields');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }
    if (!_agreedToTerms) {
      _showErrorDialog('You must agree to the Terms of Service and Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // try {
    //   await ApiService.register(
    //     name: _nameController.text.trim(),
    //     email: _emailController.text.trim(),
    //     password: _passwordController.text,
    //     phone: _phoneController.text.trim(),
    //     refCode: _refCodeController.text.trim().isEmpty ? null : _refCodeController.text.trim(),
    //   );
    //   if (!mounted) return;
    //   _showSuccessDialog();
    // } 
    // catch (e) {
    //   if (!mounted) return;
    //   _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
    try {
  const bool testMode = true;

  if (!testMode) {
    await ApiService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      refCode: _refCodeController.text.trim().isEmpty
          ? null
          : _refCodeController.text.trim(),
    );
  } else {
    await Future.delayed(const Duration(seconds: 1));
  }

  if (!mounted) return;
  _showSuccessDialog();
} catch (e) {
  if (!mounted) return;
  _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
} finally {
  if (mounted) {
    setState(() {
      _isLoading = false;
    });
  }
}
  }

  void _showSuccessDialog() {
    CustomDialog.showSuccess(
      context,
      title: 'Sign Up Successful',
      message: 'Your account has been created successfully. Let\'s verify your email now.',
      onButtonPressed: () {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => SecurityVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
          (route) => false,
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    CustomDialog.showError(
      context,
      title: 'Sign Up Error',
      message: message,
    );
  }

  int _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[^a-zA-Z0-9\s]'))) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {

    final password = _passwordController.text;

final int score =
    _hasInteractedWithPassword ? _getPasswordStrength(password) : -1;

final Color strengthColor;
final String strengthText;
final int filledBars;
  

if (score == -1) {
  strengthColor = Colors.white12;
  strengthText = '';
  filledBars = 0;
}

   else if (score <= 1) {
      strengthColor = Colors.redAccent;
      strengthText = 'Weak';
      filledBars = 1;
    } else if (score == 2) {
      strengthColor = Colors.orangeAccent;
      strengthText = 'Medium';
      filledBars = 2;
    } else if (score == 3) {
      strengthColor = const Color(0xFFE4B53E);
      strengthText = 'Strong';
      filledBars = 3;
    } else {
      strengthColor = const Color(0xFF4CAF50);
      strengthText = 'Very Strong';
      filledBars = 4;
    }

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Join the leading crypto exchange in Nigeria.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                CustomTextField(
                  label: 'Name',
                  hintText: 'Input your full name',
                  controller: _nameController,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Phone number',
                  hintText: 'Input your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Email',
                  hintText: 'Input your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  isPassword: true,
                  controller: _passwordController,
                  onChanged: (value) {
  setState(() {
    _hasInteractedWithPassword = value.isNotEmpty;
  });
},
                ),
                const SizedBox(height: 8),
                
                // Password Strength Indicator (Simplified)
                Row(
                  children: List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: index < filledBars
                            ? strengthColor
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    strengthText,
                    style: GoogleFonts.outfit(
  color: strengthColor,
  fontSize: 12,
  fontWeight: FontWeight.w500,
),
                  ),
                ),

                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Confirm password',
                  isPassword: true,
                  controller: _confirmPasswordController,
                ),

                const SizedBox(height: 20),
                // Referral Code
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showRefCode = !_showRefCode;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Referral code (optional)',
                        style: GoogleFonts.outfit(color: Colors.white54),
                      ),
                      Icon(
                        _showRefCode ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
                if (_showRefCode) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Code',
                    hintText: 'Enter referral code',
                    controller: _refCodeController,
                  ),
                ],
                const SizedBox(height: 24),

                // Terms and Conditions
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: const Color(0xFFE4B53E),
                        checkColor: Colors.black,
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: GoogleFonts.outfit(color: const Color(0xFFE4B53E)),
                              recognizer: _termsRecognizer,
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.outfit(color: const Color(0xFFE4B53E)),
                              recognizer: _privacyRecognizer,
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4B53E),
                      disabledBackgroundColor: const Color(0xFFE4B53E).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : Text(
                          'Sign up',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Or continue with',
                    style: GoogleFonts.outfit(color: Colors.white30),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton('assets/images/Google-original.png', 'Google'),
                    const SizedBox(width: 20),
                    _buildSocialButton('assets/images/apple-logo.png', 'Apple'),
                  ],
                ),

                const SizedBox(height: 24), // Reduced spacing from 32
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.outfit(color: Colors.white54),
                    ),
                    GestureDetector(
                      onTap: () {
                           Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE4B53E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48), // Increased bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String imagePath, String label) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
