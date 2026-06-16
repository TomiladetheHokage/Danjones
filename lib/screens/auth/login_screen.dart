import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dialog.dart';
import '../../services/api_service.dart';
import '../main_shell.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainShell()),
        (route) => false,
      );
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

  void _showErrorDialog(String message) {
    CustomDialog.showError(
      context,
      title: 'Login Error',
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
             onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
             },
            child: Text(
              'Sign Up',
              style: GoogleFonts.outfit(
                color: const Color(0xFFE4B53E),
                fontWeight: FontWeight.bold,
              ),
            ),
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
                    'Welcome back',
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
                    'Log in to continue your trading journey',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                CustomTextField(
                  label: 'Email',
                  hintText: 'Input your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 12),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forget Password',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFE4B53E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                          'Login',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 32),
                // Center(
                //   child: Text(
                //     'Or continue with',
                //     style: GoogleFonts.outfit(color: Colors.white30),
                //   ),
                // ),
                // const SizedBox(height: 24),

                // Touch ID / Biometric (Simulated)
                // Center(
                //   child: Column(
                //     children: [
                //       Container(
                //         padding: const EdgeInsets.all(16),
                //         decoration: BoxDecoration(
                //           color: Colors.transparent,
                //           shape: BoxShape.circle,
                //           border: Border.all(color: const Color(0xFFE4B53E).withValues(alpha: 0.5)),
                //         ),
                //         child: const Icon(
                //           Icons.fingerprint,
                //           color: Color(0xFFE4B53E),
                //           size: 40,
                //         ),
                //       ),
                //       const SizedBox(height: 8),
                //       Text(
                //         'Touch ID',
                //         style: GoogleFonts.outfit(color: Colors.white54),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 48), // Increased bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
