import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'create_ad_screen.dart';

class P2PTradingScreen extends StatefulWidget {
  const P2PTradingScreen({super.key});

  @override
  State<P2PTradingScreen> createState() => _P2PTradingScreenState();
}

class _P2PTradingScreenState extends State<P2PTradingScreen> {
  bool _isBuySelected = true;
  String _selectedToken = 'USDT';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'P2P Trading',
          style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSegmentedControl(),
              _buildFiltersRow(),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                  itemCount: 4,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildAdCard(index);
                  },
                ),
              ),
            ],
          ),
          
          // Post Ad Floating Button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => const CreateAdScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFE4B53E), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '+ Post Ad',
                    style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFF151515),
        ),
        child: Row(
          children: [
            _buildSegmentTab('Buy', _isBuySelected, () => setState(() => _isBuySelected = true)),
            _buildSegmentTab('Sell', !_isBuySelected, () => setState(() => _isBuySelected = false)),
          ],
        ),
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
            borderRadius: BorderRadius.circular(25),
            gradient: isActive ? const LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)]) : null,
          ),
          child: Text(
            label,
            style: AppTheme.inter(
              color: isActive ? Colors.black : Colors.white54,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildTokenChip('USDT'),
          const SizedBox(width: 8),
          _buildTokenChip('BTC'),
          const SizedBox(width: 8),
          _buildTokenChip('ETH'),
          const Spacer(),
          Text('Sort', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE4B53E), size: 18),
        ],
      ),
    );
  }

  Widget _buildTokenChip(String token) {
    bool isSelected = _selectedToken == token;
    return GestureDetector(
      onTap: () => setState(() => _selectedToken = token),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE4B53E) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          token,
          style: AppTheme.inter(
            color: isSelected ? Colors.black : Colors.white60,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(int index) {
    // Mock Data based on index
    final name = index == 0 ? 'CryptoKingNG' : index == 1 ? 'FastExchange' : 'LagosTrust';
    final qty = index == 2 ? '500.00' : '4,000.00';
    final limits = index == 2 ? '₦10K - ₦100K' : '₦50K - ₦5.0M';
    final methods = index == 0 ? ['Palmpay'] : index == 1 ? ['Palmpay', 'Chipper'] : ['Palmpay', 'Chipper', 'Opay'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E1E1E),
                ),
                alignment: Alignment.center,
                child: Text(name.substring(0, 2).toUpperCase(), style: AppTheme.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                // In a real app we would use avatar image and verified badge indicator overlaid.
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.green, size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('450 trades | 98.5%', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Price', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('1,455.50', style: AppTheme.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('NGN', style: AppTheme.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('$qty USDT', style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Limits', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(limits, style: AppTheme.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: methods.map((m) => _buildMethodIndicator(m)).toList(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF3C756), Color(0xFFB88A2D)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Buy USDT', style: AppTheme.inter(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodIndicator(String label) {
    Color dotColor = label == 'Palmpay' ? Colors.purpleAccent : label == 'Chipper' ? Colors.pinkAccent : Colors.greenAccent;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTheme.inter(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
