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

  Future<String?> _getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<http.Response> getCognitiveStats() async {
    return get('/cognitive-activities/stats');
  }

  Future<http.Response> getReadingActivities() async {
    return get('/cognitive-activities/reading');
  }

  Future<http.Response> createReadingActivity(Map<String, dynamic> data) async {
    return post('/cognitive-activities/reading', data);
  }

  Future<http.Response> updateReadingActivity(
      int id, Map<String, dynamic> data) async {
    return put('/cognitive-activities/reading/$id', data);
  }

  Future<http.Response> deleteReadingActivity(int id) async {
    return delete('/cognitive-activities/reading/$id');
  }

  Future<http.Response> getCrosswordActivities() async {
    return get('/cognitive-activities/crosswords');
  }

  Future<http.Response> createCrosswordActivity(
      Map<String, dynamic> data) async {
    return post('/cognitive-activities/crosswords', data);
  }

  Future<http.Response> updateCrosswordActivity(
      int id, Map<String, dynamic> data) async {
    return put('/cognitive-activities/crosswords/$id', data);
  }

  Future<http.Response> deleteCrosswordActivity(int id) async {
    return delete('/cognitive-activities/crosswords/$id');
  }

  Future<http.Response> getMovieActivities() async {
    return get('/cognitive-activities/movies');
  }

  Future<http.Response> createMovieActivity(Map<String, dynamic> data) async {
    return post('/cognitive-activities/movies', data);
  }

  Future<http.Response> updateMovieActivity(
      int id, Map<String, dynamic> data) async {
    return put('/cognitive-activities/movies/$id', data);
  }

  Future<http.Response> deleteMovieActivity(int id) async {
    return delete('/cognitive-activities/movies/$id');
  }

  Future<http.Response> startWalkingSession() async {
    return post('/physical-exercises/walking/start', {});
  }

  Future<http.Response> endWalkingSession(
      int id, Map<String, dynamic> data) async {
    return put('/physical-exercises/walking/$id/end', data);
  }

  Future<http.Response> getActiveWalkingSession() async {
    return get('/physical-exercises/walking/active');
  }

  Future<http.Response> getAllWalkingSessions() async {
    return get('/physical-exercises/walking');
  }

  Future<http.Response> getWalkingSessionsByDateRange(
      String startDate, String endDate) async {
    return get(
        '/physical-exercises/walking/range?startDate=$startDate&endDate=$endDate');
  }

  Future<http.Response> deleteWalkingSession(int id) async {
    return delete('/physical-exercises/walking/$id');
  }

  Future<http.Response> createPhysicalActivity(
      Map<String, dynamic> data) async {
    return post('/physical-exercises/activities', data);
  }

  Future<http.Response> updatePhysicalActivity(
      int id, Map<String, dynamic> data) async {
    return put('/physical-exercises/activities/$id', data);
  }

  Future<http.Response> getAllPhysicalActivities() async {
    return get('/physical-exercises/activities');
  }

  Future<http.Response> getPhysicalActivitiesByDateRange(
      String startDate, String endDate) async {
    return get(
        '/physical-exercises/activities/range?startDate=$startDate&endDate=$endDate');
  }

  Future<http.Response> deletePhysicalActivity(int id) async {
    return delete('/physical-exercises/activities/$id');
  }

  Future<http.Response> getTodayExerciseGoal() async {
    return get('/physical-exercises/goals/today');
  }

  Future<http.Response> updateDailyExerciseGoal(
      Map<String, dynamic> data) async {
    return put('/physical-exercises/goals', data);
  }

  Future<http.Response> getWeeklyExerciseSummary() async {
    return get('/physical-exercises/summary/weekly');
  }

  Future<http.Response> getUserStatistics() async {
    final userId = await _getUserId();
    return get('/user/$userId/statistics');
  }

  Future<http.Response> logout() async {
    return post('/logout', {});
  }

  Future<http.Response> getUserMe() async {
    return get('/user/profile');
  }

  Future<http.Response> updateUserConsent({
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final url = Uri.parse('$_baseUrl/api/users/$userId/consent');

    return http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> updateUserProfile({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    return put('/api/users/$userId/profile', data);
  }

  Future<http.Response> getUserStats() async {
    return get('/api/stats/user-stats');
  }

  Future<http.Response> getWeeklyProgress() async {
    return get('/api/stats/weekly-progress');
  }

  Future<http.Response> logoutUser() async {
    return post('/api/auth/logout', {});
  }

  Future<http.Response> updateUserProfileNew(Map<String, dynamic> data) async {
    return put('/user/profile', data);
  }

  Future<http.Response> updateUserConsentNew(Map<String, dynamic> data) async {
    return put('/api/user/consent', data);
  }

  Future<http.Response> getDiaryEntries(String date) async {
    return get('/api/diary/entries?date=$date');
  }

  Future<http.Response> createDiaryEntry(Map<String, dynamic> data) async {
    return post('/api/diary/entries', data);
  }

  Future<http.Response> updateDiaryEntry(
      int id, Map<String, dynamic> data) async {
    return put('/api/diary/entries/$id', data);
  }

  Future<http.Response> deleteDiaryEntry(int id) async {
    return delete('/api/diary/entries/$id');
  }

  Future<http.Response> sendDailyReport({required int userId}) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$_baseUrl/wellness-diary/daily-report');

    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'date': DateTime.now().toIso8601String().split('T')[0],
      }),
    );
  }

  Future<http.Response> previewDailyReport({required int userId}) async {
    final token = await _storage.read(key: 'jwt_token');

    final url = Uri.parse('$_baseUrl/wellness-diary/daily-report');

    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
