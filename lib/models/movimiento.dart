class Movimiento {
  final int id;
  final int billeteraId;
  final String tipo;
  final double monto;
  final String? concepto;
  final DateTime fecha;

  Movimiento({
    required this.id,
    required this.billeteraId,
    required this.tipo,
    required this.monto,
    this.concepto,
    required this.fecha,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      billeteraId: json['billetera_id'],
      tipo: json['tipo'],
      monto: double.parse(json['monto'].toString()),
      concepto: json['concepto'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billetera_id': billeteraId,
      'tipo': tipo,
      'monto': monto,
      'concepto': concepto,
      'fecha': fecha.toIso8601String(),
    };
  }

  String get tipoDisplayName {
    switch (tipo) {
      case 'CARGA':
        return 'Recarga';
      case 'PAGO':
        return 'Pago';
      case 'AJUSTE':
        return 'Ajuste';
      default:
        return tipo;
    }
  }

  String get montoFormateado {
    return '${monto >= 0 ? '+' : ''}${monto.toStringAsFixed(2)} BOB';
  }
}
