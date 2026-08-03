import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/cliente.dart';

final String url = 'https://172.16.122.103:8000/api/clientes/';

Future<List<Cliente>> fetchClientes() async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    return body.map((item) => Cliente.fromJson(item)).toList();
  } else {
    throw Exception('Fallo al cargar los clientes: ${response.statusCode}');
  }
}