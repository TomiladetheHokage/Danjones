import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';
import '../../widgets/shared/custom_dialog.dart';
import 'create_pin_screen.dart';

/// Two-state email verification screen.
///
/// STATE 1 — Initial: shows email + "Send verification code" button.
/// STATE 2 — Code sent: shows OTP input, countdown timer, and "Verify Email" button.
class SecurityVerificationScreen extends StatefulWidget {
  final String email;

  const SecurityVerificationScreen({super.key, required this.email});

  @override
  State<SecurityVerificationScreen> createState() =>
      _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState
    extends State<SecurityVerificationScreen> {
  // ── UI state ──────────────────────────────────────────────────────────────
  bool _codeSent = true;
  bool _isSending = false;
  bool _isVerifying = false;
  static const bool testMode = true;

  // ── OTP input ─────────────────────────────────────────────────────────────
  final List<String> _otpDigits = List.filled(6, '');
  final TextEditingController _hiddenController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // ── Timer ─────────────────────────────────────────────────────────────────
  static const int _timerDuration = 60;
  int _secondsRemaining = _timerDuration;
  Timer? _countdownTimer;

  bool get _timerActive => _secondsRemaining > 0;
  bool get _otpComplete => _otpDigits.every((d) => d.isNotEmpty);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _hiddenController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────
  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = _timerDuration);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get _timerLabel {
    final mins = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  // ── OTP input ─────────────────────────────────────────────────────────────
  void _onOtpChanged(String value) {
    setState(() {
      for (int i = 0; i < 6; i++) {
        _otpDigits[i] = i < value.length ? value[i] : '';
      }
    });
    if (value.length == 6) _focusNode.unfocus();
  }

  // ── API: Send / Resend OTP ────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/resend-otp'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${ApiService.authToken}',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final data = _tryDecode(response.body);
      final ok = response.statusCode >= 200 && response.statusCode < 300;

      if (ok) {
        setState(() => _codeSent = true);
        _startTimer();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _focusNode.requestFocus();
        });
      } else {
        _showError(data?['message'] ?? 'Failed to send code. Please try again.');
      }
    } on Exception catch (e) {
      if (mounted) _showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ── API: Verify OTP ───────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    if (_isVerifying || !_otpComplete) return;
    setState(() => _isVerifying = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/verify-otp'),
      )
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer ${ApiService.authToken}'
        ..fields['otp'] = _otpDigits.join();

      final streamed =
          await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      final data = _tryDecode(response.body);
      final ok = response.statusCode >= 200 && response.statusCode < 300;

      if (ok) {
        _countdownTimer?.cancel();
        _showSuccessDialog();
      } else {
        _showError(
            data?['message'] ?? 'Invalid or expired code. Please try again.');
      }
    } on Exception catch (e) {
      if (mounted) _showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

//TEST!!!!!!!!!
//   Future<void> _sendOtp() async {
//   if (_isSending) return;

//   setState(() => _isSending = true);

//   try {
//     if (!testMode) {
//       final response = await http
//           .post(
//             Uri.parse('${ApiService.baseUrl}/resend-otp'),
//             headers: {
//               'Accept': 'application/json',
//               'Authorization':
//                   'Bearer ${ApiService.authToken}',
//             },
//           )
//           .timeout(const Duration(seconds: 15));

//       if (!mounted) return;

//       final data = _tryDecode(response.body);

//       final ok =
//           response.statusCode >= 200 &&
//           response.statusCode < 300;

//       if (!ok) {
//         _showError(
//           data?['message'] ??
//               'Failed to send code. Please try again.',
//         );
//         return;
//       }
//     }

//     // TEST MODE SUCCESS
//     setState(() => _codeSent = true);

//     _startTimer();

//     Future.delayed(
//       const Duration(milliseconds: 300),
//       () {
//         if (mounted) {
//           _focusNode.requestFocus();
//         }
//       },
//     );
//   } on Exception catch (e) {
//     if (mounted) {
//       _showError(_friendlyError(e));
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isSending = false);
//     }
//   }
// }


// Future<void> _verifyOtp() async {
//   if (_isVerifying || !_otpComplete) return;

