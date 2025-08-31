import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:prueba/widgets/sidebar.dart'; // Asegúrate que esta ruta esté correcta
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ClienteWelcomePage extends StatefulWidget {
  final String token;
  const ClienteWelcomePage({super.key, required this.token});

  @override
  State<ClienteWelcomePage> createState() => _ClienteWelcomePageState();
}

class _ClienteWelcomePageState extends State<ClienteWelcomePage> {
  LocationData? _ubicacionActual;
  final Location _location = Location();
  late IO.Socket socket;


  @override
  void initState() {
    super.initState();
    _conectarSocket();
    _pedirPermisosYEscuchar();
  }

  void _conectarSocket() {
    socket = IO.io(
      'http://11.0.1.176:8000/user', // Namespace en la URL
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setPath('/ws/socket.io')
        .setAuth({'token': widget.token})
        .build(),
    );

    socket.onConnect((_) => print('Socket cliente conectado'));
    socket.on('ticket_offer', (data) {
      print('¡INTERSECTADO! Oferta recibida: $data');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¡Chofer cerca!'),
            content: Text('Se detectó un chofer cerca de ti.\n\nDatos: ${data.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
    socket.onDisconnect((_) => print('Socket cliente desconectado'));
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
      if (socket.connected) {
        socket.emit('my_location', {
          'lat': ubicacion.latitude,
          'lng': ubicacion.longitude,
        });
      }
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
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
