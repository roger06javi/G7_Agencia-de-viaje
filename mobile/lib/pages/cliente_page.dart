import 'package:flutter/material.dart';
import '../models/model_cliente.dart';
import '../services/api_cliente.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  late Future<List<Cliente>> futureClientes;

  @override
  void initState() {
    super.initState();
    futureClientes = listarClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Clientes'),
      ),
      body: FutureBuilder<List<Cliente>>(
        future: futureClientes,
        builder: (context, snapshot) {

          // Mientras carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Si hay error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          // Si no hay datos
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay clientes registrados'),
            );
          }

          // Datos obtenidos
          List<Cliente> clientes = snapshot.data!;

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              Cliente cliente = clientes[index];

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  '${cliente.nombre} ${cliente.apellido}',
                ),
                subtitle: Text(
                  cliente.email ?? 'Sin correo',
                ),
                trailing: Text(
                  cliente.estado ?? '',
                ),
              );
            },
          );
        },
      ),
    );
  }
}