class Vehiculo {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final int capacidad;
  final String estado;
  final int tipoId;
  final int choferId;

  Vehiculo({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.capacidad,
    required this.estado,
    required this.tipoId,
    required this.choferId,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) => Vehiculo(
        id: json['id'] as int,
        placa: json['placa'] as String,
        marca: json['marca'] as String,
        modelo: json['modelo'] as String,
        anio: json['anio'] as int,
        capacidad: json['capacidad'] as int,
        estado: json['estado'] as String,
        tipoId: json['tipo_id'] as int,
        choferId: json['chofer_id'] as int,
      );
}
