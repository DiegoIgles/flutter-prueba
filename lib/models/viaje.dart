class ViajeStartRequest {
  final int vehiculoId;
  ViajeStartRequest({required this.vehiculoId});
  Map<String, dynamic> toJson() => {'vehiculo_id': vehiculoId};
}

class ViajeStartResponse {
  final int viajeId;
  final String estado;
  final String monto; // string según tu service
  ViajeStartResponse({required this.viajeId, required this.estado, required this.monto});
  factory ViajeStartResponse.fromJson(Map<String, dynamic> json) => ViajeStartResponse(
    viajeId: json['viaje_id'] as int,
    estado: json['estado'] as String,
    monto: json['monto'] as String,
  );
}

class ViajeFinishRequest {
  final int viajeId;
  ViajeFinishRequest({required this.viajeId});
  Map<String, dynamic> toJson() => {'viaje_id': viajeId};
}

class ViajeFinishResponse {
  final bool ok;
  final String estado;
  ViajeFinishResponse({required this.ok, required this.estado});
  factory ViajeFinishResponse.fromJson(Map<String, dynamic> json) => ViajeFinishResponse(
    ok: (json['ok'] as bool?) ?? true,
    estado: (json['estado'] as String?) ?? 'FINALIZADO',
  );
}
