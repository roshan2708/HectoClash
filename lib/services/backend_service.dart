import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendService {
  static const String baseUrl = 'http://localhost:8080'; // Replace with your Go server URL

  static Future<bool> signup(String userId, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'password': password}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> login(String userId, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'password': password}),
    );
    return response.statusCode == 200;
  }

  static Future<void> updateUserSettings(String userId, String avatar) async {
    await http.post(
      Uri.parse('$baseUrl/settings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'avatar': avatar}),
    );
  }
  // under process to link

  static Future<String?> startMatch(String userId, String mode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/start-match'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'mode': mode}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['matchId'];
    return null;
  }

  static Future<void> submitBattleResult(String matchId, String userId, bool won, int timeTaken) async {
    await http.post(
      Uri.parse('$baseUrl/submit-battle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'matchId': matchId, 'userId': userId, 'won': won, 'timeTaken': timeTaken}),
    );
  }

  static Future<void> endMatch(String matchId, String userId, int ratings, int totalTime, double accuracy) async {
    await http.post(
      Uri.parse('$baseUrl/end-match'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'matchId': matchId, 'userId': userId, 'ratings': ratings, 'totalTime': totalTime, 'accuracy': accuracy}),
    );
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await http.get(Uri.parse('$baseUrl/leaderboard'));
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }
}