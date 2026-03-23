import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class P2PBigTimer extends StatelessWidget {
  final int minutes;
  final int seconds;

  const P2PBigTimer({super.key, required this.minutes, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBox(minutes.toString().padLeft(2, '0'), 'Min'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(':', style: AppTheme.inter(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        _buildTimeBox(seconds.toString().padLeft(2, '0'), 'Sec'),
      ],
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTheme.inter(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
