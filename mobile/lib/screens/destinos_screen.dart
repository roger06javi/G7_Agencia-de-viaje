import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/widgets.dart';

class DestinosScreen extends StatefulWidget {
  const DestinosScreen({super.key});
  @override
  State<DestinosScreen> createState() => _DestinosScreenState();
}

class _DestinosScreenState extends State<DestinosScreen> {
  List<Destino> _items = [], _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getList('destinos/');
      setState(() { _items = data.map((j) => Destino.fromJson(j)).toList(); _applyFilter(); });
    } catch (_) { if (mounted) showError(context, 'Error al cargar destinos.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() { _filtered = q.isEmpty ? _items : _items.where((d) =>
      '${d.nombreDestino} ${d.ciudad} ${d.pais}'.toLowerCase().contains(q)).toList(); });
  }

  Future<void> _delete(Destino d) async {
    if (!await confirmDelete(context, d.nombreDestino)) return;
    try { await ApiService.delete('destinos/', d.id); showSuccess(context, 'Destino eliminado ✓'); _load(); }
    catch (_) { if (mounted) showError(context, 'No se pudo eliminar.'); }
  }

  void _openForm([Destino? d]) async {
    final ok = await showModalBottomSheet<bool>(context: context,
      isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _DestinoForm(destino: d));
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('📍 Destinos')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(
        controller: _searchCtrl, onChanged: (_) => _applyFilter(),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: const InputDecoration(hintText: 'Buscar destino, ciudad o país…',
          prefixIcon: Icon(Icons.search, color: AppTheme.textMuted)))),
      Expanded(child: _loading ? const LoadingWidget() :
        _filtered.isEmpty ? EmptyState(message: _searchCtrl.text.isEmpty
          ? 'No hay destinos.\nPresiona + para agregar.' : 'Sin resultados.') :
        RefreshIndicator(color: AppTheme.primary, onRefresh: _load,
          child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) { final d = _filtered[i];
              return Card(margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(contentPadding: const EdgeInsets.all(16),
                  leading: Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: const Color(0xFF818CF8).withOpacity(.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.location_on_outlined, color: Color(0xFF818CF8))),
                  title: Text(d.nombreDestino, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 4),
                    Row(children: [
                      AppBadge(label: d.ciudad, color: const Color(0xFF93C5FD), bg: const Color(0xFF3B82F6).withOpacity(.15)),
                      const SizedBox(width: 6),
                      AppBadge(label: d.pais, color: const Color(0xFFC084FC), bg: const Color(0xFFA855F7).withOpacity(.15)),
                    ]),
                    if (d.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(d.descripcion, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ]),
                  trailing: PopupMenuButton<String>(color: AppTheme.surface2,
                    onSelected: (v) => v == 'edit' ? _openForm(d) : _delete(d),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppTheme.warning), SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppTheme.textPrimary))])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppTheme.error), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppTheme.error))])),
                    ]),
                ));
            }))),
    ]),
  );
}

class _DestinoForm extends StatefulWidget {
  final Destino? destino;
  const _DestinoForm({this.destino});
  @override
  State<_DestinoForm> createState() => _DestinoFormState();
}

class _DestinoFormState extends State<_DestinoForm> {
  final _key = GlobalKey<FormState>();
  late final _nombreCtrl = TextEditingController(text: widget.destino?.nombreDestino ?? '');
  late final _ciudadCtrl = TextEditingController(text: widget.destino?.ciudad ?? '');
  late final _paisCtrl   = TextEditingController(text: widget.destino?.pais ?? '');
  late final _descCtrl   = TextEditingController(text: widget.destino?.descripcion ?? '');
  bool _saving = false;

  @override
  void dispose() { _nombreCtrl.dispose(); _ciudadCtrl.dispose(); _paisCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {'nombre_destino': _nombreCtrl.text.trim(), 'ciudad': _ciudadCtrl.text.trim(),
      'pais': _paisCtrl.text.trim(), 'descripcion': _descCtrl.text.trim()};
    try {
      if (widget.destino != null) await ApiService.put('destinos/', widget.destino!.id, data);
      else await ApiService.post('destinos/', data);
      if (mounted) { showSuccess(context, widget.destino != null ? 'Destino actualizado ✓' : 'Destino creado ✓'); Navigator.pop(context, true); }
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
          Text(widget.destino != null ? '✏️ Editar Destino' : '➕ Nuevo Destino',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),
        AppField(label: 'Nombre del Destino', controller: _nombreCtrl, required: true),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppField(label: 'Ciudad', controller: _ciudadCtrl, required: true)),
          const SizedBox(width: 12),
          Expanded(child: AppField(label: 'País', controller: _paisCtrl, required: true)),
        ]),
        const SizedBox(height: 14),
        AppField(label: 'Descripción', controller: _descCtrl, maxLines: 3),
        const SizedBox(height: 24),
        SizedBox(height: 50, child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.destino != null ? 'Actualizar' : 'Guardar'))),
      ])))),
  );
}
