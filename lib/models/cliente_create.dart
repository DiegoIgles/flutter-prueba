class ClienteCreate {
  final String nombre;
  final String apellido;
  final String email;
  final String password;
  final String? telefono;

  ClienteCreate({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.password,
    this.telefono,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'password': password,
      if (telefono != null && telefono!.isNotEmpty) 'telefono': telefono,
    };
  }
}
