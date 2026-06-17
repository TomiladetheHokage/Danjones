import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = '';
  String _pinConfirmation = '';
  bool _editingConfirm = false;
  bool _isLoading = false;
  String? _error;

  bool get _canSubmit =>
      _pin.length == 4 && _pinConfirmation.length == 4 && !_isLoading;

  void _onKey(String key) {
    if (_isLoading) return;

    setState(() {
      _error = null;
      final isBackspace = key == '←';

      if (_editingConfirm) {
        if (isBackspace) {
          if (_pinConfirmation.isNotEmpty) {
            _pinConfirmation = _pinConfirmation.substring(0, _pinConfirmation.length - 1);
          }
        } else if (_pinConfirmation.length < 4) {
          _pinConfirmation += key;
        }
      } else {
        if (isBackspace) {
          if (_pin.isNotEmpty) {
            _pin = _pin.substring(0, _pin.length - 1);
          }
        } else if (_pin.length < 4) {
          _pin += key;
          if (_pin.length == 4) {
            _editingConfirm = true;
          }
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    if (_pin != _pinConfirmation) {
      setState(() {
        _error = 'PINs do not match.';
        _pinConfirmation = '';
        _editingConfirm = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ApiService.setTransactionPin(
        pin: _pin,
        pinConfirmation: _pinConfirmation,
      );

      if (!mounted) return;
      await _showPinSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showPinSuccessDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/tick-circle.png',
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                'PIN Set',
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your transaction PIN has been created successfully.',
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4B53E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Continue to Login',
                    style: AppTheme.inter(
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
      ),
    );
  }

  Widget _buildPinRow({
    required String title,
    required String value,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.inter(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final filled = index < value.length;
              final showCaret = isActive && !filled && index == value.length;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1D21),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFE4B53E).withOpacity(0.75)
                        : Colors.white.withOpacity(0.12),
                  ),
                ),
                alignment: Alignment.center,
                child: filled
                    ? Text(
                        '✱',
                        style: AppTheme.inter(color: Colors.white, fontSize: 18),
                      )
                    : showCaret
                        ? Container(
                            width: 2,
                            height: 18,
                            color: const Color(0xFFE4B53E),
                          )
                        : const SizedBox(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onKey(label),
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: label == '←'
              ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 20)
              : Text(
                  label,
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Set PIN',
                      style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Create a 4-digit PIN to secure your account.',
                      textAlign: TextAlign.center,
                      style: AppTheme.inter(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildPinRow(
                      title: 'PIN',
                      value: _pin,
                      isActive: !_editingConfirm,
                      onTap: () => setState(() => _editingConfirm = false),
                    ),
                    const SizedBox(height: 20),
                    _buildPinRow(
                      title: 'Confirm PIN',
                      value: _pinConfirmation,
                      isActive: _editingConfirm,
                      onTap: () => setState(() => _editingConfirm = true),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: AppTheme.inter(color: Colors.redAccent, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4B53E),
                          disabledBackgroundColor: const Color(0xFFE4B53E).withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : Text(
                                'Confirm',
                                style: AppTheme.inter(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: const Color(0xFF232323),
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 18),
              child: Column(
                children: [
                  Row(children: ['1', '2', '3'].map(_buildKey).toList()),
                  Row(children: ['4', '5', '6'].map(_buildKey).toList()),
                  Row(children: ['7', '8', '9'].map(_buildKey).toList()),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      _buildKey('0'),
                      _buildKey('←'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
