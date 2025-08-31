import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../services/chofer_notificacion_service.dart';
import 'chofer_notificacion_page.dart';


class ViajeDetallePage extends StatefulWidget {
  final int viajeId;
  final String monto;
  final String token; // Token del chofer
  final int? clienteId; // <-- Nuevo: para el lado cliente
  final int? choferId;  // <-- Nuevo: para el lado chofer

  const ViajeDetallePage({
    super.key,
    required this.viajeId,
    required this.monto,
    required this.token,
    this.clienteId,
    this.choferId,
  });

  @override
  State<ViajeDetallePage> createState() => _ViajeDetallePageState();
}

class _ViajeDetallePageState extends State<ViajeDetallePage> {
  GoogleMapController? _mapController;
  LocationData? _ubicacion;
  final Location _location = Location();
  StreamSubscription<LocationData>? _ubicacionSubscription;
  late IO.Socket socket;


  @override
  void initState() {
    super.initState();
    _conectarSocket();
    _iniciarSeguimientoUbicacion();
  }

  void _conectarSocket() {
    socket = IO.io(
      'http://127.0.0.1:8000/driver', // Namespace en la URL
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setPath('/ws/socket.io')
        .setAuth({'token': widget.token})
        .build(),
    );

    socket.onConnect((_) => print('Socket chofer conectado'));
    socket.onDisconnect((_) => print('Socket chofer desconectado'));

    // --- LADO CLIENTE: enviar ubicación con cliente_id ---
    if (widget.clienteId != null) {
      _location.onLocationChanged.listen((ubicacion) {
        if (socket.connected) {
          socket.emit('my_location', {
            'lat': ubicacion.latitude,
            'lng': ubicacion.longitude,
            'accuracy': ubicacion.accuracy,
            'ts': DateTime.now().millisecondsSinceEpoch,
            'cliente_id': widget.clienteId, // <-- aquí
          });
        }
      });
    }
  }

  Future<void> _iniciarSeguimientoUbicacion() async {
    final permiso = await _location.requestPermission();
    if (permiso == PermissionStatus.granted || permiso == PermissionStatus.grantedLimited) {
      bool habilitado = await _location.serviceEnabled();
      if (!habilitado) {
        habilitado = await _location.requestService();
      }

      if (habilitado) {
        // Mejorar precisión y frecuencia
        await _location.changeSettings(
          accuracy: LocationAccuracy.high,
          interval: 2000, // cada 2 segundos
          distanceFilter: 1, // mínimo 1 metro de diferencia
        );

        _ubicacionSubscription = _location.onLocationChanged.listen((loc) {
          print('📍 Nueva ubicación: ${loc.latitude}, ${loc.longitude}');
          setState(() => _ubicacion = loc);
          if (_mapController != null && loc.latitude != null && loc.longitude != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(loc.latitude!, loc.longitude!),
              ),
            );
          }
          if (socket.connected) {
            // --- LADO CHOFER: enviar ubicación con viaje_id y chofer_id ---
            socket.emit('location', {
              'lat': loc.latitude,
              'lng': loc.longitude,
              'ts': DateTime.now().millisecondsSinceEpoch,
              'viaje_id': widget.viajeId, // <-- aquí
              'chofer_id': widget.choferId, // <-- aquí
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _ubicacionSubscription?.cancel();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lat = _ubicacion?.latitude?.toStringAsFixed(6) ?? 'Cargando...';
    final lon = _ubicacion?.longitude?.toStringAsFixed(6) ?? 'Cargando...';

    return ChangeNotifierProvider(
      create: (_) {
        final service = ChoferNotificacionService();
        service.start(widget.token);
        return service;
      },
      child: Builder(
        builder: (context) => Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF5F6FA),
              appBar: AppBar(
                title: const Text(
                  'Detalle del viaje',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF0B0530),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: _ubicacion == null
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(_ubicacion!.latitude!, _ubicacion!.longitude!),
                              zoom: 17,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onMapCreated: (controller) => _mapController = controller,
                          ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildCard(
                          icon: Icons.directions_bus,
                          title: 'ID del viaje',
                          value: widget.viajeId.toString(),
                        ),
                        const SizedBox(height: 16),
                        _buildCard(
                          icon: Icons.attach_money,
                          title: 'Monto',
                          value: widget.monto,
                        ),
                        const SizedBox(height: 16),
                        _buildCard(
                          icon: Icons.location_on,
                          title: 'Ubicación actual',
                          value: 'Latitud: $lat\nLongitud: $lon',
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            'Puedes ahora continuar con tu viaje...',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const ChoferNotificacionPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0B0530), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
