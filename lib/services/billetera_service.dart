import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/billetera.dart';
import '../models/movimiento.dart';
import 'auth_service.dart';

class BilleteraService {
  static const String baseUrl = 'http://11.0.1.176:8000/api';
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

  Future<BilleteraCargaResponse> cargarSaldo({
    required int billeteraId,
    required double monto,
    required String concepto,
  }) async {
    final uri = Uri.parse('$baseUrl/billeteras/cargar');

    final request = BilleteraCargaRequest(
      billeteraId: billeteraId,
      monto: monto,
      concepto: concepto,
    );

    print('🌐 Cargando saldo en $uri...');
    print('📤 Payload: ${jsonEncode(request.toJson())}');

    try {
      final headers = await _authService.authHeaders(chofer: false);
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print('📥 StatusCode: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return BilleteraCargaResponse.fromJson(data);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 Error en cargarSaldo: $e');
      rethrow;
    }
  }

  // Método para simular escaneo de QR y obtener monto
  Future<double> simularEscaneoQR() async {
    // Simulación: esperar 2 segundos y devolver un monto aleatorio
    await Future.delayed(const Duration(seconds: 2));

    // Montos predefinidos para la simulación
    final montos = [10.0, 20.0, 50.0, 100.0, 200.0];
    final monto = (montos..shuffle()).first;

    print('📱 QR escaneado - Monto: $monto BOB');
    return monto;
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
