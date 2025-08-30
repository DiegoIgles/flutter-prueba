import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/token_response.dart';

class AuthService {
  static const String _baseUrl = 'http://11.0.1.176:8000/api';

  Future<TokenResponse> loginCliente(LoginRequest req) async {
    final uri = Uri.parse('$_baseUrl/clientes/login');

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
        final tokenRes = TokenResponse.fromJson(body);

        print('✅ Token recibido: ${tokenRes.accessToken}');
        return tokenRes;
      } else {
        throw Exception('❌ Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('🚨 Error en loginCliente: $e');
      rethrow;
    }
  }
}
