import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/p2p/p2p_user_header.dart';
import '../../widgets/p2p/p2p_warning_box.dart';

class P2PAppealScreen extends StatefulWidget {
  final bool isBuyer;

  const P2PAppealScreen({super.key, required this.isBuyer});

  @override
  State<P2PAppealScreen> createState() => _P2PAppealScreenState();
}

class _P2PAppealScreenState extends State<P2PAppealScreen> {
  String? _selectedReason;

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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text('Unpaid', style: AppTheme.inter(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Text('#29384920', style: AppTheme.inter(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('₦125,000.00', style: AppTheme.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  P2PUserHeader(
                    name: widget.isBuyer ? 'CryptoKing_NG' : 'Chinedu_Crypto',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Reason for Appeal', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: const Color(0xFF1A1A1A),
                  value: _selectedReason,
                  hint: Text('Select a reason', style: AppTheme.inter(color: Colors.white54, fontSize: 14)),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE4B53E)),
                  items: (widget.isBuyer ? 
                    ['I have paid but seller hasn\'t released', 'Payment issues (Wrong amount/Bank error)', 'Seller is unresponsive', 'Other'] : 
                    ['I have not received payment', 'Payment amount does not match', 'Buyer marked paid without paying', 'Other']
                  ).map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: AppTheme.inter(color: Colors.white, fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedReason = val),
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
            
            Text('Proof of ${widget.isBuyer ? 'Payment' : 'Non-receipt'}', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Color(0xFFE4B53E), size: 32),
                  const SizedBox(height: 16),
                  Text('Upload Screenshot', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(widget.isBuyer ? 'PNG, JPG or PDF' : 'Bank Statement, Chat History', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Your data is encrypted and stored securely.', style: AppTheme.inter(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            
            _buildPrimaryButton(context, 'Submit Appeal'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          // Submit appeal
        },
        child: Text(
          text,
          style: AppTheme.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
