import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Cambia esta IP por la de tu PC en la red local cuando pruebes en celular físico
  static const String baseUrl = 'http://172.16.122.141:8000/api';

  // ── Auth ─────────────────────────────────────────────────
  static Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access', data['access']);
      await prefs.setString('refresh', data['refresh']);
      await prefs.setString('username', username);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Usuario';
  }

  // ── Headers ───────────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── GET ───────────────────────────────────────────────────
  static Future<List<dynamic>> getList(String endpoint) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Error ${res.statusCode}: ${res.body}');
  }

  // ── POST ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body).toString());
  }

  // ── PUT ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> put(
      String endpoint, int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$endpoint$id/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body).toString());
  }

  // ── DELETE ────────────────────────────────────────────────
  static Future<void> delete(String endpoint, int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/$endpoint$id/'),
      headers: await _headers(),
    );
    if (res.statusCode != 204) {
      throw Exception('Error al eliminar: ${res.statusCode}');
    }
  }
}
