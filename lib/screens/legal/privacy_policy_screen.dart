import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 50),
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
  title: '1. Information We Collect',
  content:
      'Danjones App collects various types of information to provide and improve our services. This includes personal identification information, such as your name, email address, and government-issued identification for KYC compliance.\n\n'
      '- Personal Identification Data (Full Name, DOB, Address)\n'
      '- Financial Information (Bank accounts, Wallet addresses)\n'
      '- Transactional Data (Trading history, deposits, withdrawals)\n'
      '- Technical Logs (IP addresses, device IDs, browser types)',
),
              
            _buildLegalSection(
  title: '2. How We Use Your Information',
  content:
      'The data we collect is utilized to facilitate services, maintain security protocols, and ensure regulatory adherence.\n\n'
      'Your information allows us to:\n'
      '- Identity Verification: Mandatory KYC/AML processing for all users\n'
      '- Fraud Prevention: Real-time monitoring of suspicious activity',
),
              
       _buildLegalSection(
  title: '3. Data Security',
  content:
      'We implement industry-leading security measures to protect your data.\n\n'
      '- AES-256 encryption for stored data\n'
      '- TLS protocols for data in transit\n'
      '- Secure hashing for sensitive identifiers\n\n'
      'No personal data is stored in plain text.',
),
              
      _buildLegalSection(
  title: '4. Sharing of Information',
  content:
      'We do not sell your personal data to third parties. Information may only be shared with service providers under strict confidentiality agreements or as required by law enforcement agencies in compliance with legal warrants.',
),
              
              _buildLegalSection(
                title: '5. Prohibited',
                content:
                    'You may not use the Platform for any illegal activity, including money laundering, terrorist financing, or any activity that violates any law, statute, ordinance, or regulation. Market manipulation, including wash trading and spoofing, is strictly prohibited and will result in immediate account termination and reporting to relevant authorities.',
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
