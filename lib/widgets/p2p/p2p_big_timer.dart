import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class P2PBigTimer extends StatefulWidget {
  final int minutes;
  final int seconds;

  /// Called when the countdown reaches zero.
  final VoidCallback? onExpired;

  const P2PBigTimer({
    super.key,
    required this.minutes,
    required this.seconds,
    this.onExpired,
  });

  @override
  State<P2PBigTimer> createState() => _P2PBigTimerState();
}

class _P2PBigTimerState extends State<P2PBigTimer> {
  late int _totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.minutes * 60 + widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_totalSeconds > 0) {
          _totalSeconds--;
        } else {
          timer.cancel();
          widget.onExpired?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _minutes => _totalSeconds ~/ 60;
  int get _secs => _totalSeconds % 60;

  @override
  Widget build(BuildContext context) {
    final isExpired = _totalSeconds == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBox(_minutes.toString().padLeft(2, '0'), 'Min', isExpired),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              ':',
              style: AppTheme.inter(
                color: isExpired ? Colors.red.withValues(alpha: 0.6) : Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _buildTimeBox(_secs.toString().padLeft(2, '0'), 'Sec', isExpired),
      ],
    );
  }

  Widget _buildTimeBox(String value, String label, bool isExpired) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpired
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: AppTheme.inter(
              color: isExpired ? Colors.redAccent : const Color(0xFFE4B53E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
