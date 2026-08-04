import 'package:flutter/material.dart';
import '../services/api_reserva.dart';

class ReservaPage extends StatefulWidget {
  const ReservaPage({super.key});

  @override
  State<ReservaPage> createState() => _ReservaPageState();
}

class _ReservaPageState extends State<ReservaPage> {
  late Future<List<dynamic>> futureReservas;

  @override
  void initState() {
    super.initState();
    futureReservas = ApiReserva.obtenerReservas();
  }

  Future<void> refresh() async {
    setState(() {
      futureReservas = ApiReserva.obtenerReservas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Reservas'),
        actions: [
          IconButton(
            tooltip: 'Refrescar reservas',
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureReservas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay reservas registradas'));
          }

          final reservas = snapshot.data!;

          return ListView.builder(
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final reserva = reservas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xff111827),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.lightBlueAccent),
                  title: Text('Reserva #${reserva['id'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Fecha: ${reserva['fecha'] ?? 'Sin fecha'}\nEstado: ${reserva['estado'] ?? 'Pendiente'}', style: const TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar reserva',
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const _ReservaDialog(),
          );
          if (created == true) {
            await refresh();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reserva guardada correctamente')),
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

class _ReservaDialog extends StatefulWidget {
  const _ReservaDialog({super.key});

  @override
  State<_ReservaDialog> createState() => _ReservaDialogState();
}

class _ReservaDialogState extends State<_ReservaDialog> {
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController clienteIdController = TextEditingController();
  final TextEditingController paqueteIdController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    fechaController.dispose();
    estadoController.dispose();
    clienteIdController.dispose();
    paqueteIdController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (fechaController.text.isEmpty || clienteIdController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa fecha y cliente.')),
        );
      }
      return;
    }
    setState(() => loading = true);
    try {
      await ApiReserva.crearReserva({
        'fecha': fechaController.text,
        'estado': estadoController.text.isEmpty ? 'pendiente' : estadoController.text,
        'cliente': int.tryParse(clienteIdController.text),
        'paquete': int.tryParse(paqueteIdController.text),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar la reserva: $e')),
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
      title: const Text('Nueva reserva', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Fecha (YYYY-MM-DD)', fechaController),
            const SizedBox(height: 12),
            _field('Estado', estadoController),
            const SizedBox(height: 12),
            _field('ID Cliente', clienteIdController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _field('ID Paquete', paqueteIdController, keyboardType: TextInputType.number),
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
