import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'kyc_under_review_screen.dart';

class KycTier3Screen extends StatefulWidget {
  const KycTier3Screen({super.key});

  @override
  State<KycTier3Screen> createState() => _KycTier3ScreenState();
}

class _KycTier3ScreenState extends State<KycTier3Screen> {
  static const List<String> _docTypes = [
    'Bank Statement',
    'Electricity Bill',
    'Tenancy Agreement',
    'Waste Management Bill',
  ];

  String? _selectedDoc;
  bool _docDropdownOpen = false;
  bool _docUploaded = false;

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(currentStep: 2),
            const SizedBox(height: 24),

            Text(
              'Upgrade to Tier 3',
              style: AppTheme.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Verify your address to unlock unlimited withdrawals and P2P trading features.',
              style: AppTheme.inter(color: Colors.white38, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),

            Text('Document Type', style: AppTheme.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildDropdown(
              hint: 'Select document type',
              options: _docTypes,
              selected: _selectedDoc,
              isOpen: _docDropdownOpen,
              onToggle: () => setState(() => _docDropdownOpen = !_docDropdownOpen),
              onSelect: (val) => setState(() {
                _selectedDoc = val;
                _docDropdownOpen = false;
              }),
            ),
            const SizedBox(height: 6),
            Text(
              'Supported formats: JPG, PNG, Max size: 5MB.',
              style: AppTheme.inter(color: Colors.white24, fontSize: 11),
            ),
            const SizedBox(height: 20),

            _buildUploadBox(
              uploaded: _docUploaded,
              onTap: () => setState(() => _docUploaded = !_docUploaded),
            ),
            const SizedBox(height: 24),

            // Submission requirements
            Text(
              'Submission Requirements',
              style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _requirementRow('Within 3 months', 'Document must be recent.'),
            _requirementRow('Matching Details', 'Name and address must match your profile.'),
            _requirementRow('Clear Visibility', 'Name and address must match your profile.'),

            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Your data is encrypted and stored securely.',
                  style: AppTheme.inter(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSubmitButton(
              label: 'Submit for Review  →',
              enabled: _selectedDoc != null && _docUploaded,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const KycUnderReviewScreen()),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required int currentStep}) {
    return Row(
      children: List.generate(3, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isDone ? const Color(0xFFE4B53E) : const Color(0xFF1E1E1E),
                  border: Border.all(
                    color: isActive || isDone
                        ? const Color(0xFFE4B53E)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check, color: Colors.black, size: 14)
                    : Text(
                        '$step',
                        style: AppTheme.inter(
                          color: isActive ? Colors.black : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (i < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone
                        ? const Color(0xFFE4B53E)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required List<String> options,
    required String? selected,
    required bool isOpen,
    required VoidCallback onToggle,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOpen ? const Color(0xFFE4B53E) : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected ?? hint,
                    style: AppTheme.inter(
                      color: selected != null ? Colors.white : Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFE4B53E),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4B53E).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: options.map((opt) {
                final isSelected = opt == selected;
                return GestureDetector(
                  onTap: () => onSelect(opt),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE4B53E).withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      opt,
                      style: AppTheme.inter(
                        color: isSelected ? const Color(0xFFE4B53E) : Colors.white70,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadBox({required bool uploaded, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: uploaded
                ? const Color(0xFF33D17A).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              uploaded ? Icons.check_circle_rounded : Icons.upload_rounded,
              color: uploaded ? const Color(0xFF33D17A) : Colors.white24,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              uploaded ? 'Document uploaded' : 'Tap to upload document',
              style: AppTheme.inter(
                color: uploaded ? const Color(0xFF33D17A) : Colors.white38,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SVG, PNG, JPG or PDF (max. 5MB)',
              style: AppTheme.inter(color: Colors.white24, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requirementRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFE4B53E), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTheme.inter(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton({required String label, required bool enabled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: enabled ? null : const Color(0xFF1E1E1E),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.inter(
            color: enabled ? Colors.black : Colors.white24,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
