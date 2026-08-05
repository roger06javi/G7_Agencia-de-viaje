import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/widgets.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});
  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Cliente> _items = [];
  List<Cliente> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getList('clientes/clientes/');
      setState(() {
        _items = data.map((j) => Cliente.fromJson(j)).toList();
        _applyFilter();
      });
    } catch (e) {
      if (mounted) showError(context, 'Error al cargar clientes.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty ? _items : _items.where((c) =>
        '${c.nombre} ${c.apellido} ${c.cedula} ${c.correo}'.toLowerCase().contains(q)
      ).toList();
    });
  }

  Future<void> _delete(Cliente c) async {
    if (!await confirmDelete(context, '${c.nombre} ${c.apellido}')) return;
    try {
      await ApiService.delete('clientes/clientes/', c.id);
      showSuccess(context, 'Cliente eliminado ✓');
      _load();
    } catch (_) { if (mounted) showError(context, 'No se pudo eliminar.'); }
  }

  void _openForm([Cliente? c]) async {
    final ok = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClienteForm(cliente: c),
    );
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('👥 Clientes')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openForm(),
      icon: const Icon(Icons.add), label: const Text('Nuevo'),
    ),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _searchCtrl, onChanged: (_) => _applyFilter(),
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre, cédula o correo…',
            prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
          ),
        ),
      ),
      Expanded(child: _loading ? const LoadingWidget() :
        _filtered.isEmpty ? EmptyState(message: _searchCtrl.text.isEmpty
            ? 'No hay clientes.\nPresiona + para agregar uno.' : 'Sin resultados.') :
        RefreshIndicator(color: AppTheme.primary, onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final c = _filtered[i];
              return _ClienteCard(cliente: c,
                onEdit: () => _openForm(c), onDelete: () => _delete(c));
            },
          ),
        ),
      ),
    ]),
  );
}

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onEdit, onDelete;
  const _ClienteCard({required this.cliente, required this.onEdit, required this.onDelete});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(backgroundColor: const Color(0xFF34D399).withOpacity(.15),
            child: Text(cliente.nombre[0].toUpperCase(),
              style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w800))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${cliente.nombre} ${cliente.apellido}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 15)),
            Text('Cédula: ${cliente.cedula}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ])),
          PopupMenuButton<String>(
            color: AppTheme.surface2,
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [
                Icon(Icons.edit_outlined, size: 18, color: AppTheme.warning),
                SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppTheme.textPrimary)),
              ])),
              const PopupMenuItem(value: 'delete', child: Row(children: [
                Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppTheme.error)),
              ])),
            ],
          ),
        ]),
        const Divider(height: 20),
        InfoRow(icon: Icons.email_outlined, label: 'Correo', value: cliente.correo),
        if (cliente.telefono.isNotEmpty)
          InfoRow(icon: Icons.phone_outlined, label: 'Teléfono', value: cliente.telefono),
      ]),
    ),
  );
}

class _ClienteForm extends StatefulWidget {
  final Cliente? cliente;
  const _ClienteForm({this.cliente});
  @override
  State<_ClienteForm> createState() => _ClienteFormState();
}

class _ClienteFormState extends State<_ClienteForm> {
  final _key = GlobalKey<FormState>();
  late final _nombreCtrl   = TextEditingController(text: widget.cliente?.nombre ?? '');
  late final _apellidoCtrl = TextEditingController(text: widget.cliente?.apellido ?? '');
  late final _cedulaCtrl   = TextEditingController(text: widget.cliente?.cedula ?? '');
  late final _telCtrl      = TextEditingController(text: widget.cliente?.telefono ?? '');
  late final _correoCtrl   = TextEditingController(text: widget.cliente?.correo ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _nombreCtrl.dispose(); _apellidoCtrl.dispose(); _cedulaCtrl.dispose();
    _telCtrl.dispose(); _correoCtrl.dispose(); super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = { 'nombre': _nombreCtrl.text.trim(), 'apellido': _apellidoCtrl.text.trim(),
      'cedula': _cedulaCtrl.text.trim(), 'telefono': _telCtrl.text.trim(),
      'correo': _correoCtrl.text.trim() };
    try {
      if (widget.cliente != null) {
        await ApiService.put('clientes/clientes/', widget.cliente!.id, data);
      } else {
        await ApiService.post('clientes/clientes/', data);
      }
      if (mounted) { showSuccess(context, widget.cliente != null ? 'Cliente actualizado ✓' : 'Cliente creado ✓'); Navigator.pop(context, true); }
    } catch (e) {
      if (mounted) showError(context, 'Error: ${e.toString().replaceAll('Exception: ', '')}');
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    decoration: const BoxDecoration(color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    child: SafeArea(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Form(key: _key, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.cliente != null ? '✏️ Editar Cliente' : '➕ Nuevo Cliente',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: AppField(label: 'Nombre', controller: _nombreCtrl, required: true)),
          const SizedBox(width: 12),
          Expanded(child: AppField(label: 'Apellido', controller: _apellidoCtrl, required: true)),
        ]),
        const SizedBox(height: 14),
        AppField(label: 'Cédula', controller: _cedulaCtrl, required: true, keyboardType: TextInputType.number),
        const SizedBox(height: 14),
        AppField(label: 'Teléfono', controller: _telCtrl, keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        AppField(label: 'Correo Electrónico', controller: _correoCtrl, required: true, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 24),
        SizedBox(height: 50, child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.cliente != null ? 'Actualizar' : 'Guardar'),
        )),
      ])),
    )),
  );
}
