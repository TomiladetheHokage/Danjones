import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/wallet.dart';
import '../theme/app_theme.dart';

class ReceiveScreen extends StatelessWidget {
  final Wallet wallet;

  const ReceiveScreen({super.key, required this.wallet});

  String get _address => wallet.address.isNotEmpty ? wallet.address : '—';

  String get _truncatedAddress {
    if (_address.length <= 16) return _address;
    return '${_address.substring(0, 8)}...${_address.substring(_address.length - 6)}';
  }

  void _copyAddress(BuildContext context) {
    if (wallet.address.isEmpty) return;
    Clipboard.setData(ClipboardData(text: wallet.address));
    _showCopiedToast(context);
  }

  void _showCopiedToast(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: const Color(0xFFE4B53E).withValues(alpha: 0.3)),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE4B53E).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFFE4B53E),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Address copied',
                  style: AppTheme.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _truncatedAddress,
                  style: AppTheme.inter(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symbol = wallet.currency.symbol.toUpperCase();
    final imageUrl = wallet.currency.fullImageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Receive',
          style: AppTheme.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildWarningBanner(symbol),
                    const SizedBox(height: 36),
                    _buildQrCard(imageUrl, symbol),
                    const SizedBox(height: 28),
                    _buildAddressField(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  // ── Warning banner ────────────────────────────────────────────────────────
  Widget _buildWarningBanner(String symbol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFE4B53E),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Only send $symbol to this address. Sending any other asset may result in permanent loss.',
              style: AppTheme.inter(
                color: Colors.white60,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── QR card ───────────────────────────────────────────────────────────────
  Widget _buildQrCard(String imageUrl, String symbol) {
    return Column(
      children: [
        // Token identity row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: ClipOval(
                child: imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.token,
                          color: Colors.white24,
                          size: 20,
                        ),
                      )
                    : const Icon(Icons.token, color: Colors.white24, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              symbol,
              style: AppTheme.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Address',
              style: AppTheme.inter(fontSize: 15, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // QR code container
        Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE4B53E).withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          child: _QrPlaceholder(address: wallet.address),
        ),
      ],
    );
  }

  // ── Address field ─────────────────────────────────────────────────────────
  Widget _buildAddressField(BuildContext context) {
    return GestureDetector(
      onTap: () => _copyAddress(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _address,
                style: AppTheme.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _copyAddress(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4B53E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  color: Color(0xFFE4B53E),
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom button ─────────────────────────────────────────────────────────
  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFF3C756), Color(0xFFB88A2D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Confirm',
            style: AppTheme.inter(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Real QR code using qr_flutter ─────────────────────────────────────────────
class _QrPlaceholder extends StatelessWidget {
  final String address;

  const _QrPlaceholder({required this.address});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: address.isEmpty ? 'placeholder' : address,
      version: QrVersions.auto,
      size: 188,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF0D0D0D),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF0D0D0D),
      ),
    );
  }
}
