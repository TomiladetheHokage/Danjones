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
                title: '3. Account Security',
                content:
                    'To use certain features of the Platform, you must register for an account. You agree to provide accurate, current, and complete information during the registration process. You are solely responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. Notify us immediately of any unauthorized use or security breach.',
              ),
              
              _buildLegalSection(
                title: '4. Risk Disclosure',
                content:
                    'Trading digital assets involves significant risk. Prices can fluctuate wildly on any given day, and you may lose the entire value of your investment. You represent that you have sufficient knowledge and experience to understand the risks involved in trading cryptocurrencies, and you agree to bear all responsibility for your trading activities.',
              ),
              
              _buildLegalSection(
                title: '5. Prohibited Activities',
                content:
                    'You agree not to engage in any prohibited activities on the Platform, including but not limited to: market manipulation, money laundering, terrorist financing, using automated bots to access the services, or attempting to breach our security infrastructure. Violations may result in immediate account termination and legal action.',
              ),
              
              _buildLegalSection(
                title: '6. Limitation of Liability',
                content:
                    'In no event shall Danjones, its directors, employees, or agents be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the Platform. The services are provided on an "as is" and "as available" basis without any warranties of any kind.',
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
        color: const Color(0xFF1E1E1E),
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
