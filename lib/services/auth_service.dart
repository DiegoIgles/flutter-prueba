import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_request.dart';
import '../models/token_response.dart';
import '../models/cliente_create.dart';
import '../models/cliente.dart';

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
  Future<Cliente> registerCliente(ClienteCreate req) async {
    final uri = Uri.parse('$baseUrl/clientes/register');

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
        final Map<String, dynamic> body = jsonDecode(res.body);
        final cliente = Cliente.fromJson(body);

        print('✅ Cliente registrado: ${cliente.nombre}');
        return cliente;
      } else {
        throw Exception('❌ Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('🚨 Error en registerCliente: $e');
      rethrow;
    }
  }
  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Token JWT inválido');
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  Future<int?> getChoferIdFromToken() async {
    final token = await getToken(chofer: true);
    if (token == null || token.isEmpty) return null;

    final payload = _decodeJwtPayload(token);
    final sub = payload['sub'];
    if (sub is Map && sub['sub'] != null) {
      return int.tryParse(sub['sub'].toString());
    }
    if (payload['sub'] != null) {
      return int.tryParse(payload['sub'].toString());
    }
    return null;
  }
}
