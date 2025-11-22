// lib/services/configuration_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class UserUpdateRequest {
  final String name;
  final String email;
  final Map<String, dynamic> preferences;

  UserUpdateRequest({
    required this.name,
    required this.email,
    this.preferences = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'preferences': preferences,
    };
  }
}

class ConsentUpdateRequest {
  final bool marketingConsent;
  final bool dataProcessingConsent;
  final bool termsAccepted;

  ConsentUpdateRequest({
    required this.marketingConsent,
    required this.dataProcessingConsent,
    required this.termsAccepted,
  });

  Map<String, dynamic> toJson() {
    return {
      'marketingConsent': marketingConsent,
      'dataProcessingConsent': dataProcessingConsent,
      'termsAccepted': termsAccepted,
    };
  }
}

class ConsentSettings {
  final bool marketingConsent;
  final bool dataProcessingConsent;
  final bool termsAccepted;

  ConsentSettings({
    required this.marketingConsent,
    required this.dataProcessingConsent,
    required this.termsAccepted,
  });

  factory ConsentSettings.fromJson(Map<String, dynamic> json) {
    return ConsentSettings(
      marketingConsent: json['marketingConsent'] as bool,
      dataProcessingConsent: json['dataProcessingConsent'] as bool,
      termsAccepted: json['termsAccepted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marketingConsent': marketingConsent,
      'dataProcessingConsent': dataProcessingConsent,
      'termsAccepted': termsAccepted,
    };
  }
}

class ConfigurationService {
  final String _baseUrl = dotenv.env['API_BASE_URL']!;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt_token');

    if (token != null) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };
    } else {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
      };
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('$_baseUrl/api/auth/logout');
    final headers = await _getAuthHeaders();

    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Success - token will be invalidated on backend
      return;
    } else {
      throw Exception('Failed to logout: ${response.statusCode}');
    }
  }

  Future<UserProfile> updateProfile(UserUpdateRequest request) async {
    final url = Uri.parse('$_baseUrl/api/user/profile');
    final headers = await _getAuthHeaders();
    final body = jsonEncode(request.toJson());

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data);
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

  Future<ConsentSettings> updateConsent(ConsentUpdateRequest request) async {
    final url = Uri.parse('$_baseUrl/api/user/consent');
    final headers = await _getAuthHeaders();
    final body = jsonEncode(request.toJson());

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ConsentSettings.fromJson(data);
    } else {
      throw Exception('Failed to update consent: ${response.statusCode}');
    }
  }
}
