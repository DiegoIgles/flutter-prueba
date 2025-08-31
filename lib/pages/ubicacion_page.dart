import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class UbicacionPage extends StatefulWidget {
  final String token;
  const UbicacionPage({Key? key, required this.token}) : super(key: key);

  @override
  State<UbicacionPage> createState() => _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  LocationData? _ubicacionActual;
  final Location _location = Location();
  GoogleMapController? _mapController;
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
      if (_mapController != null && ubicacion.latitude != null && ubicacion.longitude != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(ubicacion.latitude!, ubicacion.longitude!),
          ),
        );
      }
      // Enviar ubicación por socket
      if (socket.connected) {
        socket.emit('my_location', {
          'lat': ubicacion.latitude,
          'lng': ubicacion.longitude,
          'accuracy': ubicacion.accuracy,
          'ts': DateTime.now().millisecondsSinceEpoch,
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
    final lat = _ubicacionActual?.latitude?.toStringAsFixed(6) ?? 'Cargando...';
    final lon = _ubicacionActual?.longitude?.toStringAsFixed(6) ?? 'Cargando...';
    final acc = _ubicacionActual?.accuracy?.toStringAsFixed(2) ?? 'Cargando...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación en tiempo real'),
        backgroundColor: const Color(0xFF0B0530),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _ubicacionActual == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_ubicacionActual!.latitude!, _ubicacionActual!.longitude!),
                      zoom: 17,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (controller) => _mapController = controller,
                  ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latitud: $lat', style: const TextStyle(fontSize: 16)),
                    Text('Longitud: $lon', style: const TextStyle(fontSize: 16)),
                    Text('Precisión: $acc m', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
