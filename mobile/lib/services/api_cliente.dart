import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/model_cliente.dart';

const String baseUrl = 'http://10.0.2.2:8000/api/';

Future<List<Cliente>> listarClientes() async {
  final response = await http.get(Uri.parse('${baseUrl}clientes/clientes/'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    return body.map((item) => Cliente.fromJson(item)).toList();
  } else {
    throw Exception('Fallo al cargar los clientes: ${response.statusCode}');
  }
}

Future<Cliente> crearCliente(Cliente cliente) async {
  final response = await http.post(
    Uri.parse('${baseUrl}clientes/clientes/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(cliente.toJson()),
  );

  if (response.statusCode == 201) {
    return Cliente.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Fallo al crear el cliente: ${response.statusCode}');
  }
}