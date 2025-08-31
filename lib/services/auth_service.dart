import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/token_response.dart';
import '../models/cliente_create.dart';
import '../models/cliente.dart';

class AuthService {
  static const String baseUrl = 'http://11.0.1.176:8000/api';

  // Almacén temporal de tokens en memoria
  static String? _tokenCliente;
  static String? _tokenChofer;

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
        _tokenCliente = tokenRes.accessToken;
        print('✅ Token recibido (cliente): $_tokenCliente');
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
      _tokenChofer = tokenRes.accessToken;
      print('✅ Token CHOFER recibido');
      return tokenRes;
    } else {
      throw Exception('❌ Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<String?> getToken({required bool chofer}) async {
    return chofer ? _tokenChofer : _tokenCliente;
  }

  Future<void> logout({required bool chofer}) async {
    if (chofer) {
      _tokenChofer = null;
    } else {
      _tokenCliente = null;
    }
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
