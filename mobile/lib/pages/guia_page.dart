import 'package:flutter/material.dart';
import '../services/api_guia.dart';

class GuiaPage extends StatefulWidget {
  const GuiaPage({super.key});

  @override
  State<GuiaPage> createState() => _GuiaPageState();
}

class _GuiaPageState extends State<GuiaPage> {
  late Future<List<dynamic>> futureGuias;

  @override
  void initState() {
    super.initState();
    futureGuias = ApiGuia.obtenerGuias();
  }

  Future<void> refresh() async {
    setState(() {
      futureGuias = ApiGuia.obtenerGuias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Guías'),
        actions: [
          IconButton(
            tooltip: 'Refrescar guías',
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureGuias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay guías registrados'));
          }

          final guias = snapshot.data!;

          return ListView.builder(
            itemCount: guias.length,
            itemBuilder: (context, index) {
              final guia = guias[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xff111827),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.person_outline, color: Colors.lightBlueAccent),
                  title: Text('${guia['nombre'] ?? ''} ${guia['apellido'] ?? ''}'.trim(), style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Teléfono: ${guia['telefono'] ?? 'N/A'}\nEspecialidad: ${guia['especialidad'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar guía',
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const _GuiaDialog(),
          );
          if (created == true) {
            await refresh();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Guía guardado correctamente')),
              );
            }
          }
        },
        backgroundColor: const Color(0xfff97316),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _GuiaDialog extends StatefulWidget {
  const _GuiaDialog({super.key});

  @override
  State<_GuiaDialog> createState() => _GuiaDialogState();
}

class _GuiaDialogState extends State<_GuiaDialog> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController especialidadController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    telefonoController.dispose();
    especialidadController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (nombreController.text.isEmpty || apellidoController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa nombre y apellido.')),
        );
      }
      return;
    }
    setState(() => loading = true);
    try {
      await ApiGuia.crearGuia({
        'nombre': nombreController.text,
        'apellido': apellidoController.text,
        'telefono': telefonoController.text,
        'especialidad': especialidadController.text,
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el guía: $e')),
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
      title: const Text('Nuevo guía', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Nombre', nombreController),
            const SizedBox(height: 12),
            _field('Apellido', apellidoController),
            const SizedBox(height: 12),
            _field('Teléfono', telefonoController),
            const SizedBox(height: 12),
            _field('Especialidad', especialidadController),
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
