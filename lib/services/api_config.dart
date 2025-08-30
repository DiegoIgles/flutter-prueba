class ApiConfig {
  // URL base del backend - cambia esta URL según tu configuración
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // URLs específicas
  static const String clienteLoginUrl = '$baseUrl/clientes/login';
  static const String clienteRegisterUrl = '$baseUrl/clientes/register';
  static const String choferLoginUrl = '$baseUrl/login';

  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout por defecto
  static const Duration defaultTimeout = Duration(seconds: 30);
}
