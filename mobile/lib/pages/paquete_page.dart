import 'package:flutter/material.dart';
import '../services/api_paquete.dart';

class PaquetePage extends StatefulWidget {
  const PaquetePage({super.key});

  @override
  State<PaquetePage> createState() => _PaquetePageState();
}

class _PaquetePageState extends State<PaquetePage> {
  late Future<List<dynamic>> futurePaquetes;

  @override
  void initState() {
    super.initState();
    futurePaquetes = ApiPaquete.obtenerPaquetes();
  }

  Future<void> refresh() async {
    setState(() {
      futurePaquetes = ApiPaquete.obtenerPaquetes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Paquetes'),
        actions: [
          IconButton(
            tooltip: 'Refrescar paquetes',
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futurePaquetes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay paquetes registrados'));
          }

          final paquetes = snapshot.data!;

          return ListView.builder(
            itemCount: paquetes.length,
            itemBuilder: (context, index) {
              final paquete = paquetes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xff111827),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.backpack, color: Colors.lightBlueAccent),
                  title: Text(paquete['nombre'] ?? 'Sin nombre', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Precio: \$${paquete['precio'] ?? '0'}\nDías: ${paquete['dias'] ?? '0'}', style: const TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar paquete',
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const _PaqueteDialog(),
          );
          if (created == true) {
            await refresh();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paquete guardado correctamente')),
              );
            }
          }
        },
        backgroundColor: const Color(0xfff97316),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PaqueteDialog extends StatefulWidget {
  const _PaqueteDialog({super.key});

  @override
  State<_PaqueteDialog> createState() => _PaqueteDialogState();
}

class _PaqueteDialogState extends State<_PaqueteDialog> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController diasController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    diasController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (nombreController.text.isEmpty || precioController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa nombre y precio.')),
        );
      }
      return;
    }
    setState(() => loading = true);
    try {
      await ApiPaquete.crearPaquete({
        'nombre': nombreController.text,
        'descripcion': descripcionController.text,
        'precio': double.tryParse(precioController.text) ?? 0,
        'dias': int.tryParse(diasController.text) ?? 1,
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el paquete: $e')),
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
      title: const Text('Nuevo paquete', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Nombre', nombreController),
            const SizedBox(height: 12),
            _field('Descripción', descripcionController, maxLines: 3),
            const SizedBox(height: 12),
            _field('Precio', precioController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _field('Días', diasController, keyboardType: TextInputType.number),
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
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xfff97316)),
          child: loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
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
