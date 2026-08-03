import 'package:flutter/material.dart';
import 'login_page.dart';

class DashboardPage extends StatelessWidget {
  final String username;

  const DashboardPage({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff111827),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_done_rounded,
              color: Colors.lightBlueAccent,
            ),
            SizedBox(width: 10),
            Text(
              "Business Manager",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Cerrar sesión",
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //================ BIENVENIDA =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff2563EB),
                    Color(0xff7C3AED),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Text(
                      username.isNotEmpty
                          ? username[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Bienvenido, ${username.isNotEmpty ? username : "Usuario"}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Has iniciado sesión correctamente.\nTodos los servicios se encuentran activos.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [

                      _statusChip(
                        Icons.check_circle,
                        "API Online",
                        Colors.greenAccent,
                      ),

                      const SizedBox(width: 10),

                      _statusChip(
                        Icons.lock,
                        "JWT Activo",
                        Colors.orangeAccent,
                      ),

                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Resumen del Sistema",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: _miniCard(
                    "Servicios",
                    "4",
                    Icons.apps,
                    Colors.cyan,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _miniCard(
                    "Estado",
                    "OK",
                    Icons.verified,
                    Colors.green,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 25),

            _dashboardCard(
              Icons.api,
              "API REST",
              "Todos los endpoints están disponibles para ser consumidos.",
              Colors.lightBlueAccent,
            ),

            const SizedBox(height: 15),

            _dashboardCard(
              Icons.security,
              "Autenticación JWT",
              "Tu token de acceso ha sido validado exitosamente.",
              Colors.orangeAccent,
            ),

            const SizedBox(height: 15),

            _dashboardCard(
              Icons.storage,
              "Servidor",
              "El backend responde correctamente a las solicitudes.",
              Colors.greenAccent,
            ),

            const SizedBox(height: 15),

            _dashboardCard(
              Icons.cloud_done,
              "Conectividad",
              "Comunicación estable entre Flutter y Django REST.",
              Colors.purpleAccent,
            ),

            const SizedBox(height: 35),

            const Center(
              child: Text(
                "Powered by Flutter + Django REST Framework",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _statusChip(
      IconData icon,
      String text,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _miniCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xff1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: color,
            size: 34,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget _dashboardCard(
      IconData icon,
      String title,
      String description,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [

          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}