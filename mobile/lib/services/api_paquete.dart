import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiPaquete {
  static Future<List<dynamic>> obtenerPaquetes() async {
    final response = await http.get(
      Uri.parse('${baseUrl}paquetes/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar paquetes');
    }
  }

  static Future<dynamic> crearPaquete(Map<String, dynamic> paquete) async {
    final response = await http.post(
      Uri.parse('${baseUrl}paquetes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(paquete),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear paquete');
    }
  }

  static Future<dynamic> actualizarPaquete(int id, Map<String, dynamic> paquete) async {
    final response = await http.put(
      Uri.parse('${baseUrl}paquetes/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(paquete),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar paquete');
    }
  }

  static Future<void> eliminarPaquete(int id) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}paquetes/$id/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar paquete');
    }
  }
}
