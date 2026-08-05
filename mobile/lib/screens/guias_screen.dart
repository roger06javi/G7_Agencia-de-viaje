import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/widgets.dart';

class GuiasScreen extends StatefulWidget {
  const GuiasScreen({super.key});
  @override
  State<GuiasScreen> createState() => _GuiasScreenState();
}

class _GuiasScreenState extends State<GuiasScreen> {
  List<Guia> _items = [], _filtered = [];
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
        ApiService.getList('guias/'),
        ApiService.getList('destinos/'),
      ]);
      setState(() {
        _items    = res[0].map((j) => Guia.fromJson(j)).toList();
        _destinos = res[1].map((j) => Destino.fromJson(j)).toList();
        _applyFilter();
      });
    } catch (_) { if (mounted) showError(context, 'Error al cargar guías.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() { _filtered = q.isEmpty ? _items : _items.where((g) =>
      '${g.nombre} ${g.experiencia} ${g.nombreDestino}'.toLowerCase().contains(q)).toList(); });
  }

  Future<void> _delete(Guia g) async {
    if (!await confirmDelete(context, g.nombre)) return;
    try { await ApiService.delete('guias/', g.id); showSuccess(context, 'Guía eliminado ✓'); _load(); }
    catch (_) { if (mounted) showError(context, 'No se pudo eliminar.'); }
  }

  void _openForm([Guia? g]) async {
    final ok = await showModalBottomSheet<bool>(context: context,
      isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _GuiaForm(guia: g, destinos: _destinos));
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('👨‍💼 Guías Turísticos')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(
        controller: _searchCtrl, onChanged: (_) => _applyFilter(),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: const InputDecoration(hintText: 'Buscar por nombre, destino o experiencia…',
          prefixIcon: Icon(Icons.search, color: AppTheme.textMuted)))),
      Expanded(child: _loading ? const LoadingWidget() :
        _filtered.isEmpty ? EmptyState(message: _searchCtrl.text.isEmpty
          ? 'No hay guías registrados.\nPresiona + para agregar.' : 'Sin resultados.') :
        RefreshIndicator(color: AppTheme.primary, onRefresh: _load,
          child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final g = _filtered[i];
              return Card(margin: const EdgeInsets.only(bottom: 12),
                child: Padding(padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(backgroundColor: const Color(0xFFF472B6).withOpacity(.15),
                        child: Text(g.nombre[0].toUpperCase(),
                          style: const TextStyle(color: Color(0xFFF472B6), fontWeight: FontWeight.w800))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(g.nombre, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 15)),
                        const SizedBox(height: 4),
                        AppBadge(label: '📍 ${g.nombreDestino}', color: const Color(0xFFC084FC), bg: const Color(0xFFA855F7).withOpacity(.15)),
                      ])),
                      PopupMenuButton<String>(color: AppTheme.surface2,
                        onSelected: (v) => v == 'edit' ? _openForm(g) : _delete(g),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppTheme.warning), SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppTheme.textPrimary))])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppTheme.error), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppTheme.error))])),
                        ]),
                    ]),
                    const Divider(height: 20),
                    InfoRow(icon: Icons.phone_outlined, label: 'Teléfono', value: g.telefono),
                    InfoRow(icon: Icons.workspace_premium_outlined, label: 'Experiencia', value: g.experiencia),
                  ])));
            }))),
    ]),
  );
}

class _GuiaForm extends StatefulWidget {
  final Guia? guia;
  final List<Destino> destinos;
  const _GuiaForm({this.guia, required this.destinos});
  @override
  State<_GuiaForm> createState() => _GuiaFormState();
}

class _GuiaFormState extends State<_GuiaForm> {
  final _key = GlobalKey<FormState>();
  late final _nombreCtrl     = TextEditingController(text: widget.guia?.nombre ?? '');
  late final _telefonoCtrl   = TextEditingController(text: widget.guia?.telefono ?? '');
  late final _experienciaCtrl= TextEditingController(text: widget.guia?.experiencia ?? '');
  int? _destinoId;
  bool _saving = false;

  @override
  void initState() { super.initState(); _destinoId = widget.guia?.destino; }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    if (_destinoId == null) { showError(context, 'Selecciona un destino.'); return; }
    setState(() => _saving = true);
    final data = {'nombre': _nombreCtrl.text.trim(), 'telefono': _telefonoCtrl.text.trim(),
      'experiencia': _experienciaCtrl.text.trim(), 'destino': _destinoId};
    try {
      if (widget.guia != null) await ApiService.put('guias/', widget.guia!.id, data);
      else await ApiService.post('guias/', data);
      if (mounted) { showSuccess(context, widget.guia != null ? 'Guía actualizado ✓' : 'Guía creado ✓'); Navigator.pop(context, true); }
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
          Text(widget.guia != null ? '✏️ Editar Guía' : '➕ Nuevo Guía',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),
        AppField(label: 'Nombre Completo', controller: _nombreCtrl, required: true),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppField(label: 'Teléfono', controller: _telefonoCtrl, required: true, keyboardType: TextInputType.phone)),
          const SizedBox(width: 12),
          Expanded(child: AppField(label: 'Experiencia', controller: _experienciaCtrl, required: true, hint: 'Ej. 5 años')),
        ]),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(value: _destinoId, dropdownColor: AppTheme.surface2,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Destino Asignado'),
          items: widget.destinos.map((d) => DropdownMenuItem(value: d.id,
            child: Text('${d.nombreDestino} — ${d.ciudad}'))).toList(),
          onChanged: (v) => setState(() => _destinoId = v),
          validator: (v) => v == null ? 'Selecciona un destino' : null),
        const SizedBox(height: 24),
        SizedBox(height: 50, child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.guia != null ? 'Actualizar' : 'Guardar'))),
      ])))),
  );
}
