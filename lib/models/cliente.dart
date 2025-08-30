class Cliente {
  final int id;
  final String nombre;
  final String email;

  Cliente({required this.id, required this.nombre, required this.email});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
    );
  }
}
