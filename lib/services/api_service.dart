import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_profile.dart';
import '../models/currency.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const _storage = FlutterSecureStorage();
  
  static String? authToken;

  static Future<void> initToken() async {
    authToken = await _storage.read(key: 'auth_token');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? refCode,
  }) async {
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
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
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
      String errMsg = 'Server error';
      try {
        final data = jsonDecode(response.body);
        errMsg = data['message'] ?? data['error'] ?? response.body;
      } catch (_) {
        errMsg = response.body;
      }
      throw Exception(errMsg);
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/login'))
      ..headers['Accept'] = 'application/json'
      ..fields['email'] = email
      ..fields['password'] = password;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
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
      String errMsg = 'Server error';
      try {
        final data = jsonDecode(response.body);
        errMsg = data['message'] ?? data['error'] ?? response.body;
      } catch (_) {
        errMsg = response.body;
      }
      throw Exception(errMsg);
    }
  }

  static Future<UserProfile> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return UserProfile.fromJson(data);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  static Future<List<Currency>> getCurrencies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallets/currencies'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['currencies'] != null) {
        final List<dynamic> currenciesJson = data['currencies'];
        return currenciesJson.map((json) => Currency.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load currencies');
    }
  }
}
