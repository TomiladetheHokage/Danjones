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
                title: '1. Information We Collect',
                content:
                    'We collect information you provide directly to us when registering for an account, verifying your identity, making deposits or withdrawals, or communicating with customer support. This information may include your name, email address, phone number, government-issued identification, and financial transaction details.',
              ),
              
              _buildLegalSection(
                title: '2. How We Use Your Information',
                content:
                    'We use the information we collect to: provide, maintain, and improve our services; process transactions; verify your identity to prevent fraud and comply with legal requirements; send you technical updates, support messages, and promotional offers; and monitor and analyze trends and usage of our Platform.',
              ),
              
              _buildLegalSection(
                title: '3. Information Sharing',
                content:
                    'We do not sell your personal information. We may share your information with trusted third-party service providers who assist us in operating our Platform, conducting our business, or serving our users, provided those parties agree to keep this information confidential and comply with applicable privacy laws.',
              ),
              
              _buildLegalSection(
                title: '4. Data Security',
                content:
                    'We implement robust security measures, including encryption and multi-factor authentication, to protect your personal information from unauthorized access, alteration, disclosure, or destruction. However, no electronic transmission or storage system is 100% secure, and we cannot guarantee absolute security.',
              ),
              
              _buildLegalSection(
                title: '5. Your Rights and Choices',
                content:
                    'Depending on your location, you may have the right to access, correct, delete, or limit the use of your personal data. You can manage your account settings within the app to update your details or contact our support team to submit data request inquiries.',
              ),
              
              _buildLegalSection(
                title: '6. Changes to this Policy',
                content:
                    'We may update this Privacy Policy from time to time to reflect changes in our practices or for legal reasons. We will notify you of any material changes by posting the new policy on this page and updating the "Last Updated" date.',
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
