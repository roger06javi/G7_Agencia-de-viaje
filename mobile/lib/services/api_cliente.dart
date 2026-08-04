import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/model_cliente.dart';
import 'api_config.dart';

Future<List<Cliente>> listarClientes() async {
  try {
    final response = await http
        .get(Uri.parse('${baseUrl}clientes/clientes/'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Cliente.fromJson(item)).toList();
    } else {
      throw Exception('Fallo al cargar los clientes: ${response.statusCode}');
    }
  } on TimeoutException {
    throw Exception('Tiempo de espera agotado al cargar clientes');
  }
}

Future<Cliente> crearCliente(Cliente cliente) async {
  try {
    final response = await http
        .post(
          Uri.parse('${baseUrl}clientes/clientes/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(cliente.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return Cliente.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo al crear el cliente: ${response.statusCode}');
    }
  } on TimeoutException {
    throw Exception('Tiempo de espera agotado al crear cliente');
  }
}
