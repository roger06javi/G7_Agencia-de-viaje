import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiGuia {
  static Future<List<dynamic>> obtenerGuias() async {
    final response = await http.get(
      Uri.parse('${baseUrl}guias/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar guías');
    }
  }

  static Future<dynamic> crearGuia(Map<String, dynamic> guia) async {
    final response = await http.post(
      Uri.parse('${baseUrl}guias/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(guia),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear guía');
    }
  }

  static Future<dynamic> actualizarGuia(int id, Map<String, dynamic> guia) async {
    final response = await http.put(
      Uri.parse('${baseUrl}guias/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(guia),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar guía');
    }
  }

  static Future<void> eliminarGuia(int id) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}guias/$id/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar guía');
    }
  }
}
