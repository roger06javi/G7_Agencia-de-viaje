import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IP del laboratorio: 'http://172.16.81.132:8000/api/'
  // IP actual de la PC local: 'http://192.168.0.102:8000/api/'
  // static const String baseUrl = 'http://192.168.0.102:8000/api/';
  static const String baseUrl = 'http://localhost:8000/api/';

  Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Usuario o contraseña incorrectos. ${response.statusCode}');
    }
  }
}