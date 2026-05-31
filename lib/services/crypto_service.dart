import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/crypto_asset.dart';
import '../widgets/interactive_chart/candle_data.dart';

class CryptoService {
  // ── CoinGecko endpoints ────────────────────────────────────────────────────
  static const String _marketsUrl =
      'https://api.coingecko.com/api/v3/coins/markets'
      '?vs_currency=usd'
      '&order=market_cap_desc'
      '&per_page=100'
      '&page=1'
      '&sparkline=true'
      '&price_change_percentage=24h';

  static const String _trendingUrl =
      'https://api.coingecko.com/api/v3/search/trending';

  // ── In-memory cache ────────────────────────────────────────────────────────
  /// Raw JSON list from /coins/markets — kept so we can filter by 'id' field
  /// for trending without touching the CryptoAsset model.
  static List<Map<String, dynamic>>? _cachedRawMarkets;

  /// Parsed [CryptoAsset] list derived from [_cachedRawMarkets].
  static List<CryptoAsset>? _cachedMarkets;

  // ── Single shared fetch ────────────────────────────────────────────────────
  /// Fetches /coins/markets once and caches the result in-memory.
  /// All subsequent calls within the session return the cached list immediately.
  static Future<List<CryptoAsset>> fetchMarketsOnce() async {
    if (_cachedMarkets != null && _cachedRawMarkets != null) {
      debugPrint(
          'CryptoService: returning cached markets (${_cachedMarkets!.length} coins)');
      return _cachedMarkets!;
    }

    debugPrint('CryptoService: fetching /coins/markets…');
    final response = await http
        .get(Uri.parse(_marketsUrl), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List<dynamic> raw = jsonDecode(response.body);
      _cachedRawMarkets =
          raw.map((e) => e as Map<String, dynamic>).toList();
      _cachedMarkets =
          _cachedRawMarkets!.map(CryptoAsset.fromJson).toList();
      debugPrint(
          'CryptoService: cached ${_cachedMarkets!.length} coins from CoinGecko');
      return _cachedMarkets!;
    } else if (response.statusCode == 429) {
      throw Exception('Rate limited by CoinGecko. Please wait a moment.');
    } else {
      throw Exception(
          'Failed to load market data (${response.statusCode})');
    }
  }

  /// Invalidates the in-memory cache so the next call re-fetches from network.
  static void invalidateCache() {
    _cachedRawMarkets = null;
    _cachedMarkets = null;
    debugPrint('CryptoService: cache invalidated');
  }

  // ── Derived sorted lists ───────────────────────────────────────────────────
  /// Returns all coins sorted by 24h price change descending (top gainers).
  /// Uses the shared [fetchMarketsOnce] cache — no extra network call.
  static Future<List<CryptoAsset>> getTopMovers() async {
    final markets = await fetchMarketsOnce();
    final sorted = List<CryptoAsset>.from(markets)
      ..sort((a, b) =>
          b.priceChangePercent.compareTo(a.priceChangePercent));
    return sorted;
  }

  /// Returns all coins sorted by 24h price change ascending (top losers).
  /// Uses the shared [fetchMarketsOnce] cache — no extra network call.
  static Future<List<CryptoAsset>> getTopLosers() async {
    final markets = await fetchMarketsOnce();
    final sorted = List<CryptoAsset>.from(markets)
      ..sort((a, b) =>
          a.priceChangePercent.compareTo(b.priceChangePercent));
    return sorted;
  }

  // ── Trending / New Coins ───────────────────────────────────────────────────
  /// Fetches trending coin IDs from /search/trending, then filters the cached
  /// raw markets list to return matching [CryptoAsset] objects.
  /// Falls back to a targeted /coins/markets call if the cache has no matches.
  static Future<List<CryptoAsset>> fetchTrendingCoins() async {
    // 1. Get trending coin IDs from /search/trending
    final trendingResponse = await http
        .get(Uri.parse(_trendingUrl), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (trendingResponse.statusCode != 200) {
      if (trendingResponse.statusCode == 429) {
        throw Exception('Rate limited by CoinGecko. Please wait a moment.');
      }
      throw Exception(
          'Failed to load trending data (${trendingResponse.statusCode})');
    }

    final trendingJson =
        jsonDecode(trendingResponse.body) as Map<String, dynamic>;
    final trendingCoins =
        (trendingJson['coins'] as List<dynamic>? ?? []);
    final trendingIds = trendingCoins
        .map((c) =>
            ((c as Map<String, dynamic>)['item']
                as Map<String, dynamic>)['id']
                ?.toString())
        .where((id) => id != null)
        .cast<String>()
        .toSet();

    debugPrint(
        'CryptoService: trending IDs = ${trendingIds.take(10).join(', ')}');

    // 2. Ensure the markets cache is warm
    await fetchMarketsOnce();

    // 3. Filter raw markets JSON by trending ID (avoids touching CryptoAsset model)
    final matched = _cachedRawMarkets!
        .where((json) =>
            trendingIds.contains(json['id']?.toString()))
        .map(CryptoAsset.fromJson)
        .toList();

    if (matched.isNotEmpty) {
      debugPrint(
          'CryptoService: ${matched.length} trending coins matched from cache');
      return matched;
    }

    // 4. Fallback: fetch the trending IDs directly from /coins/markets
    debugPrint(
        'CryptoService: cache miss — fetching trending coins from /coins/markets');
    final idsParam = trendingIds.take(20).join(',');
    final fallbackUrl =
        'https://api.coingecko.com/api/v3/coins/markets'
        '?vs_currency=usd'
        '&ids=$idsParam'
        '&order=market_cap_desc'
        '&per_page=20'
        '&page=1'
        '&sparkline=true'
        '&price_change_percentage=24h';

    final fallbackResponse = await http
        .get(Uri.parse(fallbackUrl), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (fallbackResponse.statusCode == 200) {
      final List<dynamic> raw = jsonDecode(fallbackResponse.body);
      return raw
          .map((e) => CryptoAsset.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          'Failed to load trending coin details (${fallbackResponse.statusCode})');
    }
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

  // ── OHLC candle data ───────────────────────────────────────────────────────
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

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
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

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final md = data['market_data'] as Map<String, dynamic>? ?? {};
      return {
        'market_cap':
            ((md['market_cap']?['usd']) as num?)?.toDouble() ?? 0.0,
        'circulating_supply':
            ((md['circulating_supply']) as num?)?.toDouble() ?? 0.0,
        'max_supply':
            ((md['max_supply']) as num?)?.toDouble() ?? 0.0,
        'current_price':
            ((md['current_price']?['usd']) as num?)?.toDouble() ?? 0.0,
        'price_change_24h':
            ((md['price_change_percentage_24h']) as num?)?.toDouble() ?? 0.0,
      };
    } else if (response.statusCode == 429) {
      throw Exception('Rate limited by CoinGecko. Please wait a moment.');
    } else {
      throw Exception('Failed to load coin details (${response.statusCode})');
    }
  }
}
