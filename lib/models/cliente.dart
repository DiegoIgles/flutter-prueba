class Cliente {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;

  Cliente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      telefono: json['telefono'],
    );
  }
}
