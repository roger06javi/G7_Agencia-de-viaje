import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/widgets.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});
  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  List<Pago> _items = [], _filtered = [];
  List<Reserva> _reservas = [];
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
        ApiService.getList('pagos/'),
        ApiService.getList('reservas/'),
      ]);
      setState(() {
        _items    = res[0].map((j) => Pago.fromJson(j)).toList();
        _reservas = res[1].map((j) => Reserva.fromJson(j)).toList();
        _applyFilter();
      });
    } catch (_) { if (mounted) showError(context, 'Error al cargar pagos.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() { _filtered = q.isEmpty ? _items : _items.where((p) =>
      '${p.metodoPago} ${p.reservaInfo}'.toLowerCase().contains(q)).toList(); });
  }

  Future<void> _delete(Pago p) async {
    if (!await confirmDelete(context, 'Pago #${p.id}')) return;
    try { await ApiService.delete('pagos/', p.id); showSuccess(context, 'Pago eliminado ✓'); _load(); }
    catch (_) { if (mounted) showError(context, 'No se pudo eliminar.'); }
  }

  void _openForm([Pago? p]) async {
    final ok = await showModalBottomSheet<bool>(context: context,
      isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _PagoForm(pago: p, reservas: _reservas));
    if (ok == true) _load();
  }

  Color _metodoColor(String m) => m == 'Efectivo' ? AppTheme.success : m == 'Tarjeta' ? AppTheme.info : const Color(0xFFA78BFA);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('💳 Pagos')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Registrar')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(
        controller: _searchCtrl, onChanged: (_) => _applyFilter(),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: const InputDecoration(hintText: 'Buscar por método o reserva…',
          prefixIcon: Icon(Icons.search, color: AppTheme.textMuted)))),
      Expanded(child: _loading ? const LoadingWidget() :
        _filtered.isEmpty ? EmptyState(message: _searchCtrl.text.isEmpty
          ? 'No hay pagos registrados.\nPresiona + para agregar.' : 'Sin resultados.') :
        RefreshIndicator(color: AppTheme.primary, onRefresh: _load,
          child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final p = _filtered[i];
              final color = _metodoColor(p.metodoPago);
              return Card(margin: const EdgeInsets.only(bottom: 12),
                child: Padding(padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.credit_card, color: color)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('\$${p.monto.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 18)),
                        const SizedBox(height: 4),
                        AppBadge(label: p.metodoPago, color: color, bg: color.withOpacity(.15)),
                      ])),
                      PopupMenuButton<String>(color: AppTheme.surface2,
                        onSelected: (v) => v == 'edit' ? _openForm(p) : _delete(p),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppTheme.warning), SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppTheme.textPrimary))])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppTheme.error), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppTheme.error))])),
                        ]),
                    ]),
                    const Divider(height: 20),
                    InfoRow(icon: Icons.calendar_today_outlined, label: 'Fecha', value: p.fechaPago),
                    InfoRow(icon: Icons.confirmation_number_outlined, label: 'Reserva', value: p.reservaInfo),
                  ])));
            }))),
    ]),
  );
}

class _PagoForm extends StatefulWidget {
  final Pago? pago;
  final List<Reserva> reservas;
  const _PagoForm({this.pago, required this.reservas});
  @override
  State<_PagoForm> createState() => _PagoFormState();
}

class _PagoFormState extends State<_PagoForm> {
  final _key = GlobalKey<FormState>();
  late final _fechaCtrl = TextEditingController(text: widget.pago?.fechaPago ?? '');
  late final _montoCtrl = TextEditingController(text: widget.pago?.monto.toString() ?? '');
  int? _reservaId;
  String _metodo = 'Efectivo';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reservaId = widget.pago?.reserva;
    _metodo    = widget.pago?.metodoPago ?? 'Efectivo';
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
    if (_reservaId == null) { showError(context, 'Selecciona una reserva.'); return; }
    setState(() => _saving = true);
    final data = {'fecha_pago': _fechaCtrl.text, 'monto': double.tryParse(_montoCtrl.text) ?? 0,
      'metodo_pago': _metodo, 'reserva': _reservaId};
    try {
      if (widget.pago != null) await ApiService.put('pagos/', widget.pago!.id, data);
      else await ApiService.post('pagos/', data);
      if (mounted) { showSuccess(context, widget.pago != null ? 'Pago actualizado ✓' : 'Pago registrado ✓'); Navigator.pop(context, true); }
    } catch (e) { if (mounted) showError(context, 'Error: ${e.toString().replaceAll('Exception: ', '')}'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    child: SafeArea(child: Padding(padding: const EdgeInsets.all(24),
      child: Form(key: _key, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.pago != null ? '✏️ Editar Pago' : '➕ Registrar Pago',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),
        DropdownButtonFormField<int>(value: _reservaId, dropdownColor: AppTheme.surface2,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Reserva Asociada'),
          items: widget.reservas.map((r) => DropdownMenuItem(value: r.id,
            child: Text('Reserva #${r.id} — ${r.nombreCliente} ${r.apellidoCliente}'))).toList(),
          onChanged: (v) => setState(() => _reservaId = v),
          validator: (v) => v == null ? 'Selecciona una reserva' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _fechaCtrl, readOnly: true, onTap: _pickDate,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Fecha de Pago',
            suffixIcon: Icon(Icons.calendar_today, color: AppTheme.textMuted)),
          validator: (v) => (v == null || v.isEmpty) ? 'Selecciona una fecha' : null),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppField(label: 'Monto (\$)', controller: _montoCtrl, required: true, keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: DropdownButtonFormField<String>(value: _metodo, dropdownColor: AppTheme.surface2,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Método'),
            items: ['Efectivo','Tarjeta','Transferencia'].map((m) =>
              DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _metodo = v!))),
        ]),
        const SizedBox(height: 24),
        SizedBox(height: 50, child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.pago != null ? 'Actualizar' : 'Registrar'))),
      ])))),
  );
}
