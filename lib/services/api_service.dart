import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_profile.dart';
import '../models/currency.dart';
import '../models/dashboard_data.dart';
import '../models/wallet.dart';
import '../models/p2p_ad.dart';
import '../models/p2p_trade.dart';

class ApiService {
  // Flutterwave Config
  static const String flutterwavePublicKey = 'FLWPUBK_TEST-3b5ec17c93e55e610961fa3b4295dec2-X';
  static const String flutterwaveBaseUrl = 'https://api.flutterwave.com/v3';

  // Production API Base URL
  static const String liveRoot = 'https://api.danjones.ng';
  static const String liveUrl = '$liveRoot/api';
  
  // Local Proxy URL (for bypassing CORS during Web development)
  static const String localRoot = 'http://localhost:3000';
  static const String localUrl = '$localRoot/api';

  static String get rootUrl {
    if (kIsWeb && kDebugMode) {
      return localRoot;
    }
    return liveRoot;
  }

  static String get baseUrl {
    if (kIsWeb && kDebugMode) {
      return localUrl;
    }
    return liveUrl;
  }

  static const _storage = FlutterSecureStorage();
  
  
  static String? authToken;

  static Future<void> initToken() async {
    authToken = await _storage.read(key: 'auth_token');
  }

  static Future<void> logout() async {
    authToken = null;
    await _storage.delete(key: 'auth_token');
  }

