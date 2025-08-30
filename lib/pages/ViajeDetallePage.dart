import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class ViajeDetallePage extends StatefulWidget {
  final int viajeId;
  final String monto;

  const ViajeDetallePage({
    super.key,
    required this.viajeId,
    required this.monto,
  });

  @override
  State<ViajeDetallePage> createState() => _ViajeDetallePageState();
}

class _ViajeDetallePageState extends State<ViajeDetallePage> {
  LocationData? _ubicacion;
  final Location _location = Location();
  StreamSubscription<LocationData>? _ubicacionSubscription;

  @override
  void initState() {
    super.initState();
    _iniciarSeguimientoUbicacion();
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
        });
      }
    }
  }

  @override
  void dispose() {
    _ubicacionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lat = _ubicacion?.latitude?.toStringAsFixed(5) ?? '...';
    final lon = _ubicacion?.longitude?.toStringAsFixed(5) ?? '...';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Detalle del viaje',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0B0530),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
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
