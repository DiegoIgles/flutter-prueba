import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class ChoferNotificacion {
  final String clienteNombre;
  final double monto;
  final String msg;
  final String id;
  ChoferNotificacion({
    required this.clienteNombre,
    required this.monto,
    required this.msg,
    required this.id,
  });
}

class ChoferNotificacionService with ChangeNotifier {
  IO.Socket? _socket;
  final List<ChoferNotificacion> _notificaciones = [];

  List<ChoferNotificacion> get notificaciones => List.unmodifiable(_notificaciones);

  void start(String token) {
    _socket = IO.io(
      'http://11.0.1.176:8000/driver',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/ws/socket.io')
          .setAuth({'token': token})
          .build(),
    );
    _socket!.onConnect((_) {
      // print('Conectado como chofer');
    });
    _socket!.on('notificacion_pago', (data) {
      final noti = ChoferNotificacion(
        clienteNombre: data['cliente_nombre'] ?? '',
        monto: (data['monto'] as num?)?.toDouble() ?? 0.0,
        msg: data['msg'] ?? '',
        id: UniqueKey().toString(),
      );
      _notificaciones.add(noti);
      notifyListeners();
    });
    _socket!.onDisconnect((_) {
      // print('Desconectado chofer');
    });
  }

  void clearNotificacion(String id) {
    _notificaciones.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void disposeSocket() {
    _socket?.dispose();
    _socket = null;
  }
}
