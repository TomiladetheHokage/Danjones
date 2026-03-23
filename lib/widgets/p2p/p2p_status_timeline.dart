import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class P2PStatusTimeline extends StatelessWidget {
  final int currentStep; // 0, 1, 2, 3
  
  const P2PStatusTimeline({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildStep(
            isActive: currentStep >= 0,
            isCompleted: currentStep > 0,
            title: 'Order Created',
            time: '10:45 AM',
            isFirst: true,
          ),
          _buildStep(
            isActive: currentStep >= 1,
            isCompleted: currentStep > 1,
            title: 'Payment Confirmed',
            time: '10:48 AM',
          ),
          _buildStep(
            isActive: currentStep >= 2,
            isCompleted: currentStep > 2,
            title: 'Releasing Assets',
            time: currentStep > 2 ? '10:50 AM' : 'In Progress',
            isWarning: currentStep == 2,
          ),
          _buildStep(
            isActive: currentStep >= 3,
            isCompleted: currentStep >= 3,
            title: 'Completed',
            time: '---',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required bool isActive,
    required bool isCompleted,
    required String title,
    required String time,
    bool isFirst = false,
    bool isLast = false,
    bool isWarning = false,
  }) {
    Color iconColor;
    if (isCompleted || isWarning) {
      iconColor = const Color(0xFFE4B53E);
    } else {
      iconColor = Colors.white24;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: isCompleted || isActive ? const Color(0xFFE4B53E) : Colors.white12,
              )
            else
              const SizedBox(height: 20),
            
            if (isCompleted)
              const Icon(Icons.check_circle_rounded, color: Color(0xFFE4B53E), size: 20)
            else if (isWarning)
              const Icon(Icons.access_time_filled_rounded, color: Color(0xFFE4B53E), size: 20)
            else
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
              ),

            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: isCompleted ? const Color(0xFFE4B53E) : Colors.white12,
              )
            else
              const SizedBox(height: 20),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 20 : 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTheme.inter(
                    color: isActive ? Colors.white : Colors.white54,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: AppTheme.inter(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
