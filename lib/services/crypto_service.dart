import 'dart:convert';
import 'package:http/http.dart' as http;
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
          // Find matching symbol in CoinGecko
          final cgMatch = cgData.firstWhere(
            (json) => json['symbol'].toString().toLowerCase() == currency.symbol.toLowerCase(),
            orElse: () => null,
          );
          
          if (cgMatch != null) {
            final asset = CryptoAsset.fromJson(cgMatch);
            result.add(CryptoAsset(
              symbol: currency.symbol,
              name: currency.name,
              price: asset.price,
              priceChangePercent: asset.priceChangePercent,
              sparklineData: asset.sparklineData,
              imagePath: currency.fullImageUrl,
            ));
          } else {
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
}
