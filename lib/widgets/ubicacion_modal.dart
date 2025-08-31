import 'package:flutter/material.dart';
import 'package:location/location.dart';

class UbicacionModal extends StatefulWidget {
  const UbicacionModal({super.key});

  @override
  State<UbicacionModal> createState() => _UbicacionModalState();
}

class _UbicacionModalState extends State<UbicacionModal> {
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
