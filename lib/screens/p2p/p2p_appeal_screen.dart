import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_warning_box.dart';

class P2PAppealScreen extends StatefulWidget {
  final bool isBuyer;
  final int tradeId;
  final double fiatAmount;
  final String counterpartyName;
  final String? counterpartyAvatar;
  final String currencySymbol;

  const P2PAppealScreen({
    super.key,
    required this.isBuyer,
    required this.tradeId,
    required this.fiatAmount,
    required this.counterpartyName,
    this.counterpartyAvatar,
    this.currencySymbol = '₦',
  });

  @override
  State<P2PAppealScreen> createState() => _P2PAppealScreenState();
}

class _P2PAppealScreenState extends State<P2PAppealScreen> {
  String? _selectedReason;
  bool _isSubmitting = false;

  String _formatNaira(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final buffer = StringBuffer();

    for (int i = 0; i < whole.length; i++) {
      final reversedIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return 'N${buffer.toString()}.${parts[1]}';
  }

  String get _counterpartyHandle {
    final trimmed = widget.counterpartyName.trim();
    if (trimmed.startsWith('@')) return trimmed;
    return '@$trimmed';
  }

  List<String> get _appealReasons => widget.isBuyer
      ? [
          'I have paid but seller hasn\'t released',
          'Payment issues (Wrong amount/Bank error)',
          'Seller is unresponsive',
          'Other',
        ]
      : [
          'I have not received payment',
          'Payment amount does not match',
          'Buyer marked paid without paying',
          'Other',
        ];

  Future<void> _submitAppeal() async {
    if (_selectedReason == null || _selectedReason!.trim().isEmpty) {
      _showErrorPopup('Please select a reason for the appeal.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.submitP2pDispute(
        tradeId: widget.tradeId,
        reason: _selectedReason!,
      );

      if (!mounted) return;
      await _showSuccessPopup('Appeal submitted successfully.');
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showErrorPopup(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorPopup(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1D21),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Appeal Failed',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTheme.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSuccessPopup(String message) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1D21),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4B53E).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: Color(0xFFE4B53E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Appeal Submitted',
                        style: AppTheme.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTheme.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
        );
      },
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Appeal & Dispute', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const P2PWarningBox(
              message: 'Important: False appeals or misleading information may lead to account suspension. Please provide accurate details.',
            ),
            const SizedBox(height: 32),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Unpaid',
                                style: AppTheme.inter(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '#${widget.tradeId}',
                                style: AppTheme.inter(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatNaira(widget.fiatAmount),
                          style: AppTheme.inter(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${widget.isBuyer ? 'seller' : 'buyer'}: ',
                                style: AppTheme.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: _counterpartyHandle,
                                style: AppTheme.inter(
                                  color: const Color(0xFFE4B53E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipOval(
                      child: widget.counterpartyAvatar != null && widget.counterpartyAvatar!.isNotEmpty
                          ? Image.network(
                              ApiService.resolveUrl(widget.counterpartyAvatar!) ?? widget.counterpartyAvatar!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildFallbackAvatar(80);
                              },
                            )
                          : _buildFallbackAvatar(80),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Reason for Appeal', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            PopupMenuButton<String>(
              onSelected: (value) => setState(() => _selectedReason = value),
              tooltip: '',
              elevation: 0,
              offset: const Offset(0, 10),
              color: const Color(0xFF1E1E22),
              shadowColor: Colors.black.withOpacity(0.32),
              surfaceTintColor: Colors.transparent,
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              padding: EdgeInsets.zero,
              itemBuilder: (context) => _appealReasons.map((reason) {
                final isSelected = reason == _selectedReason;
                return PopupMenuItem<String>(
                  value: reason,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  height: 54,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: isSelected
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: isSelected ? 13 : 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                );
              }).toList(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedReason ?? 'Select a reason',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.inter(
                          color: _selectedReason == null ? Colors.white38 : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFFE4B53E),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text('Description of the issue', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                maxLines: 4,
                style: AppTheme.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Please describe the issue in detail. Be specific about what happened...',
                  hintStyle: AppTheme.inter(color: Colors.white38, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Text('Proof of ${widget.isBuyer ? 'Payment' : 'Non-receipt'}', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500)),
            // const SizedBox(height: 8),
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(32),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFF1A1A1A),
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: Colors.white.withOpacity(0.05)),
            //   ),
            //   child: Column(
            //     children: [
            //       const Icon(Icons.cloud_upload_outlined, color: Color(0xFFE4B53E), size: 32),
            //       const SizedBox(height: 16),
            //       Text('Upload Screenshot', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            //       const SizedBox(height: 8),
            //       Text(widget.isBuyer ? 'PNG, JPG or PDF' : 'Bank Statement, Chat History', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 16),
            // Text('Your data is encrypted and stored securely.', style: AppTheme.inter(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            
            _buildPrimaryButton(
              context,
              _isSubmitting ? 'Submitting...' : 'Submit Appeal',
              onPressed: _isSubmitting ? null : _submitAppeal,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text, {
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: isEnabled
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
              )
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.withOpacity(0.3),
                  Colors.grey.withOpacity(0.2),
                ],
              ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                text,
                style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
              ),
      ),
    );
  }

  Widget _buildFallbackAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2A2A2A),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.counterpartyName.isNotEmpty ? widget.counterpartyName.substring(0, 1).toUpperCase() : '?',
        style: AppTheme.inter(
          color: Colors.white,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
