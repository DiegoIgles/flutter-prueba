
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
class UbicacionModal extends StatefulWidget {
  final String token;
  const UbicacionModal({Key? key, required this.token}) : super(key: key);

  @override
  State<UbicacionModal> createState() => _UbicacionModalState();
}

class _UbicacionModalState extends State<UbicacionModal> {
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
      'http://11.0.1.176:8000/user',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setPath('/ws/socket.io')
        .setAuth({'token': widget.token})
        .build(),
    );
    socket.onConnect((_) => print('Socket cliente conectado (modal)'));
    socket.onDisconnect((_) => print('Socket cliente desconectado (modal)'));
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

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📍 Tu ubicación en tiempo real',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Latitud: $lat', style: const TextStyle(fontSize: 16)),
          Text('Longitud: $lon', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
