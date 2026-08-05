import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _username = '';
  Map<String, int> _counts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _username = await ApiService.getUsername();
      final results = await Future.wait([
        ApiService.getList('clientes/clientes/').catchError((_) => []),
        ApiService.getList('destinos/').catchError((_) => []),
        ApiService.getList('paquetes/').catchError((_) => []),
        ApiService.getList('reservas/').catchError((_) => []),
        ApiService.getList('pagos/').catchError((_) => []),
        ApiService.getList('guias/').catchError((_) => []),
      ]);
      setState(() {
        _counts = {
          'Clientes': results[0].length,
          'Destinos': results[1].length,
          'Paquetes': results[2].length,
          'Reservas': results[3].length,
          'Pagos':    results[4].length,
          'Guías':    results[5].length,
        };
      });
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  final _modules = [
    {'label': 'Clientes',  'icon': Icons.people_outline,    'color': const Color(0xFF34D399), 'route': '/clientes'},
    {'label': 'Destinos',  'icon': Icons.location_on_outlined,'color': const Color(0xFF818CF8),'route': '/destinos'},
    {'label': 'Paquetes',  'icon': Icons.card_travel_outlined,'color': const Color(0xFFFB923C),'route': '/paquetes'},
    {'label': 'Reservas',  'icon': Icons.calendar_month_outlined,'color': const Color(0xFF38BDF8),'route': '/reservas'},
    {'label': 'Pagos',     'icon': Icons.credit_card_outlined,'color': const Color(0xFFA78BFA),'route': '/pagos'},
    {'label': 'Guías',     'icon': Icons.badge_outlined,     'color': const Color(0xFFF472B6),'route': '/guias'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load,
              tooltip: 'Actualizar'),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _load,
        child: _loading
            ? const LoadingWidget()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Bienvenida
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withOpacity(.2), AppTheme.surface],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withOpacity(.2)),
                    ),
                    child: Row(children: [
                      const Text('✈️', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('¡Hola, $_username!',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        const Text('Bienvenido a Agencia de Viajes',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  const Text('Resumen General',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 14),

                  // Stats grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12,
                      mainAxisSpacing: 12, childAspectRatio: 0.9,
                    ),
                    itemCount: _modules.length,
                    itemBuilder: (_, i) {
                      final m = _modules[i];
                      return StatCard(
                        label: m['label'] as String,
                        value: _counts[m['label']] ?? 0,
                        icon: m['icon'] as IconData,
                        color: m['color'] as Color,
                        onTap: () => Navigator.pushNamed(context, m['route'] as String)
                            .then((_) => _load()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Accesos rápidos
                  const Text('Acceso Rápido',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  ..._modules.map((m) => _QuickTile(
                    label: m['label'] as String,
                    icon: m['icon'] as IconData,
                    color: m['color'] as Color,
                    onTap: () => Navigator.pushNamed(context, m['route'] as String)
                        .then((_) => _load()),
                  )),
                ]),
              ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(child: Column(children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary.withOpacity(.2), AppTheme.surface],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('✈️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            const Text('Agencia de Viajes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            Text(context.mounted ? _username : '',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(child: ListView(padding: EdgeInsets.zero, children: [
          _DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', onTap: () => Navigator.pop(context)),
          const Divider(height: 1),
          ..._modules.map((m) => _DrawerItem(
            icon: m['icon'] as IconData,
            label: m['label'] as String,
            color: m['color'] as Color,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, m['route'] as String).then((_) => _load());
            },
          )),
        ])),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: AppTheme.error),
          title: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
          onTap: _logout,
        ),
      ])),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? AppTheme.textMuted, size: 22),
    title: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
    onTap: onTap,
    horizontalTitleGap: 8,
  );
}

class _QuickTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickTile({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 14),
        Expanded(child: Text(label,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
      ]),
    ),
  );
}
