import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:location/location.dart';
import 'package:flutter/material.dart';

class ClienteSockets {
  late IO.Socket socket;
  final Location _location = Location();
  final List<Map<String, dynamic>> _tickets = [];
  final ValueNotifier<List<Map<String, dynamic>>> ticketsNotifier = ValueNotifier([]);
  bool _initialized = false;

  void start(String token, BuildContext context) {
    if (_initialized) return;
    _initialized = true;
    socket = IO.io(
      'http://11.0.1.176:8000/user',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setPath('/ws/socket.io')
        .setAuth({'token': token})
        .build(),
    );
    socket.onConnect((_) => print('Socket cliente conectado'));
    socket.on('ticket_offer', (data) {
      print('¡INTERSECTADO! Oferta recibida: $data');
      // Evita duplicados
      if (!_tickets.any((t) => t['ticket_id'] == data['ticket_id'])) {
        _tickets.add(data);
        ticketsNotifier.value = List.from(_tickets);
        // Aquí puedes mostrar una notificación local si quieres
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Nueva oferta de viaje recibida!')),
        );
      }
    });
    socket.onDisconnect((_) => print('Socket cliente desconectado'));
    _location.onLocationChanged.listen((ubicacion) {
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

  void dispose() {
    socket.dispose();
    ticketsNotifier.dispose();
  }
}
