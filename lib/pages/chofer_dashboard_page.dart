import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/chofer_notificacion_service.dart';
import '../services/session_cache_service.dart';
import 'chofer_mis_vehiculos_page.dart';
import 'chofer_billetera_page.dart';
import 'chofer_movimientos_page.dart';
import 'chofer_retirar_page.dart';
import 'chofer_notificacion_page.dart';
import 'home_page.dart';

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
    try {
      // Cerrar sesión y limpiar caché
      await _authService.logout(chofer: true);
      print('🚪 Sesión de chofer cerrada correctamente');
      
      if (mounted) {
        // Navegar a la página principal
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cerrando sesión: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0530), Color(0xFF197B9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Panel de chofer profesional',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  color: Colors.white,
                  tooltip: 'Cerrar sesión',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = ChoferNotificacionService();
        service.start(widget.token);
        return service;
      },
      child: Builder(
        builder: (context) => Scaffold(
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
          body: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
              const ChoferNotificacionPage(),
            ],
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
        ),
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
