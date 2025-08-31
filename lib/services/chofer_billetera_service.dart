import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/billetera.dart';
import '../models/movimiento.dart';
import 'auth_service.dart';

class ChoferBilleteraService {
  static const String baseUrl = 'http://11.0.1.203:8000/api';

  Future<BilleteraSaldoResponse> getSaldo(int choferId) async {
    print(
        '🏦 [ChoferBilleteraService] Obteniendo saldo para chofer: $choferId');

    try {
      final token = await AuthService().getToken(chofer: true);
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/choferes/$choferId/billetera/saldo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
          '🏦 [ChoferBilleteraService] Respuesta getSaldo: ${response.statusCode}');
      print('🏦 [ChoferBilleteraService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return BilleteraSaldoResponse.fromJson(data);
      } else {
        throw Exception(
            'Error al obtener saldo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [ChoferBilleteraService] Error en getSaldo: $e');
      rethrow;
    }
  }

  Future<List<Movimiento>> getMovimientos(int choferId) async {
    print(
        '📋 [ChoferBilleteraService] Obteniendo movimientos para chofer: $choferId');

    try {
      final token = await AuthService().getToken(chofer: true);
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/choferes/$choferId/billetera/movimientos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
          '📋 [ChoferBilleteraService] Respuesta getMovimientos: ${response.statusCode}');
      print('📋 [ChoferBilleteraService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Movimiento.fromJson(item)).toList();
      } else {
        throw Exception(
            'Error al obtener movimientos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [ChoferBilleteraService] Error en getMovimientos: $e');
      rethrow;
    }
  }

  Future<BilleteraCargaResponse> cargarCreditos({
    required int billeteraId,
    required double monto,
    required String concepto,
  }) async {
    print(
        '💰 [ChoferBilleteraService] Cargando créditos: $monto a billetera $billeteraId');

    try {
      final token = await AuthService().getToken(chofer: true);
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/billeteras/cargar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'billetera_id': billeteraId,
          'monto': monto,
          'concepto': concepto,
        }),
      );

      print(
          '💰 [ChoferBilleteraService] Respuesta cargarCreditos: ${response.statusCode}');
      print('💰 [ChoferBilleteraService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return BilleteraCargaResponse.fromJson(data);
      } else {
        throw Exception(
            'Error al cargar créditos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [ChoferBilleteraService] Error en cargarCreditos: $e');
      rethrow;
    }
  }

  Future<RetiroResponse> retirarSaldo({
    required int billeteraId,
    required double monto,
    required String concepto,
  }) async {
    print(
        '💸 [ChoferBilleteraService] Retirando saldo: $monto de billetera $billeteraId');

    try {
      final token = await AuthService().getToken(chofer: true);
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/choferes/billetera/retirar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'billetera_id': billeteraId,
          'monto': monto,
          'concepto': concepto,
        }),
      );

      print(
          '💸 [ChoferBilleteraService] Respuesta retirarSaldo: ${response.statusCode}');
      print('💸 [ChoferBilleteraService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RetiroResponse.fromJson(data);
      } else {
        throw Exception(
            'Error al retirar saldo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [ChoferBilleteraService] Error en retirarSaldo: $e');
      rethrow;
    }
  }

  // Simulación de ganancia por viaje (2.30 BOB - 0.10 BOB comisión = 2.20 BOB para el chofer)
  Future<double> simularGananciaViaje() async {
    await Future.delayed(const Duration(seconds: 1)); // Simular procesamiento
    final random = Random();
    final montoViaje = 2.30;
    final comision = 0.10;
    final gananciaChofer = montoViaje - comision;

    // Añadir algo de variabilidad (±0.20 BOB)
    final variacion = (random.nextDouble() - 0.5) * 0.4;
    return gananciaChofer + variacion;
  }

  Future<double> simularMontoRetiro() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final random = Random();
    // Simular montos de retiro entre 10 y 200 BOB
    return 10 + (random.nextDouble() * 190);
  }
}

class RetiroResponse {
  final bool ok;
  final int billeteraId;
  final String saldo;

  RetiroResponse({
    required this.ok,
    required this.billeteraId,
    required this.saldo,
  });

  factory RetiroResponse.fromJson(Map<String, dynamic> json) {
    return RetiroResponse(
      ok: json['ok'] ?? true,
      billeteraId: json['billetera_id'],
      saldo: json['saldo'].toString(),
    );
  }
}
