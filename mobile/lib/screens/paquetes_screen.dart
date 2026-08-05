import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/widgets.dart';

class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({super.key});
  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  List<Paquete> _items = [], _filtered = [];
  List<Destino> _destinos = [];
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
        ApiService.getList('paquetes/'),
        ApiService.getList('destinos/'),
      ]);
      setState(() {
        _items    = res[0].map((j) => Paquete.fromJson(j)).toList();
        _destinos = res[1].map((j) => Destino.fromJson(j)).toList();
        _applyFilter();
      });
    } catch (_) { if (mounted) showError(context, 'Error al cargar paquetes.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() { _filtered = q.isEmpty ? _items : _items.where((p) =>
      '${p.nombrePaquete} ${p.nombreDestino}'.toLowerCase().contains(q)).toList(); });
  }

  Future<void> _delete(Paquete p) async {
    if (!await confirmDelete(context, p.nombrePaquete)) return;
    try { await ApiService.delete('paquetes/', p.id); showSuccess(context, 'Paquete eliminado ✓'); _load(); }
    catch (_) { if (mounted) showError(context, 'No se pudo eliminar.'); }
  }

  void _openForm([Paquete? p]) async {
    final ok = await showModalBottomSheet<bool>(context: context,
      isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _PaqueteForm(paquete: p, destinos: _destinos));
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🎒 Paquetes Turísticos')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(
        controller: _searchCtrl, onChanged: (_) => _applyFilter(),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: const InputDecoration(hintText: 'Buscar paquete o destino…',
          prefixIcon: Icon(Icons.search, color: AppTheme.textMuted)))),
      Expanded(child: _loading ? const LoadingWidget() :
        _filtered.isEmpty ? EmptyState(message: _searchCtrl.text.isEmpty
          ? 'No hay paquetes.\nPresiona + para agregar.' : 'Sin resultados.') :
        RefreshIndicator(color: AppTheme.primary, onRefresh: _load,
          child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final p = _filtered[i];
              return Card(margin: const EdgeInsets.only(bottom: 12),
                child: Padding(padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: const Color(0xFFFB923C).withOpacity(.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.card_travel, color: Color(0xFFFB923C))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.nombrePaquete, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 15)),
                        const SizedBox(height: 4),
                        AppBadge(label: '📍 ${p.nombreDestino}', color: const Color(0xFFC084FC), bg: const Color(0xFFA855F7).withOpacity(.15)),
                      ])),
                      PopupMenuButton<String>(color: AppTheme.surface2,
                        onSelected: (v) => v == 'edit' ? _openForm(p) : _delete(p),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppTheme.warning), SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppTheme.textPrimary))])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppTheme.error), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppTheme.error))])),
                        ]),
                    ]),
                    const Divider(height: 20),
                    Row(children: [
                      Expanded(child: InfoRow(icon: Icons.attach_money, label: 'Precio', value: '\$${p.precio.toStringAsFixed(2)}')),
                      Expanded(child: InfoRow(icon: Icons.calendar_today_outlined, label: 'Duración', value: '${p.duracionDias} días')),
                    ]),
                  ])));
            }))),
    ]),
  );
}

class _PaqueteForm extends StatefulWidget {
  final Paquete? paquete;
  final List<Destino> destinos;
  const _PaqueteForm({this.paquete, required this.destinos});
  @override
  State<_PaqueteForm> createState() => _PaqueteFormState();
}

class _PaqueteFormState extends State<_PaqueteForm> {
  final _key = GlobalKey<FormState>();
  late final _nombreCtrl = TextEditingController(text: widget.paquete?.nombrePaquete ?? '');
  late final _precioCtrl = TextEditingController(text: widget.paquete?.precio.toString() ?? '');
  late final _diasCtrl   = TextEditingController(text: widget.paquete?.duracionDias.toString() ?? '');
  int? _destinoId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _destinoId = widget.paquete?.destino;
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    if (_destinoId == null) { showError(context, 'Selecciona un destino.'); return; }
    setState(() => _saving = true);
    final data = {'nombre_paquete': _nombreCtrl.text.trim(),
      'precio': double.tryParse(_precioCtrl.text) ?? 0,
      'duracion_dias': int.tryParse(_diasCtrl.text) ?? 0, 'destino': _destinoId};
    try {
      if (widget.paquete != null) await ApiService.put('paquetes/', widget.paquete!.id, data);
      else await ApiService.post('paquetes/', data);
      if (mounted) { showSuccess(context, widget.paquete != null ? 'Paquete actualizado ✓' : 'Paquete creado ✓'); Navigator.pop(context, true); }
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
          Text(widget.paquete != null ? '✏️ Editar Paquete' : '➕ Nuevo Paquete',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),
        AppField(label: 'Nombre del Paquete', controller: _nombreCtrl, required: true),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          value: _destinoId,
          dropdownColor: AppTheme.surface2,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Destino'),
          items: widget.destinos.map((d) => DropdownMenuItem(value: d.id,
            child: Text('${d.nombreDestino} — ${d.ciudad}'))).toList(),
          onChanged: (v) => setState(() => _destinoId = v),
          validator: (v) => v == null ? 'Selecciona un destino' : null,
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppField(label: 'Precio (\$)', controller: _precioCtrl, required: true, keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: AppField(label: 'Duración (días)', controller: _diasCtrl, required: true, keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 24),
        SizedBox(height: 50, child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.paquete != null ? 'Actualizar' : 'Guardar'))),
      ])))),
  );
}
