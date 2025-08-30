class Cliente {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;

  Cliente({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      if (telefono != null) 'telefono': telefono,
    };
  }
}

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
      if (telefono != null) 'telefono': telefono,
    };
  }
}

class ClienteLogin {
  final String email;
  final String password;

  ClienteLogin({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final Cliente? user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: json['user'] != null ? Cliente.fromJson(json['user']) : null,
    );
  }
}
