import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/crypto_asset.dart';
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
}
