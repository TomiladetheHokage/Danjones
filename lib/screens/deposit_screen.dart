import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../theme/app_theme.dart';
import '../widgets/token_list_item.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  bool _isCryptoTab = true;
  String _searchQuery = '';
  
  // Fiat Form State
  String _selectedMethod = 'Bank Transfer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Deposit',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSegmentedControl(),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isCryptoTab ? _buildCryptoView() : _buildFiatView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        color: const Color(0xFF151515),
      ),
      child: Row(
        children: [
          _buildSegmentTab('Crypto', _isCryptoTab, () => setState(() => _isCryptoTab = true)),
          _buildSegmentTab('Fiat', !_isCryptoTab, () => setState(() => _isCryptoTab = false)),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: isActive ? const LinearGradient(colors: [Color(0xFFE4B53E), Color(0xFFB88A2D)]) : null,
          ),
          child: Text(
            label,
            style: AppTheme.inter(
              color: isActive ? Colors.black : Colors.white.withOpacity(0.5),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CRYPTO TAB
  // ==========================================
  Widget _buildCryptoView() {
    final filteredAssets = MockCrypto.marketList.where((asset) =>
            asset.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            asset.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: filteredAssets.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.white.withOpacity(0.05), height: 1),
            ),
            itemBuilder: (context, index) {
              return TokenListItem(
                asset: filteredAssets[index],
                onTap: () {
                  // Select Asset to deposit
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                cursorColor: Colors.white24,
                style: AppTheme.inter(color: Colors.white, fontSize: 14),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search Token',
                  hintStyle: AppTheme.inter(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.2),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FIAT TAB
  // ==========================================
  Widget _buildFiatView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Amount', style: AppTheme.inter(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text('₦', style: AppTheme.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: AppTheme.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '50,000',
                      hintStyle: AppTheme.inter(color: Colors.white24, fontSize: 24, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Min: ₦1,000', style: AppTheme.inter(color: Colors.white54, fontSize: 12)),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMethodChip('Bank Transfer'),
              _buildMethodChip('USSD'),
              _buildMethodChip('Card'),
            ],
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transfer Details', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('29:59', style: AppTheme.inter(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSimpleDetailRow('Bank Name', 'Zenith Bank'),
          const SizedBox(height: 16),
          
          Text('Account Number', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Darker grey box
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('123456789', style: AppTheme.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const Icon(Icons.copy_outlined, color: Color(0xFFE4B53E), size: 20),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          _buildSimpleDetailRow('Beneficiary', 'PayStack'),
          
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFE4B53E), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lorem ipsum dolor sit amet,\nconsectetur',
                    style: AppTheme.inter(color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          _buildConfirmButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMethodChip(String label) {
    final isSelected = _selectedMethod == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE4B53E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFE4B53E) : Colors.white12),
        ),
        child: Text(
          label,
          style: AppTheme.inter(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13)),
        Text(value, style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildConfirmButton() {
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
        onPressed: () {},
        child: Text(
          'I Have Made The Paymentarrow',
          style: AppTheme.inter(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }
}
