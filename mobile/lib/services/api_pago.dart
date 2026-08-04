import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiPago {
  static Future<List<dynamic>> obtenerPagos() async {
    final response = await http.get(
      Uri.parse('${baseUrl}pagos/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar pagos');
    }
  }

  static Future<dynamic> crearPago(Map<String, dynamic> pago) async {
    final response = await http.post(
      Uri.parse('${baseUrl}pagos/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pago),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear pago');
    }
  }

  static Future<dynamic> actualizarPago(int id, Map<String, dynamic> pago) async {
    final response = await http.put(
      Uri.parse('${baseUrl}pagos/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pago),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar pago');
    }
  }

  static Future<void> eliminarPago(int id) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}pagos/$id/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar pago');
    }
  }
}
