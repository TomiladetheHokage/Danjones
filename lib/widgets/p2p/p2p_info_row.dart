import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class P2PInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  final bool isBold;
  final bool isValueWhite;

  const P2PInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.isBold = false,
    this.isValueWhite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.inter(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ?? Text(
                value,
                style: AppTheme.inter(
                  color: isValueWhite ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
