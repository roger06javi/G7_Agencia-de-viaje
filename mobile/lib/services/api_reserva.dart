import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiReserva {
  static Future<List<dynamic>> obtenerReservas() async {
    final response = await http.get(
      Uri.parse('${baseUrl}reservas/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar reservas');
    }
  }

  static Future<dynamic> crearReserva(Map<String, dynamic> reserva) async {
    final response = await http.post(
      Uri.parse('${baseUrl}reservas/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reserva),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear reserva');
    }
  }

  static Future<dynamic> actualizarReserva(int id, Map<String, dynamic> reserva) async {
    final response = await http.put(
      Uri.parse('${baseUrl}reservas/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reserva),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar reserva');
    }
  }

  static Future<void> eliminarReserva(int id) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}reservas/$id/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar reserva');
    }
  }
}
