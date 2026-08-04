import 'package:flutter/material.dart';
import '../models/model_destino.dart';
import '../services/api_destino.dart';

class DestinoPage extends StatefulWidget {
  const DestinoPage({super.key});

  @override
  State<DestinoPage> createState() => _DestinoPageState();
}

class _DestinoPageState extends State<DestinoPage> {
  late Future<List<Destino>> futureDestinos;

  @override
  void initState() {
    super.initState();
    futureDestinos = listarDestinos();
  }

  Future<void> refresh() async {
    setState(() {
      futureDestinos = listarDestinos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Destino>>(
        future: futureDestinos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final destinos = snapshot.data ?? [];
          if (destinos.isEmpty) {
            return const Center(child: Text('No hay destinos registrados.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: destinos.length,
            itemBuilder: (context, index) {
              final destino = destinos[index];
              return Card(
                color: const Color(0xff111827),
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(destino.nombreDestino ?? 'Sin nombre', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${destino.ciudad ?? '-'} · ${destino.pais ?? '-'}\n${destino.descripcion ?? ''}', style: const TextStyle(color: Colors.white70)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (_) => const _DestinoDialog(),
          );
          if (result == true) refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DestinoDialog extends StatefulWidget {
  const _DestinoDialog({super.key});

  @override
  State<_DestinoDialog> createState() => _DestinoDialogState();
}

class _DestinoDialogState extends State<_DestinoDialog> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController paisController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  bool loading = false;

  Future<void> guardar() async {
    if (nombreController.text.isEmpty || paisController.text.isEmpty || ciudadController.text.isEmpty) {
      return;
    }
    setState(() => loading = true);
    try {
      await crearDestino(Destino(
        nombreDestino: nombreController.text,
        pais: paisController.text,
        ciudad: ciudadController.text,
        descripcion: descripcionController.text,
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el destino: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff0f172a),
      title: const Text('Nuevo destino', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Nombre', nombreController),
            const SizedBox(height: 12),
            _field('País', paisController),
            const SizedBox(height: 12),
            _field('Ciudad', ciudadController),
            const SizedBox(height: 12),
            _field('Descripción', descripcionController, maxLines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: loading ? null : guardar,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff6366f1)),
          child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff111827),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
