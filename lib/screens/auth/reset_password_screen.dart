import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_dialog.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (otp.isEmpty) {
      CustomDialog.showError(
        context,
        title: 'Missing OTP',
        message: 'Please enter the OTP sent to your email.',
      );
      return;
    }

    if (otp.length < 6) {
      CustomDialog.showError(
        context,
        title: 'Invalid OTP',
        message: 'OTP should be at least 6 digits.',
      );
      return;
    }

    if (password.isEmpty) {
      CustomDialog.showError(
        context,
        title: 'Missing Password',
        message: 'Please enter a new password.',
      );
      return;
    }

    if (password.length < 8) {
      CustomDialog.showError(
        context,
        title: 'Weak Password',
        message: 'Password must be at least 8 characters.',
      );
      return;
    }

    if (password != confirmPassword) {
      CustomDialog.showError(
        context,
        title: 'Password Mismatch',
        message: 'Passwords do not match.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.resetPassword(
        email: widget.email,
        otp: otp,
        password: password,
      );

      if (!mounted) return;

      // Show success and navigate to login
      await CustomDialog.showSuccess(
        context,
        title: 'Password Reset',
        message: 'Your password has been reset successfully. Please log in with your new password.',
        onButtonPressed: () {
          Navigator.of(context).pop(); // Close dialog
        },
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomDialog.showError(
        context,
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    'Reset Password',
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
                    'Enter the OTP and your new password.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFFE4B53E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Field
                Text('One-Time Code',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                  maxLength: 10,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter OTP',
                    hintStyle:
                        GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF1C1D21),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.08))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.08))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE4B53E))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),

                const SizedBox(height: 24),

                // Password Field
                Text('New Password',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    hintStyle:
                        GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF1C1D21),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.08))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.08))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE4B53E))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _showPassword = !_showPassword),
                      child: Icon(
                        _showPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Confirm Password Field
                Text('Confirm Password',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    hintStyle:
                        GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF1C1D21),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.08))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.08))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE4B53E))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword),
                      child: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4B53E),
                      disabledBackgroundColor:
                          const Color(0xFFE4B53E).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Reset Password',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
