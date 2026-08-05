import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/widgets.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});
  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  List<Reserva> _items = [], _filtered = [];
  List<Cliente> _clientes = [];
  List<Paquete> _paquetes = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        ApiService.getList('reservas/'),
        ApiService.getList('clientes/clientes/'),
        ApiService.getList('paquetes/'),
      ]);
      setState(() {
        _items    = res[0].map((j) => Reserva.fromJson(j)).toList();
        _clientes = res[1].map((j) => Cliente.fromJson(j)).toList();
        _paquetes = res[2].map((j) => Paquete.fromJson(j)).toList();
        _applyFilter();
      });
    } catch (_) { if (mounted) showError(context, 'Error al cargar reservas.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() { _filtered = q.isEmpty ? _items : _items.where((r) =>
      '${r.nombreCliente} ${r.apellidoCliente} ${r.nombrePaquete} ${r.estado}'.toLowerCase().contains(q)).toList(); });
  }

  Future<void> _delete(Reserva r) async {
    if (!await confirmDelete(context, 'Reserva #${r.id}')) return;
    try { await ApiService.delete('reservas/', r.id); showSuccess(context, 'Reserva eliminada ✓'); _load(); }
    catch (_) { if (mounted) showError(context, 'No se pudo eliminar.'); }
  }

  void _openForm([Reserva? r]) async {
    final ok = await showModalBottomSheet<bool>(context: context,
      isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ReservaForm(reserva: r, clientes: _clientes, paquetes: _paquetes));
    if (ok == true) _load();
  }

  Color _estadoColor(String e) => e == 'Confirmada' ? AppTheme.success : e == 'Cancelada' ? AppTheme.error : AppTheme.warning;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('📅 Reservas')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Nueva')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(
        controller: _searchCtrl, onChanged: (_) => _applyFilter(),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: const InputDecoration(hintText: 'Buscar por cliente, paquete o estado…',
          prefixIcon: Icon(Icons.search, color: AppTheme.textMuted)))),
      Expanded(child: _loading ? const LoadingWidget() :
        _filtered.isEmpty ? EmptyState(message: _searchCtrl.text.isEmpty
          ? 'No hay reservas.\nPresiona + para agregar.' : 'Sin resultados.') :
        RefreshIndicator(color: AppTheme.primary, onRefresh: _load,
          child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final r = _filtered[i];
              final color = _estadoColor(r.estado);
              return Card(margin: const EdgeInsets.only(bottom: 12),
                child: Padding(padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.calendar_month, color: color)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r.nombreCliente} ${r.apellidoCliente}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 15)),
                        const SizedBox(height: 4),
                        AppBadge(label: r.estado, color: color, bg: color.withOpacity(.15)),
                      ])),
                      PopupMenuButton<String>(color: AppTheme.surface2,
                        onSelected: (v) => v == 'edit' ? _openForm(r) : _delete(r),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppTheme.warning), SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppTheme.textPrimary))])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppTheme.error), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppTheme.error))])),
                        ]),
                    ]),
                    const Divider(height: 20),
                    InfoRow(icon: Icons.card_travel_outlined, label: 'Paquete', value: r.nombrePaquete),
                    InfoRow(icon: Icons.calendar_today_outlined, label: 'Fecha', value: r.fechaReserva),
                    InfoRow(icon: Icons.people_outline, label: 'Personas', value: '${r.cantidadPersonas}'),
                  ])));
            }))),
    ]),
  );
}

class _ReservaForm extends StatefulWidget {
  final Reserva? reserva;
  final List<Cliente> clientes;
  final List<Paquete> paquetes;
  const _ReservaForm({this.reserva, required this.clientes, required this.paquetes});
  @override
  State<_ReservaForm> createState() => _ReservaFormState();
}

class _ReservaFormState extends State<_ReservaForm> {
  final _key = GlobalKey<FormState>();
  late final _fechaCtrl    = TextEditingController(text: widget.reserva?.fechaReserva ?? '');
  late final _personasCtrl = TextEditingController(text: widget.reserva?.cantidadPersonas.toString() ?? '');
  int? _clienteId, _paqueteId;
  String _estado = 'Pendiente';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _clienteId = widget.reserva?.cliente;
    _paqueteId = widget.reserva?.paquete;
    _estado    = widget.reserva?.estado ?? 'Pendiente';
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context,
      initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.dark(primary: AppTheme.primary, surface: AppTheme.surface2)), child: child!));
    if (d != null) _fechaCtrl.text = d.toIso8601String().split('T')[0];
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    if (_clienteId == null || _paqueteId == null) { showError(context, 'Selecciona cliente y paquete.'); return; }
    setState(() => _saving = true);
    final data = {'fecha_reserva': _fechaCtrl.text, 'cantidad_personas': int.tryParse(_personasCtrl.text) ?? 1,
      'estado': _estado, 'cliente': _clienteId, 'paquete': _paqueteId};
    try {
      if (widget.reserva != null) await ApiService.put('reservas/', widget.reserva!.id, data);
      else await ApiService.post('reservas/', data);
      if (mounted) { showSuccess(context, widget.reserva != null ? 'Reserva actualizada ✓' : 'Reserva creada ✓'); Navigator.pop(context, true); }
    } catch (e) { if (mounted) showError(context, 'Error: ${e.toString().replaceAll('Exception: ', '')}'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
      child: Form(key: _key, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.reserva != null ? '✏️ Editar Reserva' : '➕ Nueva Reserva',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),
        DropdownButtonFormField<int>(value: _clienteId, dropdownColor: AppTheme.surface2,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Cliente'),
          items: widget.clientes.map((c) => DropdownMenuItem(value: c.id,
            child: Text('${c.nombre} ${c.apellido}'))).toList(),
          onChanged: (v) => setState(() => _clienteId = v),
          validator: (v) => v == null ? 'Selecciona un cliente' : null),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(value: _paqueteId, dropdownColor: AppTheme.surface2,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Paquete Turístico'),
          items: widget.paquetes.map((p) => DropdownMenuItem(value: p.id,
            child: Text(p.nombrePaquete))).toList(),
          onChanged: (v) => setState(() => _paqueteId = v),
          validator: (v) => v == null ? 'Selecciona un paquete' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _fechaCtrl, readOnly: true, onTap: _pickDate,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Fecha de Reserva',
            suffixIcon: Icon(Icons.calendar_today, color: AppTheme.textMuted)),
          validator: (v) => (v == null || v.isEmpty) ? 'Selecciona una fecha' : null),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppField(label: 'N° Personas', controller: _personasCtrl, required: true, keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: DropdownButtonFormField<String>(value: _estado, dropdownColor: AppTheme.surface2,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Estado'),
            items: ['Pendiente','Confirmada','Cancelada'].map((e) =>
              DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _estado = v!))),
        ]),
        const SizedBox(height: 24),
        SizedBox(height: 50, child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.reserva != null ? 'Actualizar' : 'Guardar'))),
      ])))),
  );
}
