import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:prueba/widgets/sidebar.dart'; // Asegúrate que esta ruta esté correcta

class ClienteWelcomePage extends StatefulWidget {
  final String token;
  const ClienteWelcomePage({super.key, required this.token});

  @override
  State<ClienteWelcomePage> createState() => _ClienteWelcomePageState();
}

class _ClienteWelcomePageState extends State<ClienteWelcomePage> {
  LocationData? _ubicacionActual;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _pedirPermisosYEscuchar();
  }

  Future<void> _pedirPermisosYEscuchar() async {
    bool servicioHabilitado = await _location.serviceEnabled();
    if (!servicioHabilitado) {
      servicioHabilitado = await _location.requestService();
      if (!servicioHabilitado) return;
    }

    PermissionStatus permiso = await _location.hasPermission();
    if (permiso == PermissionStatus.denied) {
      permiso = await _location.requestPermission();
      if (permiso != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((ubicacion) {
      setState(() {
        _ubicacionActual = ubicacion;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lat = _ubicacionActual?.latitude?.toStringAsFixed(5) ?? 'Cargando...';
    final lon = _ubicacionActual?.longitude?.toStringAsFixed(5) ?? 'Cargando...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido Cliente'),
        backgroundColor: const Color(0xFF0B0530), // Color oscuro
        foregroundColor: Colors.white, // Texto e íconos en blanco
      ),
      drawer: const AppSidebar(), // Asegúrate de pasar el ID correcto
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Bienvenido 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const Text(
              '📍 Tu ubicación en tiempo real:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('Latitud: $lat', style: const TextStyle(fontSize: 16)),
            Text('Longitud: $lon', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
