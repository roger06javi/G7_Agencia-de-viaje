import 'package:flutter/material.dart';
import '../services/api_categoria.dart';

class CategoriaPage extends StatefulWidget {
  const CategoriaPage({super.key});

  @override
  State<CategoriaPage> createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  late Future<List<dynamic>> futureCategorias;

  @override
  void initState() {
    super.initState();
    futureCategorias = ApiCategoria.obtenerCategorias();
  }

  Future<void> refresh() async {
    setState(() {
      futureCategorias = ApiCategoria.obtenerCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Categorías'),
        actions: [
          IconButton(
            tooltip: 'Refrescar categorías',
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureCategorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay categorías registradas'));
          }

          final categorias = snapshot.data!;

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xff111827),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.category, color: Colors.lightBlueAccent),
                  title: Text(categoria['nombre'] ?? 'Sin nombre', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(categoria['descripcion'] ?? 'Sin descripción', style: const TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar categoría',
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const _CategoriaDialog(),
          );
          if (created == true) {
            await refresh();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Categoría guardada correctamente')),
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

class _CategoriaDialog extends StatefulWidget {
  const _CategoriaDialog({super.key});

  @override
  State<_CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends State<_CategoriaDialog> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (nombreController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa el nombre.')),
        );
      }
      return;
    }
    setState(() => loading = true);
    try {
      await ApiCategoria.crearCategoria({
        'nombre': nombreController.text,
        'descripcion': descripcionController.text,
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar la categoría: $e')),
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
      title: const Text('Nueva categoría', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Nombre', nombreController),
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
