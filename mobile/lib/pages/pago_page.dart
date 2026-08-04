import 'package:flutter/material.dart';
import '../services/api_pago.dart';

class PagoPage extends StatefulWidget {
  const PagoPage({super.key});

  @override
  State<PagoPage> createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  late Future<List<dynamic>> futurePagos;

  @override
  void initState() {
    super.initState();
    futurePagos = ApiPago.obtenerPagos();
  }

  Future<void> refresh() async {
    setState(() {
      futurePagos = ApiPago.obtenerPagos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pagos'),
        actions: [
          IconButton(
            tooltip: 'Refrescar pagos',
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futurePagos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay pagos registrados'));
          }

          final pagos = snapshot.data!;

          return ListView.builder(
            itemCount: pagos.length,
            itemBuilder: (context, index) {
              final pago = pagos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xff111827),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.payment, color: Colors.lightBlueAccent),
                  title: Text('Pago #${pago['id'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Monto: \$${pago['monto'] ?? '0'}\nMétodo: ${pago['metodo'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar pago',
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const _PagoDialog(),
          );
          if (created == true) {
            await refresh();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago guardado correctamente')),
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

class _PagoDialog extends StatefulWidget {
  const _PagoDialog({super.key});

  @override
  State<_PagoDialog> createState() => _PagoDialogState();
}

class _PagoDialogState extends State<_PagoDialog> {
  final TextEditingController montoController = TextEditingController();
  final TextEditingController metodoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController reservaIdController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    montoController.dispose();
    metodoController.dispose();
    fechaController.dispose();
    reservaIdController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (montoController.text.isEmpty || metodoController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa monto y método.')),
        );
      }
      return;
    }
    setState(() => loading = true);
    try {
      await ApiPago.crearPago({
        'monto': double.tryParse(montoController.text) ?? 0,
        'metodo': metodoController.text,
        'fecha': fechaController.text.isEmpty ? DateTime.now().toString().split(' ')[0] : fechaController.text,
        'reserva': int.tryParse(reservaIdController.text),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el pago: $e')),
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
      title: const Text('Nuevo pago', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Monto', montoController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _field('Método (efectivo/tarjeta/transferencia)', metodoController),
            const SizedBox(height: 12),
            _field('Fecha (YYYY-MM-DD)', fechaController),
            const SizedBox(height: 12),
            _field('ID Reserva', reservaIdController, keyboardType: TextInputType.number),
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
