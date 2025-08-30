import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/cliente.dart';
import '../models/chofer.dart';
import 'api_config.dart';

class AuthService {
  static Future<AuthResponse> loginCliente(ClienteLogin loginData) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.clienteLoginUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(loginData.toJson()),
          )
          .timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw AuthException(
          message: error['detail'] ?? 'Error en el login',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw AuthException(
        message:
            'No se pudo conectar al servidor. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } on HttpException {
      throw AuthException(
        message: 'Error de conexión con el servidor.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  static Future<ChoferAuthResponse> loginChofer(ChoferLogin loginData) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.choferLoginUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(loginData.toJson()),
          )
          .timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ChoferAuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw AuthException(
          message: error['detail'] ?? 'Error en el login',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw AuthException(
        message:
            'No se pudo conectar al servidor. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } on HttpException {
      throw AuthException(
        message: 'Error de conexión con el servidor.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  static Future<Cliente> registerCliente(ClienteCreate clienteData) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.clienteRegisterUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(clienteData.toJson()),
          )
          .timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Cliente.fromJson(data);
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        String errorMessage = 'Error en el registro';

        // Manejar diferentes tipos de errores
        if (error['detail'] != null) {
          if (error['detail'] is String) {
            errorMessage = error['detail'];
          } else if (error['detail'] is List) {
            errorMessage = error['detail'].join(', ');
          }
        }

        throw AuthException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw AuthException(
        message:
            'No se pudo conectar al servidor. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } on HttpException {
      throw AuthException(
        message: 'Error de conexión con el servidor.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Método para validar el formato del email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Método para validar la fortaleza de la contraseña
  static bool isValidPassword(String password) {
    // Al menos 6 caracteres para la demo
    return password.length >= 6;
  }

  // Método para validar el teléfono (formato boliviano)
  static bool isValidPhone(String phone) {
    // Permitir números bolivianos: +591XXXXXXXX o solo números
    return RegExp(r'^(\+591)?[67]\d{7}$').hasMatch(phone.replaceAll(' ', ''));
  }
}

class AuthException implements Exception {
  final String message;
  final int statusCode;

  AuthException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'AuthException: $message (Status: $statusCode)';
  }
}
