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

class ApiService {
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

  /// Helper for detailed error handling as requested
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFn, {
    String? requestName,
  }) async {
    try {
      final response = await requestFn().timeout(const Duration(seconds: 15));
      return response;
    } on SocketException catch (e) {
      debugPrint('API SOCKET ERROR [$requestName]: $e');
      throw Exception('Connection failed. Please check your internet or server status.');
    } on TimeoutException catch (e) {
      debugPrint('API TIMEOUT [$requestName]: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('API UNEXPECTED ERROR [$requestName]: $e');
      // On web, CORS or connection errors often manifest as generic exceptions including the URI.
      // We catch them here and provide a cleaner message for the user.
      if (e.toString().contains('Failed to fetch') || e.toString().contains('XMLHttpRequest')) {
        throw Exception('Server unreachable. Please ensure the backend is running and CORS is enabled.');
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
      if (data['success'] == true) {
        final token = data['token'];
        if (token != null) {
          authToken = token;
          await _storage.write(key: 'auth_token', value: token);
        }
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
      if (data['success'] == true) {
        final token = data['token'];
        if (token != null) {
          authToken = token;
          await _storage.write(key: 'auth_token', value: token);
        }
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
}
