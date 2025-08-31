import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/token_response.dart';
import '../models/cliente_create.dart';
import '../models/cliente.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

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

  Future<int?> getClienteIdFromToken() async {
    final token = await getToken(chofer: false);
    print('🔐 Token para cliente: ${token?.substring(0, 50)}...');

    if (token == null || token.isEmpty) {
      print('❌ Token es null o vacío');
      return null;
    }

    try {
      final payload = _decodeJwtPayload(token);
      print('📋 Payload decodificado: $payload');

      final sub = payload['sub'];
      print('🔍 Sub encontrado: $sub (tipo: ${sub.runtimeType})');

      if (sub is Map && sub['sub'] != null) {
        final clienteId = int.tryParse(sub['sub'].toString());
        print('✅ Cliente ID desde sub.sub: $clienteId');
        return clienteId;
      }
      if (payload['sub'] != null) {
        final clienteId = int.tryParse(payload['sub'].toString());
        print('✅ Cliente ID desde sub: $clienteId');
        return clienteId;
      }
      if (payload['cliente_id'] != null) {
        final clienteId = int.tryParse(payload['cliente_id'].toString());
        print('✅ Cliente ID desde cliente_id: $clienteId');
        return clienteId;
      }
      print('❌ No se pudo extraer cliente ID del payload');
      return null;
    } catch (e) {
      print('🚨 Error decodificando token cliente: $e');
      return null;
    }
  }

  Future<Cliente?> getCurrentCliente() async {
    final clienteId = await getClienteIdFromToken();
    if (clienteId == null) return null;

    try {
      final uri = Uri.parse('$baseUrl/clientes/$clienteId');
      final headers = await authHeaders(chofer: false);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Cliente.fromJson(data);
      } else {
        print('❌ Error obteniendo cliente: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🚨 Error en getCurrentCliente: $e');
      return null;
    }
  }
}
