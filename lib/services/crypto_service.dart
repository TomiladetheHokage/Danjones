import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/crypto_asset.dart';
import '../widgets/interactive_chart/candle_data.dart';
import 'api_service.dart';

class CryptoService {
  static const String apiUrl =
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true&price_change_percentage=24h';

  /// Fetches currencies from backend and merges with CoinGecko pricing
  static Future<List<CryptoAsset>> fetchDashboardCurrencies() async {
    try {
      // Fetch backend currencies
      final backendCurrencies = await ApiService.getCurrencies();
      
      // Fetch CoinGecko prices
      final response = await http.get(Uri.parse('$apiUrl&per_page=100&page=1'));
      List<CryptoAsset> result = [];
      
      if (response.statusCode == 200) {
        final List<dynamic> cgData = jsonDecode(response.body);
        
        // Merge
        for (var currency in backendCurrencies) {
          // Skip Naira in the crypto list
          if (currency.symbol.toUpperCase() == 'NGN') continue;
          
          // Find matching symbol in CoinGecko
          final cgMatch = cgData.firstWhere(
            (json) => json['symbol'].toString().toLowerCase() == currency.symbol.toLowerCase(),
            orElse: () => null,
          );
          
          if (cgMatch != null) {
            final asset = CryptoAsset.fromJson(cgMatch);
            debugPrint('Matched ${currency.symbol} with CoinGecko data. Image: ${currency.fullImageUrl}');
            result.add(CryptoAsset(
              symbol: currency.symbol,
              name: currency.name,
              price: asset.price,
              priceChangePercent: asset.priceChangePercent,
              sparklineData: asset.sparklineData,
              imagePath: currency.fullImageUrl,
              marketCap: asset.marketCap,
              circulatingSupply: asset.circulatingSupply,
              maxSupply: asset.maxSupply,
            ));
          } else {
            debugPrint('No CoinGecko match for ${currency.symbol}. Using fallback. Image: ${currency.fullImageUrl}');
            // Provide sensible fallbacks if missing (e.g. for NGN or fiat)
            result.add(CryptoAsset(
              symbol: currency.symbol,
              name: currency.name,
              price: 1.0, 
              priceChangePercent: 0.0,
              sparklineData: [50.0, 50.0, 50.0],
              imagePath: currency.fullImageUrl,
            ));
          }
        }
        return result;
      } else {
        throw Exception('Failed to load crypto data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  static Future<List<CryptoAsset>> fetchTopMovers() async {
    return fetchDashboardCurrencies();
  }

  // ── CoinGecko coin ID lookup ───────────────────────────────────────────────
  /// Maps common ticker symbols to CoinGecko coin IDs.
  static const Map<String, String> _coinIdMap = {
    'btc': 'bitcoin',
    'eth': 'ethereum',
    'bnb': 'binancecoin',
    'sol': 'solana',
    'xrp': 'ripple',
    'ada': 'cardano',
    'matic': 'matic-network',
    'dot': 'polkadot',
    'doge': 'dogecoin',
    'avax': 'avalanche-2',
    'link': 'chainlink',
    'uni': 'uniswap',
    'ltc': 'litecoin',
    'atom': 'cosmos',
    'usdt': 'tether',
    'usdc': 'usd-coin',
    'trx': 'tron',
    'shib': 'shiba-inu',
  };

  static String coinIdForSymbol(String symbol) {
    return _coinIdMap[symbol.toLowerCase()] ?? symbol.toLowerCase();
  }

  // ── OHLC candle data ──────────────────────────────────────────────────────
  /// Fetches real OHLC candle data from CoinGecko.
  ///
  /// [days] controls the range: 1 = last 24h, 7 = last week, 30 = last month.
  /// CoinGecko returns candle intervals automatically based on [days]:
  ///   days=1  → 30-minute candles
  ///   days=7  → 4-hour candles
  ///   days=30 → 4-hour candles
  static Future<List<CandleData>> fetchOhlcCandles({
    required String symbol,
    required int days,
  }) async {
    final coinId = coinIdForSymbol(symbol);
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/$coinId/ohlc'
      '?vs_currency=usd&days=$days',
    );

    final response = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> raw = jsonDecode(response.body);
      // Each item: [timestamp_ms, open, high, low, close]
      return raw.map((item) {
        final list = item as List<dynamic>;
        return CandleData(
          timestamp: (list[0] as num).toInt(),
          open: (list[1] as num).toDouble(),
          high: (list[2] as num).toDouble(),
          low: (list[3] as num).toDouble(),
          close: (list[4] as num).toDouble(),
          volume: null,
        );
      }).toList();
    } else if (response.statusCode == 429) {
      throw Exception('Rate limited by CoinGecko. Please wait a moment.');
    } else {
      throw Exception('Failed to load chart data (${response.statusCode})');
    }
  }

  // ── Live coin detail (market info) ────────────────────────────────────────
  /// Returns fresh market_cap, circulating_supply, max_supply for a coin.
  static Future<Map<String, double>> fetchCoinMarketDetail({
    required String symbol,
  }) async {
    final coinId = coinIdForSymbol(symbol);
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/$coinId'
      '?localization=false&tickers=false&community_data=false&developer_data=false',
    );

    final response = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final md = data['market_data'] as Map<String, dynamic>? ?? {};
      return {
        'market_cap': ((md['market_cap']?['usd']) as num?)?.toDouble() ?? 0.0,
        'circulating_supply': ((md['circulating_supply']) as num?)?.toDouble() ?? 0.0,
        'max_supply': ((md['max_supply']) as num?)?.toDouble() ?? 0.0,
        'current_price': ((md['current_price']?['usd']) as num?)?.toDouble() ?? 0.0,
        'price_change_24h': ((md['price_change_percentage_24h']) as num?)?.toDouble() ?? 0.0,
      };
    } else if (response.statusCode == 429) {
      throw Exception('Rate limited by CoinGecko. Please wait a moment.');
    } else {
      throw Exception('Failed to load coin details (${response.statusCode})');
    }
  }
}
