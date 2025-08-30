import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'cliente_login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final bool isLoggedIn = false; // Cambiar a true si el usuario inicia sesión

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4F46E5);
    const topBar = Color(0xFF0B0530);

    return Scaffold(
      drawer: isLoggedIn ? const AppSidebar() : null, // solo si está logueado
      appBar: AppBar(
        backgroundColor: topBar,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: isLoggedIn
            ? null
            : TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClienteLoginPage()),
                  );
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Iniciar sesión',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDEDED), Color(0xFF8B8B8B)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoleCard(
                    icon: Icons.person,
                    label: 'Cliente',
                    color: purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClienteLoginPage()),
                      );
                    },
                  ),
                  _RoleCard(
                    icon: Icons.drive_eta,
                    label: 'Chofer',
                    color: purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login de chofer aún no implementado')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 12),
                color: Colors.black.withOpacity(0.15),
              ),
            ],
          ),
          child: Icon(icon, size: 56, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: Colors.black.withOpacity(0.35),
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