  // Helper for detailed error handling as requested
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFn, {
    String? requestName,
  }) async {
    try {
      final response = await requestFn().timeout(const Duration(seconds: 15));
      return response;
    } on SocketException catch (e) {
      debugPrint('API SOCKET ERROR [$requestName]: $e');
      throw Exception('No internet connection. Please check your network and try again.');
    } on TimeoutException catch (e) {
      debugPrint('API TIMEOUT [$requestName]: $e');
      throw Exception('Request timed out. Please check your connection and try again.');
    } catch (e) {
      debugPrint('API UNEXPECTED ERROR [$requestName]: $e');
      // Web connection/CORS errors surface as generic exceptions — keep the
      // dev-facing detail in debug mode only; show a friendly message in production.
      if (e.toString().contains('Failed to fetch') || e.toString().contains('XMLHttpRequest')) {
        if (kDebugMode) {
          throw Exception('Server unreachable. Please ensure the backend is running and CORS is enabled.');
        }
        throw Exception('No internet connection. Please check your network and try again.');
      }
      throw Exception('Something went wrong. Please try again later.');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? refCode,
  }) async {
    // Avoid carrying over a stale token from a previous session.
    authToken = null;
    await _storage.delete(key: 'auth_token');

    final response = await _makeRequest(
      () async {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/register'))
          ..headers['Accept'] = 'application/json'
          ..fields['name'] = name
          ..fields['email'] = email
          ..fields['password'] = password
          ..fields['phone'] = phone;

        if (refCode != null && refCode.isNotEmpty) {
          request.fields['ref_code'] = refCode;
        }

        final streamedResponse = await request.send();
        return await http.Response.fromStream(streamedResponse);
      },
      requestName: 'REGISTER',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final success = data['success'] == true || data['success'] == 'true' || !data.containsKey('success');
      if (success) {
        final token = (data['token'] ?? data['access_token'])?.toString();
        if (token == null || token.isEmpty) {
          throw Exception('Authentication token missing in register response.');
        }

        authToken = token;
        await _storage.write(key: 'auth_token', value: token);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to register');
      }
    } else {
      String errMsg = data['message'] ?? data['error'] ?? 'Server error (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Always reset previous auth before a new login attempt.
    authToken = null;
    await _storage.delete(key: 'auth_token');

    final response = await _makeRequest(
      () async {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/login'))
          ..headers['Accept'] = 'application/json'
          ..fields['email'] = email
          ..fields['password'] = password;

        final streamedResponse = await request.send();
        return await http.Response.fromStream(streamedResponse);
      },
      requestName: 'LOGIN',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final success = data['success'] == true || data['success'] == 'true' || !data.containsKey('success');
      if (success) {
        final token = (data['token'] ?? data['access_token'])?.toString();
        if (token == null || token.isEmpty) {
          throw Exception('Authentication token missing in login response.');
        }

        authToken = token;
        await _storage.write(key: 'auth_token', value: token);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to login');
      }
    } else {
      String errMsg = data['message'] ?? data['error'] ?? 'Server error (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  static Future<UserProfile> getUserProfile() async {
    final response = await _makeRequest(
      () => http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      requestName: 'GET_PROFILE',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return UserProfile.fromJson(data);
    } else {
      throw Exception('Failed to load user profile (${response.statusCode})');
    }
  }

  static Future<DashboardData> getDashboardData() async {
    final response = await _makeRequest(
      () => http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      requestName: 'GET_DASHBOARD',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return DashboardData.fromJson(data);
    } else {
      throw Exception('Failed to load dashboard data (${response.statusCode})');
    }
  }

  static Future<List<Currency>> getCurrencies() async {
    final response = await _makeRequest(
      () => http.get(
        Uri.parse('$baseUrl/wallets/currencies'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      requestName: 'GET_CURRENCIES',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['currencies'] != null) {
        final List<dynamic> currenciesJson = data['currencies'];
        return currenciesJson.map((json) => Currency.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load currencies (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> createP2pAd({
    required int currencyId,
    required String type,
    required double price,
    required double totalAmount,
    required double minLimit,
    required double maxLimit,
    required String terms,
  }) async {
    final response = await _makeRequest(
      () => http.post(
        Uri.parse('$baseUrl/p2p/create-ads'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          "currency_id": currencyId,
          "type": type,
          "price": price,
          "total_amount": totalAmount,
          "min_limit": minLimit,
          "max_limit": maxLimit,
          "terms": terms,
        }),
      ),
      requestName: 'CREATE_P2P_AD',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to create ad');
      }
      return data;
    } else {
      String errMsg = data['message'] ?? data['error'] ?? 'Server error (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  static Future<List<P2PAd>> getP2pAds() async {
    final response = await _makeRequest(
      () => http.get(
        Uri.parse('$baseUrl/p2p/ads'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      requestName: 'GET_P2P_ADS',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final List<dynamic> adsJson = data['ads'] ?? [];
      return adsJson.map((json) => P2PAd.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load P2P ads (${response.statusCode})');
    }
  }

  static Future<List<P2PTrade>> getMyP2pTrades() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final primaryUri = Uri.parse('$baseUrl/p2p/my-trades').replace(
      queryParameters: {'t': now},
    );

    Future<http.Response> fetch(Uri uri) {
      return http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );
    }

    http.Response response;
    try {
      response = await _makeRequest(
        () => fetch(primaryUri),
        requestName: 'GET_MY_P2P_TRADES',
      );
    } catch (_) {
      // Web debug often uses a local proxy that may not always be running.
      // If that fails, retry directly against live API.
      if (baseUrl == liveUrl) rethrow;

      final fallbackUri = Uri.parse('$liveUrl/p2p/my-trades').replace(
        queryParameters: {'t': now},
      );
      response = await _makeRequest(
        () => fetch(fallbackUri),
        requestName: 'GET_MY_P2P_TRADES_FALLBACK',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tradesJson = data['trades'] as List<dynamic>? ?? [];
      return tradesJson
          .whereType<Map<String, dynamic>>()
          .map(P2PTrade.fromJson)
          .toList();
    } else {
      throw Exception('Failed to load trades (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> initiateP2pTrade({
    required int advertisementId,
    required double amount,
  }) async {
    final response = await _makeRequest(
      () => http.post(
        Uri.parse('$baseUrl/p2p/initiate-trade'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'advertisement_id': advertisementId,
          'amount': amount,
        }),
      ),
      requestName: 'INITIATE_P2P_TRADE',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errMsg = data['message'] ?? data['error'] ?? 'Server error (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  static Future<Map<String, dynamic>> markP2pTradePaid({
    required int tradeId,
  }) async {
    final response = await _makeRequest(
      () => http.post(
        Uri.parse('$baseUrl/p2p/trades/$tradeId/pay'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      requestName: 'MARK_P2P_TRADE_PAID',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errMsg = data['message'] ?? data['error'] ?? 'Server error (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  static Future<Map<String, dynamic>> cancelP2pTrade({
    required int tradeId,
  }) async {
    final response = await _makeRequest(
      () => http.post(
        Uri.parse('$baseUrl/p2p/trades/$tradeId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      requestName: 'CANCEL_P2P_TRADE',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errMsg = data['message'] ?? data['error'] ?? 'Server error (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  static Future<Map<String, dynamic>> closeP2pAd({
    required int adId,
  }) async {
    final response = await _makeRequest(
      () => http.post(
        Uri.parse('$baseUrl/p2p/close-ads/$adId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      requestName: 'CLOSE_P2P_AD',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errMsg = data['message'] ?? data['error'] ?? 'Server error (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  // ==========================================
  // WALLET CREATION
  // ==========================================

  // Creates a wallet for the given currency. Returns the new Wallet object.
  static Future<Wallet> createWallet({required int currencyId}) async {
    final response = await _makeRequest(
      () => http.post(
        Uri.parse('$baseUrl/wallets/create'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'currency_id': currencyId}),
      ),
      requestName: 'CREATE_WALLET',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final walletJson = data['wallet'] as Map<String, dynamic>?;
      if (walletJson == null) throw Exception('Wallet data missing in response.');
      return Wallet.fromJson(walletJson);
    } else {
      final errMsg = data['message'] ?? data['error'] ?? 'Failed to create wallet (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  // ==========================================
  // SEND FEE
  // ==========================================

  // Returns fee info for a withdrawal. Response includes fee, fee_usd, rate_usd, is_high_fee, max_fee_usd.
  static Future<Map<String, dynamic>> getSendFee({
    required int currencyId,
    required double amount,
  }) async {
    final uri = Uri.parse('$baseUrl/wallets/send-fee').replace(
      queryParameters: {
        'currency_id': currencyId.toString(),
        'amount': amount.toString(),
      },
    );

    final response = await _makeRequest(
      () => http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      requestName: 'GET_SEND_FEE',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data as Map<String, dynamic>;
    } else {
      final errMsg = data['message'] ?? data['error'] ?? 'Failed to fetch fee (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  // ==========================================
  // FLUTTERWAVE DEPOSIT
  // ==========================================

  // Create a virtual account for deposit
  // NOTE: This endpoint typically requires a Secret Key. If public key fails, use Secret Key.
  static Future<Map<String, dynamic>> initiateFlutterwaveDeposit({
    required String email,
    required double amount,
    required String txRef,
  }) async {
    final response = await _makeRequest(
      () => http.post(
        Uri.parse('$flutterwaveBaseUrl/virtual-account-numbers'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $flutterwavePublicKey',
        },
        body: jsonEncode({
          "email": email,
          "is_permanent": false,
          "amount": amount,
          "tx_ref": txRef,
          "narration": "Wallet deposit",
          "frequency": 1
        }),
      ),
      requestName: 'FLW_INITIATE_DEPOSIT',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data['status'] == 'success') {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to initiate deposit');
      }
    } else {
      String errMsg = data['message'] ?? 'Flutterwave error (${response.statusCode})';
      throw Exception(errMsg);
    }
  }

  // Verify deposit on our backend
  static Future<Map<String, dynamic>> verifyFlutterwaveDeposit({
    required String reference,
  }) async {
    final response = await _makeRequest(
      () => http.post(
        Uri.parse('$baseUrl/wallets/deposit/flutterwave/verify'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          "reference": reference,
        }),
      ),
      requestName: 'FLW_VERIFY_DEPOSIT',
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      String errMsg = data['message'] ?? data['error'] ?? 'Verification failed (${response.statusCode})';
      throw Exception(errMsg);
    }
  }
}
