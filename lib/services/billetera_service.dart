import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/billetera.dart';
import '../models/movimiento.dart';
import 'auth_service.dart';

class BilleteraService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final AuthService _authService = AuthService();

  Future<BilleteraSaldoResponse> getSaldo(int clienteId) async {
    final uri = Uri.parse('$baseUrl/billeteras/$clienteId/saldo');

    print('🌐 Consultando saldo en $uri...');
    print('🔑 Cliente ID: $clienteId');

    try {
      final headers = await _authService.authHeaders(chofer: false);
      print('📤 Headers: $headers');

      final response = await http.get(uri, headers: headers);

      print('📥 StatusCode: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return BilleteraSaldoResponse.fromJson(data);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 Error en getSaldo: $e');
      rethrow;
    }
  }

  //generación y verificación de pago

  Map<String, dynamic> _cleanJson(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (v != null) out[k] = v; // NO mandamos null
    });
    return out;
  }

  String _toCurl({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required String? body,
    bool redactAuth = true,
  }) {
    final b = StringBuffer("curl -X '$method' \\\n  '${uri.toString()}'");
    final h = Map<String, String>.from(headers);
    if (redactAuth && h.containsKey('Authorization')) {
      final v = h['Authorization']!;
      h['Authorization'] =
          v.length > 24 ? '${v.substring(0, 24)}…(redacted)' : '…(redacted)';
    }
    for (final e in h.entries) {
      b.write(" \\\n  -H '${e.key}: ${e.value}'");
    }
    if (body != null && body.isNotEmpty) {
      b.write(" \\\n  -d '${body.replaceAll("'", r"'\''")}'");
    }
    return b.toString();
  }

  Map<String, String> _redactHeaders(Map<String, String> h) {
    final clone = Map<String, String>.from(h);
    if (clone.containsKey('Authorization')) {
      final v = clone['Authorization']!;
      clone['Authorization'] =
          v.length > 24 ? '${v.substring(0, 24)}…(redacted)' : '…(redacted)';
    }
    return clone;
  }

  Future<Map<String, dynamic>> generarQr({
    required double monto,
    String? vigencia,
    bool usoUnico = true,
    String? detalle,
  }) async {
    final uri = Uri.parse('$baseUrl/generar'); // tu backend expone /api/generar
    final baseHeaders = await _authService.authHeaders(chofer: false);

    // fuerza JSON y acepta JSON
    final headers = {
      ...baseHeaders,
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };

    // si no hay token, fallar explícito (evita "Cannot send Null")
    if (headers['Authorization'] == null || headers['Authorization']!.isEmpty) {
      throw Exception('No hay token Bearer. Inicia sesión nuevamente.');
    }

    final payload = _cleanJson({
      'monto': monto,
      'vigencia': vigencia, // solo si no es null
      'uso_unico': usoUnico,
      'detalle': detalle, // solo si no es null
    });

    final body = jsonEncode(payload);

    // LOGS
    debugPrint('🛰️ REQ POST $uri');
    debugPrint('🧾 Headers: ${{
      ...headers,
      if (headers.containsKey('Authorization'))
        'Authorization':
            '${headers['Authorization']!.substring(0, 24)}…(redacted)'
    }}');
    debugPrint('📦 Body: $body');
    debugPrint(_toCurl(method: 'POST', uri: uri, headers: headers, body: body));

    final res = await http.post(uri, headers: headers, body: body);

    debugPrint('⬅️ RES ${res.statusCode} ${res.reasonPhrase}');
    debugPrint('📨 Body: ${res.body}');

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('No autorizado. ¿Token expirado?');
    }
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if ((data['Codigo'] ?? 1) != 0) {
      throw Exception(data['Mensaje'] ?? 'No se pudo generar el QR');
    }
    return data;
  }

  Future<Map<String, dynamic>> verificarQr({required int movimientoId}) async {
  final uri = Uri.parse('$baseUrl/verificar');
  final baseHeaders = await _authService.authHeaders(chofer: false);
  final headers = {
    ...baseHeaders,
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };

  // ✅ el backend espera string
  final body = jsonEncode({'movimiento_id': movimientoId.toString()});

  final res = await http.post(uri, headers: headers, body: body);
  if (res.statusCode == 422) { throw Exception('422 Validation: ${res.body}'); }
  if (res.statusCode == 401 || res.statusCode == 403) { throw Exception('No autorizado'); }
  if (res.statusCode != 200) { throw Exception('Error ${res.statusCode}: ${res.body}'); }

  final data = jsonDecode(res.body) as Map<String, dynamic>;
  if ((data['Codigo'] ?? 1) != 0) { throw Exception(data['Mensaje'] ?? 'Fallo verificación'); }
  return data;
 }

  // Método para obtener historial de movimientos
  Future<List<Movimiento>> getMovimientos(int clienteId) async {
    final uri = Uri.parse('$baseUrl/movimientos/$clienteId');

    print('📋 Obteniendo movimientos para cliente $clienteId...');

    try {
      final headers = await _authService.authHeaders(chofer: false);
      final response = await http.get(uri, headers: headers);

      print('📥 StatusCode: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Movimiento.fromJson(json)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 Error en getMovimientos: $e');
      rethrow;
    }
  }

  // Método para extraer cliente ID del token usando AuthService
  Future<int?> getClienteIdFromToken() async {
    try {
      return await _authService.getClienteIdFromToken();
    } catch (e) {
      print('🚨 Error obteniendo cliente ID: $e');
      return null;
    }
  }
}
