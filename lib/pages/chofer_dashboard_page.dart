import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'chofer_mis_vehiculos_page.dart';
import 'chofer_billetera_page.dart';
import 'chofer_movimientos_page.dart';
import 'chofer_retirar_page.dart';

class ChoferDashboardPage extends StatefulWidget {
  final String token;

  const ChoferDashboardPage({
    super.key,
    required this.token,
  });

  @override
  State<ChoferDashboardPage> createState() => _ChoferDashboardPageState();
}

class _ChoferDashboardPageState extends State<ChoferDashboardPage> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages.addAll([
      ChoferMisVehiculosPage(token: widget.token),
      const ChoferBilleteraPage(),
      const ChoferMovimientosPage(),
      const ChoferRetirarPage(),
    ]);
  }

  Future<void> _logout() async {
    await _authService.logout(chofer: true);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: const Color(0xFF0B0530),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF197B9C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Mis Vehículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Mi Billetera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Movimientos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Retirar',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Mis Vehículos';
      case 1:
        return 'Mi Billetera';
      case 2:
        return 'Movimientos';
      case 3:
        return 'Retirar';
      default:
        return 'Panel Chofer';
    }
  }
}
