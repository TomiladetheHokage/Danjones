import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class P2PChatScreen extends StatelessWidget {
  final int tradeId;
  final double fiatAmount;
  final double cryptoAmount;
  final String currencySymbol;
  final String counterpartyName;
  final String? counterpartyAvatar;
  final bool isBuyer;
  final DateTime? createdAt;

  const P2PChatScreen({
    super.key,
    required this.tradeId,
    required this.fiatAmount,
    required this.cryptoAmount,
    required this.currencySymbol,
    required this.counterpartyName,
    this.counterpartyAvatar,
    required this.isBuyer,
    this.createdAt,
  });

  String _formatNaira(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final buffer = StringBuffer();

    for (int i = 0; i < whole.length; i++) {
      final reversedIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return 'N${buffer.toString()}.${parts[1]}';
  }

  String _formatCrypto(double amount) {
    return '${amount.toStringAsFixed(8)} $currencySymbol';
  }

  String _formatTimeLeft() {
    if (createdAt == null) return '--:--';
    final remaining = 900 - DateTime.now().difference(createdAt!).inSeconds;
    final clamped = remaining.clamp(0, 900);
    final mins = clamped ~/ 60;
    final secs = clamped % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDayLabel() {
    final source = createdAt ?? DateTime.now();
    final now = DateTime.now();
    if (source.year == now.year && source.month == now.month && source.day == now.day) {
      return 'Today';
    }
    return '${source.day}/${source.month}/${source.year}';
  }

  String _formatCreatedTime() {
    final source = createdAt ?? DateTime.now();
    final hour = source.hour % 12 == 0 ? 12 : source.hour % 12;
    final minute = source.minute.toString().padLeft(2, '0');
    final suffix = source.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String get _counterpartyHandle {
    final trimmed = counterpartyName.trim();
    if (trimmed.startsWith('@')) return trimmed;
    return '@$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order #$tradeId', style: AppTheme.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
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
                    Text(isBuyer ? 'Buying' : 'Selling', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                    Text(_formatCrypto(cryptoAmount), style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('Total Cost', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                    Text(_formatNaira(fiatAmount), style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Time Left', style: AppTheme.inter(color: Colors.white54, fontSize: 11)),
                    Text(_formatTimeLeft(), style: AppTheme.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(counterpartyName, style: AppTheme.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            '${isBuyer ? 'Seller' : 'Buyer'} $_counterpartyHandle',
                            style: AppTheme.inter(color: const Color(0xFFE4B53E), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.more_vert, color: Colors.white54), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 24),
                Center(child: Text(_formatDayLabel(), style: AppTheme.inter(color: Colors.white38, fontSize: 11))),
                const SizedBox(height: 16),
                Center(child: Text('Order created at ${_formatCreatedTime()}.', style: AppTheme.inter(color: Colors.white38, fontSize: 11))),
                const SizedBox(height: 24),
                _buildMessageBubble('Do not include crypto-related terms (e.g., BTC, USDT) in the transfer remarks.', _formatCreatedTime(), false),
                _buildSystemNote('Live chat messages are not available from the API yet. Trade details on this screen are now pulled from the active order.'),
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
                        hintText: 'Type a message...',
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

  Widget _buildAvatar() {
    if (counterpartyAvatar != null && counterpartyAvatar!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          ApiService.resolveUrl(counterpartyAvatar!) ?? counterpartyAvatar!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
        ),
      );
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    final initial = counterpartyName.isNotEmpty ? counterpartyName.substring(0, 1).toUpperCase() : '?';
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E1E1E)),
      alignment: Alignment.center,
      child: Text(initial, style: AppTheme.inter(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSystemNote(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTheme.inter(color: Colors.white38, fontSize: 11, height: 1.4),
        ),
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
