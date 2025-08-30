class TipoVehiculo {
  final int id;
  final String nombre;

  TipoVehiculo({required this.id, required this.nombre});

  factory TipoVehiculo.fromJson(Map<String, dynamic> json) => TipoVehiculo(
        id: json['id'] as int,
        nombre: (json['nombre'] ?? json['name'] ?? 'Tipo').toString(),
      );
}
