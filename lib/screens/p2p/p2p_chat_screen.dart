import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class P2PChatScreen extends StatelessWidget {
  const P2PChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order #29384920', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF151515),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Buying', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                    Text('100 USDT', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('Total Cost', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                    Text('125,000 NGN', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Time Left', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                    Text('14:59', style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E1E1E).withOpacity(0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFE4B53E), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('Do not include crypto-related terms (e.g., BTC, USDT, Crypto) in the bank transfer remarks.', style: AppTheme.inter(color: Colors.white60, fontSize: 11))),
                const Icon(Icons.close, color: Colors.white38, size: 16),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E1E1E)), alignment: Alignment.center, child: const Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CryptoKingNG', style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text('98.5% Completion', style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11)),
                              Text(' - replies in 5m', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.more_vert, color: Colors.white54), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 24),
                Center(child: Text('Today', style: AppTheme.inter(color: Colors.white38, fontSize: 11))),
                const SizedBox(height: 16),
                Center(child: Text('Order Created. Please pay within 15 mins.', style: AppTheme.inter(color: Colors.white38, fontSize: 11))),
                const SizedBox(height: 24),
                _buildMessageBubble('Do not include crypto-related terms (e.g., BTC, USDT) in the transfer remarks.', '10:52', false),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF151515),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.white54, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: TextField(
                      style: AppTheme.inter(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        hintStyle: AppTheme.inter(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4B53E).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Color(0xFFE4B53E), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, String time, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        width: 250,
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE4B53E) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: AppTheme.inter(color: isMe ? Colors.black : Colors.white70, fontSize: 13, height: 1.4)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(time, style: AppTheme.inter(color: isMe ? Colors.black54 : Colors.white38, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
