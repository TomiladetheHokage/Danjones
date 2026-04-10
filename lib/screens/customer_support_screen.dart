import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  int? _expandedIndex = 0;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I verify my BVN?',
      'answer': 'To verify your BVN, go to Profile > Identification. Enter your BVN number accurately. Verification is usually instant but may take up to 24 hours.'
    },
    {
      'question': 'How long do NGN deposits take?',
      'answer': 'NGN deposits via bank transfer are typically processed within 5-15 minutes. If your deposit is delayed, please ensure you used the correct reference code.'
    },
    {
      'question': 'What are the fees for P2P trading?',
      'answer': 'P2P trading on our platform is currently fee-free for Takers. Makers are charged a small transaction fee of 0.1% per completed order.'
    },
  ];

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
          'Help Center',
          style: AppTheme.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              'How can we help\nyou today?',
              textAlign: TextAlign.center,
              style: AppTheme.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D21),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                style: AppTheme.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search issues, e.g., 'Deposit NGN'",
                  hintStyle: AppTheme.inter(color: Colors.white54, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: const Icon(Icons.search, color: Color(0xFFE4B53E), size: 20),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Browse Categories Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Browse Categories',
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Categories Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                _buildCategoryCard(Icons.flag_outlined, 'Getting Started'),
                _buildCategoryCard(Icons.person_outline, 'Account Verification'),
                _buildCategoryCard(Icons.account_balance_wallet_outlined, 'Deposits & Withdrawals'),
                _buildCategoryCard(Icons.sync_alt_outlined, 'P2P Trading'),
                _buildCategoryCard(Icons.security_outlined, 'Security'),
                _buildCategoryCard(Icons.bar_chart_outlined, 'Spot Trading'),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Top Questions Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Questions',
                style: AppTheme.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // FAQs List
            ...List.generate(_faqs.length, (index) {
              final faq = _faqs[index];
              final isExpanded = _expandedIndex == index;
              return _buildFaqItem(
                question: faq['question']!,
                answer: faq['answer']!,
                isExpanded: isExpanded,
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
              );
            }),
            
            const SizedBox(height: 40),
            
            // Still need help?
            Text(
              'Still need help?',
              style: AppTheme.inter(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Contact Support Button
            SizedBox(
              width: double.infinity,
              height: 56,
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
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.headset_mic_outlined, size: 20),
                  label: Text(
                    'Contact Support',
                    style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, color: const Color(0xFFE4B53E), size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTheme.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1D21),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppTheme.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFFE4B53E),
                  size: 20,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.white.withOpacity(0.05)),
              const SizedBox(height: 12),
              Text(
                answer,
                style: AppTheme.inter(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
