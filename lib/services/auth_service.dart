import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/token_response.dart';
import '../models/cliente_create.dart';
import '../models/cliente.dart';
import 'session_cache_service.dart';

class AuthService {
  static const String baseUrl = 'http://11.0.1.204:8000/api';

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
        
        // Obtener datos del cliente y guardar en caché
        final cliente = await getCurrentCliente();
        if (cliente != null) {
          await SessionCacheService.saveClienteSession(
            token: tokenRes.accessToken,
            cliente: cliente,
          );
        }
        
        print('✅ Token recibido y guardado en caché (cliente): $_tokenCliente');
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
      
      // Guardar en caché (sin datos adicionales por ahora)
      await SessionCacheService.saveChoferSession(
        token: tokenRes.accessToken,
      );
      
      print('✅ Token CHOFER recibido y guardado en caché');
      return tokenRes;
    } else {
      throw Exception('❌ Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<String?> getToken({required bool chofer}) async {
    // Primero intentar obtener del caché
    String? cachedToken;
    if (chofer) {
      cachedToken = await SessionCacheService.getChoferToken();
    } else {
      cachedToken = await SessionCacheService.getClienteToken();
    }
    
    // Si hay token en caché, actualizar la variable en memoria y devolverlo
    if (cachedToken != null && cachedToken.isNotEmpty) {
      if (chofer) {
        _tokenChofer = cachedToken;
      } else {
        _tokenCliente = cachedToken;
      }
      return cachedToken;
    }
    
    // Si no hay en caché, devolver el que está en memoria
    return chofer ? _tokenChofer : _tokenCliente;
  }

  Future<void> logout({required bool chofer}) async {
    // Limpiar de memoria
    if (chofer) {
      _tokenChofer = null;
      // Limpiar del caché
      await SessionCacheService.clearChoferSession();
    } else {
      _tokenCliente = null;
      // Limpiar del caché
      await SessionCacheService.clearClienteSession();
    }
    
    print('🚪 Sesión cerrada y caché limpiado para ${chofer ? 'chofer' : 'cliente'}');
  }

  // Nuevo método para cargar sesión desde caché al iniciar la app
  Future<void> loadSessionFromCache() async {
    final clienteToken = await SessionCacheService.getClienteToken();
    final choferToken = await SessionCacheService.getChoferToken();
    
    if (clienteToken != null && clienteToken.isNotEmpty) {
      _tokenCliente = clienteToken;
      print('🔄 Sesión de cliente cargada desde caché');
    }
    
    if (choferToken != null && choferToken.isNotEmpty) {
      _tokenChofer = choferToken;
      print('🔄 Sesión de chofer cargada desde caché');
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
