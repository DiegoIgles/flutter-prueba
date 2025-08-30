import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_request.dart';
import '../models/token_response.dart';

class AuthService {
  // Ajusta según emulador/dispositivo
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const _storage = FlutterSecureStorage();

  Future<TokenResponse> loginCliente(LoginRequest req) async {
    final uri = Uri.parse('$baseUrl/clientes/login');
    print('🌐 Enviando POST a $uri...');
    print('📤 Payload: ${jsonEncode(req.toJson())}');

    try {
      final res = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(req.toJson()),
      );

      print('📥 StatusCode: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final tokenRes = TokenResponse.fromJson(jsonDecode(res.body));
        print('✅ Token recibido (cliente): ${tokenRes.accessToken}');
        return tokenRes;
      } else {
        throw Exception('❌ Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('🚨 Error en loginCliente: $e');
      rethrow;
    }
  }

  Future<TokenResponse> loginChofer(LoginRequest req) async {
    // Cambia el path si tu backend usa otro (p.ej. /drivers/login)
    final uri = Uri.parse('$baseUrl/login');

    print('🌐 POST $uri');
    print('📤 Payload: ${jsonEncode(req.toJson())}');

    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(req.toJson()),
    );

    print('📥 StatusCode: ${res.statusCode}');
    print('📥 Body: ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201) {
      final tokenRes = TokenResponse.fromJson(jsonDecode(res.body));
      await _saveToken('token_chofer', tokenRes);
      print('✅ Token CHOFER guardado');
      return tokenRes;
    } else {
      throw Exception('❌ Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> _saveToken(String key, TokenResponse token) async {
    await _storage.write(key: key, value: token.accessToken);
  }

  Future<String?> getToken({required bool chofer}) async {
    return _storage.read(key: chofer ? 'token_chofer' : 'token_cliente');
  }

  Future<void> logout({required bool chofer}) async {
    await _storage.delete(key: chofer ? 'token_chofer' : 'token_cliente');
  }

  Future<Map<String, String>> authHeaders({required bool chofer}) async {
    final token = await getToken(chofer: chofer);
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}