import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiCategoria {
  static Future<List<dynamic>> obtenerCategorias() async {
    final response = await http.get(
      Uri.parse('${baseUrl}categorias/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar categorías');
    }
  }

  static Future<dynamic> crearCategoria(Map<String, dynamic> categoria) async {
    final response = await http.post(
      Uri.parse('${baseUrl}categorias/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear categoría');
    }
  }

  static Future<dynamic> actualizarCategoria(int id, Map<String, dynamic> categoria) async {
    final response = await http.put(
      Uri.parse('${baseUrl}categorias/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar categoría');
    }
  }

  static Future<void> eliminarCategoria(int id) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}categorias/$id/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar categoría');
    }
  }
}
