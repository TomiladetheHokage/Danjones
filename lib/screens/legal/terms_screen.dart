import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Terms of Service',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated: May 20, 2026',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildLegalSection(
                title: '1. Acceptance of Terms',
                content:
                    'By accessing or using the Danjones App (the "Platform"), you agree to be bound by these Terms of Service. If you do not agree to all of these terms, do not use the Platform. We reserve the right to change or modify these terms at any time at our sole discretion.\n\nYour continued use of the Platform following the posting of changes will confirm your acceptance of such changes. We encourage you to frequently review the Terms to ensure you understand the terms and conditions that apply to your use of the Platform.',
              ),
              
              _buildLegalSection(
                title: '2. Eligibility',
                content:
                    'The Platform is intended solely for users who are 18 years of age or older. By using the Platform, you represent and warrant that you are of legal age to form a binding contract and meet all of the foregoing eligibility requirements. You also represent that you are not on any trade embargo or economic sanctions lists, such as the UN Security Council Sanctions List.',
              ),
              
     _buildLegalSection(
  title: '3. Risk Disclosure',
  content:
      'Trading digital assets involves significant risk and can result in the loss of your invested capital. You should not invest more than you can afford to lose and should ensure that you fully understand the risks involved.\n\n'
      'Market Volatility: Prices can fluctuate significantly in very short periods.\n'
      'Liquidity Risk: You may be unable to liquidate a position at your preferred price.\n'
      'Cybersecurity: Digital assets are subject to theft and hacking risks.',
),
              
              _buildLegalSection(
                title: '4. User Account Security',
                content:
                    'When you create an account, you agree to maintain the security of your password and accept all risks of unauthorized access to your account. You are responsible for all activities that occur under your Danjones App account.',
              ),
              
              _buildLegalSection(
                title: '5. Prohibited',
                content:
                    'You may not use the Platform for any illegal activity, including money laundering, terrorist financing, or any activity that violates any law, statute, ordinance, or regulation. Market manipulation, including wash trading and spoofing, is strictly prohibited and will result in immediate account termination and reporting to relevant authorities.',
              ),

               _buildLegalSection(
                title: '6. Acceptance of Terms',
                content:
                'By using the P2P platform, you agree to comply with these Terms & Conditions and all applicable laws and regulations.'
              ),

                 _buildLegalSection(
                title: '7. Eligibility',
              content: '''
• Users must complete KYC before trading.
• Users must provide accurate information.
• Users must be 18 years or older.
''',
              ),

                     _buildLegalSection(
                title: '8. Escrow Service',
              content: '''
• The platform will hold digital assets in escrow during active trades.
          • Crypto assets will only be released according to the platform’s procedures.
• Users must not request or make releases outside the platform.
''',
              ),

                 _buildLegalSection(
                title: '9. User Responsibilities',
              content: '''
Users agree to:
• Trade honestly and in good faith.
• Use payment accounts registered in their own name.
• Verify receipt of funds before releasing crypto.
• Follow all platform instructions during transactions.
''',
              ),


_buildLegalSection(
  title: '10. Prohibited Activities',
  content: '''
• Fraud, scams, or deceptive practices.
• Uploading fake payment receipts or proof of payment.
• Using third-party bank accounts without authorization.
• Money laundering or illegal financial activities.
• Harassment, threats, or abusive conduct.
• Taking trades outside the platform to avoid fees or security controls.
''',
),

_buildLegalSection(
  title: '11. Payment Rules',
  content: '''
• Buyers must make payments using approved payment methods.
• Sellers must verify funds have been received before releasing crypto.
• Screenshots alone are not considered proof of payment.
''',
),

_buildLegalSection(
  title: '12. Disputes',
  content: '''
• Either party may open a dispute if a transaction issue arises.
• The platform may request evidence from both parties.
• The platform’s decision after review shall be final.
''',
),

_buildLegalSection(
  title: '13. Merchant Accounts',
  content: '''
• Merchants may be subject to additional verification requirements.
• The platform may suspend or revoke merchant status for violations.
• Merchants must maintain sufficient funds and comply with merchant policies.
''',
),

_buildLegalSection(
  title: '14. Account Suspension',
  content: '''
• The platform may freeze, suspend, or terminate accounts involved in:
  - Fraudulent activity.
  - Violation of these Terms.
  - Suspicious or unlawful transactions.
''',
),

_buildLegalSection(
  title: '15. Limitation of Liability',
  content: '''
• The platform provides escrow and dispute resolution services but does not guarantee profits or transaction outcomes.
• Users are responsible for their own trading decisions.
''',
),

_buildLegalSection(
  title: '16. Compliance',
  content: '''
• Users agree to comply with all applicable AML (Anti-Money Laundering), CTF (Counter-Terrorist Financing), and financial regulations.
''',
),

_buildLegalSection(
  title: '17. Amendments',
  content: '''
• The platform may update these Terms & Conditions at any time.
• Continued use of the platform constitutes acceptance of the updated terms.
''',
),

_buildLegalSection(
  title: '18. Risk Warning',
  content: '''
• Cryptocurrency trading involves risk.
• Users may experience losses due to market fluctuations, operational errors, or other factors.
• Users trade at their own risk.
''',
),

_buildLegalSection(
  title: 'Simple Notice for Users',
  content: '''
• Never release crypto based on screenshots.
• Confirm funds have been received in your account before releasing assets.
• Keep all communications and transactions within the platform.
''',
),
              const SizedBox(height: 12),

Center(
  child: Column(
    children: [
      Text(
        '© 2026 Danjones',
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Secure Nigerian Crypto Trading.',
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 13,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 30),
        
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
