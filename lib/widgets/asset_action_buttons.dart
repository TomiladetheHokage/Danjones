import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A row of actions used in both Home and Asset Details screens.
///
/// Matches the style of the action grid on the Home screen.
class AssetActionButtons extends StatelessWidget {
  final VoidCallback? onDeposit;
  final VoidCallback? onBuy;
  final VoidCallback? onSwap;

  const AssetActionButtons({
    super.key,
    this.onDeposit,
    this.onBuy,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionItem('Deposit', 'assets/icons/deposit.png', onTap: onDeposit),
          _actionItem('Buy', 'assets/icons/buy.png', onTap: onBuy),
          _actionItem('Swap', 'assets/icons/swap.png', onTap: onSwap),
        ],
      ),
    );
  }

  Widget _actionItem(String label, String iconPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
