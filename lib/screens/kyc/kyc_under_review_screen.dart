import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../main_shell.dart';

class KycUnderReviewScreen extends StatelessWidget {
  const KycUnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KYC Verification',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE4B53E).withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFE4B53E), size: 38),
            ),
            const SizedBox(height: 20),

            // Under review badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE4B53E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE4B53E).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, color: Color(0xFFE4B53E), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Under Review',
                    style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Verification in Progress',
              style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'We are currently reviewing your documents. This usually takes less than 5 minutes, but manual reviews may take up to 24 hours.',
              textAlign: TextAlign.center,
              style: AppTheme.inter(color: Colors.white38, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 36),

            // Status timeline
            _buildTimeline(),
            const SizedBox(height: 32),

            // Why wait box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why wait?',
                    style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can explore the market and add coins to your watchlist while we verify your account.',
                    style: AppTheme.inter(color: Colors.white38, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Explore markets button
            _buildOutlinedButton(
              label: 'Explore Markets',
              icon: Icons.bar_chart_rounded,
              onTap: () {
                mainShellKey.currentState?.setTab(1);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: 14),

            // Back home button
            _buildPrimaryButton(
              label: '← Back to Home',
              onTap: () {
                mainShellKey.currentState?.setTab(0);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      _TimelineStep(
        label: 'Documents Submitted',
        status: _StepStatus.done,
      ),
      _TimelineStep(
        label: 'Under Review',
        status: _StepStatus.active,
      ),
      _TimelineStep(
        label: 'Final Approval',
        status: _StepStatus.pending,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _stepDot(step.status),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: step.status == _StepStatus.done
                          ? const Color(0xFFE4B53E).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Text(
                  step.label,
                  style: AppTheme.inter(
                    color: step.status == _StepStatus.pending ? Colors.white24 : Colors.white,
                    fontSize: 14,
                    fontWeight: step.status == _StepStatus.active
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _stepDot(_StepStatus status) {
    switch (status) {
      case _StepStatus.done:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE4B53E),
          ),
          child: const Icon(Icons.check, color: Colors.black, size: 12),
        );
      case _StepStatus.active:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE4B53E), width: 2),
            color: const Color(0xFFE4B53E).withValues(alpha: 0.15),
          ),
          child: const Center(
            child: SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Color(0xFFE4B53E),
              ),
            ),
          ),
        );
      case _StepStatus.pending:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            color: Colors.transparent,
          ),
        );
    }
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTheme.inter(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOutlinedButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE4B53E).withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFE4B53E), size: 18),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

enum _StepStatus { done, active, pending }

class _TimelineStep {
  final String label;
  final _StepStatus status;
  const _TimelineStep({required this.label, required this.status});
}
