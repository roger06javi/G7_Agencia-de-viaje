import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/model_destino.dart';
import 'api_config.dart';

Future<List<Destino>> listarDestinos() async {
  final response = await http.get(Uri.parse('${baseUrl}destinos/'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    return body.map((item) => Destino.fromJson(item)).toList();
  } else {
    throw Exception('Fallo al cargar los destinos: ${response.statusCode}');
  }
}

Future<Destino> crearDestino(Destino destino) async {
  final response = await http.post(
    Uri.parse('${baseUrl}destinos/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(destino.toJson()),
  );

  if (response.statusCode == 201) {
    return Destino.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Fallo al crear el destino: ${response.statusCode}');
  }
}
