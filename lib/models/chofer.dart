class Chofer {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String? ci;
  final String? telefono;

  Chofer({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.ci,
    this.telefono,
  });

  factory Chofer.fromJson(Map<String, dynamic> json) {
    return Chofer(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      ci: json['ci'] as String?,
      telefono: json['telefono'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      if (ci != null) 'ci': ci,
      if (telefono != null) 'telefono': telefono,
    };
  }
}

class ChoferLogin {
  final String email;
  final String password;

  ChoferLogin({
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

class ChoferAuthResponse {
  final String accessToken;
  final String tokenType;
  final Chofer? user;

  ChoferAuthResponse({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });

  factory ChoferAuthResponse.fromJson(Map<String, dynamic> json) {
    return ChoferAuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: json['user'] != null ? Chofer.fromJson(json['user']) : null,
    );
  }
}
