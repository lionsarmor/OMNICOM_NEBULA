import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // 👇 Use LAN IP instead of localhost if running on Android/iOS emulator
  static const String baseUrl = 'http://127.0.0.1:4000/api';
  // Example for LAN testing: 'http://192.168.1.150:4000/api';

  /// Register a new user
  static Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('🔹 [REGISTER] ${res.statusCode}: ${res.body}');

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception('Register failed: ${res.body}');
      }
    } on SocketException {
      throw Exception('❌ Network error: cannot connect to server');
    } catch (e) {
      print('⚠️ Register error: $e');
      rethrow;
    }
  }

  /// Login existing user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('🔹 [LOGIN] ${res.statusCode}: ${res.body}');

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception('Login failed: ${res.body}');
      }
    } on SocketException {
      throw Exception('❌ Network error: cannot connect to server');
    } catch (e) {
      print('⚠️ Login error: $e');
      rethrow;
    }
  }
}
