import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTheme.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset("assets/icons/Notification-icon.png", width: 24, height: 24, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/profile_picture.png"),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4B53E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF050505), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Change Profile Photo',
                style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 30),
            
            _buildSectionTitle('Identity Information'),
            _buildTextField(
              label: 'Full Name (KYC Verified)',
              initialValue: 'Emeka Okafor',
              readOnly: true,
              suffixIcon: Icons.lock_outline,
            ),
            _buildTextField(
              label: 'Username',
              initialValue: 'CryptoKing_NG',
            ),

            const SizedBox(height: 20),
            _buildSectionTitle('Contact Details'),
            _buildTextField(
              label: 'Email Address',
              initialValue: 'emeka.o@example.com',
              readOnly: true,
              suffixIcon: Icons.lock_outline,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'To change your email, please contact support.',
                style: AppTheme.inter(color: Colors.white38, fontSize: 11),
              ),
            ),
            // Updated phone number title as regular white text
            Text(
              'Phone number',
              style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1D21),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      // Added Nigeria Flag Icon
                      Image.asset('assets/icons/Ngn.png', width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text('+234', style: AppTheme.inter(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1D21),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Text('80 1234 5678', style: AppTheme.inter(color: Colors.white, fontSize: 14)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Modified section title to accept custom color
            _buildSectionTitle('Location', isLocation: true),
            _buildTextField(
              label: 'Residential Address',
              initialValue: '15 Admiralty Way, Lekki Phase 1',
            ),
            _buildTextField(
              label: 'City',
              initialValue: 'Lagos State',
            ),

            const SizedBox(height: 20),
         Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    // The image shows a very dark, neutral grey-black background
    color: const Color(0xFF1C1D21), 
    borderRadius: BorderRadius.circular(12),
    // The border is a very subtle white/grey, not gold
    border: Border.all(color: Colors.white.withOpacity(0.08)),
  ),
  child: Row(
    children: [
      // Only the icon is gold
      const Icon(Icons.error_outline, color: Color(0xFFE4B53E), size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          'Changes to sensitive information like phone number or address may disable withdrawals for 24 hours for security purposes.',
          style: AppTheme.inter(
            color: Colors.white70, // Matches the white/grey text in the image
            fontSize: 11, 
            height: 1.4,
          ),
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 30),
            // Styled 'Save Changes' button
            SizedBox(
              width: double.infinity,
              height: 56, // Matches Figma height
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE4B53E), Color(0xFFA7711E)],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black, // Set text color black
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Save Changes',
                    style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isLocation = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTheme.inter(
          color: isLocation ? Colors.white : const Color(0xFFE4B53E), // Changes Location title to white
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue, bool readOnly = false, IconData? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.inter(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1D21),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: readOnly ? Colors.transparent : Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    initialValue,
                    style: AppTheme.inter(
                      color: readOnly ? Colors.white54 : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (suffixIcon != null) Icon(suffixIcon, color: const Color(0xFFE4B53E).withOpacity(0.5), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}