import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/destinos_screen.dart';
import 'screens/paquetes_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/pagos_screen.dart';
import 'screens/guias_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access');
  runApp(AgenciaApp(initialRoute: token != null ? '/dashboard' : '/'));
}

class AgenciaApp extends StatelessWidget {
  final String initialRoute;
  const AgenciaApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agencia de Viajes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: initialRoute,
      routes: {
        '/':          (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/clientes':  (_) => const ClientesScreen(),
        '/destinos':  (_) => const DestinosScreen(),
        '/paquetes':  (_) => const PaquetesScreen(),
        '/reservas':  (_) => const ReservasScreen(),
        '/pagos':     (_) => const PagosScreen(),
        '/guias':     (_) => const GuiasScreen(),
      },
    );
  }
}
