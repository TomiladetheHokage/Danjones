import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final Color buttonColor;
  final Color buttonTextColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onButtonPressed;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Okay',
    this.buttonColor = Colors.redAccent,
    this.buttonTextColor = Colors.white,
    this.icon = Icons.error_outline_rounded,
    this.iconColor = Colors.redAccent,
    this.onButtonPressed,
  });

  /// Helper static method to show the error dialog
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Okay',
    VoidCallback? onButtonPressed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        buttonColor: Colors.redAccent,
        buttonTextColor: Colors.white,
        icon: Icons.error_outline_rounded,
        iconColor: Colors.redAccent,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  /// Helper static method to show the success dialog
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Continue',
    VoidCallback? onButtonPressed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        buttonColor: const Color(0xFFE4B53E),
        buttonTextColor: Colors.black,
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFFE4B53E),
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.outfit(
                    color: buttonTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