//   setState(() => _isVerifying = true);

//   try {
//     if (!testMode) {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${ApiService.baseUrl}/verify-otp'),
//       )
//         ..headers['Accept'] = 'application/json'
//         ..headers['Authorization'] =
//             'Bearer ${ApiService.authToken}'
//         ..fields['otp'] = _otpDigits.join();

//       final streamed =
//           await request.send().timeout(
//                 const Duration(seconds: 15),
//               );

//       final response =
//           await http.Response.fromStream(streamed);

//       if (!mounted) return;

//       final data = _tryDecode(response.body);

//       final ok =
//           response.statusCode >= 200 &&
//           response.statusCode < 300;

//       if (!ok) {
//         _showError(
//           data?['message'] ??
//               'Invalid or expired code.',
//         );
//         return;
//       }
//     }

//     // TEST MODE SUCCESS
//     _countdownTimer?.cancel();

//     _showSuccessDialog();
//   } on Exception catch (e) {
//     if (mounted) {
//       _showError(_friendlyError(e));
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isVerifying = false);
//     }
//   }
// }


  // ── Helpers ───────────────────────────────────────────────────────────────
  Map<String, dynamic>? _tryDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String _friendlyError(Exception e) {
    final msg = e.toString();
    if (msg.contains('timed out') || msg.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('SocketException') || msg.contains('Failed to fetch')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _showError(String message) {
    CustomDialog.showError(context, title: 'Error', message: message);
  }

  void _showSuccessDialog() {
    CustomDialog.showSuccess(
      context,
      title: 'Email Verified',
      message: 'Your email has been verified successfully.',
      buttonText: 'Set Transaction PIN',
      onButtonPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CreatePinScreen()),
          (route) => false,
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 48),
              if (_codeSent) ...[
                _buildOtpInput(),
                const SizedBox(height: 32),
                _buildResendRow(),
              ],
              const SizedBox(height: 48),
              _buildActionButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFE4B53E).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: Color(0xFFE4B53E),
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Email Verification',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.outfit(
                color: Colors.white54, fontSize: 14, height: 1.5),
            children: [
              TextSpan(
                text: _codeSent
                    ? 'Enter the 6-digit code sent to\n'
                    : 'We will send a verification code to\n',
              ),
              TextSpan(
                text: widget.email,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── OTP boxes ─────────────────────────────────────────────────────────────
  Widget _buildOtpInput() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (i) {
            final isActive = _hiddenController.text.length == i;
            final isFilled = _otpDigits[i].isNotEmpty;

            return GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 46,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFE4B53E)
                        : isFilled
                            ? Colors.white30
                            : Colors.white10,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  isFilled ? _otpDigits[i] : (isActive ? '|' : ''),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        isActive ? const Color(0xFFE4B53E) : Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.001,
            child: TextField(
              controller: _hiddenController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              showCursor: false,
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              onChanged: _onOtpChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ── Resend row ────────────────────────────────────────────────────────────
  Widget _buildResendRow() {
    return Column(
      children: [
        Text(
          "Didn't receive the code?",
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(height: 8),
        if (_timerActive)
          RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
              children: [
                const TextSpan(text: 'Resend code in '),
                TextSpan(
                  text: _timerLabel,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFE4B53E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: _isSending ? null : _sendOtp,
            child: Text(
              _isSending ? 'Sending…' : 'Resend code',
              style: GoogleFonts.outfit(
                color:
                    _isSending ? Colors.white38 : const Color(0xFFE4B53E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: _isSending ? null : TextDecoration.underline,
                decorationColor: const Color(0xFFE4B53E),
              ),
            ),
          ),
      ],
    );
  }

  // ── Primary action button ─────────────────────────────────────────────────
  Widget _buildActionButton() {
    final bool isLoading = _isSending || _isVerifying;
    final bool enabled =
        _codeSent ? (_otpComplete && !isLoading) : !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? (_codeSent ? _verifyOtp : _sendOtp) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE4B53E),
          disabledBackgroundColor:
              const Color(0xFFE4B53E).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Text(
                _codeSent ? 'Verify Email' : 'Send verification code',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
