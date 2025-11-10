// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
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

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    final body = jsonEncode(data);
    return http.post(url, headers: headers, body: body);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    final body = jsonEncode(data);
    return http.put(url, headers: headers, body: body);
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    return http.delete(url, headers: headers);
  }

  // ==================== COGNITIVE ACTIVITIES ====================

  // Statistics
  Future<http.Response> getCognitiveStats() async {
    return get('/cognitive-activities/stats');
  }

  // Reading Activities
  Future<http.Response> getReadingActivities() async {
    return get('/cognitive-activities/reading');
  }

  Future<http.Response> createReadingActivity(Map<String, dynamic> data) async {
    return post('/cognitive-activities/reading', data);
  }

  Future<http.Response> updateReadingActivity(int id, Map<String, dynamic> data) async {
    return put('/cognitive-activities/reading/$id', data);
  }

  Future<http.Response> deleteReadingActivity(int id) async {
    return delete('/cognitive-activities/reading/$id');
  }

  // Crossword Activities
  Future<http.Response> getCrosswordActivities() async {
    return get('/cognitive-activities/crosswords');
  }

  Future<http.Response> createCrosswordActivity(Map<String, dynamic> data) async {
    return post('/cognitive-activities/crosswords', data);
  }

  Future<http.Response> updateCrosswordActivity(int id, Map<String, dynamic> data) async {
    return put('/cognitive-activities/crosswords/$id', data);
  }

  Future<http.Response> deleteCrosswordActivity(int id) async {
    return delete('/cognitive-activities/crosswords/$id');
  }

  // Movie Activities
  Future<http.Response> getMovieActivities() async {
    return get('/cognitive-activities/movies');
  }

  Future<http.Response> createMovieActivity(Map<String, dynamic> data) async {
    return post('/cognitive-activities/movies', data);
  }

  Future<http.Response> updateMovieActivity(int id, Map<String, dynamic> data) async {
    return put('/cognitive-activities/movies/$id', data);
  }

  Future<http.Response> deleteMovieActivity(int id) async {
    return delete('/cognitive-activities/movies/$id');
  }

  // ==================== PHYSICAL EXERCISES ====================

  // Walking Sessions
  Future<http.Response> startWalkingSession(Map<String, dynamic> data) async {
    return post('/physical-exercises/walking/start', data);
  }

  Future<http.Response> endWalkingSession(int id, Map<String, dynamic> data) async {
    return put('/physical-exercises/walking/$id/end', data);
  }

  Future<http.Response> getActiveWalkingSession() async {
    return get('/physical-exercises/walking/active');
  }

  Future<http.Response> getAllWalkingSessions() async {
    return get('/physical-exercises/walking');
  }

  Future<http.Response> getWalkingSessionsByDateRange(String startDate, String endDate) async {
    return get('/physical-exercises/walking/range?startDate=$startDate&endDate=$endDate');
  }

  Future<http.Response> deleteWalkingSession(int id) async {
    return delete('/physical-exercises/walking/$id');
  }

  // Physical Activities
  Future<http.Response> createPhysicalActivity(Map<String, dynamic> data) async {
    return post('/physical-exercises/activities', data);
  }

  Future<http.Response> updatePhysicalActivity(int id, Map<String, dynamic> data) async {
    return put('/physical-exercises/activities/$id', data);
  }

  Future<http.Response> getAllPhysicalActivities() async {
    return get('/physical-exercises/activities');
  }

  Future<http.Response> getPhysicalActivitiesByDateRange(String startDate, String endDate) async {
    return get('/physical-exercises/activities/range?startDate=$startDate&endDate=$endDate');
  }

  Future<http.Response> deletePhysicalActivity(int id) async {
    return delete('/physical-exercises/activities/$id');
  }

  // Daily Exercise Goals
  Future<http.Response> getTodayExerciseGoal() async {
    return get('/physical-exercises/goals/today');
  }

  Future<http.Response> updateDailyExerciseGoal(Map<String, dynamic> data) async {
    return put('/physical-exercises/goals', data);
  }

  Future<http.Response> getWeeklyExerciseSummary() async {
    return get('/physical-exercises/summary/weekly');
  }
}
