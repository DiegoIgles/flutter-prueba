import 'package:flutter/material.dart';
import 'package:prueba/pages/home_page.dart';

class AppSidebarChofer extends StatelessWidget {
  const AppSidebarChofer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SidebarHeader(),
            const Divider(height: 1),
            _item(
              context,
              icon: Icons.home_outlined,
              text: 'Vehiculos',
              onTap: () => Navigator.pop(context),
            ),
            _item(
              context,
              icon: Icons.account_circle_outlined,
              text: 'Perfil',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, '/perfil');
              },
            ),
            _item(
              context,
              icon: Icons.history,
              text: 'Dashboard',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, '/viajes');
              },
            ),
            _item(
              context,
              icon: Icons.account_balance_wallet_outlined,
              text: 'Billetera',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, '/billetera');
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Cierra el Drawer
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false, // Elimina todas las rutas anteriores
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: const CircleAvatar(
        child: Icon(Icons.person, size: 36),
      ),
      accountName: const Text('Invitado'),
      accountEmail: const Text(''),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0530),
      ),
    );
  }
}
