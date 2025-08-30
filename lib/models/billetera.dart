class Billetera {
  final int id;
  final int clienteId;
  final double saldo;
  final String moneda;

  Billetera({
    required this.id,
    required this.clienteId,
    required this.saldo,
    required this.moneda,
  });

  factory Billetera.fromJson(Map<String, dynamic> json) {
    return Billetera(
      id: json['id'],
      clienteId: json['cliente_id'],
      saldo: double.parse(json['saldo'].toString()),
      moneda: json['moneda'] ?? 'BOB',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'saldo': saldo,
      'moneda': moneda,
    };
  }
}

class BilleteraSaldoResponse {
  final bool ok;
  final int billeteraId;
  final String saldo;
  final String moneda;

  BilleteraSaldoResponse({
    required this.ok,
    required this.billeteraId,
    required this.saldo,
    required this.moneda,
  });

  factory BilleteraSaldoResponse.fromJson(Map<String, dynamic> json) {
    return BilleteraSaldoResponse(
      ok: json['ok'] ?? true,
      billeteraId: json['billetera_id'],
      saldo: json['saldo'].toString(),
      moneda: json['moneda'] ?? 'BOB',
    );
  }
}

class BilleteraCargaRequest {
  final int billeteraId;
  final double monto;
  final String concepto;

  BilleteraCargaRequest({
    required this.billeteraId,
    required this.monto,
    required this.concepto,
  });

  Map<String, dynamic> toJson() {
    return {
      'billetera_id': billeteraId,
      'monto': monto,
      'concepto': concepto,
    };
  }
}

class BilleteraCargaResponse {
  final bool ok;
  final int billeteraId;
  final String saldo;

  BilleteraCargaResponse({
    required this.ok,
    required this.billeteraId,
    required this.saldo,
  });

  factory BilleteraCargaResponse.fromJson(Map<String, dynamic> json) {
    return BilleteraCargaResponse(
      ok: json['ok'],
      billeteraId: json['billetera_id'],
      saldo: json['saldo'].toString(),
    );
  }
}
